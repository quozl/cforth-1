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

\ Replace 'quit' to make CForth auto-run some application code
\ instead of just going interactive.
: app  ." CForth" cr hex quit  ;

\ " ../objs/tester" $chdir drop

" app.dic" save
