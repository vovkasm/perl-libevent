package LibEvent;
use 5.014;
use strict;
use warnings;

our $VERSION = '0.01';

use Sub::Exporter -setup => {
    exports => [qw(
        EVLOOP_ONCE EVLOOP_NONBLOCK
        EV_TIMEOUT EV_READ EV_WRITE EV_SIGNAL EV_PERSIST EV_ET
        libevent_get_version
        )],
};

require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

1;

=pod

=head1 NAME

LibEvent - Perl bindings with libevent2

=head1 SYNOPSIS

    use LibEvent;

    my $base = LibEvent::EventBase->new;

    my $ev1 = $base->timer_new(LibEvent::EV_TIMEOUT, sub {
            my ($ev, $events) = @_;
            print "Timer1\n";
            });

    $ev1->add(1.5);

    $base->loop;

=head1 DESCRIPTION

LibEvent is a thin wrapper around libevent2 functionality.

=head1 CONSTANTS
        
=head2 EVLOOP_ONCE

=head2 EVLOOP_NONBLOCK

=head2 EV_TIMEOUT

=head2 EV_READ

=head2 EV_WRITE

=head2 EV_SIGNAL

=head2 EV_PERSIST

=head2 EV_ET

=head1 FUNCTIONS

=head2 LibEvent::get_version

    my $ver = LibEvent::get_version();
    my $ver = LibEvent->get_version;
    my $ver = libevent_get_version();

Return libevent's version string.

=head1 CAVEATS

Any from libevent2 + our own ;-)

=head1 ALTERNATIVES

=over 4

=item L<EV>

=item L<Event::Lib>

=back

=head1 SEE ALSO

=over 4

=item L<http://www.wangafu.net/~nickm/libevent-book>

Fast portable non-blocking network programming with Libevent

=back

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

__END__
