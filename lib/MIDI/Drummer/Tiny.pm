package MIDI::Drummer::Tiny;

# ABSTRACT: Glorified metronome

our $VERSION = '0.6008';

use 5.024;
use strictures 2;
use Carp;
use List::Util 1.26 qw(sum0);
use Moo;
use experimental qw(signatures);
use Math::Bezier ();
use MIDI::Util   qw(
    dura_size
    reverse_dump
    set_time_signature
    timidity_conf
    play_timidity
    play_fluidsynth
    ticks
);
use Music::Duration        ();
use Music::RhythmSet::Util qw(upsize);

use MIDI::Drummer::Tiny::Types qw(:all);
use Types::Standard            qw(InstanceOf);
use Types::Path::Tiny          qw(assert_Path);

use Data::Dumper::Compact qw(ddc);
use namespace::clean;

use constant STRAIGHT => 50;    # Swing percent

=head1 SYNOPSIS

  use MIDI::Drummer::Tiny;

  my $d = MIDI::Drummer::Tiny->new(
    file      => 'drums.mid',
    bpm       => 100,
    volume    => 100,
    signature => '5/4',
    bars      => 8,
    reverb    => 0,
    soundfont => '/you/soundfonts/TR808.sf2', # option
    #kick      => 36, # Override default patch
    #snare     => 40, # "
  );

  $d->metronome5;

  $d->set_time_sig('4/4');
  $d->count_in(1);  # Closed hi-hat for 1 bar
  $d->metronome4($d->bars, $d->closed_hh, $d->eighth, 60); # swing!

  $d->rest($d->whole);

  $d->flam($d->quarter, $d->snare);
  $d->crescendo_roll([50, 127, 1], $d->eighth, $d->thirtysecond);
  $d->note($d->sixteenth, $d->crash1);
  $d->accent_note(127, $d->sixteenth, $d->crash2);

  # Alternate kick and snare
  $d->note($d->quarter, $d->open_hh, $_ % 2 ? $d->kick : $d->snare)
    for 1 .. $d->beats * $d->bars;

  # Same but with beat-strings:
  $d->sync_patterns(
    $d->open_hh => [ '1111' ],
    $d->snare   => [ '0101' ],
    $d->kick    => [ '1010' ],
  ) for 1 .. $d->bars;

  my $patterns = [
    your_function(5, 16), # e.g. a euclidean function
    your_function(7, 16), # ...
  ];
  $d->pattern( instrument => $d->kick, patterns => $patterns ); # see doc...

  $d->add_fill('...'); # see doc...

  print 'Count: ', $d->counter, "\n";

  # As a convenience, and sometimes necessity:
  $d->set_bpm(200); # handy for tempo changes
  $d->set_channel;  # reset back to 9 if ever changed

  $d->timidity_cfg('timidity-drummer.cfg');

  $d->write;
  # OR:
  $d->play_with_timidity;
  # OR:
  $d->play_with_fluidsynth;

=head1 DESCRIPTION

This module provides handy defaults and tools to produce a MIDI score
with drum parts. It is full of tools to construct a score with drum
parts. It is not a traditional "drum machine." Rather, it contains
methods to construct a drum machine, or play "as a drummer might."

Below, the term "spec" refers to a note length duration, like an
eighth or quarter note, for instance.

=for Pod::Coverage BUILD

=cut

sub BUILD ( $self, $args_ref ) {
    return unless $self->setup;

    $self->score->noop( 'c' . $self->channel, 'V' . $self->volume );

    $self->score->set_tempo( int( 60_000_000 / $self->bpm ) );

    $self->score->control_change( $self->channel, 91, $self->reverb );

    # Add a TS to the score but don't reset the beats if given
    $self->set_time_sig( $self->signature, !$args_ref->{beats} );
    return;
}

=attr verbose

Default: C<0>

=attr file

This the MIDI file name to write. It can be a string, a
L<Types::Path::Tiny/Path>, or a L<Types::Standard/FileHandle>.

Default: C<MIDI-Drummer.mid>

=cut

has file => (
    is      => 'ro',
    isa     => MIDI_File,
    coerce  => 1,
    default => 'MIDI-Drummer.mid',
);

=attr soundfont

  $soundfont = $d->soundfont;

This is the location of the soundfont file. It can be a string or a
L<Types::Path::Tiny/File>.

=cut

has soundfont => (
    is     => 'rw',
    isa    => Soundfont_File,
    coerce => 1,
);

=attr score

Default: C<MIDI::Simple-E<gt>new_score>

=method sync

  $d->sync(@code_refs);

This is a simple pass-through to the B<score> C<synch> method.

This allows simultaneous playing of multiple "tracks" defined by code
references.

=cut

has score => (
    is      => 'ro',
    isa     => InstanceOf ['MIDI::Simple'],
    default => sub { MIDI::Simple->new_score },
    handles => { sync => 'synch' },
);

=attr reverb

Default: C<15>

=attr channel

Default: C<9>

=method set_channel

  $d->set_channel;
  $d->set_channel($channel);

Reset the channel to C<9> by default, or the given argument if
different.

=cut

has channel => (
    is      => 'rwp',
    isa     => Channel,
    default => 9,
);

sub set_channel ( $self, $channel = 9 ) {
    $self->score->noop("c$channel");
    $self->_set_channel($channel);
    return;
}

=attr volume

Default: C<100>

=method set_volume

  $d->set_volume;
  $d->set_volume($volume);

Set the volume (L<MIDI::Drummer::Tiny::Types::MIDI/Velocity>) to the given argument.

If not given a B<volume> argument, this method mutes (sets to C<0>).

=cut

has volume => (
    is      => 'rwp',
    isa     => Velocity,
    default => 100,

);

sub set_volume ( $self, $volume = 0 ) {
    $self->score->noop("V$volume");
    $self->_set_volume($volume);
    return;
}

=attr bpm

Default: C<120>

=method set_bpm

  $d->set_bpm($bpm);

Reset the L<beats per minute|MIDI::Drummer::Tiny::Types/BPM>.

=cut

has bpm => (
    is      => 'rw',
    isa     => BPM,
    default => 120,
    writer  => 'set_bpm',
    trigger => 1,
);

sub _trigger_bpm ( $self, $bpm = 120 ) {    ## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
    $self->score->set_tempo( int( 60_000_000 / $bpm ) );
    return;
}

=attr bars

Default: C<4>

=attr signature

Default: C<4/4>

B<beats> / B<divisions>

=attr beats

Computed from the B<signature>, if not given in the constructor.

Default: C<4>

=attr divisions

Computed from the B<signature>.

Default: C<4>

=attr setup

Run the commands in the C<BUILD> method that set-up new midi score
events like tempo, time signature, etc.

Default: C<1>

=attr counter

  $d->counter( $d->counter + $duration );
  $count = $d->counter;

Beat counter of durations, where a quarter-note is equal to 1. An
eighth-note is 0.5, etc.

This is automatically accumulated each time a C<rest> or C<note> is
added to the score.

=cut

my %attr_defaults = (
    ro => {
        verbose => 0,
        reverb  => 15,
        bars    => 4,
    },
    rw => {
        signature => '4/4',
        beats     => 4,
        divisions => 4,
        setup     => 1,
        counter   => 0,
    },
);
for my $is ( keys %attr_defaults ) {
    for my $attr ( keys %{ $attr_defaults{$is} } ) {
        has $attr => (
            is      => $is,
            default => $attr_defaults{$is}{$attr},
        );
    }
}

=kit metronome

=over

=item click, bell

=back

=kit hi-hats

=over

=item open_hh, closed_hh, pedal_hh

=back

=kit crash and splash cymbals

=over

=item crash1, crash2, splash, china

=back

=kit ride cymbals

=over

=item ride1, ride2, ride_bell

=back

=kit snare drums and handclaps

=over

=item snare, acoustic_snare, electric_snare, side_stick, clap

Where the B<snare> is by default the same as the B<acoustic_snare> but
can be overridden with the B<electric_snare> (C<40>).

=back

=kit tom-toms

=over

=item hi_tom, hi_mid_tom, low_mid_tom, low_tom, hi_floor_tom, low_floor_tom

=back

=kit bass drums

=over

=item kick, acoustic_bass, electric_bass

Where the B<kick> is by default the same as the B<acoustic_bass> but
can be overridden with the B<electric_bass> (C<36>).

=back

=kit auxiliary percussion

=over

=item tambourine, cowbell, vibraslap

=back

=kit Latin and African drums

=over

=item hi_bongo, low_bongo, mute_hi_conga, open_hi_conga, low_conga, high_timbale, low_timbale

=back

=kit Latin and African auxiliary percussion

=over

=item high_agogo, low_agogo, cabasa, maracas, short_whistle, long_whistle, short_guiro, long_guiro, claves, hi_wood_block, low_wood_block, mute_cuica, open_cuica

=back

=kit triangles

=over

=item mute_triangle, open_triangle

=back

=cut

use constant PERCUSSION_START => 33;
for my $sound ( qw(
    click
    bell
    acoustic_bass
    electric_bass
    side_stick
    acoustic_snare
    clap
    electric_snare
    low_floor_tom
    closed_hh
    hi_floor_tom
    pedal_hh
    low_tom
    open_hh
    low_mid_tom
    hi_mid_tom
    crash1
    hi_tom
    ride1
    china
    ride_bell
    tambourine
    splash
    cowbell
    crash2
    vibraslap
    ride2
    hi_bongo
    low_bongo
    mute_hi_conga
    open_hi_conga
    low_conga
    high_timbale
    low_timbale
    high_agogo
    low_agogo
    cabasa
    maracas
    short_whistle
    long_whistle
    short_guiro
    long_guiro
    claves
    hi_wood_block
    low_wood_block
    mute_cuica
    open_cuica
    mute_triangle
    open_triangle
) )
{
    state $percussion_note;
    has $sound => (
        is      => 'ro',
        isa     => PercussionNote,
        default => PERCUSSION_START + $percussion_note++,
    );
}
has kick => (
    is      => 'ro',
    isa     => PercussionNote,
    default => 35,               # Alt: 36
);
has snare => (
    is      => 'ro',
    isa     => PercussionNote,
    default => 38,               # Alt: 40
);

=duration whole notes

=over

=item whole, triplet_whole, dotted_whole, double_dotted_whole

=back

=duration half notes

=over

=item half, triplet_half, dotted_half, double_dotted_half

=back

=duration quarter notes

=over

=item quarter, triplet_quarter, dotted_quarter, double_dotted_quarter

=back

=duration eighth notes

=over

=item eighth, triplet_eighth, dotted_eighth, double_dotted_eighth

=back

=duration sixteenth notes

=over

=item sixteenth, triplet_sixteenth, dotted_sixteenth, double_dotted_sixteenth

=back

=duration thirty-secondth notes

=over

=item thirtysecond, triplet_thirtysecond, dotted_thirtysecond, double_dotted_thirtysecond

=back

=duration sixty-fourth notes

=over

=item sixtyfourth, triplet_sixtyfourth, dotted_sixtyfourth, double_dotted_sixtyfourth

=back

=duration one-twenty-eighth notes

=over

=item onetwentyeighth, triplet_onetwentyeighth, dotted_onetwentyeighth, double_dotted_onetwentyeighth

=back

=cut

my %basic_note_durations = (
    whole           => 'w',
    half            => 'h',
    quarter         => 'q',
    eighth          => 'e',
    sixteenth       => 's',
    thirtysecond    => 'x',
    sixtyfourth     => 'y',
    onetwentyeighth => 'z',
);

my %duration_prefixes = (
    triplet       => 't',
    dotted        => 'd',
    double_dotted => 'dd',
);

for my $basic_duration ( keys %basic_note_durations ) {
    my $duration = $basic_note_durations{$basic_duration};

    has $basic_duration => (
        is      => 'ro',
        isa     => Duration,
        default => "${duration}n",
    );

    for my $prefix ( keys %duration_prefixes ) {
        has "${prefix}_${basic_duration}" => (
            is      => 'ro',
            isa     => Duration,
            default => "$duration_prefixes{$prefix}${duration}n",
        );
    }
}

=method new

  $d = MIDI::Drummer::Tiny->new(%arguments);

Return a new C<MIDI::Drummer::Tiny> object and add a time signature
event to the score.

=method note

  $d->note( $d->quarter, $d->closed_hh, $d->kick );
  $d->note( 'qn', 42, 35 ); # Same thing

Add notes to the score.

This method takes the same arguments as L<MIDI::Simple/"Parameters for n/r/noop">.

It also keeps track of the beat count with the C<counter> attribute.

=cut

sub note ( $self, @spec ) {
    my $size
        = $spec[0] =~ /^d(\d+)$/
        ? $1 / ticks( $self->score )
        : dura_size( $spec[0] );

    # carp __PACKAGE__,' L',__LINE__,' ',,"$spec[0]\n";
    # carp __PACKAGE__,' L',__LINE__,' ',,"$size\n";
    $self->counter( $self->counter + $size );
    return $self->score->n(@spec);
}

=method accent_note

  $d->accent_note($accent_value, $d->sixteenth, $d->snare);

Play an accented note.

For instance, this can be a "ghosted note", where the B<accent> is a
smaller number (< 50).  Or a note that is greater than the normal
score volume.

=cut

sub accent_note ( $self, $accent, @spec ) {
    my $resume = $self->score->Volume;
    $self->score->Volume($accent);
    $self->note(@spec);
    return $self->score->Volume($resume);
}

=method rest

  $d->rest( $d->quarter );

Add a rest to the score.

This method takes the same arguments as L<MIDI::Simple/"Parameters for n/r/noop">.

It also keeps track of the beat count with the C<counter> attribute.

=cut

sub rest ( $self, @spec ) {
    my $size
        = $spec[0] =~ /^d(\d+)$/
        ? $1 / ticks( $self->score )
        : dura_size( $spec[0] );

    # carp __PACKAGE__,' L',__LINE__,' ',,"$spec[0] => $size\n";
    $self->counter( $self->counter + $size );
    return $self->score->r(@spec);
}

=method count_in

  $d->count_in;
  $d->count_in($bars);
  $d->count_in({ bars => $bars, patch => $patch });

Play a patch for the number of beats times the number of bars.

If no bars are given, the object setting is used.  If no patch is
given, the closed hihat is used.

=cut

sub count_in ( $self, $args_ref ) {

    my $bars   = $self->bars;
    my $patch  = $self->pedal_hh;
    my $accent = $self->closed_hh;

    if ( $args_ref && ref $args_ref ) {
        $bars   = $args_ref->{bars}   if defined $args_ref->{bars};
        $patch  = $args_ref->{patch}  if defined $args_ref->{patch};
        $accent = $args_ref->{accent} if defined $args_ref->{accent};
    }
    elsif ($args_ref) {
        $bars = $args_ref;    # given a simple integer
    }

    my $j = 1;
    for my $i ( 1 .. $self->beats * $bars ) {
        if ( $i == $self->beats * $j - $self->beats + 1 ) {
            $self->accent_note( 127, $self->quarter, $accent );
            $j++;
        }
        else {
            $self->note( $self->quarter, $patch );
        }
    }
    return;
}

=method metronome3

  $d->metronome3;
  $d->metronome3($bars);
  $d->metronome3($bars, $cymbal);
  $d->metronome3($bars, $cymbal, $tempo);
  $d->metronome3($bars, $cymbal, $tempo, $swing);

Add a steady 3/x beat to the score.

Defaults for all metronome methods:

  bars: The object B<bars>
  cymbal: B<closed_hh>
  tempo: B<quarter-note>
  swing: 50 percent = straight-time

=cut

sub metronome3 (
    $self,
    $bars   = $self->bars,
    $cymbal = $self->closed_hh,
    $tempo  = $self->quarter,
    $swing  = 50                  # percent
    )
{
    my $x = dura_size($tempo) * ticks( $self->score );
    my $y = sprintf '%0.f', ( $swing / 100 ) * $x;
    my $z = $x - $y;
    for ( 1 .. $bars ) {
        $self->note( "d$x", $cymbal, $self->kick );
        if ( $swing > STRAIGHT ) {
            $self->note( "d$y", $cymbal );
            $self->note( "d$z", $cymbal );
        }
        else {
            $self->note( "d$x", $cymbal );
        }
        $self->note( "d$x", $cymbal, $self->snare );
    }
    return;
}

=method metronome4

  $d->metronome4;
  $d->metronome4($bars);
  $d->metronome4($bars, $cymbal);
  $d->metronome4($bars, $cymbal, $tempo);
  $d->metronome4($bars, $cymbal, $tempo, $swing);

Add a steady 4/x beat to the score.

=cut

sub metronome4 (
    $self,
    $bars   = $self->bars,
    $cymbal = $self->closed_hh,
    $tempo  = $self->quarter,
    $swing  = 50                  # percent
    )
{
    my $x = dura_size($tempo) * ticks( $self->score );
    my $y = sprintf '%0.f', ( $swing / 100 ) * $x;
    my $z = $x - $y;
    for my $n ( 1 .. $bars ) {
        $self->note( "d$x", $cymbal, $self->kick );
        if ( $swing > STRAIGHT ) {
            $self->note( "d$y", $cymbal );
            $self->note( "d$z", $cymbal );
        }
        else {
            $self->note( "d$x", $cymbal );
        }
        $self->note( "d$x", $cymbal, $self->snare );
        if ( $swing > STRAIGHT ) {
            $self->note( "d$y", $cymbal );
            $self->note( "d$z", $cymbal );
        }
        else {
            $self->note( "d$x", $cymbal );
        }
    }
    return;
}

=method metronome5

  $d->metronome5;
  $d->metronome5($bars);
  $d->metronome5($bars, $cymbal);
  $d->metronome5($bars, $cymbal, $tempo);
  $d->metronome5($bars, $cymbal, $tempo, $swing);

Add a 5/x beat to the score.

=cut

sub metronome5 (
    $self,
    $bars   = $self->bars,
    $cymbal = $self->closed_hh,
    $tempo  = $self->quarter,
    $swing  = 50                  # percent
    )
{
    my $x    = dura_size($tempo) * ticks( $self->score );
    my $half = $x / 2;
    my $y    = sprintf '%0.f', ( $swing / 100 ) * $x;
    my $z    = $x - $y;

    for my $n ( 1 .. $bars ) {
        $self->note( "d$x", $cymbal, $self->kick );
        if ( $swing > STRAIGHT ) {
            $self->note( "d$y", $cymbal );
            $self->note( "d$z", $cymbal );
        }
        else {
            $self->note( "d$x", $cymbal );
        }
        $self->note( "d$x", $cymbal, $self->snare );
        if ( $swing > STRAIGHT ) {
            $self->note( "d$y", $cymbal );
            $self->note( "d$z", $cymbal );
        }
        else {
            $self->note( "d$x", $cymbal );
        }
        if ( $n % 2 ) {
            $self->note( "d$x", $cymbal );
        }
        else {
            $self->note( "d$half", $cymbal );
            $self->note( "d$half", $self->kick );
        }
    }
    return;
}

=method metronome6

  $d->metronome6;
  $d->metronome6($bars);
  $d->metronome6($bars, $cymbal);
  $d->metronome6($bars, $cymbal, $tempo);
  $d->metronome6($bars, $cymbal, $tempo, $swing);

Add a 6/x beat to the score.

=cut

sub metronome6 (
    $self,
    $bars   = $self->bars,
    $cymbal = $self->closed_hh,
    $tempo  = $self->quarter,
    $swing  = 50                  # percent
    )
{
    my $x = dura_size($tempo) * ticks( $self->score );
    my $y = sprintf '%0.f', ( $swing / 100 ) * $x;
    my $z = $x - $y;

    for my $n ( 1 .. $bars ) {
        $self->note( "d$x", $cymbal, $self->kick );
        if ( $swing > STRAIGHT ) {
            $self->note( "d$y", $cymbal );
            $self->note( "d$z", $cymbal );
        }
        else {
            $self->note( "d$x", $cymbal );
        }
        $self->note( "d$x", $cymbal );
        $self->note( "d$x", $cymbal, $self->snare );
        if ( $swing > STRAIGHT ) {
            $self->note( "d$y", $cymbal );
            $self->note( "d$z", $cymbal );
        }
        else {
            $self->note( "d$x", $cymbal );
        }
        $self->note( "d$x", $cymbal );
    }
    return;
}

=method metronome7

  $d->metronome7;
  $d->metronome7($bars);
  $d->metronome7($bars, $cymbal);
  $d->metronome7($bars, $cymbal, $tempo);
  $d->metronome7($bars, $cymbal, $tempo, $swing);

Add a 7/x beat to the score.

=cut

sub metronome7 (
    $self,
    $bars   = $self->bars,
    $cymbal = $self->closed_hh,
    $tempo  = $self->quarter,
    $swing  = 50                  # percent
    )
{
    my $x = dura_size($tempo) * ticks( $self->score );
    my $y = sprintf '%0.f', ( $swing / 100 ) * $x;
    my $z = $x - $y;

    for my $n ( 1 .. $bars ) {
        $self->note( "d$x", $cymbal, $self->kick );
        if ( $swing > STRAIGHT ) {
            $self->note( "d$y", $cymbal );
            $self->note( "d$z", $cymbal );
        }
        else {
            $self->note( "d$x", $cymbal );
        }
        $self->note( "d$x", $cymbal );
        if ( $swing > STRAIGHT ) {
            $self->note( "d$y", $cymbal, $self->kick );
            $self->note( "d$z", $cymbal );
        }
        else {
            $self->note( "d$x", $cymbal, $self->kick );
        }
        $self->note( "d$x", $cymbal, $self->snare );
        if ( $swing > STRAIGHT ) {
            $self->note( "d$y", $cymbal );
            $self->note( "d$z", $cymbal );
        }
        else {
            $self->note( "d$x", $cymbal );
        }
        $self->note( "d$x", $cymbal );
    }
    return;
}

=method metronome44

  $d->metronome44;
  $d->metronome44($bars);
  $d->metronome44($bars, $flag);
  $d->metronome44($bars, $flag, $cymbal);

Add a steady quarter-note based 4/4 beat to the score.

If a B<flag> is provided the beat is modified to include alternating
eighth-note kicks.

=cut

sub metronome44 (
    $self, $bars = $self->bars,
    $flag = 0, $cymbal = $self->closed_hh,
    )
{
    my $i = 0;
    for my $n ( 1 .. $self->beats * $bars ) {
        if ( $n % 2 == 0 ) {
            $self->note( $self->quarter, $cymbal, $self->snare );
        }
        else {
            if ( $flag == 0 ) {
                $self->note( $self->quarter, $cymbal, $self->kick );
            }
            else {
                if ( $i % 2 == 0 ) {
                    $self->note( $self->quarter, $cymbal, $self->kick );
                }
                else {
                    $self->note( $self->eighth, $cymbal, $self->kick );
                    $self->note( $self->eighth, $self->kick );
                }
            }
            $i++;
        }
    }
    return;
}

=method flam

  $d->flam($spec);
  $d->flam( $spec, $grace_note );
  $d->flam( $spec, $grace_note, $patch );
  $d->flam( $spec, $grace_note, $patch, $accent );

Add a "flam" to the score, where a ghosted 64th gracenote is played
before the primary note.

If not provided the B<snare> is used for the B<grace> and B<patch>
patches.  Also, 1/2 of the score volume is used for the B<accent>
if that is not given.

If the B<grace> note is given as a literal C<'r'>, rest instead of
adding a note to the score.

=cut

sub flam (
    $self, $spec,
    $grace  = $self->snare,
    $patch  = $self->snare,
    $accent = sprintf '%0.f',
    $self->score->Volume / 2
    )
{
    my ( $x, $y )
        = @MIDI::Simple::Length{ $spec, $self->sixtyfourth };    ## no critic (Variables::ProhibitPackageVars)
    my $z = sprintf '%0.f', ( $x - $y ) * ticks( $self->score );
    if ( $grace eq 'r' ) {
        $self->rest( $self->sixtyfourth );
    }
    else {
        $self->accent_note( $accent, $self->sixtyfourth, $grace );
    }
    return $self->note( 'd' . $z, $patch );
}

=method roll

  $d->roll( $length, $spec );
  $d->roll( $length, $spec, $patch );

Add a drum roll to the score, where the B<patch> is played for
duration B<length> in B<spec> increments.

If not provided the B<snare> is used for the B<patch>.

=cut

sub roll ( $self, $length, $spec, $patch = $self->snare ) {
    my ( $x, $y ) = @MIDI::Simple::Length{ $length, $spec };    ## no critic (Variables::ProhibitPackageVars)
    my $z = sprintf '%0.f', $x / $y;
    $self->note( $spec, $patch ) for 1 .. $z;
    return;
}

=method crescendo_roll

  $d->crescendo_roll( [$start, $end, $bezier], $length, $spec );
  $d->crescendo_roll( [$start, $end, $bezier], $length, $spec, $patch );

Add a drum roll to the score, where the B<patch> is played for
duration B<length> in B<spec> notes, at increasing or decreasing
volumes from B<start> to B<end>.

If not provided the B<snare> is used for the B<patch>.

If true, the B<bezier> flag will render the crescendo with a curve,
rather than as a straight line.

      |            *
      |           *
  vol |         *
      |      *
      |*
      ---------------
            time

=cut

sub crescendo_roll ( $self, $span_ref, $length, $spec,
    $patch = $self->snare )
{
    my ( $i, $j, $k ) = $span_ref->@*;
    my ( $x, $y ) = @MIDI::Simple::Length{ $length, $spec };    ## no critic (Variables::ProhibitPackageVars)
    my $z = sprintf '%0.f', $x / $y;
    if ($k) {
        my $bezier = Math::Bezier->new( 1, $i, $z, $i, $z, $j, );
        for ( my $n = 0 ; $n <= 1 ; $n += ( 1 / ( $z - 1 ) ) ) {
            my ( undef, $v ) = $bezier->point($n);
            $v = sprintf '%0.f', $v;

            # carp (__PACKAGE__,' ',__LINE__," $n INC: $v\n");
            $self->accent_note( $v, $spec, $patch );
        }
    }
    else {
        my $v = sprintf '%0.f', ( $j - $i ) / ( $z - 1 );

        # carp (__PACKAGE__,' ',__LINE__," VALUE: $v\n");
        for my $n ( 1 .. $z ) {
            if ( $n == $z ) {
                if ( $i < $j ) {
                    $i += $j - $i;
                }
                elsif ( $i > $j ) {
                    $i -= $i - $j;
                }
            }

            # carp (__PACKAGE__,' ',__LINE__," $n INC: $i\n");
            $self->accent_note( $i, $spec, $patch );
            $i += $v;
        }
    }
    return;
}

=method pattern

  $d->pattern( patterns => \@patterns );
  $d->pattern( patterns => \@patterns, instrument => $d->kick );
  $d->pattern( patterns => \@patterns, instrument => $d->kick, %options );

Play a given set of beat B<patterns> with the given B<instrument>.

The B<patterns> are an arrayref of "beat-strings".  By default these
are made of contiguous ones and zeros, meaning "strike" or "rest".
For example:

  patterns => [qw( 0101 0101 0110 0110 )],

This method accumulates the number of beats in the object's B<counter>
attribute.

The B<vary> option is a hashref of coderefs, keyed by single character
tokens, like the digits 0-9.  Each coderef duration should add up to
the given B<duration> option.  The single argument to the coderefs is
the object itself and may be used as: C<my $self = shift;> in yours.

These patterns can be generated with any custom function, as in the
L</SYNOPSIS>. For instance, you could use the L<Creating::Rhythms>
module to generate Euclidean patterns.

Defaults:

  instrument: snare
  patterns: [] (i.e. empty!)
  Options:
    duration: quarter-note
    beats: given by constructor
    repeat: 1
    negate: 0 (flip the bit values)
    vary:
        0 => sub { $self->rest( $args{duration} ) },
        1 => sub { $self->note( $args{duration}, $args{instrument} ) },

=cut

sub pattern ( $self, %args ) {
    $args{instrument} ||= $self->snare;
    $args{patterns}   ||= [];
    $args{beats}      ||= $self->beats;
    $args{negate}     ||= 0;
    $args{repeat}     ||= 1;

    return unless $args{patterns}->@*;

    # set size and duration
    my $size;
    if ( $args{duration} ) {
        $size = dura_size( $args{duration} ) || 1;
    }
    else {
        $size = 4 / length( $args{patterns}->[0] );
        my $dump = reverse_dump('length');
        $args{duration} = $dump->{$size} || $self->quarter;
    }

    # set the default beat-string variations
    $args{vary} ||= {
        0 => sub { $self->rest( $args{duration} ) },
        1 =>
            sub { $self->note( $args{duration}, $args{instrument} ) },
    };

    for my $pattern ( $args{patterns}->@* ) {
        $pattern =~ tr/01/10/ if $args{negate};

        next if $pattern =~ /^0+$/;

        for ( 1 .. $args{repeat} ) {
            for my $bit ( split //, $pattern ) {
                $args{vary}{$bit}->( $self, %args );
            }
        }
    }
    return;
}

=method sync_patterns

  $d->sync_patterns( $instrument1 => $patterns1, $inst2 => $pats2, ... );
  $d->sync_patterns(
      $d->open_hh => [ '11111111') ],
      $d->snare   => [ '0101' ],
      $d->kick    => [ '1010' ],
      duration    => $d->eighth, # render all notes at this level of granularity
  ) for 1 .. $d->bars;

Execute the C<pattern> method for multiple voices.

If a C<duration> is provided, this will be used for each pattern
(primarily for the B<add_fill> method).

=cut

sub sync_patterns ( $self, %patterns ) {
    my $master_duration = delete $patterns{duration};

    my @subs;
    for my $instrument ( keys %patterns ) {
        push @subs, sub {
            $self->pattern(
                instrument => $instrument,
                patterns   => $patterns{$instrument},
                $master_duration
                ? ( duration => $master_duration )
                : (),
            );
        },;
    }

    return $self->sync(@subs);
}

=method add_fill

  $d->add_fill( $fill, $instrument1 => $patterns1, $inst2 => $pats2, ... );
  $d->add_fill(
      sub {
          my $self = shift;
          return {
            duration       => 16, # sixteenth note fill
            $self->open_hh => '00000000',
            $self->snare   => '11111111',
            $self->kick    => '00000000',
          };
      },
      $d->open_hh => [ '11111111' ],  # example phrase
      $d->snare   => [ '0101' ],      # "
      $d->kick    => [ '1010' ],      # "
  );

Add a fill to the beat pattern.  That is, replace the end of the given
beat-string phrase with a fill.  The fill is given as the first
argument and should be a coderef that returns a hashref.  The default
is a three-note, eighth-note snare fill.

=cut

sub add_fill ( $self, $fill = undef, %patterns ) {
    $fill //= sub { {
        duration       => 8,
        $self->open_hh => '000',
        $self->snare   => '111',
        $self->kick    => '000',
    } };
    my $fill_patterns = $fill->($self);
    carp 'Fill: ', ddc($fill_patterns) if $self->verbose;
    my $fill_duration = delete $fill_patterns->{duration} || 8;
    my $fill_length   = length( ( values %$fill_patterns )[0] );

    my %lengths;
    for my $instrument ( keys %patterns ) {
        $lengths{$instrument}
            = sum0 map { length $_ } $patterns{$instrument}->@*;
    }

    my $lcm = _multilcm( $fill_duration, values %lengths );
    carp "LCM: $lcm\n" if $self->verbose;

    my $size = 4 / $lcm;
    my $dump = reverse_dump('length');
    my $master_duration
        = $dump->{$size} || $self->eighth;    # XXX this || is not right
    carp "Size: $size, Duration: $master_duration\n" if $self->verbose;

    my $fill_chop
        = $fill_duration == $lcm
        ? $fill_length
        : int( $lcm / $fill_length ) + 1;
    carp "Chop: $fill_chop\n" if $self->verbose;

    my %fresh_patterns;
    for my $instrument ( keys %patterns ) {

        # get a single "flattened" pattern as an arrayref
        my $pattern
            = [ map { split //, $_ } $patterns{$instrument}->@* ];

        # the fresh pattern is possibly upsized with the LCM
        $fresh_patterns{$instrument}
            = $pattern->@* < $lcm
            ? [ join '', upsize( $pattern, $lcm )->@* ]
            : [ join '', $pattern->@* ];
    }
    carp 'Patterns: ', ddc( \%fresh_patterns ) if $self->verbose;

    my %replacement;
    for my $instrument ( keys $fill_patterns->%* ) {

        # get a single "flattened" pattern as a zero-pre-padded arrayref
        my $pattern = [
            split //,       sprintf '%0*s',
            $fill_duration, $fill_patterns->{$instrument} ];

        # the fresh pattern string is possibly upsized with the LCM
        my $fresh
            = $pattern->@* < $lcm
            ? join '', upsize( $pattern, $lcm )->@*
            : join '', $pattern->@*;

        # the replacement string is the tail of the fresh pattern string
        $replacement{$instrument} = substr $fresh, -$fill_chop;
    }
    carp 'Replacements: ', ddc( \%replacement ) if $self->verbose;

    my %replaced;
    for my $instrument ( keys %fresh_patterns ) {

        # get the string to replace
        my $string = join '', $fresh_patterns{$instrument}->@*;

        # replace the tail of the string
        my $pos = length $replacement{$instrument};
        substr $string, -$pos, $pos, $replacement{$instrument};
        carp "$instrument: $string\n" if $self->verbose;

        # prepare the replaced pattern for syncing
        $replaced{$instrument} = [$string];
    }

    $self->sync_patterns( %replaced, duration => $master_duration, );

    return \%replaced;
}

=method set_time_sig

  $d->set_time_sig;
  $d->set_time_sig('5/4');
  $d->set_time_sig( '5/4', 0 );

Add a time signature event to the score, and reset the B<beats> and
B<divisions> object attributes.

If a ratio argument is given, set the B<signature> object attribute to
it.  If the 2nd argument flag is C<0>, the B<beats> and B<divisions>
are B<not> reset.

=cut

sub set_time_sig ( $self, $time_signature, $set = 1 ) {
    $self->signature($time_signature) if $time_signature;
    if ($set) {
        my ( $beats, $divisions ) = split /\//, $self->signature;
        $self->beats($beats);
        $self->divisions($divisions);
    }
    return set_time_signature( $self->score, $self->signature );
}

=method write

Output the score as a MIDI file with the module L</file> attribute as
the file name.

=cut

sub write ($self) {    ## no critic (Subroutines::ProhibitBuiltinHomonyms)
    return $self->score->write_score( $self->file );
}

=method timidity_cfg

  $timidity_conf = $d->timidity_cfg;
  $d->timidity_cfg($config_file);

Return a timidity.cfg paragraph to use a defined B<soundfont>
attribute. If a B<config_file> is given, the timidity configuration is
written to that file.

=cut

sub timidity_cfg {
    my ($self, $config) = @_;
    croak 'No soundfont defined' unless $self->soundfont;
    my $cfg = timidity_conf( $self->soundfont, $config );
    return $cfg;
}

=method play_with_timidity

  $d->play_with_timidity;
  $d->play_with_timidity($config_file);

Play the score with C<timidity>.

If there is a B<soundfont> attribute, either the given B<config_file>
or C<timidity-midi-util.cfg> is used for the timidity configuration.
If a soundfont is not defined, a timidity configuration file is not
rendered.

See L<MIDI::Util/play_timidity> for more details.

=cut

sub play_with_timidity {
    my ($self, $config) = @_;
    return play_timidity( $self->score, assert_Path( $self->file ),
        $self->soundfont, $config );
}

=method play_with_fluidsynth

  $d->play_with_fluidsynth;
  $d->play_with_fluidsynth(\@config);

Play the score with C<fluidsynth>.

See L<MIDI::Util/play_fluidsynth> for more details.

=cut

sub play_with_fluidsynth {
    my ($self, $config) = @_;
    return play_fluidsynth( $self->score, assert_Path( $self->file ),
        $self->soundfont, $config );
}

# lifted from https://www.perlmonks.org/?node_id=56906
sub _gcf ( $x, $y ) {
    ( $x, $y ) = ( $y, $x % $y ) while $y;
    return $x;
}

sub _lcm ( $x, $y ) { return $x * $y / _gcf( $x, $y ) }

sub _multilcm {    ## no critic (Subroutines::RequireArgUnpacking)
    my $x = shift;
    $x = _lcm( $x, shift ) while @_;
    return $x;
}

1;

__END__

=head1 SEE ALSO

The F<t/*> test file and the F<eg/*> programs in this distribution.

Also F<eg/drum-fills-advanced> in the L<Music::Duration::Partition>
distribution.

L<https://ology.github.io/midi-drummer-tiny-tutorial/>

L<Data::Dumper::Compact>

L<List::Util>

L<Math::Bezier>

L<MIDI::Util>

L<Moo>

L<Music::Duration>

L<Music::RhythmSet::Util>

L<https://en.wikipedia.org/wiki/General_MIDI#Percussion>

L<https://en.wikipedia.org/wiki/General_MIDI_Level_2#Drum_sounds>

=head1 THANK YOU

L<Mark Gardner|https://metacpan.org/author/MJGARDNER> -
refactoring-master - modernized everything under the hood, post-0.5013.

Woo!

=cut
