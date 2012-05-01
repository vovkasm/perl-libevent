use strict;
use warnings;
use Test::More;

use_ok('LibEvent');

is EVLOOP_ONCE(), 0x1;
is EVLOOP_NONBLOCK(), 0x2;

done_testing;
