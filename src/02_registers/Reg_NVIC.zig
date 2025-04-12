//! Nested Vectored Interrupt Controller Registers
//! - version : 0.1.0
//! - author:weng

const RegType = @import("./RegType.zig");
const nvic_base_addr: u32 = 0xE000_E100;

/// Interrupt Set Enable Register n
/// - addressOffset: '0'
/// - resetValue: '0'
const NVICISER = packed struct(u32) {
    /// Interrupt set enable bits
    SETENA: u32,
};
/// Interrupt Set Enable Register n
pub const NVICISER_N: *volatile [8]NVICISER = @ptrFromInt(nvic_base_addr + 0x0);

/// Interrupt Clear Enable Register n
/// - addressOffset: '0x80'
/// - resetValue: '0'
const NVICICER = packed struct(u32) {
    /// Interrupt clear-enable bits
    CLRENA: u32,
};
/// Interrupt Clear Enable Register n
pub const NVICICER_N: *volatile [8]NVICICER = @ptrFromInt(nvic_base_addr + 0x80);

/// Interrupt Set Pending Register n
/// - address offset is 0x100
const NVICISPR = packed struct(u32) {
    /// Interrupt set-pending bits
    SETPEND: u32,
};
pub const NVICISPR_N: *volatile [8]NVICISPR = @ptrFromInt(nvic_base_addr + 0x100);

/// Interrupt Clear Pending Register n
/// - addr offset is 0x180
const NVICICPR = packed struct(u32) {
    /// Interrupt clear-pending bits
    CLRPEND: u32,
};
pub const NVICICPR_N: *volatile [8]NVICICPR = @ptrFromInt(nvic_base_addr + 0x180);

/// Interrupt Active bit Register n
/// - addr offset is 0x200
const NVICIABR = packed struct(u32) {
    /// Interrupt active flags
    ACTIVE: u32,
};
pub const NVICIABR_N: *volatile [8]NVICIABR = @ptrFromInt(nvic_base_addr + 0x200);

/// Interrupt Priority Register n
/// - addr offset is 0x300
const NVICIP = packed struct(u8) {
    /// Priority of interrupt n
    PRI: u8,
};
pub const NVICIP_N: *volatile [240]NVICIP = @ptrFromInt(nvic_base_addr + 0x300);

/// Software Trigger Interrupt Register
/// - addressOffset: '0xE00'
/// - resetValue: '0'
const NVICSTIR = struct {
    pub const reg_ins = RegType.RegIns.init(nvic_base_addr + 0xE00);
    /// Interrupt ID of the interrupt to trigger, in the range 0-239. For
    /// example, a value of 0x03 specifies interrupt IRQ3.
    pub const INTID = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 9,
    };
};

// IRQn Type
pub const IRQnType = enum(i32) {
    /// Not available device specific interrupt
    /// 128
    IRQn_NotAvail = -128,
    // core interrupts part ------------------
    /// 242
    IRQn_NonMaskableInt = -14,
    /// 243
    IRQn_HardFault = -13,
    /// 244
    IRQn_MemoryManagement = -12,
    /// 245
    IRQn_BusFault = -11,
    /// 246
    IRQn_UsageFault = -10,
    /// 251
    IRQn_SVCall = -5,
    /// 252
    IRQn_DebugMonitor = -4,
    /// 254
    IRQn_PendSV = -2,
    /// 255
    IRQn_SysTick = -1,

    // device specific interrupts -----------
    IRQn_DMA0 = 0,
    IRQn_DMA1 = 1,
    IRQn_DMA2 = 2,
    IRQn_DMA3 = 3,
    IRQn_DMA4 = 4,
    IRQn_DMA5 = 5,
    IRQn_DMA6 = 6,
    IRQn_DMA7 = 7,
    IRQn_DMA8 = 8,
    IRQn_DMA9 = 9,
    IRQn_DMA10 = 10,
    IRQn_DMA11 = 11,
    IRQn_DMA12 = 12,
    IRQn_DMA13 = 13,
    IRQn_DMA14 = 14,
    IRQn_DMA15 = 15,
    IRQn_DMA_Error = 16,
    IRQn_MCM = 17,
    IRQn_FTFC = 18,
    IRQn_Read_Collision = 19,
    IRQn_LVD_LVW = 20,
    IRQn_FTFC_Fault = 21,
    IRQn_WDOG_EWM = 22,
    IRQn_RCM = 23,
    IRQn_LPI2C0_Master = 24,
    IRQn_LPI2C0_Slave = 25,
    IRQn_LPSPI0 = 26,
    IRQn_LPSPI1 = 27,
    IRQn_LPSPI2 = 28,
    /// < LPUART0 Transmit / Receive Interrupt
    IRQn_LPUART0_RxTx = 31,
    /// LPUART1 Transmit / Receive  Interrupt
    IRQn_LPUART1_RxTx = 33,
    /// LPUART2 Transmit / Receive  Interrupt
    IRQn_LPUART2_RxTx = 35,
    IRQn_ADC0 = 39,
    IRQn_ADC1 = 40,
    IRQn_CMP0 = 41,
    IRQn_ERM_single_fault = 44,
    IRQn_ERM_double_fault = 45,
    IRQn_RTC = 46,
    IRQn_RTC_Seconds = 47,
    IRQn_LPIT0_Ch0 = 48,
    IRQn_LPIT0_Ch1 = 49,
    IRQn_LPIT0_Ch2 = 50,
    IRQn_LPIT0_Ch3 = 51,
    IRQn_PDB0 = 52,
    IRQn_SCG = 57,
    IRQn_LPTMR0 = 58,
    IRQn_PORTA = 59,
    IRQn_PORTB = 60,
    IRQn_PORTC = 61,
    IRQn_PORTD = 62,
    IRQn_PORTE = 63,
    IRQn_SWI = 64,
    IRQn_PDB1 = 68,
    IRQn_FLEXIO = 69,
    IRQn_CAN0_ORed = 78,
    IRQn_CAN0_Error = 79,
    IRQn_CAN0_Wake_Up = 80,
    IRQn_CAN0_ORed_0_15_MB = 81,
    IRQn_CAN0_ORed_16_31_MB = 82,
    IRQn_CAN1_ORed = 85,
    IRQn_CAN1_Error = 86,
    IRQn_CAN1_ORed_0_15_MB = 88,
    IRQn_CAN2_ORed = 92,
    IRQn_CAN2_Error = 93,
    IRQn_CAN2_ORed_0_15_MB = 95,
    IRQn_FTM0_Ch0_Ch1 = 99,
    IRQn_FTM0_Ch2_Ch3 = 100,
    IRQn_FTM0_Ch4_Ch5 = 101,
    IRQn_FTM0_Ch6_Ch7 = 102,
    IRQn_FTM0_Fault = 103,
    IRQn_FTM0_Ovf_Reload = 104,
    IRQn_FTM1_Ch0_Ch1 = 105,
    IRQn_FTM1_Ch2_Ch3 = 106,
    IRQn_FTM1_Ch4_Ch5 = 107,
    IRQn_FTM1_Ch6_Ch7 = 108,
    IRQn_FTM1_Fault = 109,
    IRQn_FTM1_Ovf_Reload = 110,
    IRQn_FTM2_Ch0_Ch1 = 111,
    IRQn_FTM2_Ch2_Ch3 = 112,
    IRQn_FTM2_Ch4_Ch5 = 113,
    IRQn_FTM2_Ch6_Ch7 = 114,
    IRQn_FTM2_Fault = 115,
    IRQn_FTM2_Ovf_Reload = 116,
    IRQn_FTM3_Ch0_Ch1 = 117,
    IRQn_FTM3_Ch2_Ch3 = 118,
    IRQn_FTM3_Ch4_Ch5 = 119,
    IRQn_FTM3_Ch6_Ch7 = 120,
    IRQn_FTM3_Fault = 121,
    IRQn_FTM3_Ovf_Reload = 122,
};
