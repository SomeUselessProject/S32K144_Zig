//! ## Low Power Periodic Interrupt Timer (LPIT)
//! - author: qinwu weng
//! - date: 2025/02/25
//! - version: 0.2.0
//! - brief: the registers of LPIT module

/// Version ID Register
/// - address offset is 0
/// - reset value is 0x1000000
const VERID_REG = packed struct(u32) {
    /// [0..15] Feature Number
    FEATURE: u16 = 0,
    // [16..23] Minor Version Number
    MINOR: u8 = 0,
    /// [24..31] Major Version Number
    MAJOR: u8 = 0,
};

/// Parameter Register
/// - address offset is 0x4
/// - reset value is 0x404
const PARAM_REG = packed struct(u32) {
    /// [0..7] Number of Timer Channels
    CHANNEL: u8 = 0,
    /// [8..15] Number of External Trigger Inputs
    EXT_TRIG: u8 = 0,
    /// [16..31]
    RES16_31: u16 = 0,
};

/// Module Control Register
/// - addressOffset: '0x8'
/// - resetValue: '0'
const MCR_REG = packed struct(u32) {
    /// [0] Module Clock Enable
    /// - 0 Peripheral clock to timers is disabled
    /// - 1 Peripheral clock to timers is enabled
    M_CEN: u1 = 0,
    /// [1] Software Reset Bit
    /// - 0 Timer channels and registers are not reset
    /// - 1 Timer channels and registers are reset
    SW_RST: u1 = 0,
    /// [2] DOZE Mode Enable Bit
    /// - 0 Timer channels are stopped in DOZE mode
    /// - 1 Timer channels continue to run in DOZE mode
    DOZE_EN: u1 = 0,
    /// [3] Debug Enable Bit
    /// - 0 Timer channels are stopped in Debug mode
    /// - 1 Timer channels continue to run in Debug mode
    DBG_EN: u1 = 0,
    /// [4..31]
    RES4_31: u28 = 0,
};

/// Module Status Register
/// - addressOffset: '0xC'
/// - resetValue: '0'
const MSR_REG = packed struct(u32) {
    /// [0] Channel 0 Timer Interrupt Flag
    /// - 0 Timer has not timed out
    /// - 1 Timeout has occurred
    TIF0: u1 = 0,
    /// [1] Channel 1 Timer Interrupt Flag
    /// - 0 Timer has not timed out
    /// - 1 Timeout has occurred
    TIF1: u1 = 0,
    /// [2] Channel 2 Timer Interrupt Flag
    /// - 0 Timer has not timed out
    /// - 1 Timeout has occurred
    TIF2: u1 = 0,
    /// [3] Channel 3 Timer Interrupt Flag
    /// - 0 Timer has not timed out
    /// - 1 Timeout has occurred
    TIF3: u1 = 0,
    /// [4..31]
    RES4_31: u28 = 0,
};

/// Module Interrupt Enable Register
/// - addressOffset: '0x10'
/// - resetValue: '0'
const MIER_REG = packed struct(u32) {
    /// [0] Channel 0 Timer Interrupt Enable
    /// - 0 Interrupt generation is disabled
    /// - 1 Interrupt generation is enabled
    TIE0: u1 = 0,
    /// [1] Channel 1 Timer Interrupt Enable
    /// - 0 Interrupt generation is disabled
    /// - 1 Interrupt generation is enabled
    TIE1: u1 = 0,
    /// [2] Channel 2 Timer Interrupt Enable
    /// - 0 Interrupt generation is disabled
    /// - 1 Interrupt generation is enabled
    TIE2: u1 = 0,
    /// [3] Channel 3 Timer Interrupt Enable
    /// - 0 Interrupt generation is disabled
    /// - 1 Interrupt generation is enabled
    TIE3: u1 = 0,
    /// [4..31]
    RES4_31: u28 = 0,
};

/// Set Timer Enable Register
/// - addressOffset: '0x14'
/// - resetValue: '0'
const SETTEN_REG = packed struct(u32) {
    /// [0] Set Timer 0 Enable
    /// - 0 No effect
    /// - 1 Enables the Timer Channel 0
    SET_T_EN_0: u1 = 0,
    /// [1] Set Timer 1 Enable
    /// - 0 No effect
    /// - 1 Enables the Timer Channel 1
    SET_T_EN_1: u1 = 0,
    /// [2] Set Timer 2 Enable
    /// - 0 No effect
    /// - 1 Enables the Timer Channel 2
    SET_T_EN_2: u1 = 0,
    /// [3] Set Timer 3 Enable
    /// - 0 No effect
    /// - 1 Enables the Timer Channel 3
    SET_T_EN_3: u1 = 0,
    /// [4..31]
    RES4_31: u28 = 0,
};

/// Clear Timer Enable Register
/// - addressOffset: '0x18'
/// - resetValue: '0'
const CLRTEN_REG = packed struct(u32) {
    /// [0] Clear Timer 0 Enable
    /// - 0 No action
    /// - 1 Clear T_EN bit for Timer Channel 0
    CLR_T_EN_0: u1 = 0,
    /// [1] Clear Timer 1 Enable
    /// - 0 No action
    /// - 1 Clear T_EN bit for Timer Channel 1
    CLR_T_EN_1: u1 = 0,
    /// [2] Clear Timer 2 Enable
    /// - 0 No action
    /// - 1 Clear T_EN bit for Timer Channel 2
    CLR_T_EN_2: u1 = 0,
    /// [3] Clear Timer 3 Enable
    /// - 0 No action
    /// - 1 Clear T_EN bit for Timer Channel 3
    CLR_T_EN_3: u1 = 0,
    /// [4..31]
    RES4_31: u28 = 0,
};

/// Timer Value Register
/// - channel 0 addressOffset: '0x20'
/// - channel 1 0x30
/// - channel 2 0x40
/// - channel 3 0x50
/// - resetValue: '0'
const TVAL_REG = packed struct(u32) {
    /// [0..31] Timer Value
    /// - 0 Invalid load value in compare modes.
    /// - 1 Invalid load value in compare modes.
    TMR_VAL: u32 = 0,
};

/// Current Timer Value
/// - 0 channel addressOffset: '0x24'
/// - 1 channel 0x34
/// - 2 channel 0x44
/// - 3 channel 0x54
/// - resetValue: '0xFFFFFFFF'
const CVAL_REG = packed struct(u32) {
    /// [0..31] Current Timer Value
    TMR_CUR_VAL: u32 = 0xFFFF_FFFF,
};

/// Timer Control Register
/// - 0 CHANNEL addressOffset: '0x28'
/// - 1 CHANNEL 0x38
/// - 2 CHANNEL 0x48
/// - 3 CHANNEL 0x58
/// - resetValue: '0'
const TCTRL_REG = packed struct(u32) {
    /// [0] Timer Enable
    /// - 0 Timer Channel is disabled
    /// - 1 Timer Channel is enabled
    T_EN: u1 = 0,
    /// [1] Chain Channel
    /// - 0 Channel Chaining is disabled. Channel Timer runs independently.
    /// - 1 Channel Chaining is enabled. Timer decrements on previous channel's timeout
    CHAIN: u1 = 0,
    /// [2..3] Timer Operation Mode
    /// - 00 32-bit Periodic Counter
    /// - 01 Dual 16-bit Periodic Counter
    /// - 10 32-bit Trigger Accumulator
    /// - 11 32-bit Trigger Input Capture
    MODE: u2 = 0,
    /// [4..15]
    RES4_15: u12 = 0,
    /// [16] Timer Start On Trigger
    /// - 0 Timer starts to decrement immediately based on restart
    /// condition (controlled by TSOI bit)
    /// - 1 Timer starts to decrement when rising edge on selected
    /// trigger is detected
    TSOT: u1 = 0,
    /// [17] Timer Stop On Interrupt
    /// - 0 The channel timer does not stop after timeout.
    /// - 1 The channel timer will stop after a timeout, and the
    /// channel timer will restart based on TSOT.
    /// - When TSOT = 0, the channel timer will restart after a rising edge on the
    /// T_EN bit is detected (which means that the timer channel
    /// is disabled and then enabled);
    /// - when TSOT = 1, the channel timer will restart after a rising edge on the selected
    /// trigger is detected.
    TSOI: u1 = 0,
    /// [18] Timer Reload On Trigger
    /// - 0 Timer will not reload on selected trigger
    /// - 1 Timer will reload on selected trigger
    TROT: u1 = 0,
    /// [19..22]
    RES19_22: u4 = 0,
    /// [23] Trigger Source
    /// - 0 Trigger source selected in external
    /// - 1 Trigger source selected is the internal trigger
    TRG_SRC: u1 = 0,
    /// [24..27] Trigger Select
    TRG_SEL: u4 = 0,
    /// [28..31]
    RES28_31: u4 = 0,
};

const lpit0_base_addr: u32 = 0x4003_7000;
/// Version ID Register
pub const LPIT0_VERID: *volatile VERID_REG = @ptrFromInt(lpit0_base_addr + 0x00);
/// Parameter Register
pub const LPIT0_PARAM: *volatile PARAM_REG = @ptrFromInt(lpit0_base_addr + 0x04);
/// Module Control Register
pub const LPIT0_MCR: *volatile MCR_REG = @ptrFromInt(lpit0_base_addr + 0x08);
/// Module Status Register
pub const LPIT0_MSR: *volatile MSR_REG = @ptrFromInt(lpit0_base_addr + 0x0C);
/// Module Interrupt Enable Register
pub const LPIT0_MIER: *volatile MIER_REG = @ptrFromInt(lpit0_base_addr + 0x10);
/// Set Timer Enable Register
pub const LPIT0_SETTEN: *volatile SETTEN_REG = @ptrFromInt(lpit0_base_addr + 0x14);
/// Clear Timer Enable Register
pub const LPIT0_CLRTEN: *volatile CLRTEN_REG = @ptrFromInt(lpit0_base_addr + 0x18);
/// Timer Value Register
pub const LPIT0_TVALS: [4]*volatile TVAL_REG = .{
    @ptrFromInt(lpit0_base_addr + 0x20),
    @ptrFromInt(lpit0_base_addr + 0x30),
    @ptrFromInt(lpit0_base_addr + 0x40),
    @ptrFromInt(lpit0_base_addr + 0x50),
};
/// Current Timer Value
pub const LPIT0_CVALS: [4]*volatile CVAL_REG = .{
    @ptrFromInt(lpit0_base_addr + 0x24),
    @ptrFromInt(lpit0_base_addr + 0x34),
    @ptrFromInt(lpit0_base_addr + 0x44),
    @ptrFromInt(lpit0_base_addr + 0x54),
};
/// Timer Control Register
pub const LPIT0_TCTRLS: [4]*volatile TCTRL_REG = .{
    @ptrFromInt(lpit0_base_addr + 0x28),
    @ptrFromInt(lpit0_base_addr + 0x38),
    @ptrFromInt(lpit0_base_addr + 0x48),
    @ptrFromInt(lpit0_base_addr + 0x58),
};
