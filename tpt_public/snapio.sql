prompt Taking a &1 second snapshot...

@@snapper "stats,gather=sw,sinclude=physical,winclude=db file" &1 1 "select sid from v$session"
