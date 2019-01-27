package MIDI::Drummer::Tiny;

# ABSTRACT: Glorified metronome

our $VERSION = '0.0600';

use Moo;
use MIDI::Simple;

=head1 SYNOPSIS

 use MIDI::Drummer::Tiny;
 my $d = MIDI::Drummer::Tiny->new(
    file      => 'drums.mid',
    bpm       => 120,
    signature => '3/4',
    bars      => 32,
    patch     => 26, # TR808
 );
 $d->count_in();
 $d->note( $d->quarter, $d->open_hh, $_ % 2 ? $d->kick : $d->snare )
    for 1 .. $d->beats * $d->bars;  # Alternate beats
 $d->metronome();  # <- Similar but honoring time signature
 $d->write();

=head1 DESCRIPTION

This module provides a MIDI drummer with the essentials to add notes to produce
a MIDI score.

=cut

sub BUILD {
   my ( $self, $args ) = @_;

    my ($beats, $divisions) = split /\//, $self->signature;
    $self->beats($beats);
    $self->divisions($divisions);
    $self->score->time_signature(
        $self->beats,
        sqrt( $self->divisions ),
        ( $self->divisions == 8 ? 24 : 18 ),
        8
    );

    $self->score->noop( 'c' . $self->channel, 'V' . $self->volume );
    $self->score->set_tempo( int( 60_000_000 / $self->bpm ) );

    $self->score->patch_change( $self->channel, $self->patch );

    $self->score->control_change( $self->channel, 91, $self->reverb ) if $self->reverb;
    $self->score->control_change( $self->channel, 93, $self->chorus ) if $self->chorus;
    $self->score->control_change( $self->channel, 10, $self->pan ) if $self->pan;
}

=head1 ATTRIBUTES

=over 4

=item file: MIDI-Drummer.mid

=item score: MIDI::Simple->new_score

=item channel: 9

=item volume: 100

=item patch: 0

=item bpm: 120

=item reverb: 0

=item chorus: 0

=item pan: 0

=item bars: 4

=item beats: 4

Computed given the B<signature>.

=item divisions: 4

Computed given the B<signature>.

=item signature: 4/4

B<beats>/B<divisions>

=back

=cut

has channel   => ( is => 'ro', default => sub { 9 } );
has patch     => ( is => 'ro', default => sub { 0 } );
has volume    => ( is => 'ro', default => sub { 100 } );
has bpm       => ( is => 'ro', default => sub { 120 } );
has reverb    => ( is => 'ro', default => sub { 0 } );
has chorus    => ( is => 'ro', default => sub { 0 } );
has pan       => ( is => 'ro', default => sub { 0 } );
has file      => ( is => 'ro', default => sub { 'MIDI-Drummer.mid' } );
has bars      => ( is => 'ro', default => sub { 4 } );
has score     => ( is => 'ro', default => sub { MIDI::Simple->new_score } );
has signature => ( is => 'ro', default => sub { '4/4' });
has beats     => ( is => 'rw' );
has divisions => ( is => 'rw' );

=head1 KIT

These patches may be overridden as with any other attribute.

=over 4

=item kick

=item snare

=item open_hh

=item closed_hh

=item pedal_hh

=item crash1

=item crash2

=item splash

=item china

=item ride1

=item ride2

=item ride_bell

=item hi_tom

=item hi_mid_tom

=item low_mid_tom

=item low_tom

=item hi_floor_tom

=item low_floor_tom

=back

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

=over 4

=item whole

=item half

=item quarter, triplet_quarter

=item eighth, triplet_eighth

=item sixteenth, triplet_sixteenth

=back

=cut

# duration
has whole             => ( is => 'ro', default => sub { 'wn' } );
has half              => ( is => 'ro', default => sub { 'hn' } );
has quarter           => ( is => 'ro', default => sub { 'qn' } );
has triplet_quarter   => ( is => 'ro', default => sub { 'tqn' } );
has eighth            => ( is => 'ro', default => sub { 'en' } );
has triplet_eighth    => ( is => 'ro', default => sub { 'ten' } );
has sixteenth         => ( is => 'ro', default => sub { 'sn' } );
has triplet_sixteenth => ( is => 'ro', default => sub { 'tsn' } );

=head1 METHODS

=head2 note()

 $d->note( $d->quarter, $d->closed_hh, $d->kick );
 $d->note( 'qn', 'n42', 'n35' ); # Same thing

Add a note to the score.

This method takes the same arguments as with L<MIDI::Simple/"Parameters for n/r/noop">.

=cut

sub note { return shift->score->n(@_) }

=head2 rest()

 $d->rest( $d->quarter );

Add a rest to the score.

This method takes the same arguments as with L<MIDI::Simple/"Parameters for n/r/noop">.

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

Output the score to the F<*.mid> file given in the constuctor.

=cut

sub write {
    my $self = shift;
    $self->score->write_score( $self->file );
}

1;
