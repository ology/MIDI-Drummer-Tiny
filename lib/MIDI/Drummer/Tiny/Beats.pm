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

  my $beat = $beats->get_beat($drummer);
  $beat->{beat}->();

=head1 DESCRIPTION

Return the common beats, as listed in the "Pocket Operations", that
are L<linked below|/SEE ALSO>.

=cut

=head1 METHODS

=head2 new

  $beats = MIDI::Drummer::Tiny::beats->new;

Return a new C<MIDI::Drummer::Tiny::Beats> object.

=head2 get_beat

  $beat = $beats->get_beat($drummer, $beat);

Return either the given B<beat> or a random beat from the collection
of known beats.

A B<drummer> object and a B<beat> number are required.

=cut

sub get_beat {
    my ($self, $drummer, $beat_number) = @_;
    my $beats = $self->all_beats($drummer);
    unless ($beat_number) {
        my @keys = keys %$beats;
        $beat_number = $keys[ int rand @keys ];
    }
    return $beats->{$beat_number};
}

=head2 all_beats

  $all = $beats->all_beats($drummer);

Return all the known beats as a hash reference, given a required
B<drummer> object.

=cut

sub all_beats {
    my ($self, $drummer) = @_;
    return $self->_beats($drummer);
}

sub _beats {
    my ($self, $d) = @_;
    my %beats = (

        1 => {
            name => "ONE AND SEVEN & FIVE AND THIRTEEN",
            beat => sub {
                $d->sync_patterns(
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
                    duration  => $d->sixteenth,
                ),
            },
        },

        3 => {
            name => "TINY HOUSE",
            beat => sub {
                $d->sync_patterns( # 123456789ABCDEF0
                    $d->kick    => ['1000100010001000'],
                    $d->open_hh => ['0010001000100010'],
                    duration  => $d->sixteenth,
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
