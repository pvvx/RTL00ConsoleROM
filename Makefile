LIBDIR = lib
FILENAME_PREFIX = test
ADDRESS = 0x10001000
tmp?=/tmp
#ADDRESS = 0x10000BC8

#FLASHER = stlink-v2-1
#FLASHER = stlink-v2
FLASHER = Jlink
ifeq ($(FLASHER), Jlink)
# Jlink FLASHER_SPEED ..4000 kHz
FLASHER_SPEED = 3500
else 
ifeq ($(FLASHER),stlink-v2)
# stlink-v2 FLASHER_SPEED ..1800 kHz
FLASHER_SPEED = 1800
else
# ? FLASHER_SPEED ..500 kHz ?
FLASHER_SPEED = 500
endif
endif

#FLASH_TOOLDIR = tools/openocd

CC_PARAMS = -Wall -g3 -Os -mlittle-endian -mlong-calls -mthumb -mcpu=cortex-m3 -mfloat-abi=soft -mthumb-interwork -ffunction-sections -ffreestanding -fsingle-precision-constant -fshort-wchar -fno-short-enums -Ddouble=float -nostartfiles -nostdlib  
LINK_PARAMS = -Wstrict-aliasing=0 -Wl,--gc-sections -Wl,-Map=$(FILENAME_PREFIX).map -Wl,-Trtl8710.ld -Wl,-defsym -Wl,seg0_size_1k=0x002c     
#-Wl,--entry=start_init -Wl,--section-start=.text=$(ADDRESS)
BASE_PARAMS = -DCORTEX_INTERRUPT_MAX=32 -I$(LIBDIR) -I$(LIBDIR)/cpu/rtl8710 -I$(LIBDIR)/cpu/cortex -I$(LIBDIR)/fwlib   
LIBC_PARAMS = -L$(LIBDIR)/cpu/rtl8710 -I$(LIBDIR)/libc $(LIBDIR)/libc/libc.c -DLIBC_PRINTF $(LIBDIR)/cpu/cortex/cortex.c 
#-lgcc
#$(LIBDIR)/libc/libc.c -DLIBC_PRINTF $(LIBDIR)/cpu/cortex/cortex.c
FIRMWARE_PARAMS = main.c  

#---------------------------
# User defined
#---------------------------
# + or set in PATH D:\MCU\GNU_Tools_ARM_Embedded\5.4_2016q2\bin;
GCC_PATH=d:/MCU/GNU_Tools_ARM_Embedded/5.4_2016q2/bin/
#---------------------------
# Default
#---------------------------
# Compilation tools
CROSS_COMPILE = $(GCC_PATH)arm-none-eabi-
AR = $(CROSS_COMPILE)ar
CC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
NM = $(CROSS_COMPILE)nm
LD = $(CROSS_COMPILE)ld
GDB = $(CROSS_COMPILE)gdb
SIZE = $(CROSS_COMPILE)size
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
STRIP = $(CROSS_COMPILE)strip

all: firmware

firmware:
	$(CC) $(CC_PARAMS) $(BASE_PARAMS) $(LIBC_PARAMS) $(LINK_PARAMS) $(FIRMWARE_PARAMS) -o $(FILENAME_PREFIX).elf
	$(OBJCOPY) -j .header -j .text -j .data -Obinary $(FILENAME_PREFIX).elf $(RAM1_IMAGE) ram.bin
	$(OBJCOPY) -j .fheader -j .header -j .text -j .data -Obinary $(FILENAME_PREFIX).elf $(RAM1_IMAGE) flash.bin
	$(OBJDUMP) -S $(FILENAME_PREFIX).elf >$(FILENAME_PREFIX).asm

size:
	$(SIZE) -A -x $(FILENAME_PREFIX).elf

clean:
	rm -rf *.bin test.elf test.asm flash.bin ram.bin test.map

test:
	#openocd -f interface/$(FLASHER).cfg -c "adapter_khz $(FLASHER_SPEED)" -f $(LIBDIR)/cpu/rtl8710/rtl8710.ocd -f $(LIBDIR)/cpu/cortex/cortex.ocd -c "init" -c "reset halt" -c "load_image $(FILENAME_PREFIX).bin $(ADDRESS) bin" -c "cortex_bootstrap $(ADDRESS)" -c "shutdown"

flash:
	#openocd -f interface/$(FLASHER).cfg -c "adapter_khz $(FLASHER_SPEED)" -f $(LIBDIR)/cpu/rtl8710/rtl8710.ocd -c "init" -c "reset halt" -c "rtl8710_flash_auto_erase 1" -c "rtl8710_flash_auto_verify 1" -c "rtl8710_flash_write flash.bin 0" -c "rtl8710_reboot" -c "reset run" -c shutdown

reset:
	#openocd -f interface/$(FLASHER).cfg -c "adapter_khz $(FLASHER_SPEED)" -f $(LIBDIR)/cpu/rtl8710/rtl8710.ocd -c "init" -c "reset halt" -c "rtl8710_reboot" -c shutdown

	