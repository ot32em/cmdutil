git svn show-externals | awk 'BEGIN{FS=" "}/^[^#]/{split($1, a, "http");printf("git svn clone http%s ./%s%s\n", a[2], a[1], $2)}' | bash
