#!/usr/bin/perl
use strict;
use warnings;

use MIDI::Drummer::Tiny::Beats;

my $beats = MIDI::Drummer::Tiny::Beats->new;

my $all = $beats->all_beats;

for my $n (1 .. keys %$all) {
    my $beat = $beats->get_beat($n);
    # print $beat->{name}, "\n";
    $beat->{beat}->() for 1 .. 4;
}

$d->play_with_timidity;