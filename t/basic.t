use strict;
use warnings;
use Test::More;

use LibEvent;

my $base = LibEvent::EventBase->new;

my $ev1 = $base->event_new(-1, 0, sub { die("Timer!") });
$ev1->add(2); # two seconds

$base->loop;

ok 1;

done_testing;
