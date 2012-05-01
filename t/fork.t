use strict;
use warnings;
use Test::More;

use LibEvent;

my $base = LibEvent::EventBase->new;

pipe(my $rh, my $wh) or die("Can't create pipe: $!");

if (my $child_pid = fork) {
    my $st = <$rh>;
    is $st, "CHILD OK\n", "child ok";
}
else {
    $base->reinit;
    print $wh "CHILD OK\n";
    exit;
}

done_testing;
