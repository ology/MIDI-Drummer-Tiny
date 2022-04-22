#!/usr/bin/env perl
use strict;
use warnings;

# Adapted from the book "Progressive Steps to Syncopation for the Modern Drummer"
# https://www.amazon.com/dp/0882847953

use Algorithm::Combinatorics qw(variations_with_repetition);
use lib map { "$ENV{HOME}/sandbox/$_/lib" } qw(MIDI-Drummer-Tiny MIDI-Util);
use MIDI::Drummer::Tiny;
use MIDI::Util qw(dura_size);

my $bpm = shift || 100;

my $d = MIDI::Drummer::Tiny->new(
    bpm    => $bpm,
    file   => "$0.mid",
    kick   => 'n36',
    snare  => 'n40',
    reverb => 15,
);

$d->sync(
    \&snare,
    \&kick,
    \&hhat,
);

$d->write;

sub snare {
    $d->combinatorial( $d->snare );
}

sub kick {
    $d->steady( $d->kick );
}

sub hhat {
    $d->steady( $d->closed_hh );
}
