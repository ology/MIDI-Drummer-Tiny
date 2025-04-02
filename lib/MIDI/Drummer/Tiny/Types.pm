package MIDI::Drummer::Tiny::Types;

# ABSTRACT: Type library for MIDI::Drummer::Tiny

use strict;
use warnings;

use Type::Library
    -extends => [ qw(
        Types::MIDI
        Types::Music
        Types::Common::String
    ) ],
    -declare => qw(
        Duration
        MIDI_File
        Soundfont_File
    );
use Type::Utils -all;
use Types::Standard   qw(FileHandle);
use Types::Path::Tiny qw(File Path);

use MIDI::Util qw(midi_dump);

=type Duration

A L<non-empty string|Types::Common::String/Types> corresponding to
a L<duration in MIDI::Simple|MIDI::Simple/"Parameters for n/r/noop">.

=cut

my %length = %{ midi_dump('length') };
declare Duration, as NonEmptyStr, where { exists $length{$_} };

=type MIDI_File

The name of the MIDI file to be written.

=cut

declare MIDI_File, as Path | FileHandle;

=type Soundfont_File

The name of the MIDI soundfont file to use.

=cut

declare Soundfont_File, as File;

1;
