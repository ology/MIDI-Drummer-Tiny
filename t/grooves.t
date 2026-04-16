#!perl
use Test::More;

use_ok 'MIDI::Drummer::Tiny::Grooves';

my $grooves = new_ok 'MIDI::Drummer::Tiny::Grooves';

subtest all => sub {
    my $all = $grooves->all_grooves;
    isa_ok $all, 'HASH', 'all_grooves';
    ok exists($all->{1}), '1 exists';
    is $all->{1}{name}, 'ONE AND SEVEN & FIVE AND THIRTEEN', '1 named';
    isa_ok $all->{1}{groove}, 'ARRAY', '1 groove';
};

subtest search => sub {
    my $got = $grooves->search({ cat => 'house' });
    isa_ok $got, 'HASH', 'search all';
    is scalar(keys %$got), 9, 'size';
    my $n = 27;
    ok exists($got->{$n}), 'exists';
    is $got->{$n}{name}, 'DIRTY HOUSE', 'named';
    isa_ok $got->{$n}{groove}, 'ARRAY', 'groove';
    $got = $grooves->search({ name => 'deep' });
    isa_ok $got, 'HASH', 'search subset';
    is scalar(keys %$got), 3, 'size';
};

done_testing();
