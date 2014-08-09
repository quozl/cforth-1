\ Load file for application-specific Forth extensions

fl ../../lib/misc.fth
fl ../../lib/dl.fth

0 ccall: i2c-start   { i.wr i.slave i.alen a.abuf i.dlen a.dbuf -- }
1 ccall: i2c-wait    { -- i.status }
2 ccall: i2c-init    { -- }
3 ccall: spins       { i.nspins -- }
4 ccall: wfi         { -- }
5 ccall: get-msecs   { -- n }

\ Mimics the tether version
: i2c-op  ( dbuf dlen abuf alen slave op -- result )
   swap 2swap swap   ( dbuf dlen  op slave  alen abuf )
   2>r  2swap swap   ( op slave  dlen dbuf  r: alen abuf )
   2r>  2swap        ( op slave  alen abuf  dlen dbuf  )
   i2c-start  i2c-wait
;
: ?result  ( result -- )  0< abort" I2C Error"  ;
: i2c-read  ( adr len slave -- )  0 0 rot 0 i2c-op  ?result  ;
: i2c-write  ( adr len slave -- )  0 0 rot 1 i2c-op  ?result  ;

\ Replace 'quit' to make CForth auto-run some application code
\ instead of just going interactive.
: app  ." CForth" cr hex quit  ;

\ " ../objs/tester" $chdir drop

" app.dic" save
