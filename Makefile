SRCDIR 	= source
SRCS	= $(wildcard source/*.c)
OBJS_TEENSY_40	=  $(SRCS:.c=_teensy_40.o) source/boot_hdr_teensy_40.ao source/boot_teensy_40.ao source/vector_teensy_40.ao source/glitch_teensy_40.ao
OBJS_TEENSY_41	=  $(SRCS:.c=_teensy_41.o) source/boot_hdr_teensy_41.ao source/boot_teensy_41.ao source/vector_teensy_41.ao source/glitch_teensy_41.ao

PREFIX	= arm-none-eabi
CC		= $(PREFIX)-gcc
OBJCOPY	= $(PREFIX)-objcopy
CFLAGS 	= -mcpu=cortex-m7 -mthumb -Os -Wall -fno-builtin
LDFLAGS = -nostartfiles -nostdlib
ASFLAGS	=

all: output/test_teensy_40.hex output/test_teensy_41.hex

output/test_teensy_40.hex: test_teensy_40.hex
	-rm -f source/*_teensy_40.o
	-rm -f source/*_teensy_40.ao
	-rm -f output/test_teensy_40.elf output/test_teensy_40.hex
	mkdir -p output
	mv test_teensy_40.elf output/test_teensy_40.elf
	mv test_teensy_40.hex output/test_teensy_40.hex

output/test_teensy_41.hex: test_teensy_41.hex
	-rm -f source/*_teensy_41.o
	-rm -f source/*_teensy_41.ao
	-rm -f output/test_teensy_41.elf output/test_teensy_41.hex
	mkdir -p output
	mv test_teensy_41.elf output/test_teensy_41.elf
	mv test_teensy_41.hex output/test_teensy_41.hex

%.hex: %.elf
	$(OBJCOPY) -O ihex $^ $@

# %_teensy_40.hex: %_teensy_40.elf
# 	$(OBJCOPY) -O ihex $^ $@

test_teensy_40.elf: $(OBJS_TEENSY_40)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS) -T linker_teensy_40.x 

%_teensy_40.o: %.c
	$(CC) $(CFLAGS) -DTEENSY_40 -c $< -o $@

%_teensy_40.ao: %.sx
	$(CC) $(ASFLAGS) -DTEENSY_40 -c $< -o $@

# %_teensy_41.hex: %_teensy_41.elf
# 	$(OBJCOPY) -O ihex $^ $@

test_teensy_41.elf: $(OBJS_TEENSY_41)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS) -T linker_teensy_41.x 

%_teensy_41.o: %.c
	$(CC) $(CFLAGS) -DTEENSY_41 -c $< -o $@

%_teensy_41.ao: %.sx
	$(CC) $(ASFLAGS) -DTEENSY_41 -c $< -o $@

clean: 
	-rm -f source/*.o
	-rm -f source/*.ao
	-rm -rf output