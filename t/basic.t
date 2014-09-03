use strict;
use warnings;
use Test::More;
use Test::Fatal;
use Carp 'confess';
use Time::HiRes 'time';

use LibEvent ':all';

my $base = LibEvent::EventBase->new;

{
    {
        my $ev = $base->timer_new(0, sub { fail("Should not be called") });
        ok !$ev->pending, "not pending yet";
        $ev->add(2);
        ok $ev->pending, "now pending";
    }
    is $base->loop, 1;
}

{
    my $tm1;
    my $ev1;
    $ev1 = $base->timer_new(0, sub {
            my ($ev, $events) = @_;
            ok($events && EV_TIMEOUT, "events mask with EV_TIMEOUT");
            is("$ev","$ev1", "we got same event object as event_new");
            is(sprintf("%.2f",time - $tm1), "0.50", "timer after 0.5s");
            undef $ev1; # TODO: can we fix this? (it cycle $ev1 and they destroys after $base :-(
        });
    ok !$ev1->pending, "not yet scheduled";
    $ev1->add(0.5); # 0.5 second 
    ok $ev1->pending, "now waiting";

    $tm1 = time;
    is $base->loop, 1;
}

{ # persistent
    my $cnt = 2;
    my $ev;
    $ev = $base->timer_new(EV_PERSIST, sub {
            $cnt--;
            is $ev->events, EV_TIMEOUT|EV_PERSIST, "events mask is consistent";
            ok $ev->pending, "still pending";
            undef $ev if $cnt == 0;
        });
    ok !$ev->pending, "not pending yet";
    $ev->add(0.05);
    ok $ev->pending, "now pending";

    is $base->loop, 1;
    is $cnt, 0, "counter now empty";
}

{
    my $cnt = 2;
    my $ev;
    $ev = $base->timer_new(EV_PERSIST, sub {
            $cnt--;
            ok shift->pending, "still pending";
            is $base->break, 0, "break return success status";
        });
    ok !$ev->pending, "not pending yet";
    $ev->add(0.05);
    ok $ev->pending, "now pending";

    is $base->loop, 0;
    is $cnt, 1, "only one event fire";
}

{
    # re-add
    my $cnt = 0;
    my $ev = $base->timer_new(0, sub {
            my $e = shift;
            ++$cnt;
            if ($cnt == 1) {
                ok 1, "First timer invocatin, re-add it";
                ok !$e->pending, "not yet pending again";
                $e->add(0.05);
                ok $e->pending, "now pending again";
            }
        });
    ok !$ev->pending, "not yet pending";
    $ev->add(0.05);
    ok $ev->pending, "now pending";

    is $base->loop, 1;
    is $cnt, 2, "two events gotten";
}

{
    # add, remove, add
    my $cnt = 0;
    my $ev = $base->timer_new(EV_PERSIST, sub {
            my $e = shift;
            ++$cnt;
            if ($cnt == 1) {
                ok 1, "First timer invocatin, remove it";
                $e->del;
            }
            if ($cnt == 3) {
                ok 1, "Third timer invocation, break loop";
                $base->break;
            }
        });
    $ev->add(0.05);

    is $base->loop, 1;
    is $cnt, 1, "first event gotten";

    $ev->del; # second remove just for fun
    $ev->add(0.05);
    is $base->loop, 0;
    is $cnt, 3, "3 events was gotten";

    $ev->del; # remove before destroy
}

my $timer1_cb_called;
sub timer1_cb {
    my ($ev, $events) = @_;
    if ($timer1_cb_called) {
        fail("timer1_cb called more than once");
    }
    $timer1_cb_called = 1;
}

{
    my $ev = $base->timer_new(0, \&timer1_cb);
    $ev->add(0.05);
    is $base->loop, 1, "now exit";
}

{
    my $ev = $base->timer_new(0, "not_existing_sub");
    $ev->add(0.05);
    like(
        exception { $base->loop; },
        qr/Undefined subroutine &main::not_existing_sub/
    );
}

done_testing;
