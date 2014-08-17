: ms  ( ms -- )
   get-msecs +
   begin
      dup get-msecs - 0<
   until
   drop
;
