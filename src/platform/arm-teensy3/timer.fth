: ms  ( ms -- )
   get-msecs +
   begin
      dup get-msecs - 0<
   until
   drop
;

0 value timestamp
: t(  get-msecs to timestamp  ;
: )t  get-msecs timestamp - .d ." ms"  ;
