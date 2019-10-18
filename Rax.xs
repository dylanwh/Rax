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
    dTHX;
    SvREFCNT_dec( (SV *) data );
}

static void rax_init_from_hash(pTHX_ rax *rt, HV *init)
{
    SV *value;
    char *buffer;
    I32 len;

    while (value = hv_iternextsv(init, &buffer, &len)) {
        raxInsert(rt,
                (unsigned char *)buffer,
                len,
                (void *)newSVsv(value),
                NULL);
    }
}

MODULE = Rax PACKAGE = Rax PREFIX = rax_

PROTOTYPES: DISABLE

Rax
rax_new(package, ...)
    SV *package = NO_INIT
PREINIT:
    SV *init = NULL;
CODE:
    (void)package;
    RETVAL = raxNew();

    if (items > 1) {
        init = ST(1);
        if (!SvROK(init)) {
            croak("Rax->new() takes an optional hash ref");
        }
        switch (SvTYPE(SvRV(init))) {
            case SVt_PVHV:
                rax_init_from_hash(aTHX_ RETVAL, (HV *) SvRV(init));
                break;
            default:
                break;
        }
    }
OUTPUT:
    RETVAL

void
rax_DESTROY(self)
    Rax self
CODE:
    raxFreeWithCallback(self, rax_free_callback);

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
PPCODE:
    /* PPCODE to prevent mortalizing self... */
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
    XPUSHs(ST(0));

bool
rax_iter_compare(self, op, ...)
    Rax::Iterator self
    const char *op;
PREINIT:
    const char *element = NULL;
    STRLEN len = 0;
    int rv;
CODE:
    if (items > 2) {
        element = SvPVutf8(ST(2), len);
    }
    rv = raxCompare(&self->it, op, (unsigned char *) element, len);
    RETVAL = rv ? true : false;
OUTPUT:
    RETVAL

SV *
rax_iter_key(self)
    Rax::Iterator self
CODE:
    RETVAL = newSVpvn((const char *)self->it.key, self->it.key_len);
OUTPUT:
    RETVAL

void
rax_iter_value(self)
    Rax::Iterator self
PREINIT:
    SV *value = &PL_sv_undef;
PPCODE:
    /* I am only using PPCODE here because I don't think I want self->it.data to be mortalized */
    if (self->it.data != NULL)
        value = (SV *) self->it.data;
    XPUSHs(value);

void
rax_iter_next(self)
    Rax::Iterator self
PREINIT:
    int rv;
    raxIterator *iter;
PPCODE:
    iter = &self->it;
    rv = raxNext(iter);
    switch (GIMME_V) {
        case G_VOID:
            break;
        case G_SCALAR:
            if (rv) {
                XPUSHs(sv_2mortal(newSVpvn((const char *)iter->key, iter->key_len)));
            }
            else {
                XPUSHs(&PL_sv_undef);
            }
            break;
        case G_ARRAY:
            if (rv) {
                EXTEND(sp, 2);
                PUSHs( sv_2mortal(newSVpvn((const char *)iter->key, iter->key_len)));
                PUSHs( iter->data != NULL ? (SV *) iter->data : &PL_sv_undef );
            }
            break;
        default:
            /* shouldn't happen, don't care if it does. */
            break;
    }

void
rax_iter_prev(self)
    Rax::Iterator self
PREINIT:
    int rv;
    raxIterator *iter;
PPCODE:
    iter = &self->it;
    rv = raxPrev(iter);
    switch (GIMME_V) {
        case G_VOID:
            break;
        case G_SCALAR:
            if (rv) {
                XPUSHs(sv_2mortal(newSVpvn((const char *)iter->key, iter->key_len)));
            }
            else {
                XPUSHs(&PL_sv_undef);
            }
            break;
        case G_ARRAY:
            if (rv) {
                EXTEND(sp, 2);
                PUSHs( sv_2mortal(newSVpvn((const char *)iter->key, iter->key_len)));
                PUSHs( iter->data != NULL ? (SV *) iter->data : &PL_sv_undef );
            }
            break;
        default:
            /* shouldn't happen, don't care if it does. */
            break;
    }

bool
rax_iter_eof(self)
    Rax::Iterator self
CODE:
    RETVAL = raxEOF(&self->it) ? true : false;
OUTPUT:
    RETVAL

void
rax_iter_DESTROY(self)
    Rax::Iterator self
CODE:
    raxStop(&self->it);
    SvREFCNT_dec(self->rax_ref);
    free(self);
