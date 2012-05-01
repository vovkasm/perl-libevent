#include <event2/event.h>
#include "libevent.h"
#include "xshelper.h"

MODULE = LibEvent PACKAGE = LibEvent

MODULE = LibEvent PACKAGE = LibEvent::EventBase
PROTOTYPES: DISABLE

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
  PPCODE:
    RETVAL = event_reinit(ev_base);

void 
DESTROY(event_base_t* ev_base)
  PPCODE:
    event_base_free(ev_base);
