/* %W% %G% */
/*-
  File: object.h
  Last Modification: 92/08/12
  Author: Michael Moscovitch
  Description: Object oriented C code
  Project:
  History:
*/
/* %Z%%M% %I% %G% */

#ifndef _object_h
#define _object_h

#include <ansipro.h>

struct objectstruct {
    /* object variables */
};

struct objectstruct *object_construct PROTO((void));
void object_destroy PROTO((struct objectstruct * ob));
void object_clear PROTO((struct objectstruct * ob));
void object_free PROTO((struct objectstruct * ob));

#endif				/* _object_h */
