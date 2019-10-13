#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "rax.h"

typedef rax * Rax;

static void rax_free_callback(void *data)
{
    SvREFCNT_dec( (SV *) data );
}

MODULE = Rax PACKAGE = Rax PREFIX = rax_

PROTOTYPES: DISABLE

Rax
new(package)
    SV *package = NO_INIT
CODE:
    (void)package;
    RETVAL = raxNew();
OUTPUT:
    RETVAL

SV *
insert(self, key, ...)
    Rax self
    SV *key
PREINIT:
    SV *value = NULL;
    SV *prev_value = NULL;
    int rv;
    STRLEN len;
    const char *buffer;
CODE:
    buffer = SvPVutf8(key, len);

    if (items > 2 && SvOK(ST(2)))
        value = newSVsv(ST(2));

    rv = raxInsert(self, (unsigned char *)buffer, len, (void *)value, (void **) &prev_value);
    if ( rv == 0 && prev_value != NULL && SvOK(prev_value)) {
        RETVAL = prev_value;
    }
    else {
        RETVAL = &PL_sv_undef;
    }
OUTPUT:
    RETVAL

SV *
remove(self, key)
    Rax self
    SV *key
PREINIT:
    int rv;
    SV *prev_value = NULL;
    STRLEN len;
    const char *buffer;
CODE:
    buffer = SvPVutf8(key, len);
    rv = raxRemove(self, (unsigned char *)buffer, len, (void **) &prev_value);
    if ( rv == 1 && prev_value != NULL && SvOK(prev_value)) {
        RETVAL = prev_value;
    }
    else {
        RETVAL = &PL_sv_undef;
    }
OUTPUT:
    RETVAL

bool
exists(self, key)
    Rax self
    SV *key
PREINIT:
    STRLEN len;
    const char *buffer;
    void *value;
CODE:
    buffer = SvPVutf8(key, len);
    value = raxFind(self, (unsigned char *)buffer, len);
    RETVAL = value != raxNotFound;
OUTPUT:
    RETVAL

SV *
find(self, key)
    Rax self
    SV *key
PREINIT:
    STRLEN len;
    const char *buffer;
    void *value;
CODE:
    buffer = SvPVutf8(key, len);
    value = raxFind(self, (unsigned char *)buffer, len);
    if (value != NULL && value != raxNotFound) {
        RETVAL = newSVsv((SV *) value);
    }
    else {
        RETVAL = &PL_sv_undef;
    }
OUTPUT:
    RETVAL

void
show(Rax self)
PREINIT:
    SV *self_sv;
    const char *self_sv_str;
    STRLEN len;
CODE:
    self_sv = ST(0);
    self_sv_str = SvPV(self_sv, len);
    printf("self: %s\n", self_sv_str);
    raxShow(self);

size_t
size(Rax self)
CODE:
    RETVAL = raxSize(self);
OUTPUT:
    RETVAL

void
DESTROY(Rax self)
    CODE:
        raxFreeWithCallback(self, rax_free_callback);


MODULE = Rax PACKAGE = Rax::Iterator PREFIX = rax_iter_



