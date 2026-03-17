ASSEMBLER = nasm
ASM_FLAGS = -f elf64
ASM_SRC = asm-curl.asm
OBJECT = asm-curl.o
TARGET = asm-curl

all: $(TARGET)

$(OBJECT): $(ASM_SRC)
	$(ASSEMBLER) $(ASM_FLAGS) $(ASM_SRC)

$(TARGET): $(OBJECT)
	ld -o $(TARGET) $(OBJECT)
	./$(TARGET)

clean:
	rm -f $(OBJECT) $(TARGET)
