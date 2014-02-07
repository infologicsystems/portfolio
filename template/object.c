/* %W% %G% */
/*-
  File: object.c
  Last Modification: 92/08/12
  Author: Michael Moscovitch
  Description: object oriented C code
  Project:
  History:
*/
static char _sccsid[] = "%Z%%M% %I% %G%";

#include <stdio.h>
#include <string.h>
#include <memdbg.h>
#include <chead.h>
#include "object.h"

/* create object and allocate storage */
struct objectstruct *object_construct()
{
    struct objectstruct *ob;

    ob = MEM_NEW("ob", struct objectstruct);
    if (ob == NULL)
	return NULL;
    object_clear(ob);
    return ob;
}

/* destroy object and free any storage allocated */
void object_destroy(ob)
    struct objectstruct *ob;
{
    object_free(ob);
    free(ob);
}

/* initialize all properties on the object.
clear all the fields in the object structure */
void object_clear(ob)
    struct objectstruct *ob;
{
}

/* free all memory allocated to the object except for the object itself */
void object_free(ob)
    struct objectstruct *ob;
{
    object_clear(ob);
}

