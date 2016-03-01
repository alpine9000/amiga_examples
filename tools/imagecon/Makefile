SRCS=imagecon.c
HOST_WARNINGS=-pedantic-errors -Wfatal-errors -Wall -Werror -Wextra -Wno-unused-parameter -Wshadow
HOST_CFLAGS=$(HOST_WARNINGS)

imagecon: $(SRCS)
	gcc $(HOST_CFLAGS) $(SRCS) -o imagecon -lpng