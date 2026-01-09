package MIDI::Drummer::Tiny::Beats;

use Moo;
use strictures 2;
use MIDI::Util qw(dura_size);
use namespace::clean;

=head1 SYNOPSIS

  use MIDI::Drummer::Tiny;
  use MIDI::Drummer::Tiny::Beats;

  my $d = MIDI::Drummer::Tiny->new;
  my $f = MIDI::Drummer::Tiny::Beats->new;

  my $beat = $f->get_beat($d);
  $beat->{beat}->();

=head1 DESCRIPTION

Return the common beats, as listed in the "Pocket Operations", that
are L<linked below|/SEE ALSO>.

=cut

=head1 METHODS

=head2 new

  $f = MIDI::Drummer::Tiny::beats->new;

Return a new C<MIDI::Drummer::Tiny::Beats> object.

=head2 get_beat

  $beat = $f->get_beat($drummer, $beat);

Return either the given beat subroutine or a random beat.

A B<drummer> object and a B<beat> number are required.

=cut

sub get_beat {
    my ($self, $drummer, $beat_number) = @_;
    my $beats = $self->_beats($drummer);
    unless ($beat_number) {
        my @keys = keys %$beats;
        $beat_number = $keys[ int rand @keys ];
    }
    return $beats->{$beat_number};
}

sub _beats {
    my ($self, $d) = @_;
    my %beats = (

        1 => {
            name => "ONE AND SEVEN & FIVE AND THIRTEEN",
            beat => sub {
                $d->note($d->quarter, $d->kick);
                $d->note($d->eighth, $d->snare);
                $d->note($d->dotted_quarter, $d->kick);
                $d->note($d->quarter, $d->snare);
                # $d->sync_patterns(
                #     $d->snare => [qw(0000 1000 0000 1000)],
                #     $d->kick  => [qw(1000 0010 0000 0000)],
                #     duration  => $d->sixteenth,
                # ),
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
