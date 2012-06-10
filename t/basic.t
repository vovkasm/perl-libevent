use strict;
use warnings;
use Test::More;
use Carp 'confess';
use Time::HiRes 'time';

use LibEvent ':all';

my $base = LibEvent::EventBase->new;

{
    {
        my $ev = $base->event_new(-1, 0, sub { fail("Should not be called") });
        $ev->add(2);
    }
    is $base->loop, 1;
}

{
    my $tm1;
    my $ev1;
    $ev1 = $base->event_new(-1, EV_TIMEOUT, sub {
            my ($ev, $events) = @_;
            ok($events && EV_TIMEOUT, "events mask with EV_TIMEOUT");
            is("$ev","$ev1", "we got same event object as event_new");
            is(sprintf("%.2f",time - $tm1), "0.50", "timer after 0.5s");
            undef $ev1; # TODO: can we fix this? (it cycle $ev1 and they destroys after $base :-(
        });
    $ev1->add(0.5); # 0.5 second 

    $tm1 = time;
    is $base->loop, 1;
}

{ # persistent
    my $cnt = 2;
    my $ev;
    $ev = $base->event_new(-1, EV_TIMEOUT|EV_PERSIST, sub {
            $cnt--;
            is $ev->events, EV_TIMEOUT|EV_PERSIST, "events mask is consistent";
            undef $ev if $cnt == 0;
        });
    $ev->add(0.1);

    is $base->loop, 1;
    is $cnt, 0, "counter now empty";
}

{
    my $cnt = 2;
    my $ev;
    $ev = $base->event_new(-1, EV_TIMEOUT|EV_PERSIST, sub {
            $cnt--;
            is $base->break, 0, "break return success status";
        });
    $ev->add(0.1);

    is $base->loop, 0;
    is $cnt, 1, "only one event fire";
}

done_testing;
