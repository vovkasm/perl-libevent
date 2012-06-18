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

Block event loop until at least one event became active, then exit after process all active events.

See L<LibEvent::EventBase/$base-E<gt>loop($flags)>.

=head2 EVLOOP_NONBLOCK

Do not block (see which events are ready now, process of the highest-priority ones, then exit).

See L<LibEvent::EventBase/$base-E<gt>loop($flags)>.

=head2 EV_TIMEOUT

Indicates that a timeout has occurred.

=head2 EV_READ

Wait for a handle to become readable.

=head2 EV_WRITE

Wait for a handle to become writeable.

=head2 EV_SIGNAL

Wait for a signal to be raised.

=head2 EV_PERSIST

Persistent event: won't get removed automatically when activated.

=head2 EV_ET

Select edge-triggered behavior, if supported by the backend.

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
