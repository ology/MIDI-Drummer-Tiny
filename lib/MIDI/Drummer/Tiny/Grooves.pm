package MIDI::Drummer::Tiny::Grooves;

use Moo;
use strictures 2;
use MIDI::Drummer::Tiny ();
use namespace::clean;

=head1 SYNOPSIS

  use MIDI::Drummer::Tiny;
  use MIDI::Drummer::Tiny::Grooves;
  use MIDI::Drummer::Tiny::Grooves qw(:house :rock); <- TODO

  my $drummer = MIDI::Drummer::Tiny->new;

  my $grooves = MIDI::Drummer::Tiny::Grooves->new(drummer => $drummer);
  
  my $all = $grooves->all_grooves;

  my $groove = $grooves->get_groove;  # random groove
  $groove = $grooves->get_groove(42); # numbered groove

  say $groove->{cat};
  say $groove->{name};
  $groove->{groove}->() for 1 .. 4; # play the groove 4 times!

  # play 4 random rock grooves
  my $rock = $grooves->search(cat => 'rock');
  my @nums = keys %$rock;
  for (1 .. 4) {
    $groove = $rock->{ $nums[ rand @nums ] };
    say $groove->{name};
    $groove->{groove}->();
  }

=head1 DESCRIPTION

Return the common grooves, as listed in the "Pocket Operations", that
are L<linked below|/SEE ALSO>.

A groove is a numbered and named hash reference, with the following
structure:

  { 1 => {
      name => "ONE AND SEVEN & FIVE AND THIRTEEN",
      groove => sub {
        $self->drummer->sync_patterns(
        $self->drummer->kick  => ['1000001000000000'],
        $self->drummer->snare => ['0000100000001000'],
        duration => $self->drummer->sixteenth,
      ),
    },
  },
  2 => { ... }, ... }

=cut

=head1 ACCESSORS

=head2 drummer

  $drummer = $grooves->drummer;

The L<MIDI::Drummer::Tiny> object. If not given in the constructor, a
new one is created when a method is called.

=cut

has drummer => (
  is      => 'rw',
  isa     => sub { die "Invalid drummer object" unless ref($_[0]) eq 'MIDI::Drummer::Tiny' },
  default => sub { MIDI::Drummer::Tiny->new },
);

=head1 METHODS

=head2 new

  $grooves = MIDI::Drummer::Tiny::Grooves->new;
  $grooves = MIDI::Drummer::Tiny::Grooves->new(drummer => $drummer);

Return a new C<MIDI::Drummer::Tiny::Grooves> object.

=head2 get_groove

  $groove = $grooves->get_groove($groove_number);
  $groove = $grooves->get_groove; # random groove

Return a numbered or random groove from the collection of known
grooves.

=cut

sub get_groove {
    my ($self, $groove_number) = @_;
    my $all = $self->all_grooves;
    unless ($groove_number) {
        my @keys = keys %$all;
        $groove_number = $keys[ int rand @keys ];
    }
    return $all->{$groove_number};
}

=head2 all_grooves

  $all = $grooves->all_grooves;

Return all the known grooves as a hash reference.

=cut

sub all_grooves {
    my ($self) = @_;
    return $self->_grooves;
}

=head2 search

  $found = $grooves->search(cat => $x, name => $y, drummer => $drummer);

Return the found grooves with names matching the given B<cat> or
B<name> strings as a hash reference.

The B<drummer> object is required.

=cut

sub search {
    my ($self, %args) = @_;
    my $all = $self->all_grooves;
    my $found = {};
    if ($args{cat}) {
        my $string = lc $args{cat};
        for my $k (keys %$all) {
            if (lc($all->{$k}{cat}) =~ /$string/) {
                $found->{$k} = $all->{$k};
            }
        }
    }
    if ($args{name}) {
        my $string = lc $args{name};
        for my $k (keys %$all) {
            if (lc($all->{$k}{name}) =~ /$string/) {
                $found->{$k} = $all->{$k};
            }
        }
    }
    return $found;
}

sub _grooves {
    my ($self) = @_;
    my %grooves = (

        1 => {
            cat  => "Basic Patterns",
            name => "ONE AND SEVEN & FIVE AND THIRTEEN",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1000001000000000'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        2 => {
            cat  => "Basic Patterns",
            name => "BOOTS N' CATS",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000000010000000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101010101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        3 => {
            cat  => "Basic Patterns",
            name => "TINY HOUSE",
            groove => sub {
                $self->drummer->sync_patterns( # 123456789ABCDEF0
                    $self->drummer->kick    => ['1000100010001000'],
                    $self->drummer->open_hh => ['0010001000100010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        4 => {
            cat  => "Basic Patterns",
            name => "GOOD TO GO",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1001001000100000'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        5 => {
            cat  => "Basic Patterns",
            name => "HIP HOP",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1010001100000010'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101010101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        6 => {
            cat  => "Standard Breaks",
            name => "STANDARD BREAK 1",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000000000100000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101011101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        7 => {
            cat  => "Standard Breaks",
            name => "STANDARD BREAK 2",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000000000100000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101110100010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        8 => {
            cat  => "Standard Breaks",
            name => "ROLLING BREAK",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000000100100000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101010101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        9 => {
            cat  => "Standard Breaks",
            name => "THE UNKNOWN DRUMMER",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1001001000100000'],
                    $self->drummer->snare     => ['0100100100001000'],
                    $self->drummer->closed_hh => ['0110110100000100'],
                    $self->drummer->open_hh   => ['0000000010000010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        10 => {
            cat  => "Rock",
            name => "ROCK 1",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000000110100000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101010101010'],
                    $self->drummer->crash1    => ['1000000000000000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        11 => {
            cat  => "Rock",
            name => "ROCK 2",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000000110100000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101010101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        12 => {
            cat  => "Rock",
            name => "ROCK 3",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000000110100000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101010101000'],
                    $self->drummer->open_hh   => ['0000000000000010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        13 => {
            cat  => "Rock",
            name => "ROCK 4",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000000110100000'],
                    $self->drummer->snare     => ['0000100000001011'],
                    $self->drummer->closed_hh => ['1010101010101000'],
                    $self->drummer->open_hh   => ['0000000000000010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        14 => {
            cat  => "Electro",
            name => "ELECTRO 1 - A",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1000001000000000'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration  => $self->drummer->sixteenth,
                ),
            },
        },

        15 => {
            cat  => "Electro",
            name => "ELECTRO 1 - B",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1000001000100010'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration  => $self->drummer->sixteenth,
                ),
            },
        },

        # nb: ELECTRO 2 - A == ELECTRO 1 - A

        16 => {
            cat  => "Electro",
            name => "ELECTRO 2 - B",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1000000000100100'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration  => $self->drummer->sixteenth,
                ),
            },
        },

        17 => {
            cat  => "Electro",
            name => "ELECTRO 3 - A",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1000001000010000'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration  => $self->drummer->sixteenth,
                ),
            },
        },

        18 => {
            cat  => "Electro",
            name => "ELECTRO 3 - B",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1000001000010100'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration  => $self->drummer->sixteenth,
                ),
            },
        },

        19 => {
            cat  => "Electro",
            name => "ELECTRO 4",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1000001000100100'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration  => $self->drummer->sixteenth,
                ),
            },
        },

        20 => {
            cat  => "Electro",
            name => "SIBERIAN NIGHTS",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000001000000000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1011101110111011'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        21 => {
            cat  => "Electro",
            name => "NEW WAVE",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000001011000000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1101111111111111'],
                    $self->drummer->open_hh   => ['0010000000000000'],
                    $self->drummer->maracas   => ['0000100000001000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        22 => {
            cat  => "House",
            name => "HOUSE",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick    => ['1000100010001000'],
                    $self->drummer->snare   => ['0000100000001000'],
                    $self->drummer->open_hh => ['0010001000100010'],
                    $self->drummer->crash1  => ['1000000000000000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        23 => {
            cat  => "House",
            name => "HOUSE 2",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000001011000000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1101101111011011'],
                    $self->drummer->open_hh   => ['0010010000100100'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        24 => {
            cat  => "House",
            name => "BRIT HOUSE",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000001011000000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1101110111011101'],
                    $self->drummer->open_hh   => ['0010001000100010'],
                    $self->drummer->crash1    => ['0010001000100010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        25 => {
            cat  => "House",
            name => "FRENCH HOUSE",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000001011000000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101010101010'],
                    $self->drummer->open_hh   => ['0101010101010101'],
                    $self->drummer->maracas   => ['1110101111101011'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        26 => {
            cat  => "House",
            name => "DIRTY HOUSE",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1010100010101001'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['0000000000100001'],
                    $self->drummer->open_hh   => ['0010000000000010'],
                    $self->drummer->clap      => ['0010100010101000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        27 => {
            cat  => "House",
            name => "DEEP HOUSE",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000100010001000'],
                    $self->drummer->clap      => ['0000100000001000'],
                    $self->drummer->closed_hh => ['0100000101000000'],
                    $self->drummer->open_hh   => ['0010001000100010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        28 => {
            cat  => "House",
            name => "DEEPER HOUSE",
            groove => sub {
                $self->drummer->sync_patterns(     # 123456789ABCDEF0
                    $self->drummer->kick        => ['1000100010001000'],
                    $self->drummer->clap        => ['0100000001000000'],
                    $self->drummer->open_hh     => ['0010001000110010'],
                    $self->drummer->maracas     => ['0001000010000000'],
                    $self->drummer->low_mid_tom => ['0010000100100000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        29 => {
            cat  => "House",
            name => "SLOW DEEP HOUSE",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000100010001000'],
                    $self->drummer->clap      => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1000100010001000'],
                    $self->drummer->open_hh   => ['0011001101100010'],
                    $self->drummer->maracas   => ['1111111111111111'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        30 => {
            cat  => "House",
            name => "FOOTWORK - A",
            groove => sub {
                $self->drummer->sync_patterns(    # 123456789ABCDEF0
                    $self->drummer->kick       => ['1001001010010010'],
                    $self->drummer->clap       => ['0000000000001000'],
                    $self->drummer->closed_hh  => ['0010000000100000'],
                    $self->drummer->side_stick => ['1111111111111111'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        31 => {
            cat  => "House",
            name => "FOOTWORK - B",
            groove => sub {
                $self->drummer->sync_patterns(    # 123456789ABCDEF0
                    $self->drummer->kick       => ['1001001010010010'],
                    $self->drummer->clap       => ['0000000000001000'],
                    $self->drummer->closed_hh  => ['0010001100100010'],
                    $self->drummer->side_stick => ['1111111111111111'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        32 => {
            cat  => "Miami Bass",
            name => "MIAMI BASS - A",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000001000100100'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1011101110111011'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        33 => {
            cat  => "Miami Bass",
            name => "MIAMI BASS - B",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000001000000000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1011101110111011'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        34 => {
            cat  => "Miami Bass",
            name => "SALLY",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000001000100010'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101010101010'],
                    $self->drummer->low_tom   => ['1000001000100010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        35 => {
            cat  => "Miami Bass",
            name => "ROCK THE PLANET",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1001001000000000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1011101110111111'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        36 => {
            cat  => "Hip Hop",
            name => "HIP HOP 1 - A",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1000001100010010'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        37 => {
            cat  => "Hip Hop",
            name => "HIP HOP 1 - B",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1000000100010000'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        38 => {
            cat  => "Hip Hop",
            name => "HIP HOP 2 - A",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1000000111010101'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        39 => {
            cat  => "Hip Hop",
            name => "HIP HOP 2 - B",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1000000110010000'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        40 => {
            cat  => "Hip Hop",
            name => "HIP HOP 3 - A",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1010000010100000'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        41 => {
            cat  => "Hip Hop",
            name => "HIP HOP 3 - B",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1010000011010000'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        42 => {
            cat  => "Hip Hop",
            name => "HIP HOP 4 - A",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1001000101100001'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        43 => {
            cat  => "Hip Hop",
            name => "HIP HOP 4 - B",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1010000111100000'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        44 => {
            cat  => "Hip Hop",
            name => "HIP HOP 5",
            groove => sub {
                $self->drummer->sync_patterns(#123456789ABCDEF0
                    $self->drummer->kick  => ['1010000110100001'],
                    $self->drummer->snare => ['0000100000001000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        45 => {
            cat  => "Hip Hop",
            name => "HIP HOP 6",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1010000000110001'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101010101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        46 => {
            cat  => "Hip Hop",
            name => "HIP HOP 7",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000000100100101'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101010101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        47 => {
            cat  => "Hip Hop",
            name => "HIP HOP 8",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1001000010110000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1101101111011011'],
                    $self->drummer->open_hh   => ['0000010000000100'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        48 => {
            cat  => "Hip Hop",
            name => "TRAP - A",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000001000001000'],
                    $self->drummer->snare     => ['0000000010000000'],
                    $self->drummer->closed_hh => ['1010101010101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        49 => {
            cat  => "Hip Hop",
            name => "TRAP - B",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['0010100000000000'],
                    $self->drummer->snare     => ['0000000010000000'],
                    $self->drummer->closed_hh => ['1110101010101110'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        50 => {
            cat  => "Hip Hop",
            name => "PLANET ROCK - A",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000001000000000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->clap      => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1011101110111111'],
                    $self->drummer->cowbell   => ['1010101101011010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        51 => {
            cat  => "Hip Hop",
            name => "PLANET ROCK - B",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000001000100100'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->clap      => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1011101110111111'],
                    $self->drummer->cowbell   => ['1010101101011010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        52 => {
            cat  => "Hip Hop",
            name => "INNA CLUB",
            groove => sub {
                $self->drummer->sync_patterns( # 123456789ABCDEF0
                    $self->drummer->kick    => ['0010000100100001'],
                    $self->drummer->snare   => ['0000100000001000'],
                    $self->drummer->clap    => ['0000100000001000'],
                    $self->drummer->open_hh => ['1010101010101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        53 => {
            cat  => "Hip Hop",
            name => "ICE",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick    => ['1000001000100010'],
                    $self->drummer->snare   => ['0000100000001000'],
                    $self->drummer->maracas => ['1010101010101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        54 => {
            cat  => "Hip Hop",
            name => "BACK TO CALI - A",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000001000000000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->clap      => ['0000101010001010'],
                    $self->drummer->closed_hh => ['1010101010101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        55 => {
            cat  => "Hip Hop",
            name => "BACK TO CALI - B",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000001000100100'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->clap      => ['1000101010001000'],
                    $self->drummer->closed_hh => ['1010101010100010'],
                    $self->drummer->open_hh   => ['0000000000001000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        56 => {
            cat  => "Hip Hop",
            name => "SNOOP STYLES",
            groove => sub {
                $self->drummer->sync_patterns(    # 123456789ABCDEF0
                    $self->drummer->kick       => ['1001001000010000'],
                    $self->drummer->snare      => ['0000100000001000'],
                    $self->drummer->clap       => ['0000100000001000'],
                    $self->drummer->side_stick => ['0010010010010000'],
                    $self->drummer->open_hh    => ['1001001000010000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        57 => {
            cat  => "Hip Hop",
            name => "THE GROOVE - A",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1001000100010010'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->maracas   => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101010101010'],
                    $self->drummer->open_hh   => ['0000000100000000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        58 => {
            cat  => "Hip Hop",
            name => "THE GROOVE - B",
            groove => sub {
                $self->drummer->sync_patterns(     # 123456789ABCDEF0
                    $self->drummer->kick        => ['1001000100010010'],
                    $self->drummer->snare       => ['0000100000001000'],
                    $self->drummer->maracas     => ['0000100000001000'],
                    $self->drummer->closed_hh   => ['1010101010000100'],
                    $self->drummer->open_hh     => ['0000000100111010'],
                    $self->drummer->hi_mid_tom  => ['0000000001100000'],
                    $self->drummer->low_mid_tom => ['0000000000010100'],
                    $self->drummer->low_tom     => ['0000000000000011'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        58 => {
            cat  => "Hip Hop",
            name => "BOOM BAP",
            groove => sub {
                $self->drummer->sync_patterns(     # 123456789ABCDEF0
                    $self->drummer->kick        => ['1010010001000100'],
                    $self->drummer->snare       => ['0010001000100010'],
                    $self->drummer->clap        => ['0010001000100010'],
                    $self->drummer->closed_hh   => ['1111111111111101'],
                    $self->drummer->cowbell     => ['0000000010000000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        59 => {
            cat  => "Hip Hop",
            name => "MOST WANTED - A",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000001011000001'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->clap      => ['0000100000001000'],
                    $self->drummer->closed_hh => ['0010101010101010'],
                    $self->drummer->crash1    => ['1000000000000000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        60 => {
            cat  => "Hip Hop",
            name => "MOST WANTED - B",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['0010001011000000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->clap      => ['0000100000001000'],
                    $self->drummer->closed_hh => ['0010101010101010'],
                    $self->drummer->open_hh   => ['0010000000000000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        60 => {
            cat  => "Funk and Soul",
            name => "AMEN BREAK - A",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1010000000110000'],
                    $self->drummer->snare     => ['0000000101001001'],
                    $self->drummer->closed_hh => ['1010101010101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        61 => {
            cat  => "Funk and Soul",
            name => "AMEN BREAK - B",
            groove => sub {
                $self->drummer->sync_patterns(    # 123456789ABCDEF0
                    $self->drummer->kick       => ['1010000000110000'],
                    $self->drummer->snare      => ['0000100101001001'],
                    $self->drummer->side_stick => ['0000100000000000'],
                    $self->drummer->closed_hh  => ['1010101010101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        62 => {
            cat  => "Funk and Soul",
            name => "AMEN BREAK - C",
            groove => sub {
                $self->drummer->sync_patterns(    # 123456789ABCDEF0
                    $self->drummer->kick       => ['1010000000100000'],
                    $self->drummer->snare      => ['0000100101001001'],
                    $self->drummer->side_stick => ['0000000000000010'],
                    $self->drummer->closed_hh  => ['1010101010101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        63 => {
            cat  => "Funk and Soul",
            name => "AMEN BREAK - D",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1010000000100000'],
                    $self->drummer->snare     => ['0100100101000010'],
                    $self->drummer->closed_hh => ['1010101010001010'],
                    $self->drummer->crash1    => ['0000000000100000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        64 => {
            cat  => "Funk and Soul",
            name => "THE FUNKY DRUMMER",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1010001000100100'],
                    $self->drummer->snare     => ['0000100101011001'],
                    $self->drummer->closed_hh => ['1111111011111011'],
                    $self->drummer->open_hh   => ['0000000100000100'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        65 => {
            cat  => "Funk and Soul",
            name => "IMPEACH THE PRESIDENT",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000000110000010'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101110001010'],
                    $self->drummer->open_hh   => ['0000000000100000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        66 => {
            cat  => "Funk and Soul",
            name => "WHEN THE LEVEE BREAKS",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1100000100110000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101010101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        67 => {
            cat  => "Funk and Soul",
            name => "IT'S A NEW DAY",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1010000000110001'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101010101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        68 => {
            cat  => "Funk and Soul",
            name => "THE BIG BEAT",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1001001010000000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['0000100000001000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        69 => {
            cat  => "Funk and Soul",
            name => "ASHLEY'S ROACHCLIP",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1010001011000000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101010001010'],
                    $self->drummer->open_hh   => ['0000000000100000'],
                    $self->drummer->cowbell   => ['1010101010101010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        70 => {
            cat  => "Funk and Soul",
            name => "PAPA WAS TOO",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000000110100001'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['0000100010101011'],
                    $self->drummer->crash1    => ['0000100000000000'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        71 => {
            cat  => "Funk and Soul",
            name => "SUPERSTITION",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0
                    $self->drummer->kick      => ['1000100010001000'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->crash1    => ['1010101111101011'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

        72 => {
            cat  => "Funk and Soul",
            name => "CISSY STRUT - A",
            groove => sub {
                $self->drummer->sync_patterns(   # 123456789ABCDEF0 0000000000000000
                    $self->drummer->kick      => ['1001010001011010'],
                    $self->drummer->snare     => ['0000100101100000'],
                    $self->drummer->closed_hh => ['0000000000001010'],
                    duration => $self->drummer->sixteenth,
                ),
            },
        },

    );
    return \%grooves;
}

1;

__END__

=head1 SEE ALSO

The "Pocket Operations" at L<https://shittyrecording.studio/>

=cut
