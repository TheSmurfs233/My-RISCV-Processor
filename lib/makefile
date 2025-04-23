CROSS = riscv64-unknown-elf-
CC = $(CROSS)gcc

# OPTIMIZATION = -Os          # 代码体积优化（嵌入式推荐）
# OPTIMIZATION = -O2       # 性能优化（可选）
# OPTIMIZATION = -O0    # 调试模式（开发阶段使用）
# $(OPTIMIZATION) \

CFLAGS = -march=rv32im -mabi=ilp32 -nostdlib 
LDFILE = linker.ld
OBJCOPY = $(CROSS)objcopy

TARGET = x.elf
SOURCE = start.s main.c sys_timer.c seg.c
# SOURCE = start.s main.c 

.PHONY: all clean

all: text.hex data.hex

$(TARGET):$(SOURCE)
	$(CC) $(CFLAGS) -T $(LDFILE) -o $@ $(SOURCE)

text.bin: $(TARGET)
	$(OBJCOPY) --dump-section .text=$@ $<
	
# data.bin: $(TARGET)
# 	$(OBJCOPY) --dump-section .data=$@ $<
data.bin: $(TARGET)
	$(OBJCOPY) -O binary --only-section=.rodata --only-section=.sdata --only-section=.data $< $@
text.hex: text.bin
	hexdump -v -e '1/4 "%08x\n"'  $< > $@
data.hex: data.bin
	hexdump -v -e '1/4 "%08x\n"'  $< > $@
	
clean:
	rm -f $(TARGET) text.bin data.bin text.hex data.hex