/*  
 * The basic linker file for s32k144 lld
 * attention: some symbol used in gcc link should be modified
 * date: 2025/03/31
 * version: 0.1.0
 * author: weng
 *
*/
ENTRY(resetHandler)

MEMORY{
    /* 0x1FFF_8000 LENGTH 0x8000 SRAML ; 0x2000_0000 length 0x7000 SRAMU ; total length is 0xF000 60K */
    RAM (XRW) : ORIGIN = 0x1FFF8000, LENGTH = 0xF000
    /*  0x0000_0000 - 0x0000_0400 ; len = 0x400 interrupts 
        0x0000_0400 - 0x0000_0410 ; len = 0x10 flash config
        0x0000_0410 - 0x0000_8000 ; len = 0x0007FBF0 program flash
        total 512K
    */
    FLASH (RX) : ORIGIN = 0x00000000, LENGTH = 0x0007FBF0
}

/* Set stack start to the end of RAM (stack grows from high memory addresses -> low) */
PROVIDE(__stack = ORIGIN(RAM) + LENGTH(RAM));

/* provide weak interrupts handlers to be overide by user  */
PROVIDE(LPUART0_RxTx_IRQHandler = defaultHandler);
PROVIDE(LPUART1_RxTx_IRQHandler = defaultHandler);
PROVIDE(LPUART2_RxTx_IRQHandler = defaultHandler);
PROVIDE(LPTMR0_IRQHandler = defaultHandler);


/* Enforce emmition of flash_config */
EXTERN(.flash_config)

SECTIONS{

    /* ISR VECTOR TABLE 0x400 */
    .isr_vector :
    {
        . = ALIGN(4);
        KEEP(*(.isr_vector))
        . = ALIGN(4);

    } > FLASH

    /* FLASH CONFIG this region will protect the flash if is not correct*/
    .flash_config 0x400 :
    {
        . = ALIGN(4);
        KEEP(*(.flash_config))    /* Flash Configuration Field (FCF) */
        . = ALIGN(4);

    } > FLASH

    /* Program code and other data goes into FLASH */
    .text :
    {
        . = ALIGN(4);
        *(.text)
        *(.text*)
        . = ALIGN(4);

    } >FLASH

    /* Constant data */
    .rodata :
    {
        . = ALIGN(4);
        *(.rodata)
        *(.rodata*)
        . = ALIGN(4);
    } >FLASH

    /* Special ARM debug info */
    /* TODO: Not sure precisely what this does */
    .ARM : {
        __exidx_start = .;
        *(.ARM.exidx*)
        __exidx_end = .;
    } >FLASH

    /* Loads the FLASH (LOAD) address that holds initalization data */
    _sidata = LOADADDR(.data);

    .data : 
    {
        . = ALIGN(4);
        _sdata = .;        /* create a global symbol at data start */
        *(.data)                   
        *(.data*)
        . = ALIGN(4);
        _edata = .;        /* define a global symbol at data end */
    } >RAM AT> FLASH



    /* Uninitialized data section, startup code will set this to all 0 */
    . = ALIGN(4);
    .bss :
    {
        /* This is used by the startup in order to initialize the .bss secion */
        _sbss = .;         /* define a global symbol at bss start */
        *(.bss)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;         /* define a global symbol at bss end */
    } >RAM

    /* TODO: Not sure precisely what this does */
    .ARM.attributes 0 : { *(.ARM.attributes) }
}
