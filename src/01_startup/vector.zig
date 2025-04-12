//! this file define all the hardware interrupts vectors

/// The default handler of all interrupt handler
/// The default interrupt handler function will only block here
export fn defaultHandler() callconv(.C) noreturn {
    while (true) {}
}

const resetHandler = @import("./entry.zig").resetHandler;

/// The __stack symbol we defined in our linker script for where the stack pointer should
/// start (the very end of RAM). Note is given the type "anyopaque" as this symbol is
/// only ever meant to be used by taking the address with &. It doesn't actually "point"
/// to anything valid at all!
extern var __stack: anyopaque;

/// The actual instance of our vector table we will export into the section
/// ".isr_vector", ensuring it is placed at the beginning of flash memory.
/// Actual interrupt handlers (rather than the defaultHandler) could be added
/// by assigning them in struct instantiation.
pub const Vector_Table: VectorTable = .{
    .initial_stack_pointer = &__stack,
};

pub const VECTOR_LIST_PTR: *align(4) volatile [255]IsrFunction = @ptrCast(@constCast(&Vector_Table));

/// Note that any interrupt function is specified to use the "C" calling convention.
/// This is because Zig's calling convention could differ from C. C being the defacto
/// "standard" for function calling conventions, it's what the processor expects when
/// it branches to one of these functions. Normal functions in application code, however
/// can use normal Zig function definitions. These functions are "special" in the sense
/// that they are being called by "hardware" directly.
///
/// - align(2) function
pub const IsrFunction = *const fn () callconv(.C) void;

/// 47
extern fn LPUART0_RxTx_IRQHandler() callconv(.C) void;
/// 49
extern fn LPUART1_RxTx_IRQHandler() callconv(.C) void;
/// 51
extern fn LPUART2_RxTx_IRQHandler() callconv(.C) void;
/// 74
extern fn LPTMR0_IRQHandler() callconv(.C) void;

/// An "extern" struct here is used here to create a
/// struct that has the same memory layout as a C struct.
/// Note that this is NOT the same as "packed", so care must be taken
/// to match the memory layout the CPU is expecting. In this case
/// all fields are ultimately a u32, so silently added padding bytes
/// aren't a concern.
///
/// - align 4 的向量表
pub const VectorTable = extern struct {
    /// 0 STACK TOP
    initial_stack_pointer: *anyopaque,
    // Internal peripherial interrupt handlers
    /// 1 DEFAULT ENTRY
    Reset_Handler: IsrFunction = resetHandler,
    /// 2
    NMI_Handler: IsrFunction = defaultHandler,
    /// 3
    HardFault_Handler: IsrFunction = defaultHandler,
    /// 4
    MemManage_Handler: IsrFunction = defaultHandler,
    /// 5
    BusFault_Handler: IsrFunction = defaultHandler,
    /// 6
    UsageFault_Handler: IsrFunction = defaultHandler,
    /// 7
    reserved1: u32 = undefined,
    /// 8
    reserved2: u32 = undefined,
    /// 9
    reserved3: u32 = undefined,
    /// 10
    reserved4: u32 = undefined,
    /// 11
    SVC_Handler: IsrFunction = defaultHandler,
    /// 12
    DebugMon_Handler: IsrFunction = defaultHandler,
    /// 13
    reserved5: u32 = undefined,
    /// 14
    PendSV_Handler: IsrFunction = defaultHandler,
    /// 15
    SysTick_Handler: IsrFunction = defaultHandler,
    // -------------------------------------------------------------------
    // External peripherial interrupt handlers
    /// 16
    DMA0_IRQHandler: IsrFunction = defaultHandler,
    /// 17
    DMA1_IRQHandler: IsrFunction = defaultHandler,
    /// 18
    DMA2_IRQHandler: IsrFunction = defaultHandler,
    /// 19
    DMA3_IRQHandler: IsrFunction = defaultHandler,
    /// 20
    DMA4_IRQHandler: IsrFunction = defaultHandler,
    /// 21
    DMA5_IRQHandler: IsrFunction = defaultHandler,
    /// 22
    DMA6_IRQHandler: IsrFunction = defaultHandler,
    /// 23
    DMA7_IRQHandler: IsrFunction = defaultHandler,
    /// 24
    DMA8_IRQHandler: IsrFunction = defaultHandler,
    /// 25
    DMA9_IRQHandler: IsrFunction = defaultHandler,
    /// 26
    DMA10_IRQHandler: IsrFunction = defaultHandler,
    /// 27
    DMA11_IRQHandler: IsrFunction = defaultHandler,
    /// 28
    DMA12_IRQHandler: IsrFunction = defaultHandler,
    /// 29
    DMA13_IRQHandler: IsrFunction = defaultHandler,
    /// 30
    DMA14_IRQHandler: IsrFunction = defaultHandler,
    /// 31
    DMA15_IRQHandler: IsrFunction = defaultHandler,
    /// 32
    DMA_Error_IRQHandler: IsrFunction = defaultHandler,
    /// 33
    MCM_IRQHandler: IsrFunction = defaultHandler,
    /// 34
    FTFC_IRQHandler: IsrFunction = defaultHandler,
    /// 35
    Read_Collision_IRQHandler: IsrFunction = defaultHandler,
    /// 36
    LVD_LVW_IRQHandler: IsrFunction = defaultHandler,
    /// 37
    FTFC_Fault_IRQHandler: IsrFunction = defaultHandler,
    /// 38
    WDOG_EWM_IRQHandler: IsrFunction = defaultHandler,
    /// 39
    RCM_IRQHandler: IsrFunction = defaultHandler,
    /// 40
    LPI2C0_Master_IRQHandler: IsrFunction = defaultHandler,
    /// 41
    LPI2C0_Slave_IRQHandler: IsrFunction = defaultHandler,
    /// 42
    LPSPI0_IRQHandler: IsrFunction = defaultHandler,
    /// 43
    LPSPI1_IRQHandler: IsrFunction = defaultHandler,
    /// 44
    LPSPI2_IRQHandler: IsrFunction = defaultHandler,
    /// 45
    Reserved45_IRQHandler: IsrFunction = defaultHandler,
    /// 46
    Reserved46_IRQHandler: IsrFunction = defaultHandler,
    /// 47
    LPUART0_RxTx_IRQHandler: IsrFunction = LPUART0_RxTx_IRQHandler,
    /// 48
    Reserved48_IRQHandler: IsrFunction = defaultHandler,
    /// 49
    LPUART1_RxTx_IRQHandler: IsrFunction = LPUART1_RxTx_IRQHandler,
    /// 50
    Reserved50_IRQHandler: IsrFunction = defaultHandler,
    /// 51
    LPUART2_RxTx_IRQHandler: IsrFunction = LPUART2_RxTx_IRQHandler,
    /// 52
    Reserved52_IRQHandler: IsrFunction = defaultHandler,
    /// 53
    Reserved53_IRQHandler: IsrFunction = defaultHandler,
    /// 54
    Reserved54_IRQHandler: IsrFunction = defaultHandler,
    /// 55
    ADC0_IRQHandler: IsrFunction = defaultHandler,
    /// 56
    ADC1_IRQHandler: IsrFunction = defaultHandler,
    /// 57
    CMP0_IRQHandler: IsrFunction = defaultHandler,
    /// 58
    Reserved58_IRQHandler: IsrFunction = defaultHandler,
    /// 59
    Reserved59_IRQHandler: IsrFunction = defaultHandler,
    /// 60
    ERM_single_fault_IRQHandler: IsrFunction = defaultHandler,
    /// 61
    ERM_double_fault_IRQHandler: IsrFunction = defaultHandler,
    /// 62
    RTC_IRQHandler: IsrFunction = defaultHandler,
    /// 63
    RTC_Seconds_IRQHandler: IsrFunction = defaultHandler,
    /// 64
    LPIT0_Ch0_IRQHandler: IsrFunction = defaultHandler,
    /// 65
    LPIT0_Ch1_IRQHandler: IsrFunction = defaultHandler,
    /// 66
    LPIT0_Ch2_IRQHandler: IsrFunction = defaultHandler,
    /// 67
    LPIT0_Ch3_IRQHandler: IsrFunction = defaultHandler,
    /// 68
    PDB0_IRQHandler: IsrFunction = defaultHandler,
    /// 69
    Reserved69_IRQHandler: IsrFunction = defaultHandler,
    /// 70
    Reserved70_IRQHandler: IsrFunction = defaultHandler,
    /// 71
    Reserved71_IRQHandler: IsrFunction = defaultHandler,
    /// 72
    Reserved72_IRQHandler: IsrFunction = defaultHandler,
    /// 73
    SCG_IRQHandler: IsrFunction = defaultHandler,
    /// 74
    LPTMR0_IRQHandler: IsrFunction = LPTMR0_IRQHandler,
    /// 75
    PORTA_IRQHandler: IsrFunction = defaultHandler,
    /// 76
    PORTB_IRQHandler: IsrFunction = defaultHandler,
    /// 77
    PORTC_IRQHandler: IsrFunction = defaultHandler,
    /// 78
    PORTD_IRQHandler: IsrFunction = defaultHandler,
    /// 79
    PORTE_IRQHandler: IsrFunction = defaultHandler,
    /// 80
    SWI_IRQHandler: IsrFunction = defaultHandler,
    /// 81
    Reserved81_IRQHandler: IsrFunction = defaultHandler,
    /// 82
    Reserved82_IRQHandler: IsrFunction = defaultHandler,
    /// 83
    Reserved83_IRQHandler: IsrFunction = defaultHandler,
    /// 84
    PDB1_IRQHandler: IsrFunction = defaultHandler,
    /// 85
    FLEXIO_IRQHandler: IsrFunction = defaultHandler,
    /// 86
    Reserved86_IRQHandler: IsrFunction = defaultHandler,
    /// 87
    Reserved87_IRQHandler: IsrFunction = defaultHandler,
    /// 88
    Reserved88_IRQHandler: IsrFunction = defaultHandler,
    /// 89
    Reserved89_IRQHandler: IsrFunction = defaultHandler,
    /// 90
    Reserved90_IRQHandler: IsrFunction = defaultHandler,
    /// 91
    Reserved91_IRQHandler: IsrFunction = defaultHandler,
    /// 92
    Reserved92_IRQHandler: IsrFunction = defaultHandler,
    /// 93
    Reserved93_IRQHandler: IsrFunction = defaultHandler,
    /// 94
    CAN0_ORed_IRQHandler: IsrFunction = defaultHandler,
    /// 95
    CAN0_Error_IRQHandler: IsrFunction = defaultHandler,
    /// 96
    CAN0_Wake_Up_IRQHandler: IsrFunction = defaultHandler,
    /// 97
    CAN0_ORed_0_15_MB_IRQHandler: IsrFunction = defaultHandler,
    /// 98
    CAN0_ORed_16_31_MB_IRQHandler: IsrFunction = defaultHandler,
    /// 99
    Reserved99_IRQHandler: IsrFunction = defaultHandler,
    /// 100
    Reserved100_IRQHandler: IsrFunction = defaultHandler,
    /// 101
    CAN1_ORed_IRQHandler: IsrFunction = defaultHandler,
    /// 102
    CAN1_Error_IRQHandler: IsrFunction = defaultHandler,
    /// 103
    Reserved103_IRQHandler: IsrFunction = defaultHandler,
    /// 104
    CAN1_ORed_0_15_MB_IRQHandler: IsrFunction = defaultHandler,
    /// 105
    Reserved105_IRQHandler: IsrFunction = defaultHandler,
    /// 106
    Reserved106_IRQHandler: IsrFunction = defaultHandler,
    /// 107
    Reserved107_IRQHandler: IsrFunction = defaultHandler,
    /// 108
    CAN2_ORed_IRQHandler: IsrFunction = defaultHandler,
    /// 109
    CAN2_Error_IRQHandler: IsrFunction = defaultHandler,
    /// 110
    Reserved110_IRQHandler: IsrFunction = defaultHandler,
    /// 111
    CAN2_ORed_0_15_MB_IRQHandler: IsrFunction = defaultHandler,
    /// 112
    Reserved112_IRQHandler: IsrFunction = defaultHandler,
    /// 113
    Reserved113_IRQHandler: IsrFunction = defaultHandler,
    /// 114
    Reserved114_IRQHandler: IsrFunction = defaultHandler,
    /// 115
    FTM0_Ch0_Ch1_IRQHandler: IsrFunction = defaultHandler,
    /// 116
    FTM0_Ch2_Ch3_IRQHandler: IsrFunction = defaultHandler,
    /// 117
    FTM0_Ch4_Ch5_IRQHandler: IsrFunction = defaultHandler,
    /// 118
    FTM0_Ch6_Ch7_IRQHandler: IsrFunction = defaultHandler,
    /// 119
    FTM0_Fault_IRQHandler: IsrFunction = defaultHandler,
    /// 120
    FTM0_Ovf_Reload_IRQHandler: IsrFunction = defaultHandler,
    /// 121
    FTM1_Ch0_Ch1_IRQHandler: IsrFunction = defaultHandler,
    /// 122
    FTM1_Ch2_Ch3_IRQHandler: IsrFunction = defaultHandler,
    /// 123
    FTM1_Ch4_Ch5_IRQHandler: IsrFunction = defaultHandler,
    /// 124
    FTM1_Ch6_Ch7_IRQHandler: IsrFunction = defaultHandler,
    /// 125
    FTM1_Fault_IRQHandler: IsrFunction = defaultHandler,
    /// 126
    FTM1_Ovf_Reload_IRQHandler: IsrFunction = defaultHandler,
    /// 127
    FTM2_Ch0_Ch1_IRQHandler: IsrFunction = defaultHandler,
    /// 128
    FTM2_Ch2_Ch3_IRQHandler: IsrFunction = defaultHandler,
    /// 129
    FTM2_Ch4_Ch5_IRQHandler: IsrFunction = defaultHandler,
    /// 130
    FTM2_Ch6_Ch7_IRQHandler: IsrFunction = defaultHandler,
    /// 131
    FTM2_Fault_IRQHandler: IsrFunction = defaultHandler,
    /// 132
    FTM2_Ovf_Reload_IRQHandler: IsrFunction = defaultHandler,
    /// 133
    FTM3_Ch0_Ch1_IRQHandler: IsrFunction = defaultHandler,
    /// 134
    FTM3_Ch2_Ch3_IRQHandler: IsrFunction = defaultHandler,
    /// 135
    FTM3_Ch4_Ch5_IRQHandler: IsrFunction = defaultHandler,
    /// 136
    FTM3_Ch6_Ch7_IRQHandler: IsrFunction = defaultHandler,
    /// 137
    FTM3_Fault_IRQHandler: IsrFunction = defaultHandler,
    /// 138
    FTM3_Ovf_Reload_IRQHandler: IsrFunction = defaultHandler,
};
