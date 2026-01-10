package MIDI::Drummer::Tiny::Beats;

use Moo;
use strictures 2;
use MIDI::Util qw(dura_size);
use namespace::clean;

=head1 SYNOPSIS

  use MIDI::Drummer::Tiny;
  use MIDI::Drummer::Tiny::Beats;

  my $drummer = MIDI::Drummer::Tiny->new;
  
  my $beats = MIDI::Drummer::Tiny::Beats->new;

  my $all = $beats->all_beats;

  my $beat = $beats->get_beat; # random beat
  $beat = $beats->get_beat(42); # numbered beat
  # with a pre-made drummer object
  $beat = $beats->get_beat(42, $drummer);

  say $beat->{name};
  $beat->{beat}->() for 1 .. 4; # play the beat 4 times!

  # play 4 random rock beats
  my $rock = $beats->search('rock');
  my $nums = [ keys %$rock ];
  for (1 .. 4) {
    $beat = $rock->{ $nums[ rand @$nums ] };
    say $beat->{name};
    $beat->{beat}->();
  }

=head1 DESCRIPTION

Return the common beats, as listed in the "Pocket Operations", that
are L<linked below|/SEE ALSO>.

A beat is a numbered and named hash reference, with the following
structure:

  { 1 => {
      name => "ONE AND SEVEN & FIVE AND THIRTEEN",
      beat => sub {
        $d->sync_patterns(
        $d->kick  => ['1000001000000000'],
        $d->snare => ['0000100000001000'],
        duration  => $d->sixteenth,
      ),
    },
  },
  2 => { ... }, ... }

=cut

=head1 METHODS

=head2 new

  $beats = MIDI::Drummer::Tiny::beats->new;

Return a new C<MIDI::Drummer::Tiny::Beats> object.

=head2 get_beat

  $beat = $beats->get_beat; # random beat
  $beat = $beats->get_beat($beat_number);
  $beat = $beats->get_beat($beat_number, $drummer); # with object
  $beat = $beats->get_beat(0, $drummer); # random beat

Return either the given B<beat> or a random beat from the collection
of known beats.

A B<drummer> object optional but the B<beat_number> is required.

=cut

sub get_beat {
    my ($self, $beat_number, $drummer) = @_;
    my $beats = $self->all_beats($drummer);
    unless ($beat_number) {
        my @keys = keys %$beats;
        $beat_number = $keys[ int rand @keys ];
    }
    return $beats->{$beat_number};
}

=head2 all_beats

  $all = $beats->all_beats;

Return all the known beats as a hash reference.

=cut

sub all_beats {
    my ($self, $drummer) = @_;
    return $self->_beats($drummer);
}

=head2 search

  $found = $beats->search($string);
  $found = $beats->search($string, $drummer);

Return the found beats with names matching the given B<string> as a
hash reference.

=cut

sub search {
    my ($self, $string, $drummer) = @_;
    return $self->_beats($drummer);
}

sub _beats {
    my ($self, $d) = @_;
    $d ||= MIDI::Drummer::Tiny->new;
    my %beats = (

        1 => {
            name => "ONE AND SEVEN & FIVE AND THIRTEEN",
            beat => sub {
                $d->sync_patterns(#123456789ABCDEF0
                    $d->kick  => ['1000001000000000'],
                    $d->snare => ['0000100000001000'],
                    duration  => $d->sixteenth,
                ),
            },
        },

        2 => {
            name => "BOOTS N' CATS",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000000010000000'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1010101010101010'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        3 => {
            name => "TINY HOUSE",
            beat => sub {
                $d->sync_patterns( # 123456789ABCDEF0
                    $d->kick    => ['1000100010001000'],
                    $d->open_hh => ['0010001000100010'],
                    duration    => $d->sixteenth,
                ),
            },
        },

        4 => {
            name => "GOOD TO GO",
            beat => sub {
                $d->sync_patterns(#123456789ABCDEF0
                    $d->kick  => ['1001001000100000'],
                    $d->snare => ['0000100000001000'],
                    duration  => $d->sixteenth,
                ),
            },
        },

        5 => {
            name => "HIP HOP",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1010001100000010'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1010101010101010'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        6 => {
            name => "STANDARD BREAK 1",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000000000100000'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1010101011101010'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        7 => {
            name => "STANDARD BREAK 2",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000000000100000'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1010101110100010'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        8 => {
            name => "ROLLING BREAK",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000000100100000'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1010101010101010'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        9 => {
            name => "THE UNKNOWN DRUMMER",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1001001000100000'],
                    $d->snare     => ['0100100100001000'],
                    $d->closed_hh => ['0110110100000100'],
                    $d->open_hh   => ['0000000010000010'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        10 => {
            name => "ROCK 1",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000000110100000'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1010101010101010'],
                    $d->crash     => ['1000000000000000'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        11 => {
            name => "ROCK 2",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000000110100000'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1010101010101010'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        12 => {
            name => "ROCK 3",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000000110100000'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1010101010101000'],
                    $d->open_hh   => ['0000000000000010'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        13 => {
            name => "ROCK 4",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0 0000000000000000
                    $d->kick      => ['1000000110100000'],
                    $d->snare     => ['0000100000001011'],
                    $d->closed_hh => ['1010101010101000'],
                    $d->open_hh   => ['0000000000000010'],
                    duration      => $d->sixteenth,
                ),
            },
        },

    );
    return \%beats;
}

1;

__END__

=head1 SEE ALSO

The "Pocket Operations" at L<https://shittyrecording.studio/>

=cut
