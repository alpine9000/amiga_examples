MAKEADF=./out/makeadf
SRCS=makeadf.c
HOST_WARNINGS=-pedantic-errors -Wfatal-errors -Wall -Werror -Wextra -Wno-unused-parameter -Wshadow
HOST_CFLAGS=$(HOST_WARNINGS)

$(MAKEADF): out bin $(SRCS)
	gcc $(HOST_CFLAGS) $(SRCS) -o $(MAKEADF)

out:
	mkdir out

bin:
	mkdir bin

clean:
	rm -r out bin