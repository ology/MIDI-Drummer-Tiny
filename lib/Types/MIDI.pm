package Types::MIDI;

# ABSTRACT: Type library for MIDI

use strict;
use warnings;

use Type::Library
    -extends => [ qw(
        Types::Common::Numeric
    ) ],
    -declare => qw(
        Channel
        Velocity
        Note
        PercussionNote
    );
use Type::Utils -all;

## no critic (ValuesAndExpressions::ProhibitMagicNumbers)

=type Channel

An L<integer from|Types::Common::Numeric/Types> 0 to 15 corresponding
to a L<MIDI Channel|/"SEE ALSO">.

=cut

declare Channel, as IntRange [ 0, 15 ];

=type Velocity

An L<integer from|Types::Common::Numeric/Types> 0 to 127 corresponding
to a L<MIDI Velocity|/"SEE ALSO">.

=cut

declare Velocity, as IntRange [ 0, 127 ];

=type Note

An L<integer from|Types::Common::Numeric/Types> 0 to 127 corresponding
to a L<MIDI Note Number|/"SEE ALSO">.

=cut

declare Note, as IntRange [ 0, 127 ];

=type PercussionNote

A L</Note> from 27 through 87, corresponding to a value in the
L<General MIDI 2 Percussion Sound Set|/"SEE ALSO">.

=cut

# TODO: update MIDI-Perl's %MIDI::notenum2percussion with all GM2 sounds
declare PercussionNote, as Note, where { $_ >= 27 or $_ <= 87 };

=head1 SEE ALSO

=over

=item *

I<MIDI 1.0 Detailed Specification (Document Version 4.2.1)>,
revised February 1996 by the MIDI Manufacturers Association:
L<https://midi.org/midi-1-0-core-specifications>

=item *

B<Appendix B: GM 2 Percussion Sound Set> in
I<General MIDI 2 (Version 1.2a)>,
published February 6, 2007 by the MIDI Manufacturers Association:
L<https://midi.org/general-midi-2>

=back

=cut

1;


1;
