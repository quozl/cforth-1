// Edit this file to include C routines that can be called as Forth words.
// See "ccalls" below.

// This is the only thing that we need from forth.h
#define cell long

// Prototypes

cell i2c_start();
cell i2c_wait();
cell i2c_init();
cell get_msecs();
cell wfi();
cell spins();

cell ((* const ccalls[])()) = {
    (cell (*)())i2c_start,    // Entry # 0
    (cell (*)())i2c_wait,     // Entry # 1
    (cell (*)())i2c_init,     // Entry # 2
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
