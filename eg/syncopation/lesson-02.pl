#!/usr/bin/env perl
use strict;
use warnings;

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

my $counter = 0;

$d->sync(
    \&snare,
    \&kick,
    \&hhat,
);

$d->write;

sub snare {
    combinatorial( $d->snare );
}

sub kick {
    combinatorial( $d->kick );
}

sub hhat {
    steady( $d->pedal_hh );
}

sub steady {
    my ( $instrument, $opts ) = @_;

    $opts->{duration} ||= $d->quarter;

    for my $n ( 1 .. $counter ) {
        $d->note( $opts->{duration}, $instrument );
    }
}

sub combinatorial {
    my ( $instrument, $opts ) = @_;

    $opts->{negate}   ||= 0;
    $opts->{beats}    ||= 4;
    $opts->{repeat}   ||= 4;
    $opts->{duration} ||= $d->quarter;
    $opts->{vary}     ||= {
        0 => sub { $d->rest( $opts->{duration} ) },
        1 => sub { $d->note( $opts->{duration}, $instrument ) },
    };

    my @items = $opts->{patterns}
        ? $opts->{patterns}->@*
        : sort map { join '', @$_ }
            variations_with_repetition( [ keys $opts->{vary}->%* ], $opts->{beats} );

    for my $pattern (@items) {
        $pattern =~ tr/01/10/ if $opts->{negate};

        for ( 1 .. $opts->{repeat} ) {
            for my $bit ( split //, $pattern ) {
                $opts->{vary}{$bit}->();
                $counter += dura_size( $opts->{duration} );
            }
        }
    }
}
