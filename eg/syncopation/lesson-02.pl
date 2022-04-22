#!/usr/bin/env perl
use strict;
use warnings;

use List::Util qw(max);
use lib map { "$ENV{HOME}/sandbox/$_/lib" } qw(MIDI-Drummer-Tiny);
use MIDI::Drummer::Tiny;

my $bpm = shift || 100;

my $d = MIDI::Drummer::Tiny->new(
    bpm    => $bpm,
    file   => "$0.mid",
    kick   => 'n36',
    snare  => 'n40',
    reverb => 15,
);

$d->sync(
    \&hhat,
    \&snare,
    \&kick,
);

$d->write;

sub hhat {
    steady( $d->pedal_hh );
}

sub snare {
    bitwise( $d->snare );
}

sub kick {
    bitwise( $d->kick );
}

sub steady {
    my ( $instrument, $opts ) = @_;

    $opts->{repeat}   ||= 4;
    $opts->{duration} ||= $d->quarter;
    $opts->{digits}   ||= [ 0 .. 15 ];

    my $limit;
    if ( $opts->{patterns} ) {
        my $width = length $opts->{patterns}->[0];
        $limit = $width * $opts->{patterns}->@*;
    }
    else {
        my $max = max $opts->{digits}->@*;
        my $width = length sprintf '%.b', $max;
        $limit = ++$max * $width * $opts->{repeat};
    }

    for my $n ( 1 .. $limit ) {
        $d->note( $opts->{duration}, $instrument );
    }
}

sub bitwise {
    my ( $instrument, $opts ) = @_;

    $opts->{negate}   ||= 0;
    $opts->{repeat}   ||= 4;
    $opts->{duration} ||= $d->quarter;
    $opts->{digits}   ||= [ 0 .. 15 ];
    $opts->{ifthen}   ||= sub {
        $d->note( $opts->{duration}, $instrument );
    };
    $opts->{ifelse}   ||= sub {
        $d->rest( $opts->{duration} );
    };

    my ( $width, @items );
    if ( $opts->{patterns} ) {
        $width = length $opts->{patterns}->[0];
        @items = $opts->{patterns}->@*;
    }
    else {
        $width = length sprintf '%.b', max $opts->{digits}->@*;
        @items = $opts->{digits}->@*;
    }

    for my $i (@items) {
        my $pattern = $opts->{patterns} ? $i : sprintf '%.*b', $width, $i;
        $pattern =~ tr/01/10/ if $opts->{negate};

        for ( 1 .. $opts->{repeat} ) {
            for my $bit ( split //, $pattern ) {
                if ($bit) {
                    $opts->{ifthen}->();
                }
                else {
                    $opts->{ifelse}->();
                }
            }
        }
    }
}
