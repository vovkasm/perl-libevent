use strict;
use warnings;
use Test::More;

use_ok('LibEvent',':all');

is EVLOOP_ONCE(), 0x1;
is EVLOOP_NONBLOCK(), 0x2;

like LibEvent::get_version(), qr/2\..+/, "version string ok and version is 2.*";

done_testing;
