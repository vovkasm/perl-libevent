use strict;
use warnings;
use Test::More;
use Carp 'confess';
use Time::HiRes 'time';
use IO::Handle;
use autodie;

use LibEvent;

my $base = LibEvent::EventBase->new;

{
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
            my ($ev, $events) = @_;
            fail("Timeout detected!") if $events & EV_TIMEOUT;
            my $msg;
            is $ev->io->sysread($msg, 1024), 5, 'Message length same as sended';
            is $msg, "Hello", 'Message text is right';
            $cnt--;
        });
    $ev->add(2);

    is $base->loop, 1;

    is $cnt, 0, "read handler was called";
}

done_testing;
