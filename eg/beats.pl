#!/usr/bin/perl
use strict;
use warnings;

use MIDI::Drummer::Tiny;
use MIDI::Drummer::Tiny::Beats;

my $d = MIDI::Drummer::Tiny->new;
my $b = MIDI::Drummer::Tiny::Beats->new;
my $beats = $b->all_beats($d);

for my $n (1 .. keys %$beats) {
    my $beat = $b->get_beat($d, $n);
    $beat->{beat}->() for 1 .. 4;
}

$d->play_with_timidity;