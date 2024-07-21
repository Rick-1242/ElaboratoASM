AS_FLAGS = --32 
DEBUG = --gdwarf-2
LD_FLAGS = -m elf_i386
SRC_FILES = $(wildcard src/*.s)
OBJ_FILES = $(patsubst src/%.s, obj/%.o, $(SRC_FILES))
TARGET = bin/pianificatore

#--------------------------------------

all: $(TARGET)

$(TARGET): $(OBJ_FILES)
	ld $(LD_FLAGS) -o $@ $^

obj/%.o: src/%.s
	as $(AS_FLAGS) $(DEBUG) -o $@ $^

#--------------------------------------

clean:
	rm -f obj/*.o $(TARGET)

.PHONY: all clean

