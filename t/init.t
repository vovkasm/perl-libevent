use strict;
use warnings;
use Test::More;

use LibEvent;

my $base = LibEvent::EventBase->new;

is $base->loop, 1, "no events registered";

ok 1;

done_testing;
