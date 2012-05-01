#include <event2/event.h>
#include "libevent.h"
#include "xshelper.h"

static void libevent_event_callback(evutil_socket_t s, short events, void* arg) {
    croak("Yes!");
}

MODULE = LibEvent PACKAGE = LibEvent
PROTOTYPES: DISABLED

BOOT:
{
    HV* stash = gv_stashpv("LibEvent", GV_ADD);

    newCONSTSUB(stash, "EVLOOP_ONCE",               newSViv(EVLOOP_ONCE));
    newCONSTSUB(stash, "EVLOOP_NONBLOCK",           newSViv(EVLOOP_NONBLOCK));

    newCONSTSUB(stash, "EV_TIMEOUT",    newSViv(EV_TIMEOUT));
    newCONSTSUB(stash, "EV_READ",       newSViv(EV_READ));
    newCONSTSUB(stash, "EV_WRITE",      newSViv(EV_WRITE));
    newCONSTSUB(stash, "EV_SIGNAL",     newSViv(EV_SIGNAL));
    newCONSTSUB(stash, "EV_PERSIST",    newSViv(EV_PERSIST));
    newCONSTSUB(stash, "EV_ET",         newSViv(EV_ET));
}

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

void 
DESTROY(event_base_t* ev_base)
  PPCODE:
    event_base_free(ev_base);

void
event_new(event_base_t* ev_base, evutil_socket_t s, short events, CV* callback_cv)
  PPCODE:
    event_t* ev = event_new(ev_base, s, events, libevent_event_callback, callback_cv);

    SV* obj = sv_newmortal();
    sv_setref_pv( obj, "LibEvent::Event", ev );
    PUSHs(obj);

MODULE = LibEvent PACKAGE = LibEvent::Event
PROTOTYPES: DISABLED

int
add(event_t* ev, int timeout)
  CODE:
    const struct timeval tv = { timeout, 0 };
    RETVAL = event_add(ev, &tv);
  OUTPUT:
    RETVAL

void
DESTROY(event_t* ev)
  PPCODE:
    event_free(ev);

