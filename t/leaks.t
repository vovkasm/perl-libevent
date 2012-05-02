use strict;
use warnings;
use Test::More;

unless (eval "require Test::LeakTrace; 1") {
    plan skip_all => "Test::LeakTrace not found, skipped";
}
Test::LeakTrace->import();

use LibEvent;

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

done_testing;
