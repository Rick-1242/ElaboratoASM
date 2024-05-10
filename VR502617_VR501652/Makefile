AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

all: bin/pianificatore

bin/pianificatore: obj/main.o obj/IO.o
	ld $(LD_FLAGS) obj/main.o obj/IO.o -o bin/pianificatore

obj/main.o: src/main.s
	as $(AS_FLAGS) $(DEBUG) src/main.s -o obj/main.o

obj/itoa.o: src/IO.s
	as $(AS_FLAGS) $(DEBUG) src/IO.s -o obj/IO.o


clean:
	rm -f obj/*.o bin/pianificatore