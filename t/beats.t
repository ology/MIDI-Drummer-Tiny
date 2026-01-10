#!perl

use Test::More;

use MIDI::Drummer::Tiny ();

use_ok 'MIDI::Drummer::Tiny::Beats';

my $drummer = MIDI::Drummer::Tiny->new;

my $beats = new_ok 'MIDI::Drummer::Tiny::Beats';

my $all = $beats->all_beats;

isa_ok $all, 'HASH', 'all_beats';
ok exists($all->{1}), '1 exists';
is $all->{1}{name}, 'ONE AND SEVEN & FIVE AND THIRTEEN', '1 named';
isa_ok $all->{1}{beat}, 'CODE', '1 beat sub';

done_testing();