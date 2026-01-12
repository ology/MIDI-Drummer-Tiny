#!/usr/bin/perl
use strict;
use warnings;

use MIDI::Drummer::Tiny ();
use MIDI::Drummer::Tiny::Grooves ();

my $search = shift || 'rock';

my $d = MIDI::Drummer::Tiny->new(
    kick  => 36,
    snare => 40,
);
my $grooves = MIDI::Drummer::Tiny::Grooves->new(drummer => $d);

# my $all = $grooves->all_grooves;
my $all = $grooves->search(cat => $search);

for my $n (keys %$all) {
    my $groove = $grooves->get_groove($n);
    # print $groove->{name}, "\n";
    $groove->{groove}->() for 1 .. 4;
}

$d->play_with_timidity;