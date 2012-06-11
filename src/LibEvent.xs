#include <event2/event.h>
#include <event2/event_struct.h>
#include <sys/time.h>
#include "libevent.h"
#include "xshelper.h"

typedef struct pevent_timer {
    SV* callback;
    struct event ev;
} pevent_timer_t;

typedef struct pevent_io {
    SV* callback;
    SV* io_sv;
    struct event ev;
} pevent_io_t;

typedef struct pevent_sig {
    SV* callback;
    int signum;
    struct event ev;
} pevent_sig_t;

static void libevent_timer_callback(evutil_socket_t s, short events, void* arg) {
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

SV*
get_version()
  CODE:
    const char *version = event_get_version();
    RETVAL = newSVpv(version, 0);
  OUTPUT:
    RETVAL

MODULE = LibEvent PACKAGE = LibEvent::EventBase
PROTOTYPES: DISABLED

void
new(SV* klass,... )
  PPCODE:
    const char* classname = SvPV_nolen_const(klass);
    event_base_t* ev_base = event_base_new();
    
    SV* obj = sv_newmortal();
    sv_setref_pv( obj, classname, ev_base );
    PUSHs(obj);

int
reinit(event_base_t* ev_base)
  CODE:
    RETVAL = event_reinit(ev_base);
  OUTPUT:
    RETVAL

int
loop(event_base_t* ev_base,... )
  CODE:
    int flags = 0;
    if (items > 1) flags = SvIV(ST(1)); 
    RETVAL = event_base_loop(ev_base, flags);
  OUTPUT:
    RETVAL

int
break(event_base_t* ev_base)
  CODE:
    RETVAL = event_base_loopbreak(ev_base);
  OUTPUT:
    RETVAL

SV*
get_method(event_base_t* ev_base)
  CODE:
    RETVAL = newSVpv(event_base_get_method(ev_base), 0);
  OUTPUT:
    RETVAL

void 
DESTROY(event_base_t* ev_base)
  PPCODE:
    event_base_free(ev_base);

void
event_new(event_base_t* ev_base, SV* io_sv, short events, SV* cb_sv)
  PPCODE:
    if ((events & (EV_READ|EV_WRITE)) == 0) {
        croak("event_new: io events should containts EV_READ or EV_WRITE flags");
    }
    events &= ~EV_SIGNAL;

    SV* obj = sv_newmortal();
    pevent_io_t* pev = (pevent_io_t*)malloc(sizeof(pevent_io_t));
    sv_setref_pv( obj, "LibEvent::EvIO", pev );
    SV* sv_ev = SvRV(obj);
    
    pev->callback = newSVsv(cb_sv);

    evutil_socket_t s;
    pev->io_sv = newSVsv(io_sv);
    PerlIO* io = IoIFP(sv_2io(pev->io_sv));
    if (!io) {
        free(pev);
        croak("event_new: you should pass file descriptor");
    }
    s = PerlIO_fileno(io);
    if (s < 0) {
        free(pev);
        croak("event_new: you should pass opened file descriptor");
    }

    if (event_assign(&pev->ev, ev_base, s, events, libevent_io_callback, sv_ev) != 0) {
        free(pev);
        croak("Can't assign event part of pevent. event_assign failed.");
    }

    PUSHs(obj);

void
timer_new(event_base_t* ev_base, short events, SV* cb_sv)
  PPCODE:
    events &= ~(EV_SIGNAL|EV_READ|EV_WRITE);
    events |= EV_TIMEOUT;

    SV* obj = sv_newmortal();
    pevent_timer_t* pev = (pevent_timer_t*)malloc(sizeof(pevent_timer_t));
    sv_setref_pv( obj, "LibEvent::EvTimer", pev );
    SV* sv_ev = SvRV(obj);

    pev->callback = newSVsv(cb_sv);

    if (event_assign(&pev->ev, ev_base, -1, events, libevent_timer_callback, sv_ev) != 0) {
        croak("Can't assign event part of pevent. event_assign failed.");
    }

    PUSHs(obj);

void
signal_new(event_base_t* ev_base, int signum, short events, SV* cb_sv)
  PPCODE:
    events &= ~(EV_TIMEOUT|EV_READ|EV_WRITE);
    events |= EV_SIGNAL;

    SV* obj = sv_newmortal();
    pevent_sig_t* pev = (pevent_sig_t*)malloc(sizeof(pevent_sig_t));
    sv_setref_pv( obj, "LibEvent::EvSignal", pev );
    SV* sv_ev = SvRV(obj);

    pev->callback = newSVsv(cb_sv);
    pev->signum = signum;

    if (event_assign(&pev->ev, ev_base, signum, events, libevent_sig_callback, sv_ev) != 0) {
        croak("Can't assign event part of pevent. event_assign failed.");
    }

    PUSHs(obj);

MODULE = LibEvent PACKAGE = LibEvent::EvTimer
PROTOTYPES: DISABLED

int
add(pevent_timer_t* pev, NV timeout)
  CODE:
    struct timeval tv;
    tv.tv_sec = (time_t)timeout;
    tv.tv_usec = (suseconds_t)((timeout - ((NV)tv.tv_sec)) * 1000000);
    RETVAL = event_add(&pev->ev, &tv);
  OUTPUT:
    RETVAL

short
events(pevent_timer_t* pev)
  CODE:
    RETVAL = event_get_events(&pev->ev);
  OUTPUT:
    RETVAL

void
DESTROY(pevent_timer_t* pev)
  PPCODE:
    event_del(&pev->ev);
    SvREFCNT_dec(pev->callback);
    free(pev);

MODULE = LibEvent PACKAGE = LibEvent::EvIO
PROTOTYPES: DISABLED

int
add(pevent_io_t* pev, NV timeout)
  CODE:
    struct timeval tv;
    tv.tv_sec = (time_t)timeout;
    tv.tv_usec = (suseconds_t)((timeout - ((NV)tv.tv_sec)) * 1000000);
    RETVAL = event_add(&pev->ev, &tv);
  OUTPUT:
    RETVAL

short
events(pevent_io_t* pev)
  CODE:
    RETVAL = event_get_events(&pev->ev);
  OUTPUT:
    RETVAL

SV*
io(pevent_io_t* pev)
  CODE:
    RETVAL = newSVsv(pev->io_sv);
  OUTPUT:
    RETVAL

void
DESTROY(pevent_io_t* pev)
  PPCODE:
    event_del(&pev->ev);
    if (pev->io_sv != NULL) SvREFCNT_dec(pev->io_sv);
    SvREFCNT_dec(pev->callback);
    free(pev);

MODULE = LibEvent PACKAGE = LibEvent::EvSignal
PROTOTYPES: DISABLED

int
add(pevent_sig_t* pev, NV timeout)
  CODE:
    struct timeval tv;
    tv.tv_sec = (time_t)timeout;
    tv.tv_usec = (suseconds_t)((timeout - ((NV)tv.tv_sec)) * 1000000);
    RETVAL = event_add(&pev->ev, &tv);
  OUTPUT:
    RETVAL

short
events(pevent_sig_t* pev)
  CODE:
    RETVAL = event_get_events(&pev->ev);
  OUTPUT:
    RETVAL

int
signum(pevent_sig_t* pev)
  CODE:
    RETVAL = pev->signum;
  OUTPUT:
    RETVAL

void
DESTROY(pevent_timer_t* pev)
  PPCODE:
    event_del(&pev->ev);
    SvREFCNT_dec(pev->callback);
    free(pev);


