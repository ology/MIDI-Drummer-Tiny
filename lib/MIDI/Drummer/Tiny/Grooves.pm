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

  $found = $grooves->search(cat => $string, drummer => $drummer);
  $found = $grooves->search(name => $string, drummer => $drummer);

Return the found grooves with names matching the given B<string> as a
hash reference.

The B<drummer> object is required.

=cut

sub search {
    my ($self, %args) = @_;
    my $key = exists $args{cat} ? 'cat' : 'name';
    my $string = lc $args{$key};
    my $all = $self->all_grooves;
    my $found = {};
    for my $k (keys %$all) {
        $found->{$k} = $all->{$k}
            if lc($all->{$k}{$key}) =~ /$string/;
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
                $self->drummer->sync_patterns(   # 123456789ABCDEF0 0000000000000000
                    $self->drummer->kick      => ['1010000000110001'],
                    $self->drummer->snare     => ['0000100000001000'],
                    $self->drummer->closed_hh => ['1010101010101010'],
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
