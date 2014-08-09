\ Load file for application-specific Forth extensions

fl ../../lib/misc.fth
fl ../../lib/dl.fth

0 ccall: spins       { i.nspins -- }
1 ccall: wfi         { -- }
2 ccall: get-msecs   { -- n }

\ Replace 'quit' to make CForth auto-run some application code
\ instead of just going interactive.
: app  ." CForth" cr hex quit  ;

\ " ../objs/tester" $chdir drop

" app.dic" save
