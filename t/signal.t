use strict;
use warnings;
use Test::More;

use POSIX ();
use LibEvent;

$SIG{HUP} = "IGNORE";

my $base = LibEvent::EventBase->new;

my $tm = $base->timer_new(0, sub {
        my ($ev, $events) = @_;
        ok 1, "Ok timer called, now send HUP to self";
        kill POSIX::SIGHUP() => $$;
        ok !$ev->pending, "timer event is NOT pending";
        $ev->add(0.2);
        ok $ev->pending, "timer event is pending";
    });

my $cnt = 2;
my $sw = $base->signal_new(POSIX::SIGHUP, LibEvent::EV_PERSIST, sub {
        $cnt--;
        if ($cnt) {
            ok 1, "Just got first HUP";
        }
        else {
            ok 1, "Just got second HUP";
            $base->break;
        }
    });
    
$tm->add(0.1);
$sw->add;

is $base->loop, 0, "event loop exit";

done_testing;
