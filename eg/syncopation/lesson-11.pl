#!/usr/bin/env perl
use strict;
use warnings;

use Algorithm::Combinatorics qw(variations_with_repetition);
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
    \&snare,
    \&kick,
    \&hhat,
);

$d->write;

sub snare {
    combinatorial( $d->snare, {
        vary => {
            0 => sub {
                $d->note( $d->eighth, $d->snare );
                $d->note( $d->eighth, $d->snare );
            },
            1 => sub {
                $d->note( $d->eighth, $d->snare );
                $d->note( $d->sixteenth, $d->snare );
                $d->note( $d->sixteenth, $d->snare );
            },
#            2 => sub {
#                $d->note( $d->sixteenth, $d->snare );
#                $d->note( $d->sixteenth, $d->snare );
#                $d->note( $d->eighth, $d->snare );
#            },
        },
    });
}

sub kick {
    steady( $d->kick );
}

sub hhat {
    steady( $d->closed_hh );
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

sub combinatorial {
    my ( $instrument, $opts ) = @_;

    $opts->{beats}    ||= 4;
    $opts->{repeat}   ||= 4;
    $opts->{duration} ||= $d->quarter;
    $opts->{vary}     ||= {
        0 => sub { $d->rest( $opts->{duration} ) },
        1 => sub { $d->note( $opts->{duration}, $instrument ) },
    };

    my @items = $opts->{patterns}
        ? $opts->{patterns}->@*
        : sort map { join '', @$_ } variations_with_repetition( [ keys $opts->{vary}->%* ], $opts->{beats} );

    for my $pattern (@items) {
        for ( 1 .. $opts->{repeat} ) {
            for my $bit ( split //, $pattern ) {
                $opts->{vary}{$bit}->();
            }
        }
    }
}
