#!/usr/bin/perl
use strict;
use warnings;

use MIDI::Drummer::Tiny ();
use MIDI::Drummer::Tiny::Grooves ();

my $cat  = shift // 'House';
my $name = shift // 'DEEP';

my $d = MIDI::Drummer::Tiny->new(
    kick  => 36,
    snare => 40,
);
my $grooves = MIDI::Drummer::Tiny::Grooves->new(drummer => $d);

my $set = {};
# $set = $grooves->all_grooves;
$set = $grooves->search($set, cat => $cat) if $cat;
$set = $grooves->search($set, name => $name) if $name;

for my $n (sort keys %$set) {
    my $groove = $grooves->get_groove($n);
    print $groove->{name}, "\n";
    $groove->{groove}->() for 1 .. 4;
}

$d->play_with_timidity;