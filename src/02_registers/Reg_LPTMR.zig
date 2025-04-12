//! ### The Low Power Timer Registers of S32K144
//! - version: 0.1.0
//! - date: 2025/03/22
//! - author: weng

/// Low Power Timer Control Status Register
/// - addressOffset: '0'
/// - resetValue: '0'
const CSR = packed struct(u32) {
    /// [0] Timer Enable
    /// - 0 LPTMR is disabled and internal logic is reset.
    /// - 1 LPTMR is enabled.
    TEN: u1 = 0,
    /// [1] Timer Mode Select
    /// - 0 Time Counter mode.
    /// - 1 Pulse Counter mode.
    TMS: u1 = 0,
    /// [2] Timer Free-Running Counter
    /// - 0 CNR is reset whenever TCF is set.
    /// - 1 CNR is reset on overflow.
    /// - true: Free Running Mode enabled. Reset counter on 16-bit overflow
    /// - false: Free Running Mode disabled. Reset counter on Compare Match.
    TFC: u1 = 0,
    /// [3] Timer Pin Polarity
    /// - 0 Pulse Counter input source is active-high, and the CNR
    /// - will increment on the rising-edge.
    /// - 1 Pulse Counter input source is active-low, and the CNR will
    /// increment on the falling-edge.
    TPP: u1 = 0,
    /// [4..5] Timer Pin Select
    /// - 00 Pulse counter input 0 is selected.
    /// - 01 Pulse counter input 1 is selected.
    /// - 10 Pulse counter input 2 is selected.
    /// - 11 Pulse counter input 3 is selected.
    TPS: u2 = 0,
    /// [6] Timer Interrupt Enable
    /// - 0 Timer interrupt disabled.
    /// - 1 Timer interrupt enabled.
    TIE: u1 = 0,
    /// [7] Timer Compare Flag
    /// - 0 The value of CNR is not equal to CMR and increments.
    /// - 1 The value of CNR is equal to CMR and increments.
    TCF: u1 = 0,
    /// [8] Timer DMA Request Enable
    /// - 0 Timer DMA Request disabled.
    /// - 1 Timer DMA Request enabled.
    TDRE: u1 = 0,
    /// [9..31]
    RES9_31: u23 = 0,
};

/// Low Power Timer Prescale Register
/// - addressOffset: '0x4'
/// - resetValue: '0'
const PSR = packed struct(u32) {
    /// [0..1] Prescaler Clock Select
    /// - 00 Prescaler/glitch filter clock 0 selected. SIRCDIV2
    /// - 01 Prescaler/glitch filter clock 1 selected. LPO_1KHZ
    /// - 10 Prescaler/glitch filter clock 2 selected. RTC
    /// - 11 Prescaler/glitch filter clock 3 selected. PCC SELECTED
    PCS: u2 = 0,
    /// [2] Prescaler Bypass
    /// - 0 Prescaler/glitch filter is enabled.
    /// - 1 Prescaler/glitch filter is bypassed.
    PBYP: u1 = 0,
    /// [3..6] Prescale Value
    /// - 0000 Prescaler divides the prescaler clock by 2; glitch filter
    /// does not support this configuration.
    /// - 0001 Prescaler divides the prescaler clock by 4; glitch filter
    /// recognizes change on input pin after 2 rising clock edges.
    /// - 0010 Prescaler divides the prescaler clock by 8; glitch filter
    /// recognizes change on input pin after 4 rising clock edges.
    /// - 0011 Prescaler divides the prescaler clock by 16; glitch filter
    /// recognizes change on input pin after 8 rising clock edges.
    /// - 0100 Prescaler divides the prescaler clock by 32; glitch filter
    /// recognizes change on input pin after 16 rising clock edges.
    /// - 0101 Prescaler divides the prescaler clock by 64; glitch filter
    /// recognizes change on input pin after 32 rising clock edges.
    /// - 0110 Prescaler divides the prescaler clock by 128; glitch
    /// filter recognizes change on input pin after 64 rising clock edges.
    /// - 0111 Prescaler divides the prescaler clock by 256; glitch
    /// filter recognizes change on input pin after 128 rising clock edges.
    /// - 1000 Prescaler divides the prescaler clock by 512; glitch
    /// filter recognizes change on input pin after 256 rising clock edges.
    /// - 1001 Prescaler divides the prescaler clock by 1024; glitch
    /// filter recognizes change on input pin after 512 rising clock edges.
    /// - 1010 Prescaler divides the prescaler clock by 2048; glitch
    /// filter recognizes change on input pin after 1024 rising clock edges.
    /// - 1011 Prescaler divides the prescaler clock by 4096; glitch
    /// filter recognizes change on input pin after 2048 rising clock edges.
    /// - 1100 Prescaler divides the prescaler clock by 8192; glitch
    /// filter recognizes change on input pin after 4096 rising clock edges.
    /// - 1101 Prescaler divides the prescaler clock by 16,384; glitch
    /// filter recognizes change on input pin after 8192 rising clock edges.
    /// - 1110 Prescaler divides the prescaler clock by 32,768; glitch
    /// filter recognizes change on input pin after 16,384 rising clock edges.
    /// - 1111 Prescaler divides the prescaler clock by 65,536; glitch
    /// filter recognizes change on input pin after 32,768 rising clock edges.
    PRESCALE: u4 = 0,
    /// [7..31]
    RES7_31: u25 = 0,
};

/// Low Power Timer Compare Register
/// - resetValue: '0'
/// - addressOffset: '0x8'
const CMR = packed struct(u32) {
    /// [0..15] Compare Value
    COMPARE: u16 = 0,
    /// [16..31]
    RES16_31: u16 = 0,
};

/// Low Power Timer Counter Register
/// - resetValue: '0'
/// - addressOffset: '0xC'
const CNR = packed struct(u32) {
    /// [0..15] Counter Value
    COUNTER: u16 = 0,
    /// [16..31]
    RES16_31: u16 = 0,
};

const lptmr0_base_addr: u32 = 0x4004_0000;
/// Low Power Timer Control Status Register Ptr
/// - addressOffset: '0'
/// - resetValue: '0'
pub const LPTMR0_CSR: *volatile CSR = @ptrFromInt(lptmr0_base_addr + 0x00);
/// Low Power Timer Prescale Register
/// - addressOffset: '0x4'
/// - resetValue: '0'
pub const LPTMR0_PSR: *volatile PSR = @ptrFromInt(lptmr0_base_addr + 0x04);
/// Low Power Timer Compare Register
/// - resetValue: '0'
/// - addressOffset: '0x8'
pub const LPTMR0_CMR: *volatile CMR = @ptrFromInt(lptmr0_base_addr + 0x08);
/// Low Power Timer Counter Register
/// - resetValue: '0'
/// - addressOffset: '0xC'
pub const LPTMR0_CNR: *volatile CNR = @ptrFromInt(lptmr0_base_addr + 0x0C);
