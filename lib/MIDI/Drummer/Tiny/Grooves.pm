package MIDI::Drummer::Tiny::Grooves;

use Moo;
use strictures 2;
use MIDI::Drummer::Tiny ();
use namespace::clean;

=head1 SYNOPSIS

  use MIDI::Drummer::Tiny;
  use MIDI::Drummer::Tiny::Grooves;

  my $drummer = MIDI::Drummer::Tiny->new;

  my $beats = MIDI::Drummer::Tiny::Grooves->new;

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

  $beats = MIDI::Drummer::Tiny::Grooves->new;

Return a new C<MIDI::Drummer::Tiny::Grooves> object.

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

  $found = $beats->search(cat => $string, drummer => $drummer);
  $found = $beats->search(name => $string, drummer => $drummer);

Return the found beats with names matching the given B<string> as a
hash reference.

The B<drummer> object is required.

=cut

sub search {
    my ($self, %args) = @_;
    my $key = exists $args{cat} ? 'cat' : 'name';
    my $string = lc $args{$key};
    my $all = $self->all_beats($args{drummer});
    my $found = {};
    for my $k (keys %$all) {
        $found->{$k} = $all->{$k}
            if lc($all->{$k}{$key}) =~ /$string/;
    }
    return $found;
}

sub _beats {
    my ($self, $d) = @_;
    $d ||= MIDI::Drummer::Tiny->new;
    my %beats = (

        1 => {
            cat  => "Basic Patterns",
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
            cat  => "Basic Patterns",
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
            cat  => "Basic Patterns",
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
            cat  => "Basic Patterns",
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
            cat  => "Basic Patterns",
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
            cat  => "Standard Breaks",
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
            cat  => "Standard Breaks",
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
            cat  => "Standard Breaks",
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
            cat  => "Standard Breaks",
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
            cat  => "Rock",
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
            cat  => "Rock",
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
            cat  => "Rock",
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
            cat  => "Rock",
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
            cat  => "Electro",
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
            cat  => "Electro",
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
            cat  => "Electro",
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
            cat  => "Electro",
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
            cat  => "Electro",
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
            cat  => "Electro",
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
            cat  => "Electro",
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
            cat  => "Electro",
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
            cat  => "House",
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
            cat  => "House",
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
            cat  => "House",
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

        25 => {
            cat  => "House",
            name => "FRENCH HOUSE",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000001011000000'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1010101010101010'],
                    $d->open_hh   => ['0101010101010101'],
                    $d->maracas   => ['1110101111101011'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        26 => {
            cat  => "House",
            name => "DIRTY HOUSE",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1010100010101001'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['0000000000100001'],
                    $d->open_hh   => ['0010000000000010'],
                    $d->clap      => ['0010100010101000'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        27 => {
            cat  => "House",
            name => "DEEP HOUSE",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000100010001000'],
                    $d->clap      => ['0000100000001000'],
                    $d->closed_hh => ['0100000101000000'],
                    $d->open_hh   => ['0010001000100010'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        28 => {
            cat  => "House",
            name => "DEEPER HOUSE",
            beat => sub {
                $d->sync_patterns(     # 123456789ABCDEF0
                    $d->kick        => ['1000100010001000'],
                    $d->clap        => ['0100000001000000'],
                    $d->open_hh     => ['0010001000110010'],
                    $d->maracas     => ['0001000010000000'],
                    $d->low_mid_tom => ['0010000100100000'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        29 => {
            cat  => "House",
            name => "SLOW DEEP HOUSE",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000100010001000'],
                    $d->clap      => ['0000100000001000'],
                    $d->closed_hh => ['1000100010001000'],
                    $d->open_hh   => ['0011001101100010'],
                    $d->maracas   => ['1111111111111111'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        30 => {
            cat  => "House",
            name => "FOOTWORK - A",
            beat => sub {
                $d->sync_patterns(    # 123456789ABCDEF0
                    $d->kick       => ['1001001010010010'],
                    $d->clap       => ['0000000000001000'],
                    $d->closed_hh  => ['0010000000100000'],
                    $d->side_stick => ['1111111111111111'],
                    duration       => $d->sixteenth,
                ),
            },
        },

        31 => {
            cat  => "House",
            name => "FOOTWORK - B",
            beat => sub {
                $d->sync_patterns(    # 123456789ABCDEF0
                    $d->kick       => ['1001001010010010'],
                    $d->clap       => ['0000000000001000'],
                    $d->closed_hh  => ['0010001100100010'],
                    $d->side_stick => ['1111111111111111'],
                    duration       => $d->sixteenth,
                ),
            },
        },

        32 => {
            cat  => "Miami Bass",
            name => "MIAMI BASS - A",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000001000100100'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1011101110111011'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        33 => {
            cat  => "Miami Bass",
            name => "MIAMI BASS - B",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000001000000000'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1011101110111011'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        34 => {
            cat  => "Miami Bass",
            name => "SALLY",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0
                    $d->kick      => ['1000001000100010'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1010101010101010'],
                    $d->low_tom   => ['1000001000100010'],
                    duration      => $d->sixteenth,
                ),
            },
        },

        33 => {
            cat  => "Miami Bass",
            name => "ROCK THE PLANET",
            beat => sub {
                $d->sync_patterns(   # 123456789ABCDEF0 0000000000000000
                    $d->kick      => ['1001001000000000'],
                    $d->snare     => ['0000100000001000'],
                    $d->closed_hh => ['1011101110111111'],
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
