#include <event2/event.h>
#include <event2/event_struct.h>
#include <sys/time.h>
#include "libevent.h"
#include "xshelper.h"

typedef struct pevent_timer {
    SV* pbase;
    SV* callback;
    struct event ev;
} pevent_timer_t;

typedef struct pevent_io {
    SV* pbase;
    SV* callback;
    SV* io_sv;
    struct event ev;
} pevent_io_t;

typedef struct pevent_sig {
    SV* pbase;
    SV* callback;
    int signum;
    struct event ev;
} pevent_sig_t;

static void libevent_timer_callback(evutil_socket_t s, short events, void* arg) {
    PERL_UNUSED_ARG(s);
    dTHX;
    dSP;

    SV* sv_ev = (SV*)arg;
    pevent_timer_t *pev = (pevent_timer_t*)SvIV(sv_ev);

    ENTER;
    SAVETMPS;

    PUSHMARK(SP);
    mXPUSHs(newRV(sv_ev));
    mXPUSHs(newSViv(events));
    PUTBACK;

    call_sv(pev->callback, G_VOID|G_DISCARD);

    FREETMPS;
    LEAVE;
}

static void libevent_io_callback(evutil_socket_t s, short events, void* arg) {
    PERL_UNUSED_ARG(s);
    dTHX;
    dSP;

    SV* sv_ev = (SV*)arg;
    pevent_io_t *pev = (pevent_io_t*)SvIV(sv_ev);

    ENTER;
    SAVETMPS;

    PUSHMARK(SP);
    mXPUSHs(newRV(sv_ev));
    mXPUSHs(newSViv(events));
    PUTBACK;

    call_sv(pev->callback, G_VOID|G_DISCARD);

    FREETMPS;
    LEAVE;
}

static void libevent_sig_callback(evutil_socket_t s, short events, void* arg) {
    PERL_UNUSED_ARG(s);
    dTHX;
    dSP;

    SV* sv_ev = (SV*)arg;
    pevent_sig_t *pev = (pevent_sig_t*)SvIV(sv_ev);

    ENTER;
    SAVETMPS;

    PUSHMARK(SP);
    mXPUSHs(newRV(sv_ev));
    mXPUSHs(newSViv(events));
    PUTBACK;

    call_sv(pev->callback, G_VOID|G_DISCARD);

    FREETMPS;
    LEAVE;
}

MODULE = LibEvent PACKAGE = LibEvent
PROTOTYPES: DISABLED

BOOT:
{
    HV* stash = gv_stashpv("LibEvent", GV_ADD);

    newCONSTSUB(stash, "EVLOOP_ONCE",       newSViv(EVLOOP_ONCE));
    newCONSTSUB(stash, "EVLOOP_NONBLOCK",   newSViv(EVLOOP_NONBLOCK));

    newCONSTSUB(stash, "EV_TIMEOUT",    newSViv(EV_TIMEOUT));
    newCONSTSUB(stash, "EV_READ",       newSViv(EV_READ));
    newCONSTSUB(stash, "EV_WRITE",      newSViv(EV_WRITE));
    newCONSTSUB(stash, "EV_SIGNAL",     newSViv(EV_SIGNAL));
    newCONSTSUB(stash, "EV_PERSIST",    newSViv(EV_PERSIST));
    newCONSTSUB(stash, "EV_ET",         newSViv(EV_ET));
}

MODULE = LibEvent PACKAGE = LibEvent
PROTOTYPES: DISABLED

void
get_version(...)
  ALIAS:
    libevent_get_version = 1
  PPCODE:
    PERL_UNUSED_VAR(ix);
    const char *version = event_get_version();
    mXPUSHs( newSVpv(version, 0) );

INCLUDE: base.xsi
INCLUDE: simple-events.xsi
