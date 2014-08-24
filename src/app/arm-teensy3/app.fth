\ Load file for application-specific Forth extensions

fl ../../lib/misc.fth
fl ../../lib/dl.fth

#0 ccall: spins       { i.nspins -- }
#1 ccall: wfi         { -- }
#2 ccall: get-msecs   { -- n }
#3 ccall: a@          { i.pin -- n }
#4 ccall: p!          { i.val i.pin -- }
#5 ccall: p@          { i.pin -- n }
#6 ccall: m!          { i.mode i.pin -- }
#7 ccall: get-usecs   { -- n }
#8 ccall: delay       { n -- }
#9 ccall: bye         { -- }
#10 ccall: /nv        { -- n }
#11 ccall: nv-base    { -- n }
#12 ccall: nv-length  { -- n }
#13 ccall: nv@        { i.adr -- i.val }
#14 ccall: nv!        { i.val i.adr -- }

fl ../../platform/arm-teensy3/watchdog.fth
fl ../../platform/arm-teensy3/timer.fth
fl ../../platform/arm-teensy3/pcr.fth
fl ../../platform/arm-teensy3/gpio.fth

: be-in      0 swap m!  ;
: be-out     1 swap m!  ;
: be-pullup  2 swap m!  ;

: go-on      1 swap p!  ;
: go-off     0 swap p!  ;

: wait  ( ms -- )
   get-msecs +
   begin
      dup get-msecs - 0<  key?  or
   until
   drop
;

: lb
   d be-out  e be-out
   begin
      d go-on  d# 125 wait  d go-off
      e go-on  d# 125 wait  e go-off
      key?
   until
;

\ a non-volatile buffer for source code
: .d%          ( n -- )  push-decimal  (.) type [char] % emit  pop-base  ;
: .usage       ( -- )    nv-length d# 100 * /nv / .d%  ;
: nv$          ( -- $ )  nv-base nv-length  ;
: .nv          ( -- )    nv$ type  ;
: nv-dump      ( -- )    nv$ 1+ cdump  ;
: nv-dump-all  ( -- )    nv-base /nv dump  ;
: nv-evaluate  ( -- )    nv$  ['] evaluate  catch  ?dup  if  3drop  then  ;

\ add a line to non-volatile buffer
: nv  ( text ( )
   nv-length            ( pos )
   eol parse            ( pos adr len )
   dup 0=               ( pos adr len empty )
   if  3drop exit  then ( pos adr len )
   bounds do            ( pos )
      i c@ over         ( pos char pos )
      nv!               ( pos )
      1+                ( pos+1 )
   loop                 ( pos+len )
   h# a over nv!        ( pos+len+1 )
   1+ 0 swap nv!        ( )
;

\ scan backwards for a line break
: strrnl  ( a.begin a.end -- a.match )
   swap  do  i c@ h# a =  if  i leave  then  -1 +loop
;

\ forget last line
: nv-undo  ( -- )
   nv$ 2-               ( adr len )
   dup 0< if  2drop ." no more"  exit  then  ( adr len )
   bounds               ( adr adr )
   strrnl               ( adr )
   nv-base - 1+         ( pos ) \ of first char in line to remove
   0 swap nv!
;

\ wip entire non-volatile buffer
: nv-wipe      ( -- )    0 0 nv!  ;

\ FIXME: a way to prevent execution in case of obvious bug
\ now the only way is to reflash with nv-evaluate removed
: app
   nv-evaluate
   ." CForth" cr hex quit
;

" app.dic" save
