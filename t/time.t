use strict;
use warnings;
use Test::More;
use Carp 'confess';
use Time::HiRes 'time';

use LibEvent ':all';

my $base = LibEvent::EventBase->new;

{
    is sprintf("%0.1f",$base->now), sprintf("%0.1f",time()), '$base->now is okey outside loop';

    my $tm1;
    my $ev1 = $base->timer_new(0, sub {
            my ($ev, $events) = @_;
            is sprintf("%0.1f",$base->now), sprintf("%0.1f",time()), '$base->now is okey';
        });
    $ev1->add(0.5); # 0.5 second 

    $tm1 = time;
    is $base->loop, 1;

    is sprintf("%0.1f",$base->now), sprintf("%0.1f",time()), '$base->now is okey outside loop';
}

done_testing;
