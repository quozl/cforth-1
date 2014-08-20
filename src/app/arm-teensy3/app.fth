\ Load file for application-specific Forth extensions

fl ../../lib/misc.fth
fl ../../lib/dl.fth

0 ccall: spins       { i.nspins -- }
1 ccall: wfi         { -- }
2 ccall: get-msecs   { -- n }
3 ccall: a@          { i.pin -- n }
4 ccall: p!          { i.val i.pin -- }
5 ccall: p@          { i.pin -- n }
6 ccall: m!          { i.mode i.pin -- }
7 ccall: get-usecs   { -- n }
8 ccall: delay       { n -- }
9 ccall: bye         { -- }

fl ../../platform/arm-teensy3/watchdog.fth
fl ../../platform/arm-teensy3/timer.fth
fl ../../platform/arm-teensy3/pcr.fth
fl ../../platform/arm-teensy3/gpio.fth

d# 13 value d13
d# 14 value d14

: be-in      0 swap m!  ;
: be-out     1 swap m!  ;
: be-pullup  2 swap m!  ;

: go-on      1 swap p!  ;
: go-off     0 swap p!  ;

: wait       d# 125 ms  ;

: lb
   d13 be-out  d14 be-out
   begin
      d13 go-on  wait  d13 go-off
      d14 go-on  wait  d14 go-off
      key?
   until
;

\ Replace 'quit' to make CForth auto-run some application code
\ instead of just going interactive.
: app  lb ." CForth" cr hex quit  ;

" app.dic" save
