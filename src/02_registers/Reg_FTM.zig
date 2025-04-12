//! Flex Timer Module of S32K144
//! - date : 2025/03/07
//! - version : 0.1.0
//! - author : weng

const RegType = @import("./RegType.zig");
const ftm0_base_addr: u32 = 0x4003_8000;
const ftm1_base_addr: u32 = 0x4003_9000;
const ftm2_base_addr: u32 = 0x4003_A000;

/// Status And Control
/// - addressOffset: '0'
/// - resetValue: '0'
pub const FTM_SC = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(ftm0_base_addr + 0x00),
        RegType.RegIns.init(ftm1_base_addr + 0x00),
        RegType.RegIns.init(ftm2_base_addr + 0x00),
    };

    /// Prescale Factor Selection
    /// - 000 Divide by 1
    /// - 001 Divide by 2
    /// - 010 Divide by 4
    /// - 011 Divide by 8
    /// - 100 Divide by 16
    /// - 101 Divide by 32
    /// - 110 Divide by 64
    /// - 111 Divide by 128
    pub const PS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 3,
    };

    /// Clock Source Selection
    /// - 00  No clock selected. This in effect disables the FTM counter.
    /// - 01 FTM input clock
    /// - 10 Fixed frequency clock
    /// - 11 External clock
    pub const CLKS = RegType.FieldDef{
        .bit_start = 3,
        .bit_len = 2,
    };

    /// Center-Aligned PWM Select
    /// - 0 FTM counter operates in Up Counting mode.
    /// - 1 FTM counter operates in Up-Down Counting mode.
    pub const CPWMS = RegType.FieldDef{
        .bit_start = 5,
        .bit_len = 1,
    };

    /// Reload Point Interrupt Enable
    /// - 0 Reload point interrupt is disabled.
    /// - 1 Reload point interrupt is enabled.
    pub const RIE = RegType.FieldDef{
        .bit_start = 6,
        .bit_len = 1,
    };

    /// Reload Flag
    /// - 0 A selected reload point did not happen.
    /// - 1 A selected reload point happened.
    pub const RF = RegType.FieldDef{
        .bit_start = 7,
        .bit_len = 1,
    };

    /// Timer Overflow Interrupt Enable
    /// - 0 Disable TOF interrupts. Use software polling.
    /// - 1 Enable TOF interrupts. An interrupt is generated when TOF equals one.
    pub const TOIE = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 1,
    };

    /// Timer Overflow Flag
    /// - 0 FTM counter has not overflowed.
    /// - 1 FTM counter has overflowed.
    pub const TOF = RegType.FieldDef{
        .bit_start = 9,
        .bit_len = 1,
    };

    /// Channel 0 PWM enable bit
    /// - 0 Channel output port is disabled
    /// - 1 Channel output port is enabled
    pub const PWMEN0 = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 1,
    };

    /// Channel 1 PWM enable bit
    /// - 0 Channel output port is disabled
    /// - 1 Channel output port is enabled
    pub const PWMEN1 = RegType.FieldDef{
        .bit_start = 17,
        .bit_len = 1,
    };

    /// Channel 2 PWM enable bit
    /// - 0 Channel output port is disabled
    /// - 1 Channel output port is enabled
    pub const PWMEN2 = RegType.FieldDef{
        .bit_start = 18,
        .bit_len = 1,
    };

    /// Channel 3 PWM enable bit
    /// - 0 Channel output port is disabled
    /// - 1 Channel output port is enabled
    pub const PWMEN3 = RegType.FieldDef{
        .bit_start = 19,
        .bit_len = 1,
    };

    /// Channel 4 PWM enable bit
    /// - 0 Channel output port is disabled
    /// - 1 Channel output port is enabled
    pub const PWMEN4 = RegType.FieldDef{
        .bit_start = 20,
        .bit_len = 1,
    };

    /// Channel 5 PWM enable bit
    /// - 0 Channel output port is disabled
    /// - 1 Channel output port is enabled
    pub const PWMEN5 = RegType.FieldDef{
        .bit_start = 21,
        .bit_len = 1,
    };

    /// Channel 6 PWM enable bit
    /// - 0 Channel output port is disabled
    /// - 1 Channel output port is enabled
    pub const PWMEN6 = RegType.FieldDef{
        .bit_start = 22,
        .bit_len = 1,
    };

    /// Channel 7 PWM enable bit
    /// - 0 Channel output port is disabled
    /// - 1 Channel output port is enabled
    pub const PWMEN7 = RegType.FieldDef{
        .bit_start = 23,
        .bit_len = 1,
    };

    /// Filter Prescaler
    /// - 0000 Divide by 1
    /// - 0001 Divide by 2
    /// - 0010 Divide by 3
    /// - 0011 Divide by 4
    /// - 0100 Divide by 5
    /// - 0101 Divide by 6
    /// - 0110 Divide by 7
    /// - 0111 Divide by 8
    /// - 1000 Divide by 9
    /// - 1001 Divide by 10
    /// - 1010 Divide by 11
    /// - 1011 Divide by 12
    /// - 1100 Divide by 13
    /// - 1101 Divide by 14
    /// - 1110 Divide by 15
    /// - 1111 Divide by 16
    pub const FLTPS = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 4,
    };
};

/// Counter
/// - addressOffset: '0x4'
/// - resetValue: '0'
pub const FTM_CNT = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(ftm0_base_addr + 0x4),
        RegType.RegIns.init(ftm1_base_addr + 0x4),
        RegType.RegIns.init(ftm2_base_addr + 0x4),
    };

    /// Counter Value
    pub const COUNT = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 16,
    };
};

/// Modulo
/// - addressOffset: '0x8'
/// - reset value is 0
pub const FTM_MOD = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(ftm0_base_addr + 0x8),
        RegType.RegIns.init(ftm1_base_addr + 0x8),
        RegType.RegIns.init(ftm2_base_addr + 0x8),
    };

    /// MOD
    pub const MOD = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 16,
    };
};

/// Channel (n) Status And Control
/// - addressOffset: '0xC'
/// - reset value is 0
pub const FTM_C0SC = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(ftm0_base_addr + 0xC),
        RegType.RegIns.init(ftm1_base_addr + 0xC),
        RegType.RegIns.init(ftm2_base_addr + 0xC),
    };

    /// DMA Enable
    /// - 0 Disable DMA transfers.
    /// - 1 Enable DMA transfers.
    pub const DMA = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 1,
    };
};
