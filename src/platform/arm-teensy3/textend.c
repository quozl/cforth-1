// Edit this file to include C routines that can be called as Forth words.
// See "ccalls" below.

// This is the only thing that we need from forth.h
#define cell long

// Prototypes

cell get_msecs();
cell wfi();
cell spins();

cell ((* const ccalls[])()) = {
    (cell (*)())spins,        // Entry # 3
    (cell (*)())wfi,          // Entry # 4
    (cell (*)())get_msecs,    // Entry # 5
};

// Forth words to call the above routines may be created by:
//
//  system also
//  0 ccall: sum      { i.a i.b -- i.sum }
//  1 ccall: byterev  { s.in -- s.out }
//
// and could be used as follows:
//
//  5 6 sum .
//  p" hello"  byterev  count type
