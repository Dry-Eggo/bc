#pragma once

/*
  This is the header file containing runtime bridges from BC code to C
  this contains:
    ~ C Version of BC types
*/

// integers
typedef signed char i8;
typedef unsigned char u8;
typedef signed short i16;
typedef unsigned short u16;
typedef signed int i32;
typedef unsigned int u32;
typedef signed long int i64;
typedef unsigned long int u64;
// string
typedef char *cstr;
typedef void *ptr;
