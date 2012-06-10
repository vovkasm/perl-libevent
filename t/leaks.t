use strict;
use warnings;
use Test::More;
use IO::Handle;
use autodie;

unless (eval "require Test::LeakTrace; 1") {
    plan skip_all => "Test::LeakTrace not found, skipped";
}
Test::LeakTrace->import();

use LibEvent ':all';

no_leaks_ok(sub {
    my $base = LibEvent::EventBase->new;

    my $ev1 = $base->event_new(-1, 0, sub { 'noop' });
    $ev1->add(0.1); # one second 

    {
        my $ev2 = $base->event_new(-1, 0, sub { 'noop' });
        $ev2->add(2);
    }

    $base->loop;
});

no_leaks_ok(sub {
    my $base = LibEvent::EventBase->new;

    pipe(my $in, my $out);
    $out->autoflush(1);
    $in->blocking(0);
    $out->blocking(0);

    my $tm = $base->event_new(-1, EV_TIMEOUT, sub {
            print $out "Hello";
        });
    $tm->add(0.2);

    my $cnt = 1;
    my $ev = $base->event_new($in, EV_READ|EV_TIMEOUT, sub {
            my ($ev0, $events) = @_;
            fail("Timeout detected!") if $events & EV_TIMEOUT;
            my $msg;
            $ev0->io->sysread($msg, 1024);
            fail("Something not correct in test") unless $msg eq "Hello";
            $cnt--;
        });
    $ev->add(2);

    $base->loop;
});

done_testing;
