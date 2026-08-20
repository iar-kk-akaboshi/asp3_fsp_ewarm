#include "core_asm.inc"
#if defined(__GNUC__) || defined(__clang__)
#define _kernel_exc_tbl __Vectors
#else
#define _kernel_exc_tbl __vector_table
#endif