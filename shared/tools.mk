WARN_ERROR=-Werror
HOST_WARNINGS=$(WARN_ERROR) -pedantic-errors -Wfatal-errors -Wall  -Wextra -Wno-unused-parameter -Wshadow -limagequant
HOST_CFLAGS=$(HOST_WARNINGS) -O3 $(EXTRA_CFLAGS)

$(PROGRAM): out bin $(OBJS) 
	gcc $(OBJS) -o $(PROGRAM) $(LIBS)

-include $(OBJS:.o=.d)

out/%.o: %.c
	gcc -c $(HOST_CFLAGS) $< -o $@ 
	@gcc -MM $(HOST_CFLAGS) $*.c > out/$*.d
	@mv -f out/$*.d out/$*.d.tmp
	@sed  's/^.*\:/out\/&/' < out/$*.d.tmp > out/$*.d
	@rm -f out/$*.d.tmp

out:
	mkdir out

bin:
	mkdir bin

clean:
	rm -rf out bin *~
