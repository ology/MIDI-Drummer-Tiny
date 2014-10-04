package MIDI::Drummer;

# ABSTRACT: Glorified metronome

use strict;
use warnings;

our $VERSION = '0.08_01';

use Moo;
use MIDI::Simple;

has file => ( is => 'ro', default => sub { 'MIDI-Drummer.mid' } );
has channel => ( is => 'ro' );
has volume => ( is => 'ro' );
has bpm => ( is => 'ro' );
has reverb => ( is => 'ro' );
has chorus => ( is => 'ro' );
has pan => ( is => 'ro' );
has score => ( is => 'ro' );
has bars => ( is => 'ro', default => sub { 4 } );
has signature => ( is => 'ro', default => sub { '4/4' } );

has beats => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        my ($beats) = split /\//, $self->signature;
        return $beats;
    },
);

has divisions => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        my ($beats, $divs) = split /\//, $self->signature;
        return $divs;
    },
);

sub BUILDARGS
{
   my ( $class, %args ) = @_;

    $args{channel} ||= 9;
    $args{volume}  ||= 100;
    $args{bpm}     ||= 120;
    $args{score}   ||= MIDI::Simple->new_score;

    $args{score}->noop( 'c' . $args{channel}, 'V' . $args{volume} );
    $args{score}->set_tempo( int( 60_000_000 / $args{bpm} ) );

    $args{reverb} ||= 0;
    $args{score}->control_change( $args{channel}, 91, $args{reverb} );
    $args{chorus} ||= 0;
    $args{score}->control_change( $args{channel}, 93, $args{chorus} );
    $args{pan}    ||= 0;
    $args{score}->control_change( $args{channel}, 10, $args{pan} );

   return \%args;
}

has open_hh => ( is => 'ro', default => sub { 'n46' } );
has closed_hh => ( is => 'ro', default => sub { 'n42' } );
has kick => ( is => 'ro', default => sub { 'n35' } );
has snare => ( is => 'ro', default => sub { 'n38' } );

has quarter => ( is => 'ro', default => sub { 'qn' } );

sub note { return shift->score->n(@_) }
sub rest { return shift->score->r(@_) }

sub count_in {
    my $self = shift;
    my $bars = shift || $self->bars;
    for my $i ( 1 .. $self->beats * $bars ) {
        $self->note( $self->quarter, $self->closed_hh );
    }
}

sub metronome {
    my $self = shift;
    my $bars = shift || $self->bars;
    for my $n ( 1 .. $self->beats * $bars ) {
        $self->note( $self->quarter, $self->open_hh, $n % 2 ? $self->kick : $self->snare );
    }
}

sub write {
    my $self = shift;
    $self->score->write_score( $self->file );
}

1;
