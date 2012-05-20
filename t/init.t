use strict;
use warnings;
use Test::More;

use LibEvent;

my $base = LibEvent::EventBase->new;

is $base->loop, 1, "no events registered";

like $base->get_method, qr/^(kqueue|epoll|select|poll)$/, "event_base->get_method returns anything useful";

ok 1;

done_testing;
