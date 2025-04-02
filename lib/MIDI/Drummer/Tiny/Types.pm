package MIDI::Drummer::Tiny::Types;

# ABSTRACT: Type library for MIDI::Drummer::Tiny

use strict;
use warnings;

use Type::Library
    -extends => [ qw(
        Types::MIDI
        Types::Music
        Types::Common::Numeric
        Types::Common::String
    ) ],
    -declare => qw(
        Duration
    );
use Type::Utils -all;

use MIDI::Util qw(midi_dump);

=type Duration

A L<non-empty string|Types::Common::String/Types> corresponding to
a L<duration in MIDI::Simple|MIDI::Simple/"Parameters for n/r/noop">.

=cut

my %length = %{ midi_dump('length') };
declare Duration, as NonEmptyStr, where { exists $length{$_} };

1;
