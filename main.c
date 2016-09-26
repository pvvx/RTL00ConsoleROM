/*
 *  Test RTL Console ROM
 *  pvvx 26.09.16
 */

//#include <stdint.h>
#include <stdio.h>
//#include "basic_types.h"
//#include "cortex.h"
#include "rtl8710.h"
#include "rom_lib.h"
#include "hal_pinmux.h"
#include "hal_peri_on.h"

//----------------------------------------------- Header
#define HEAD_DATA_ATTR __attribute__((aligned(4), section(".header.data")))
#define HEAD_CODE_ATTR __attribute__((aligned(4), section(".header.code")))
#define FLASH_HEAD_ATTR __attribute__((aligned(4), section(".fheader.data")))

typedef struct _Boot_Head {
	void * start_addr0;	//+0x00  Run if ( v400001F4 & 0x8000000 ) && ( v40000210 & 0x80000000 )
	void * start_addr1;	//+0x04  Run if ( v40000210 & 0x20000000 )
	void * start_addr2;	//+0x08  Run if ( v40000210 & 0x10000000 )
	void * start_addr3;	//+0x0c  Run if ( v400001F4 & 0x8000000 ) && ( v40000210 & 0x8000000 )
	void * start_addr4;	//+0x10  for Init console, Run if ( v40000210 & 0x4000000 )
	u32 sign; 			//+0x14 =  0x88167923 // if != -> Image1 Validation Incorrect !!! Please Re-boot and try again, or re-burn the flash image
	u32 reserved; 		//+0x18 u32 0xFFFFFFFF,
} BOOT_HEAD, *PBOOT_HEAD;

typedef struct _Flash_Head {
	u32 SpicCalibrationPattern[4];	//+0x00  = { 0x96969999,0xFC66CC3F,0x03CC33C0,0x6231DCE5 };
	u32 Seg_size;					//+0x10 in Bytes
	u32 Seg_load_addr;				//+0x14
	u32 Image_2_Addr_1k;			//+0x18 unit is 1024 bytes | 0xFFFF0000
	u32 Dummy;						//+0x1C = 0xFFFFFFFF
} FLASH_HEAD, *PFLASH_HEAD;

void start_init(void);
void start_init1(void);
void start_init2(void);
void start_init3(void);
void start_init4(void);
int main(int);

BOOT_HEAD HEAD_DATA_ATTR boot_head = {
		start_init,
		start_init1,
		start_init2,
		start_init3,
		start_init4,
		0x88167923, 0xFFFFFFFF
	};

// Run if ( v400001F4 & 0x8000000 ) && ( v40000210 & 0x80000000 )
void HEAD_CODE_ATTR  start_init(void)
{
	main(0);
}
// Run if ( v40000210 & 0x20000000 )
void HEAD_CODE_ATTR start_init1(void)
{
	main(1);
}
// Run if ( v40000210 & 0x10000000 )
void HEAD_CODE_ATTR start_init2(void)
{
	main(2);
}
// Run if ( v400001F4 & 0x8000000 ) && ( v40000210 & 0x8000000 )
void HEAD_CODE_ATTR start_init3(void)
{
	main(3);
}
// for Init console, Run if ( v40000210 & 0x4000000 )
void HEAD_CODE_ATTR start_init4(void)
{
	main(4);
}

//----------------------------------------------- Main
extern volatile u32 ConfigDebugErr;
extern volatile u8 * pUartLogCtl;
extern int UartLogCmdExecute(volatile u8 *);
extern u32 STACK_TOP;

int main(int ini)
{
	if(ini == 0) HalPinCtrlRtl8195A(JTAG, 0, 1);
	if((ini > 0)&&(ini < 4)) {
		__asm__ __volatile__ ("cpsid f\n");
		HalCpuClkConfig(2); // 0 - 166666666 Hz, 1 - 83333333 Hz, 2 - 41666666 Hz, 3 - 20833333 Hz, 4 - 10416666 Hz, 5 - 4000000 Hz
		ConfigDebugErr = -1;
		VectorTableInitRtl8195A((u32)&STACK_TOP); // 0x1FFFFFFC);
		HalInitPlatformLogUartV02();
		HalInitPlatformTimerV02();
		__asm__ __volatile__ ("cpsie f\n");
	}
	printf("\r\nStart Init code: %d\r\n", ini);
	printf("EFUSE  0..3: 0x%08x 0x%08x 0x%08x 0x%08x\r\n", SYS->EFUSE_SYSCFG0, SYS->EFUSE_SYSCFG1, SYS->EFUSE_SYSCFG2, SYS->EFUSE_SYSCFG3);
	printf("EFUSE  4..7: 0x%08x 0x%08x 0x%08x 0x%08x\r\n", SYS->EFUSE_SYSCFG4, SYS->EFUSE_SYSCFG5, SYS->EFUSE_SYSCFG6, SYS->EFUSE_SYSCFG7);
	printf("SYSCFG 0..2: 0x%08x 0x%08x 0x%08x\r\n", SYS->SYSTEM_CFG0, SYS->SYSTEM_CFG1, SYS->SYSTEM_CFG2);
	printf("SOC_FUNC_EN: 0x%08x\r\n", PERI_ON->SOC_FUNC_EN);

	printf("\r\nRTL Console ROM: Start - press key 'Up', Help '?'\r\n");
	while(pUartLogCtl[5] != 1);
	pUartLogCtl[3] = 0;
	pUartLogCtl[6] = 1;
    DiagPrintf("\r<RTL8710AF>");
    while(1) {
    	while(pUartLogCtl[4] != 1 );
    	UartLogCmdExecute(pUartLogCtl);
        DiagPrintf("\r<RTL8710AF>");
        pUartLogCtl[4] = 0;
    }
	return 1;
}



