package MIDI::Drummer::Tiny;

# ABSTRACT: Glorified metronome

use strict;
use warnings;

our $VERSION = '0.0201';

use Moo;
use MIDI::Simple;

=head1 SYNOPSIS

 use MIDI::Drummer::Tiny;
 my $d = MIDI::Drummer::Tiny->new(
    file => 'drums.mid',
    bpm => 120,
    signature => '4/4',
    bars => 32,
 );
 $d->count_in();
 $d->note( $d->quarter, $d->open_hh, $_ % 2 ? $d->kick : $d->snare )
    for 1 .. $d->beats * $d->bars;  # Alternate even beats
 $d->metronome();  # <- Similar but honoring time signature
 $d->write();

=head1 DESCRIPTION

This module provides a MIDI drummer with the bare essentials to add notes to a
MIDI score.

=cut

sub BUILDARGS
{
   my ( $class, %args ) = @_;

    $args{channel}   ||= 9;
    $args{volume}    ||= 100;
    $args{bpm}       ||= 120;
    $args{signature} ||= '4/4';
    $args{score}     ||= MIDI::Simple->new_score;

    ($args{beats}, $args{divisions}) = split /\//, $args{signature};

    $args{score}->time_signature(
        $args{beats},
        sqrt( $args{divisions} ),
        ( $args{divisions} == 8 ? 24 : 18 ),
        8
    );

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

=head1 ATTRIBUTES

=head2 channel: 9

=head2 volume: 100

=head2 bpm: 120

=head2 reverb: 0

=head2 chorus: 0

=head2 pan: 0

=head2 bars: 4

=head2 beats: 4

=head2 divisions: 4

=head2 signature: 4/4

=head2 file: MIDI-Drummer.mid

=head2 score MIDI::Simple->new_score

=cut

has channel => ( is => 'ro' );
has volume => ( is => 'ro' );
has bpm => ( is => 'ro' );
has reverb => ( is => 'ro' );
has chorus => ( is => 'ro' );
has pan => ( is => 'ro' );
has beats => ( is => 'ro' );
has divisions => ( is => 'ro' );
has signature => ( is => 'ro' );
has score => ( is => 'ro' );

has file => ( is => 'ro', default => sub { 'MIDI-Drummer.mid' } );
has bars => ( is => 'ro', default => sub { 4 } );

=head1 KIT

=head2 kick

=head2 snare

=head2 open_hh

=head2 closed_hh

=head2 pedal_hh

=head2 crash1

=head2 crash2

=head2 splash

=head2 china

=head2 ride1

=head2 ride2

=head2 ride_bell

=head2 hi_tom

=head2 hi_mid_tom

=head2 low_mid_tom

=head2 low_tom

=head2 hi_floor_tom

=head2 low_floor_tom

=cut

# kit
has kick          => ( is => 'ro', default => sub { 'n35' } );
has snare         => ( is => 'ro', default => sub { 'n38' } );
has open_hh       => ( is => 'ro', default => sub { 'n46' } );
has closed_hh     => ( is => 'ro', default => sub { 'n42' } );
has pedal_hh      => ( is => 'ro', default => sub { 'n44' } );
has crash1        => ( is => 'ro', default => sub { 'n49' } );
has crash2        => ( is => 'ro', default => sub { 'n57' } );
has splash        => ( is => 'ro', default => sub { 'n55' } );
has china         => ( is => 'ro', default => sub { 'n52' } );
has ride1         => ( is => 'ro', default => sub { 'n51' } );
has ride2         => ( is => 'ro', default => sub { 'n59' } );
has ride_bell     => ( is => 'ro', default => sub { 'n53' } );
has hi_tom        => ( is => 'ro', default => sub { 'n50' } );
has hi_mid_tom    => ( is => 'ro', default => sub { 'n48' } );
has low_mid_tom   => ( is => 'ro', default => sub { 'n47' } );
has low_tom       => ( is => 'ro', default => sub { 'n45' } );
has hi_floor_tom  => ( is => 'ro', default => sub { 'n43' } );
has low_floor_tom => ( is => 'ro', default => sub { 'n41' } );

=head1 DURATIONS

=head2 whole

=head2 half

=head2 quarter

=head2 eighth

=head2 sixteenth

=cut

# duration
has whole => ( is => 'ro', default => sub { 'wn' } );
has half => ( is => 'ro', default => sub { 'hn' } );
has quarter => ( is => 'ro', default => sub { 'qn' } );
has eighth => ( is => 'ro', default => sub { 'en' } );
has sixteenth => ( is => 'ro', default => sub { 'sn' } );

=head1 METHODS

=head2 note()

 $d->note( $d->quarter, $d->closed_hh, $d->kick );
 $d->note( 'qn', 'n42', 'n35' ); # Same thing

Send a note to the score.

=cut

sub note { return shift->score->n(@_) }

=head2 rest()

 $d->rest( $d->quarter );

Send a rest to the score.

=cut

sub rest { return shift->score->r(@_) }

=head2 count_in()

 $d->count_in;
 $d->count_in($bars);

Play the closed hihat for the number of beats times the given bars.
If no bars are given, the default of 1 is used.

=cut

sub count_in {
    my $self = shift;
    my $bars = shift || 1;
    for my $i ( 1 .. $self->beats * $bars) {
        $self->note( $self->quarter, $self->closed_hh );
    }
}


=head2 metronome()

Add a steady beat to the score.

=cut

sub metronome {
    my $self = shift;
    my $bars = shift || $self->bars;
    for my $n ( 1 .. $self->beats * $bars ) {
        if ( $self->beats % 3 == 0 )
        {
            $self->note( $self->quarter, $self->open_hh, $n % 3 ? $self->kick : $self->snare );
        }
        else {
            $self->note( $self->quarter, $self->open_hh, $n % 2 ? $self->kick : $self->snare );
        }
    }
}

=head2 write()

Output the score to a F<*.mid> file.

=cut

sub write {
    my $self = shift;
    $self->score->write_score( $self->file );
}

1;
