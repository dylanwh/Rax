#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "rax.h"

typedef rax * Rax;

struct RaxIterator {
    SV *rax_ref;
    raxIterator it;
};

typedef struct RaxIterator * Rax__Iterator;

static void rax_free_callback(void *data)
{
    SvREFCNT_dec( (SV *) data );
}

MODULE = Rax PACKAGE = Rax PREFIX = rax_

PROTOTYPES: DISABLE

Rax
rax_new(package)
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
rax_remove(self, key)
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
rax_exists(self, key)
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
rax_find(self, key)
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
rax_show(self)
    Rax self
CODE:
    raxShow(self);

size_t
rax_size(self)
    Rax self
CODE:
    RETVAL = raxSize(self);
OUTPUT:
    RETVAL

void
rax_DESTROY(self)
    Rax self
CODE:
    raxFreeWithCallback(self, rax_free_callback);

Rax::Iterator
rax_iter(self)
    Rax self
PREINIT:
    struct RaxIterator *ctx;
CODE:
    ctx = malloc(sizeof(struct RaxIterator));
    ctx->rax_ref = newRV_inc(SvRV(ST(0)));
    raxStart(&ctx->it, self);
    RETVAL = ctx;
OUTPUT:
    RETVAL

MODULE = Rax PACKAGE = Rax::Iterator PREFIX = rax_iter_

void
rax_iter_seek(self, op, ...)
    Rax::Iterator self
    const char *op
PREINIT:
    const char *element = NULL;
    STRLEN len = 0;
    int rv;
CODE:
    if (items > 2) {
        element = SvPVutf8(ST(2), len);
    }
    rv = raxSeek(&self->it, op, (unsigned char *) element, len);
    if (rv == 0) {
        if (errno == 0) {
            croak("\"%s\" is not a valid operation for Rax::Iterator->seek()", op);
        }
        else {
            croak("Rax ran out of memory");
        }
    }

void
rax_iter_DESTROY(self)
    Rax::Iterator self
CODE:
    raxStop(&self->it);
    SvREFCNT_dec(self->rax_ref);
    free(self);
