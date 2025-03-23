package MIDI::Drummer::Tiny::Types;

# ABSTRACT: Type library for MIDI::Drummer::Tiny

use strict;
use warnings;

use Type::Library -extends => [ qw(
    Types::Standard
    Types::Common::Numeric
    Types::Common::String
) ],
    -declare => qw(
    MIDINote
    Duration
    PercussionNote
    );
use Type::Utils -all;

use MIDI::Util qw(midi_dump);

=type Duration

A L<non-empty string|Types::Common::String/Types> corresponding to a
L<duration in MIDI::Simple|MIDI::Simple/"Parameters for n/r/noop">.

=cut

my %length = %{ midi_dump('length') };
declare Duration, as NonEmptyStr, where { exists $length{$_} };

## no critic (ValuesAndExpressions::ProhibitMagicNumbers)

=type MIDINote

An L<integer from|Types::Common::Numeric/Types> 0 to 127 corresponding
to a L<MIDI Note Number|/"SEE ALSO">.

=cut

declare MIDINote, as IntRange [ 0, 127 ];

=type PercussionNote

A L</MIDINote> from 27 through 87, corresponding to a value in the
L<General MIDI 2 Percussion Sound Set|/"SEE ALSO">.

=cut

# TODO: update MIDI-Perl's %MIDI::notenum2percussion with all GM2 sounds
declare PercussionNote, as MIDINote, where { $_ >= 27 or $_ <= 87 };

=head1 SEE ALSO

=over

=item *

B<Channel Voice Messages: Note Number>
in I<MIDI 1.0 Detailed Specification (Document Version 4.2.1)>,
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
