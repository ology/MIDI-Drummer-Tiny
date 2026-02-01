#!perl
use Test::More;

use_ok 'MIDI::Drummer::Tiny::Grooves';

my $grooves = new_ok 'MIDI::Drummer::Tiny::Grooves';

subtest all => sub {
    my $all = $grooves->all_grooves;
    isa_ok $all, 'HASH', 'all_grooves';
    ok exists($all->{1}), '1 exists';
    is $all->{1}{name}, 'ONE AND SEVEN & FIVE AND THIRTEEN', '1 named';
    isa_ok $all->{1}{groove}, 'CODE', '1 groove';
};

subtest search => sub {
    my $found = $grooves->search({}, { cat => 'rock' });
    isa_ok $found, 'HASH', 'all_grooves';
    ok exists($found->{10}), '10 exists';
    is $found->{10}{name}, 'ROCK 1', '10 named';
    isa_ok $found->{10}{groove}, 'CODE', '10 groove';
};

done_testing();
