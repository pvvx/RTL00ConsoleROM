
ENTRY(start_init)

MEMORY{
	tcm (rwx)	: ORIGIN = 0x1FFF0000, LENGTH = 64k
	ram (rwx)	: ORIGIN = 0x10000ba8, LENGTH = 0x70000 - 0x0ba8
/*	flash (rx)	: ORIGIN = 0x98000000, LENGTH = 1024k  */
}

PROVIDE(STACK_TOP = 0x1FFF0000 + 64k - 4);

SECTIONS{
  __rom_bss_start__ = 0x10000300;
  __rom_bss_end__ = 0x10000bc8;

	.fheader  : {
		flash_head = ABSOLUTE(.); 	
		LONG(0x96969999)
		LONG(0xFC66CC3F)
		LONG(0x03CC33C0)
		LONG(0x6231DCE5)
		FirmvareSize = ABSOLUTE(.); 
		LONG(__seg0_end__ - __seg0_start__)
		LONG(__seg0_start__)
		SHORT(seg0_size_1k)
		SHORT(0xFFFF)
		LONG(0xFFFFFFFF)
/*		*(.fheader.data) */
	} > ram

	.header  : {
		__seg0_start__ = ABSOLUTE(.);
		boot_head = ABSOLUTE(.); 
		KEEP(*(.header.data*)) 
		. = ALIGN(4); 
		__seg0_size__ = ABSOLUTE(.); 
		LONG(__seg0_end__ - __seg0_start__)
		. = ALIGN(4); 
		KEEP(*(.header.code*)) 
		*(.header*)
	} > ram

	.text : { 
		. = ALIGN(4); 
		*(.vector.data*) *(.vector.code*) *(.vector*) 
		__text_beg__ = ABSOLUTE(.); 
		*(.text) *(.text*) *(.rodata) *(.rodata*) *(.glue_7) *(.glue_7t) *(.eh_frame) *(.ARM.extab*) 
		. = ALIGN(4); 
		__text_end__ = ABSOLUTE(.);
	 } >ram

	.data : { 
		. = ALIGN(4); 
		__data_beg__ = ABSOLUTE(.); 
		*(.ram_vectors) *(.data) *(.data*) *(.ram_func) . = ALIGN(4); 
		__data_end__ = ABSOLUTE(.); 
		. = ALIGN(4); 
		__seg0_end__ = ABSOLUTE(.); 
	} >ram

	.bss : { 
		. = ALIGN(4); 
		__bss_beg__ = ABSOLUTE(.); 
		*(.bss) *(COMMON) . = ALIGN(4); 
		__bss_end__ = ABSOLUTE(.); 
	} >ram

	.ARM.exidx : { 
	___exidx_start = ABSOLUTE(.); 
	*(.ARM.exidx*) ; 
	___exidx_end = ABSOLUTE(.);  
	} >ram

	.ARM.extab : { 
		*(.ARM.extab*) 
	} >ram

	. = ALIGN(4);
	
	end = .; 
	PROVIDE (end = .);
}

INCLUDE "export-rom_v03.txt"

