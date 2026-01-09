#!/usr/bin/perl
use strict;
use warnings;

use MIDI::Drummer::Tiny;
use MIDI::Drummer::Tiny::Beats;

my $d = MIDI::Drummer::Tiny->new;
my $f = MIDI::Drummer::Tiny::Beats->new;

my $beat = $f->get_beat($d);
$beat->{beat}->() for 1 .. 4;

$d->play_with_timidity;