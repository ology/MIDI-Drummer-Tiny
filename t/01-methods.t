#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

use_ok 'MIDI::Drummer';

my $md = MIDI::Drummer->new(
);
isa_ok $md, 'MIDI::Drummer';

is $md->beats, 4, 'beats';
is $md->divisions, 4, 'divisions';

done_testing();
