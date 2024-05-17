AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

all: bin/pianificatore

bin/pianificatore: obj/main.o obj/io.o obj/itoa.o  obj/atoi.o
	ld $(LD_FLAGS) obj/main.o obj/io.o obj/itoa.o  obj/atoi.o -o bin/pianificatore

#-------------------------- 

obj/main.o: src/main.s
	as $(AS_FLAGS) $(DEBUG) src/main.s -o obj/main.o

obj/io.o: src/io.s
	as $(AS_FLAGS) $(DEBUG) src/io.s -o obj/io.o

obj/itoa.o: src/itoa.s
	as $(AS_FLAGS) $(DEBUG) src/itoa.s -o obj/itoa.o

obj/atoi.o: src/atoi.s
	as $(AS_FLAGS) $(DEBUG) src/atoi.s -o obj/atoi.o

#-------------------------

clean:
	rm -f obj/*.o bin/pianificatore