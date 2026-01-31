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

  # play grooves
  my $set = $grooves->search({}, cat => 'house');
  $set = $grooves->search($set, name => 'deep');
  my @nums = keys %$set;
  for (1 .. 4) {
    $groove = $set->{ $nums[ rand @nums ] };
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
    return $self->_grooves();
}

=head2 search

  $set = $grooves->search({}, cat => $x, name => $y); # search all grooves
  $set = $grooves->search($set, cat => $x, name => $y); # search the subset

Return the found grooves with names matching the given B<cat> or
B<name> strings as a hash reference.

=cut

sub search {
    my ($self, $set, %args) = @_;
    print "$self, $set, %args\n";
    unless (keys %$set) {
        $set = $self->all_grooves;
    }
    my $found = {};
    if ($args{cat}) {
        my $string = lc $args{cat};
        for my $k (keys %$set) {
            if (lc($set->{$k}{cat}) =~ /$string/) {
                $found->{$k} = $set->{$k};
            }
        }
    }
    if ($args{name}) {
        my $string = lc $args{name};
        for my $k (keys %$set) {
            if (lc($set->{$k}{name}) =~ /$string/) {
                $found->{$k} = $set->{$k};
            }
        }
    }
    return $self, $found;
}

sub _grooves {
    my ($self, %args) = @_;

    $args{kick}    ||= $self->drummer->kick;
    $args{snare}   ||= $self->drummer->snare;
    $args{closed}  ||= $self->drummer->closed_hh;
    $args{open}    ||= $self->drummer->open_hh;
    $args{cowbell} ||= $self->drummer->cowbell;
    $args{cymbal}  ||= $self->drummer->crash1;
    $args{shaker}  ||= $self->drummer->maracas;
    $args{clap}    ||= $self->drummer->clap;
    $args{hi_tom}  ||= $self->drummer->hi_mid_tom;
    $args{mid_tom} ||= $self->drummer->low_mid_tom;
    $args{low_tom} ||= $self->drummer->low_tom;
    $args{rimshot} ||= $self->drummer->side_stick;

    $args{duration} ||= $self->drummer->sixteenth;

    my %grooves = (

        1 => {
            cat  => "Basic Patterns",
            name => "ONE AND SEVEN & FIVE AND THIRTEEN",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1000001000000000'],
                    $args{snare} => ['0000100000001000'],
                    duration     => $args{duration},
                ),
            },
        },

        2 => {
            cat  => "Basic Patterns",
            name => "BOOTS N' CATS",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000000010000000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1010101010101010'],
                    duration      => $args{duration},
                ),
            },
        },

        3 => {
            cat  => "Basic Patterns",
            name => "TINY HOUSE",
            groove => sub {
                $self->drummer->sync_patterns( # 123456789ABCDEF0
                    $args{kick} => ['1000100010001000'],
                    $args{open} => ['0010001000100010'],
                    duration    => $args{duration},
                ),
            },
        },

        4 => {
            cat  => "Basic Patterns",
            name => "GOOD TO GO",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1001001000100000'],
                    $args{snare} => ['0000100000001000'],
                    duration     => $args{duration},
                ),
            },
        },

        5 => {
            cat  => "Basic Patterns",
            name => "HIP HOP",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1010001100000010'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1010101010101010'],
                    duration      => $args{duration},
                ),
            },
        },

        6 => {
            cat  => "Standard Breaks",
            name => "STANDARD BREAK 1",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000000000100000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1010101011101010'],
                    duration      => $args{duration},
                ),
            },
        },

        7 => {
            cat  => "Standard Breaks",
            name => "STANDARD BREAK 2",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000000000100000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1010101110100010'],
                    duration      => $args{duration},
                ),
            },
        },

        8 => {
            cat  => "Standard Breaks",
            name => "ROLLING BREAK",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000000100100000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1010101010101010'],
                    duration      => $args{duration},
                ),
            },
        },

        9 => {
            cat  => "Standard Breaks",
            name => "THE UNKNOWN DRUMMER",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1001001000100000'],
                    $args{snare}  => ['0100100100001000'],
                    $args{closed} => ['0110110100000100'],
                    $args{open}   => ['0000000010000010'],
                    duration      => $args{duration},
                ),
            },
        },

        10 => {
            cat  => "Rock",
            name => "ROCK 1",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000000110100000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1010101010101010'],
                    $args{cymbal} => ['1000000000000000'],
                    duration      => $args{duration},
                ),
            },
        },

        11 => {
            cat  => "Rock",
            name => "ROCK 2",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000000110100000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1010101010101010'],
                    duration      => $args{duration},
                ),
            },
        },

        12 => {
            cat  => "Rock",
            name => "ROCK 3",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000000110100000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1010101010101000'],
                    $args{open}   => ['0000000000000010'],
                    duration => $args{duration},
                ),
            },
        },

        13 => {
            cat  => "Rock",
            name => "ROCK 4",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000000110100000'],
                    $args{snare}  => ['0000100000001011'],
                    $args{closed} => ['1010101010101000'],
                    $args{open}   => ['0000000000000010'],
                    duration => $args{duration},
                ),
            },
        },

        14 => {
            cat  => "Electro",
            name => "ELECTRO 1 - A",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1000001000000000'],
                    $args{snare} => ['0000100000001000'],
                    duration  => $args{duration},
                ),
            },
        },

        15 => {
            cat  => "Electro",
            name => "ELECTRO 1 - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1000001000100010'],
                    $args{snare} => ['0000100000001000'],
                    duration  => $args{duration},
                ),
            },
        },

        # nb: ELECTRO 2 - A == ELECTRO 1 - A

        16 => {
            cat  => "Electro",
            name => "ELECTRO 2 - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1000000000100100'],
                    $args{snare} => ['0000100000001000'],
                    duration  => $args{duration},
                ),
            },
        },

        17 => {
            cat  => "Electro",
            name => "ELECTRO 3 - A",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1000001000010000'],
                    $args{snare} => ['0000100000001000'],
                    duration  => $args{duration},
                ),
            },
        },

        18 => {
            cat  => "Electro",
            name => "ELECTRO 3 - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1000001000010100'],
                    $args{snare} => ['0000100000001000'],
                    duration  => $args{duration},
                ),
            },
        },

        19 => {
            cat  => "Electro",
            name => "ELECTRO 4",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1000001000100100'],
                    $args{snare} => ['0000100000001000'],
                    duration  => $args{duration},
                ),
            },
        },

        20 => {
            cat  => "Electro",
            name => "SIBERIAN NIGHTS",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000001000000000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1011101110111011'],
                    duration => $args{duration},
                ),
            },
        },

        21 => {
            cat  => "Electro",
            name => "NEW WAVE",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000001011000000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1101111111111111'],
                    $args{open}   => ['0010000000000000'],
                    $args{shaker} => ['0000100000001000'],
                    duration => $args{duration},
                ),
            },
        },

        22 => {
            cat  => "House",
            name => "HOUSE",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000100010001000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{open}   => ['0010001000100010'],
                    $args{cymbal} => ['1000000000000000'],
                    duration => $args{duration},
                ),
            },
        },

        23 => {
            cat  => "House",
            name => "HOUSE 2",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000001011000000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1101101111011011'],
                    $args{open}   => ['0010010000100100'],
                    duration => $args{duration},
                ),
            },
        },

        24 => {
            cat  => "House",
            name => "BRIT HOUSE",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000001011000000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1101110111011101'],
                    $args{open}   => ['0010001000100010'],
                    $args{cymbal} => ['0010001000100010'],
                    duration => $args{duration},
                ),
            },
        },

        25 => {
            cat  => "House",
            name => "FRENCH HOUSE",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000001011000000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1010101010101010'],
                    $args{open}   => ['0101010101010101'],
                    $args{shaker} => ['1110101111101011'],
                    duration => $args{duration},
                ),
            },
        },

        26 => {
            cat  => "House",
            name => "DIRTY HOUSE",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1010100010101001'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['0000000000100001'],
                    $args{open}   => ['0010000000000010'],
                    $args{clap}   => ['0010100010101000'],
                    duration => $args{duration},
                ),
            },
        },

        27 => {
            cat  => "House",
            name => "DEEP HOUSE",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000100010001000'],
                    $args{clap}   => ['0000100000001000'],
                    $args{closed} => ['0100000101000000'],
                    $args{open}   => ['0010001000100010'],
                    duration => $args{duration},
                ),
            },
        },

        28 => {
            cat  => "House",
            name => "DEEPER HOUSE",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}    => ['1000100010001000'],
                    $args{clap}    => ['0100000001000000'],
                    $args{open}    => ['0010001000110010'],
                    $args{shaker}  => ['0001000010000000'],
                    $args{mid_tom} => ['0010000100100000'],
                    duration => $args{duration},
                ),
            },
        },

        29 => {
            cat  => "House",
            name => "SLOW DEEP HOUSE",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000100010001000'],
                    $args{clap}   => ['0000100000001000'],
                    $args{closed} => ['1000100010001000'],
                    $args{open}   => ['0011001101100010'],
                    $args{shaker} => ['1111111111111111'],
                    duration => $args{duration},
                ),
            },
        },

        30 => {
            cat  => "House",
            name => "FOOTWORK - A",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}    => ['1001001010010010'],
                    $args{clap}    => ['0000000000001000'],
                    $args{closed}  => ['0010000000100000'],
                    $args{rimshot} => ['1111111111111111'],
                    duration => $args{duration},
                ),
            },
        },

        31 => {
            cat  => "House",
            name => "FOOTWORK - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}    => ['1001001010010010'],
                    $args{clap}    => ['0000000000001000'],
                    $args{closed}  => ['0010001100100010'],
                    $args{rimshot} => ['1111111111111111'],
                    duration => $args{duration},
                ),
            },
        },

        32 => {
            cat  => "Miami Bass",
            name => "MIAMI BASS - A",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000001000100100'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1011101110111011'],
                    duration => $args{duration},
                ),
            },
        },

        33 => {
            cat  => "Miami Bass",
            name => "MIAMI BASS - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000001000000000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1011101110111011'],
                    duration => $args{duration},
                ),
            },
        },

        34 => {
            cat  => "Miami Bass",
            name => "SALLY",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}    => ['1000001000100010'],
                    $args{snare}   => ['0000100000001000'],
                    $args{closed}  => ['1010101010101010'],
                    $args{low_tom} => ['1000001000100010'],
                    duration => $args{duration},
                ),
            },
        },

        35 => {
            cat  => "Miami Bass",
            name => "ROCK THE PLANET",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1001001000000000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1011101110111111'],
                    duration => $args{duration},
                ),
            },
        },

        36 => {
            cat  => "Hip Hop",
            name => "HIP HOP 1 - A",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1000001100010010'],
                    $args{snare} => ['0000100000001000'],
                    duration => $args{duration},
                ),
            },
        },

        37 => {
            cat  => "Hip Hop",
            name => "HIP HOP 1 - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1000000100010000'],
                    $args{snare} => ['0000100000001000'],
                    duration => $args{duration},
                ),
            },
        },

        38 => {
            cat  => "Hip Hop",
            name => "HIP HOP 2 - A",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1000000111010101'],
                    $args{snare} => ['0000100000001000'],
                    duration => $args{duration},
                ),
            },
        },

        39 => {
            cat  => "Hip Hop",
            name => "HIP HOP 2 - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1000000110010000'],
                    $args{snare} => ['0000100000001000'],
                    duration => $args{duration},
                ),
            },
        },

        40 => {
            cat  => "Hip Hop",
            name => "HIP HOP 3 - A",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1010000010100000'],
                    $args{snare} => ['0000100000001000'],
                    duration => $args{duration},
                ),
            },
        },

        41 => {
            cat  => "Hip Hop",
            name => "HIP HOP 3 - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1010000011010000'],
                    $args{snare} => ['0000100000001000'],
                    duration => $args{duration},
                ),
            },
        },

        42 => {
            cat  => "Hip Hop",
            name => "HIP HOP 4 - A",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1001000101100001'],
                    $args{snare} => ['0000100000001000'],
                    duration => $args{duration},
                ),
            },
        },

        43 => {
            cat  => "Hip Hop",
            name => "HIP HOP 4 - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1010000111100000'],
                    $args{snare} => ['0000100000001000'],
                    duration => $args{duration},
                ),
            },
        },

        44 => {
            cat  => "Hip Hop",
            name => "HIP HOP 5",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1010000110100001'],
                    $args{snare} => ['0000100000001000'],
                    duration => $args{duration},
                ),
            },
        },

        45 => {
            cat  => "Hip Hop",
            name => "HIP HOP 6",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1010000000110001'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1010101010101010'],
                    duration => $args{duration},
                ),
            },
        },

        46 => {
            cat  => "Hip Hop",
            name => "HIP HOP 7",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000000100100101'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1010101010101010'],
                    duration => $args{duration},
                ),
            },
        },

        47 => {
            cat  => "Hip Hop",
            name => "HIP HOP 8",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1001000010110000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1101101111011011'],
                    $args{open}   => ['0000010000000100'],
                    duration => $args{duration},
                ),
            },
        },

        48 => {
            cat  => "Hip Hop",
            name => "TRAP - A",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000001000001000'],
                    $args{snare}  => ['0000000010000000'],
                    $args{closed} => ['1010101010101010'],
                    duration => $args{duration},
                ),
            },
        },

        49 => {
            cat  => "Hip Hop",
            name => "TRAP - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['0010100000000000'],
                    $args{snare}  => ['0000000010000000'],
                    $args{closed} => ['1110101010101110'],
                    duration => $args{duration},
                ),
            },
        },

        50 => {
            cat  => "Hip Hop",
            name => "PLANET ROCK - A",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}    => ['1000001000000000'],
                    $args{snare}   => ['0000100000001000'],
                    $args{clap}    => ['0000100000001000'],
                    $args{closed}  => ['1011101110111111'],
                    $args{cowbell} => ['1010101101011010'],
                    duration => $args{duration},
                ),
            },
        },

        51 => {
            cat  => "Hip Hop",
            name => "PLANET ROCK - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}    => ['1000001000100100'],
                    $args{snare}   => ['0000100000001000'],
                    $args{clap}    => ['0000100000001000'],
                    $args{closed}  => ['1011101110111111'],
                    $args{cowbell} => ['1010101101011010'],
                    duration => $args{duration},
                ),
            },
        },

        52 => {
            cat  => "Hip Hop",
            name => "INNA CLUB",
            groove => sub {
                $self->drummer->sync_patterns( # 123456789ABCDEF0
                    $args{kick}  => ['0010000100100001'],
                    $args{snare} => ['0000100000001000'],
                    $args{clap}  => ['0000100000001000'],
                    $args{open}  => ['1010101010101010'],
                    duration => $args{duration},
                ),
            },
        },

        53 => {
            cat  => "Hip Hop",
            name => "ICE",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000001000100010'],
                    $args{snare}  => ['0000100000001000'],
                    $args{shaker} => ['1010101010101010'],
                    duration => $args{duration},
                ),
            },
        },

        54 => {
            cat  => "Hip Hop",
            name => "BACK TO CALI - A",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000001000000000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{clap}   => ['0000101010001010'],
                    $args{closed} => ['1010101010101010'],
                    duration => $args{duration},
                ),
            },
        },

        55 => {
            cat  => "Hip Hop",
            name => "BACK TO CALI - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000001000100100'],
                    $args{snare}  => ['0000100000001000'],
                    $args{clap}   => ['1000101010001000'],
                    $args{closed} => ['1010101010100010'],
                    $args{open}   => ['0000000000001000'],
                    duration => $args{duration},
                ),
            },
        },

        56 => {
            cat  => "Hip Hop",
            name => "SNOOP STYLES",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}    => ['1001001000010000'],
                    $args{snare}   => ['0000100000001000'],
                    $args{clap}    => ['0000100000001000'],
                    $args{rimshot} => ['0010010010010000'],
                    $args{open}    => ['1001001000010000'],
                    duration => $args{duration},
                ),
            },
        },

        57 => {
            cat  => "Hip Hop",
            name => "THE GROOVE - A",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1001000100010010'],
                    $args{snare}  => ['0000100000001000'],
                    $args{shaker} => ['0000100000001000'],
                    $args{closed} => ['1010101010101010'],
                    $args{open}   => ['0000000100000000'],
                    duration => $args{duration},
                ),
            },
        },

        58 => {
            cat  => "Hip Hop",
            name => "THE GROOVE - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}    => ['1001000100010010'],
                    $args{snare}   => ['0000100000001000'],
                    $args{shaker}  => ['0000100000001000'],
                    $args{closed}  => ['1010101010000100'],
                    $args{open}    => ['0000000100111010'],
                    $args{hi_tom}  => ['0000000001100000'],
                    $args{mid_tom} => ['0000000000010100'],
                    $args{low_tom} => ['0000000000000011'],
                    duration => $args{duration},
                ),
            },
        },

        58 => {
            cat  => "Hip Hop",
            name => "BOOM BAP",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}    => ['1010010001000100'],
                    $args{snare}   => ['0010001000100010'],
                    $args{clap}    => ['0010001000100010'],
                    $args{closed}  => ['1111111111111101'],
                    $args{cowbell} => ['0000000010000000'],
                    duration => $args{duration},
                ),
            },
        },

        59 => {
            cat  => "Hip Hop",
            name => "MOST WANTED - A",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000001011000001'],
                    $args{snare}  => ['0000100000001000'],
                    $args{clap}   => ['0000100000001000'],
                    $args{closed} => ['0010101010101010'],
                    $args{cymbal} => ['1000000000000000'],
                    duration => $args{duration},
                ),
            },
        },

        60 => {
            cat  => "Hip Hop",
            name => "MOST WANTED - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['0010001011000000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{clap}   => ['0000100000001000'],
                    $args{closed} => ['0010101010101010'],
                    $args{open}   => ['0010000000000000'],
                    duration => $args{duration},
                ),
            },
        },

        60 => {
            cat  => "Funk and Soul",
            name => "AMEN BREAK - A",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1010000000110000'],
                    $args{snare}  => ['0000000101001001'],
                    $args{closed} => ['1010101010101010'],
                    duration => $args{duration},
                ),
            },
        },

        61 => {
            cat  => "Funk and Soul",
            name => "AMEN BREAK - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}    => ['1010000000110000'],
                    $args{snare}   => ['0000100101001001'],
                    $args{rimshot} => ['0000100000000000'],
                    $args{closed}  => ['1010101010101010'],
                    duration => $args{duration},
                ),
            },
        },

        62 => {
            cat  => "Funk and Soul",
            name => "AMEN BREAK - C",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}    => ['1010000000100000'],
                    $args{snare}   => ['0000100101001001'],
                    $args{rimshot} => ['0000000000000010'],
                    $args{closed}  => ['1010101010101010'],
                    duration => $args{duration},
                ),
            },
        },

        63 => {
            cat  => "Funk and Soul",
            name => "AMEN BREAK - D",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1010000000100000'],
                    $args{snare}  => ['0100100101000010'],
                    $args{closed} => ['1010101010001010'],
                    $args{cymbal} => ['0000000000100000'],
                    duration => $args{duration},
                ),
            },
        },

        64 => {
            cat  => "Funk and Soul",
            name => "THE FUNKY DRUMMER",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1010001000100100'],
                    $args{snare}  => ['0000100101011001'],
                    $args{closed} => ['1111111011111011'],
                    $args{open}   => ['0000000100000100'],
                    duration => $args{duration},
                ),
            },
        },

        65 => {
            cat  => "Funk and Soul",
            name => "IMPEACH THE PRESIDENT",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000000110000010'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1010101110001010'],
                    $args{open}   => ['0000000000100000'],
                    duration => $args{duration},
                ),
            },
        },

        66 => {
            cat  => "Funk and Soul",
            name => "WHEN THE LEVEE BREAKS",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1100000100110000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1010101010101010'],
                    duration => $args{duration},
                ),
            },
        },

        67 => {
            cat  => "Funk and Soul",
            name => "IT'S A NEW DAY",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1010000000110001'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1010101010101010'],
                    duration => $args{duration},
                ),
            },
        },

        68 => {
            cat  => "Funk and Soul",
            name => "THE BIG BEAT",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1001001010000000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['0000100000001000'],
                    duration => $args{duration},
                ),
            },
        },

        69 => {
            cat  => "Funk and Soul",
            name => "ASHLEY'S ROACHCLIP",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}    => ['1010001011000000'],
                    $args{snare}   => ['0000100000001000'],
                    $args{closed}  => ['1010101010001010'],
                    $args{open}    => ['0000000000100000'],
                    $args{cowbell} => ['1010101010101010'],
                    duration => $args{duration},
                ),
            },
        },

        70 => {
            cat  => "Funk and Soul",
            name => "PAPA WAS TOO",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000000110100001'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['0000100010101011'],
                    $args{cymbal} => ['0000100000000000'],
                    duration => $args{duration},
                ),
            },
        },

        71 => {
            cat  => "Funk and Soul",
            name => "SUPERSTITION",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000100010001000'],
                    $args{snare}  => ['0000100000001000'],
                    $args{closed} => ['1010101111101011'],
                    duration => $args{duration},
                ),
            },
        },

        72 => {
            cat  => "Funk and Soul",
            name => "CISSY STRUT - A",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1001010001011010'],
                    $args{snare}  => ['0000100101100000'],
                    $args{cymbal} => ['0000000000001010'],
                    duration => $args{duration},
                ),
            },
        },

        73 => {
            cat  => "Funk and Soul",
            name => "CISSY STRUT - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}  => ['1001000101011010'],
                    $args{snare} => ['0010011011000000'],
                    duration => $args{duration},
                ),
            },
        },

        74 => {
            cat  => "Funk and Soul",
            name => "CISSY STRUT - C",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000100101011010'],
                    $args{snare}  => ['0010111001000000'],
                    $args{cymbal} => ['0000000000001010'],
                    duration => $args{duration},
                ),
            },
        },

        75 => {
            cat  => "Funk and Soul",
            name => "CISSY STRUT - D",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1000100101011010'],
                    $args{snare}  => ['1010010011000000'],
                    $args{cymbal} => ['0000000000001010'],
                    duration => $args{duration},
                ),
            },
        },

        76 => {
            cat  => "Funk and Soul",
            name => "HOOK AND SLING - A",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1010000001000110'],
                    $args{snare}  => ['0000101100101000'],
                    $args{cymbal} => ['1011010011010010'],
                    duration => $args{duration},
                ),
            },
        },

        77 => {
            cat  => "Funk and Soul",
            name => "HOOK AND SLING - B",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['0000000000000010'],
                    $args{snare}  => ['1000110100110011'],
                    $args{cymbal} => ['1101001011001010'],
                    duration => $args{duration},
                ),
            },
        },

        78 => {
            cat  => "Funk and Soul",
            name => "HOOK AND SLING - C",
            groove => sub {
                $self->drummer->sync_patterns(
                    $args{kick}   => ['1100000000001101'],
                    $args{snare}  => ['0010101100110010'],
                    $args{cymbal} => ['1010110101001100'],
                    duration => $args{duration},
                ),
            },
        },

        79 => {
            cat  => "Funk and Soul",
            name => "HOOK AND SLING - D",
            groove => sub {
                $self->drummer->sync_patterns(# 123456789ABCDEF0 0000000000000000
                    $args{kick}   => ['1010010000010110'],
                    $args{snare}  => ['0000100100100001'],
                    $args{cymbal} => ['1010110100000000'],
                    duration      => $args{duration},
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
