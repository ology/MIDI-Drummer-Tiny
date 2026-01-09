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

TBD

=cut

=head1 METHODS

=head2 new

  $f = MIDI::Drummer::Tiny::beats->new;

Return a new C<MIDI::Drummer::Tiny::Beats> object.

=head2 get_beat

 $beat = $f->get_beat($drummer_obj, $beat_number);

Return either the given beat subroutine or a random beat.

A B<drummer_object> and a B<beat_number> are required.

=cut

sub get_beat {
    my ($self, $drummer) = @_;
    my $beats = $self->_beats($drummer);
    my @keys = keys %$beats;
    my $beat = $keys[ int rand @keys ];
    return $beats->{$beat};
}

sub _beats {
    my ($self, $d) = @_;
    my %beats = (

        1 => sub { # ONE AND SEVEN & FIVE AND THIRTEEN
            $d->note($d->quarter, $d->kick);
            $d->note($d->eighth, $d->snare);
            $d->note($d->dotted_quarter, $d->kick);
            $d->note($d->quarter, $d->snare);
        },

    );
    return \%beats;
}

1;

__END__

=head1 SEE ALSO

TBD

=cut
