# Compilers
ASM=nasm
CC=clang
# Flags
ASM_FLAGS=-f elf64 -F dwarf -g
CC_FLAGS=-g -Wall
LD_FLAGS=-lcurl -no-pie
# Files
ASM_SRC=main.asm
ASM_OBJ=main.o
TARGET=casm-curl
C_SRC=get_sockaddr.c
C_OBJ=get_sockaddr.o

all: $(TARGET)

$(TARGET): $(ASM_OBJ) $(C_OBJ)
	$(CC) $(CC_FLAGS) -o $@ $^ $(LD_FLAGS)

$(ASM_OBJ): $(ASM_SRC)
	$(ASM) $(ASM_FLAGS) -o $@ $< 

$(C_OBJ): $(C_SRC)
	$(CC) $(CC_FLAGS) -c -o $@ $<

clean:
	rm -f $(TARGET) *.o
