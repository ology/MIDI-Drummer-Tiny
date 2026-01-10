#!/usr/bin/perl
use strict;
use warnings;

use MIDI::Drummer::Tiny ();
use MIDI::Drummer::Tiny::Beats ();

my $search = shift || 'rock';

my $d = MIDI::Drummer::Tiny->new(
    kick  => 36,
    snare => 40,
);
my $beats = MIDI::Drummer::Tiny::Beats->new;

# my $all = $beats->all_beats;
my $all = $beats->search($search, $d);

for my $n (keys %$all) {
    my $beat = $beats->get_beat($n, $d);
    # print $beat->{name}, "\n";
    $beat->{beat}->() for 1 .. 4;
}

$d->play_with_timidity;