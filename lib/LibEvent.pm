package LibEvent;
use 5.014;
use strict;
use warnings;

our $VERSION = '0.01';

our (@ISA, @EXPORT);
BEGIN {
    require Exporter;
    @ISA = 'Exporter';
    @EXPORT = qw(
        EVLOOP_ONCE EVLOOP_NONBLOCK
        EV_TIMEOUT EV_READ EV_WRITE EV_SIGNAL EV_PERSIST EV_ET
    );
}

require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

1;

__END__
