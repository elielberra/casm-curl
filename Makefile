ASSEMBLER = nasm
ASM_FLAGS = -f elf64 -g
ASM_SRC = asm-curl.asm
OBJECT = asm-curl.o
TARGET = asm-curl

all: $(TARGET)

$(OBJECT): $(ASM_SRC)
	$(ASSEMBLER) $(ASM_FLAGS) $(ASM_SRC)

$(TARGET): $(OBJECT)
	ld -o $(TARGET) $(OBJECT)

clean:
	rm -f $(OBJECT) $(TARGET)
