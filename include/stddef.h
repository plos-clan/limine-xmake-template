#ifndef STDDEF_H
#define STDDEF_H 1

typedef __SIZE_TYPE__ size_t;
typedef __PTRDIFF_TYPE__ ptrdiff_t;

#undef NULL
#define NULL ((void *)0)

#undef offsetof
#define offsetof(s, m) __builtin_offsetof(s, m)

#endif
