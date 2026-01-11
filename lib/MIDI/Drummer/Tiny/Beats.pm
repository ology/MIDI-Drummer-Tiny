package MIDI::Drummer::Tiny::Beats;

use Moo;
use strictures 2;
use MIDI::Drummer::Tiny ();
use namespace::clean;

=head1 SYNOPSIS

  use MIDI::Drummer::Tiny;
  use MIDI::Drummer::Tiny::Beats;

  my $drummer = MIDI::Drummer::Tiny->new;
  
  my $beats = MIDI::Drummer::Tiny::Beats->new;

  my $all = $beats->all_beats;

  my $beat = $beats->get_beat(0, $drummer); # random beat
  $beat = $beats->get_beat(42, $drummer); # numbered beat
  
  say $beat->{name};
  $beat->{beat}->() for 1 .. 4; # play the beat 4 times!

  # play 4 random rock beats
  my $rock = $beats->search('rock', $drummer);
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

  $beats = MIDI::Drummer::Tiny::Beats->new;

Return a new C<MIDI::Drummer::Tiny::Beats> object.

=head2 get_beat

  $beat = $beats->get_beat($beat_number, $drummer); # with object
  $beat = $beats->get_beat(0, $drummer); # random beat

Return either the given B<beat> or a random beat from the collection
of known beats.

A B<drummer> object optional but is really not useful without one.
The B<beat_number> is required, and C<0> means "return a random
beat."

=cut

sub get_beat {
    my ($self, $beat_number, $drummer) = @_;
    my $all = $self->all_beats($drummer);
    unless ($beat_number) {
        my @keys = keys %$all;
        $beat_number = $keys[ int rand @keys ];
    }
    return $all->{$beat_number};
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

  $found = $beats->search($string, $drummer);

Return the found beats with names matching the given B<string> as a
hash reference.

=cut

sub search {
    my ($self, $string, $drummer) = @_;
    $string = lc $string;
    my $all = $self->all_beats($drummer);
    my $found = {};
    for my $n (keys %$all) {
        $found->{$n} = $all->{$n}
            if lc($all->{$n}{name}) =~ /$string/;
    }
    return $found;
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
                    $d->crash1    => ['1000000000000000'],
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
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000000110100000'],
                    $d->snare     => ['0000100000001011'],
                    $d->closed_hh => ['1010101010101000'],
                    $d->open_hh   => ['0000000000000010'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        14 => {
            name => "ELECTRO 1 - A",
            beat => sub {
                $d->sync_patterns(#123456789ABCDEF0
                    $d->kick  => ['1000001000000000'],
                    $d->snare => ['0000100000001000'],
                    duration  => $d->sixteenth,
                ),
            },
        },

        15 => {
            name => "ELECTRO 1 - B",
            beat => sub {
                $d->sync_patterns(#123456789ABCDEF0
                    $d->kick  => ['1000001000100010'],
                    $d->snare => ['0000100000001000'],
                    duration  => $d->sixteenth,
                ),
            },
        },

        # nb: ELECTRO 2 - A == ELECTRO 1 - A

        16 => {
            name => "ELECTRO 2 - B",
            beat => sub {
                $d->sync_patterns(#123456789ABCDEF0
                    $d->kick  => ['1000000000100100'],
                    $d->snare => ['0000100000001000'],
                    duration  => $d->sixteenth,
                ),
            },
        },

        17 => {
            name => "ELECTRO 3 - A",
            beat => sub {
                $d->sync_patterns(#123456789ABCDEF0
                    $d->kick  => ['1000001000010000'],
                    $d->snare => ['0000100000001000'],
                    duration  => $d->sixteenth,
                ),
            },
        },

        18 => {
            name => "ELECTRO 3 - B",
            beat => sub {
                $d->sync_patterns(#123456789ABCDEF0
                    $d->kick  => ['1000001000010100'],
                    $d->snare => ['0000100000001000'],
                    duration  => $d->sixteenth,
                ),
            },
        },

        19 => {
            name => "ELECTRO 4",
            beat => sub {
                $d->sync_patterns(#123456789ABCDEF0
                    $d->kick  => ['1000001000100100'],
                    $d->snare => ['0000100000001000'],
                    duration  => $d->sixteenth,
                ),
            },
        },

        20 => {
            name => "SIBERIAN NIGHTS",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000001000000000'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1011101110111011'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        21 => {
            name => "NEW WAVE",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000001011000000'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1101111111111111'],
                    $d->open_hh   => ['0010000000000000'],
                    $d->maracas   => ['0000100000001000'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        22 => {
            name => "HOUSE",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick    => ['1000100010001000'],
                    $d->snare   => ['0000100000001000'],
                    $d->open_hh => ['0010001000100010'],
                    $d->crash1  => ['1000000000000000'],
                    duration    => $d->sixteenth,
                ),
            },
        },

        23 => {
            name => "HOUSE 2",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000001011000000'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1101101111011011'],
                    $d->open_hh   => ['0010010000100100'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        24 => {
            name => "BRIT HOUSE",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000001011000000'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1101110111011101'],
                    $d->open_hh   => ['0010001000100010'],
                    $d->crash1    => ['0010001000100010'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        24 => {
            name => "FRENCH HOUSE",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0 0000000000000000
                    $d->kick      => ['1000001011000000'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1010101010101010'],
                    $d->open_hh   => ['0101010101010101'],
                    $d->maracas   => ['1110101111101011'],
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
