//! created by weng
//! - 2025/02/23
//! - system tick clock

const RegType = @import("./RegType.zig");
const sysTick_baseAddress: u32 = 0xE000_E010;

/// SysTick Control and Status Register
/// - address offset is 0
/// - reset value is 0x4
pub const SysTick_CSR = struct {
    pub const reg_ins = RegType.RegIns.init(sysTick_baseAddress + 0x0);
    /// ENABLE [0] Enables the counter
    /// - 1 counter enabled
    /// - 0 counter disabled
    pub const ENABLE = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 1,
    };
    /// TICKINT [1]
    /// Enables SysTick exception request
    /// - 0 counting down to 0 does not assert the SysTick exception request
    /// - 1 counting down to 0 asserts the SysTick exception request
    pub const TICKINT = RegType.FieldDef{
        .bit_start = 1,
        .bit_len = 1,
    };
    /// CLKSOURCE [2] Indicates the clock source
    /// - 0 external clock
    /// - 1 processor clock
    pub const CLKSOURCE = RegType.FieldDef{
        .bit_start = 2,
        .bit_len = 1,
    };
    /// COUNTFLAG [16]
    /// - Returns 1 if timer counted to 0 since last time this was read
    pub const COUNTFLAG = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 1,
    };
};

/// SysTick Reload Value Register
/// - addr offset is 0x4
/// - reset value is 0
pub const SysTick_RVR = struct {
    pub const reg_ins = RegType.RegIns.init(sysTick_baseAddress + 0x4);
    /// [0..23]
    /// - Value to load into the SysTick Current Value Register when the counter reaches 0
    pub const RELOAD = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 24,
    };
};

/// SysTick Current Value Register
/// - addr offset is 0x8
/// - reset value is 0
pub const SysTick_CVR = struct {
    pub const reg_ins = RegType.RegIns.init(sysTick_baseAddress + 0x8);
    /// CURRENT [0..23]
    /// - Current value at the time the register is accessed
    pub const CURRENT = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 24,
    };
};

/// SysTick Calibration Value Register
/// - addr offset is 0xC
/// - reset value is 0x80000000
pub const SysTick_CALIB = struct {
    pub const reg_ins = RegType.RegIns.init(sysTick_baseAddress + 0xC);
    /// TENMS [0..23]
    /// - Reload value to use for 10ms timing
    pub const TENMS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 24,
    };
    /// SKEW [30]
    /// - Indicates whether the TENMS value is exact
    /// - 0 exact
    /// - 1 inexact
    pub const SKEW = RegType.FieldDef{
        .bit_start = 30,
        .bit_len = 1,
    };
    /// NOREF [31]
    /// - Indicates whether the device provides a reference clock to the processor
    /// - 0 The reference clock is provided
    /// - 1 The reference clock is not provided
    pub const NOREF = RegType.FieldDef{
        .bit_start = 31,
        .bit_len = 1,
    };
};
