EXE=num2str
AS= as --32
LD= ld -m elf_i386
FLAGS=	-gstabs
OBJ=num2str.o

$(EXE): $(OBJ)
	$(LD) -o $(EXE) $(OBJ)

num2str.o: num2str.s
	$(AS) $(FLAGS) -o num2str.o num2str.s

clean:
	rm -f *.o $(EXE) core
