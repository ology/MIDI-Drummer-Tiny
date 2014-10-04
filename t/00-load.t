#!perl
use Test::More;

BEGIN {
    use_ok 'MIDI::Drummer';
}

diag("Testing MIDI::Drummer $MIDI::Drummer::VERSION, Perl $], $^X");

done_testing();
