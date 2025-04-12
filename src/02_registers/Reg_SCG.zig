//! SCG - System Clock Generator
//! - some registers must update all fields at the same time
//! - version: 0.2.0
//! - author : weng

const RegType = @import("./RegType.zig");

const scg_base_addr: u32 = 0x4006_4000;

const VERID_REG = packed struct(u32) {
    /// [0..31] SCG Version Number
    VERSION: u32 = 0,
};

const PRAM_REG = packed struct(u32) {
    /// [0.,7] Clock Present
    CLKPRES: u8 = 0b1111_1110,
    /// [8..26]
    _unused8_26: u19 = 0,
    /// [27..31] Divider Present
    DIVPRES: u5 = 0b11111,
};

const CLKOUTCNFG_REG = packed struct(u32) {
    /// [0..23]
    _unused0_23: u24 = 0,
    /// [24..27] SCG Clkout Select
    /// - 0000 SCG SLOW Clock
    /// - 0001 System OSC (SOSC_CLK)
    /// - 0010 Slow IRC (SIRC_CLK)
    /// - 0011 Fast IRC (FIRC_CLK)
    /// - 0110 System PLL (SPLL_CLK)
    CLKOUTSEL: u4 = 0,
    /// [28..31]
    _unused28_31: u4 = 0,
};

const SIRCCFG_REG = packed struct(u32) {
    /// [0] Frequency Range
    /// - 0 Slow IRC low range clock (2 MHz)
    /// - 1 Slow IRC high range clock (8 MHz )
    RANGE: u1 = 1,
    /// [1..31]
    _unused1_31: u31 = 0,
};

const FIRCCFG_REG = packed struct(u32) {
    /// [0..1] Frequency Range
    /// - 00 Fast IRC is trimmed to 48 MHz
    RANGE: u2 = 0,
    /// [2..31]
    _unused2_31: u30 = 0,
};

/// Version ID Register
/// - reset value is 0x1_000_000
/// - 0001 0000 0000 0000 0000 0000 0000
pub const VERID_Reg: *volatile VERID_REG = @ptrFromInt(scg_base_addr + 0x00);

/// Parameter Register
/// - reset value is 0xF80000FE
/// - 1111 1000 | 0000 0000 | 0000 0000 | 1111 1110
pub const PRAM_Reg: *volatile PRAM_REG = @ptrFromInt(scg_base_addr + 0x04);

/// SCG CLKOUT Configuration Register
/// - reset value is 0x3000000
/// - 0000 0011 | 0000 0000 | 0000 0000 | 0000 0000
pub const CLKOUTCNFG_Reg: *volatile CLKOUTCNFG_REG = @ptrFromInt(scg_base_addr + 0x20);

/// Slow IRC Configuration Register
/// - reset value is 0x1
pub const SCG_SIRCCFG_Reg: *volatile SIRCCFG_REG = @ptrFromInt(scg_base_addr + 0x208);

/// Fast IRC Configuration Register
/// - reset value is 0
pub const SCG_FIRCCFG_Reg: *volatile FIRCCFG_REG = @ptrFromInt(scg_base_addr + 0x308);

/// Clock Status Register
/// - reset value is 0x3000001
/// - 0000 0011 | 0000 0000 | 0000 0000 | 0000 0001
pub const CSR_REG = struct {
    pub const reg_ins = RegType.RegIns.init(scg_base_addr + 0x10);
    /// [0..3] Slow Clock Divide Ratio
    /// - 0000 Divide-by-1
    /// - 0001 Divide-by-2
    /// - 0010 Divide-by-3
    /// - 0011 Divide-by-4
    /// - 0100 Divide-by-5
    /// - 0101 Divide-by-6
    /// - 0110 Divide-by-7
    /// - 0111 Divide-by-8
    pub const DIVSLOW = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 4,
    };
    /// [4..7] Bus Clock Divide Ratio
    /// - 0000 Divide-by-1
    /// - 0001 Divide-by-2
    /// - 0010 Divide-by-3
    /// - 0011 Divide-by-4
    /// - 0100 Divide-by-5
    /// - 0101 Divide-by-6
    /// - 0110 Divide-by-7
    /// - 0111 Divide-by-8
    /// - 1000 Divide by 9
    /// - 1001 Divide by 10
    /// - 1010 Divide by 11
    /// - 1011 Divide by 12
    /// - 1100 Divide by 13
    /// - 1101 Divide by 14
    /// - 1110 Divide by 15
    /// - 1111 Divide by 16
    pub const DIVBUS = RegType.FieldDef{
        .bit_start = 4,
        .bit_len = 4,
    };

    /// [16..19] Core Clock Divide Ratio
    /// - 0000 Divide-by-1
    /// - 0001 Divide-by-2
    /// - 0010 Divide-by-3
    /// - 0011 Divide-by-4
    /// - 0100 Divide-by-5
    /// - 0101 Divide-by-6
    /// - 0110 Divide-by-7
    /// - 0111 Divide-by-8
    /// - 1000 Divide by 9
    /// - 1001 Divide by 10
    /// - 1010 Divide by 11
    /// - 1011 Divide by 12
    /// - 1100 Divide by 13
    /// - 1101 Divide by 14
    /// - 1110 Divide by 15
    /// - 1111 Divide by 16
    pub const DIVCORE = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 4,
    };

    /// [24..27] System Clock Source
    /// - 0001 System OSC (SOSC_CLK)
    /// - 0010 Slow IRC (SIRC_CLK)
    /// - 0011 Fast IRC (FIRC_CLK)
    /// - 0110 System PLL (SPLL_CLK)
    pub const SCS = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 4,
    };
};

/// Run Clock Control Register
/// - reset value is 0x3000001
/// - 0000 0011 | 0000 0000 | 0000 0000 | 0000 0001
pub const RCCR_REG = struct {
    pub const reg_ins = RegType.RegIns.init(scg_base_addr + 0x14);
    /// [0..3] Slow Clock Divide Ratio
    /// - 0000 Divide-by-1
    /// - 0001 Divide-by-2
    /// - 0010 Divide-by-3
    /// - 0011 Divide-by-4
    /// - 0100 Divide-by-5
    /// - 0101 Divide-by-6
    /// - 0110 Divide-by-7
    /// - 0111 Divide-by-8
    pub const DIVSLOW = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 4,
    };
    /// [4..7] Bus Clock Divide Ratio
    /// - 0000 Divide-by-1
    /// - 0001 Divide-by-2
    /// - 0010 Divide-by-3
    /// - 0011 Divide-by-4
    /// - 0100 Divide-by-5
    /// - 0101 Divide-by-6
    /// - 0110 Divide-by-7
    /// - 0111 Divide-by-8
    /// - 1000 Divide by 9
    /// - 1001 Divide by 10
    /// - 1010 Divide by 11
    /// - 1011 Divide by 12
    /// - 1100 Divide by 13
    /// - 1101 Divide by 14
    /// - 1110 Divide by 15
    /// - 1111 Divide by 16
    pub const DIVBUS = RegType.FieldDef{
        .bit_start = 4,
        .bit_len = 4,
    };

    /// [16..19] Core Clock Divide Ratio
    /// - 0000 Divide-by-1
    /// - 0001 Divide-by-2
    /// - 0010 Divide-by-3
    /// - 0011 Divide-by-4
    /// - 0100 Divide-by-5
    /// - 0101 Divide-by-6
    /// - 0110 Divide-by-7
    /// - 0111 Divide-by-8
    /// - 1000 Divide by 9
    /// - 1001 Divide by 10
    /// - 1010 Divide by 11
    /// - 1011 Divide by 12
    /// - 1100 Divide by 13
    /// - 1101 Divide by 14
    /// - 1110 Divide by 15
    /// - 1111 Divide by 16
    pub const DIVCORE = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 4,
    };

    /// [24..27] System Clock Source
    /// - 0001 System OSC (SOSC_CLK)
    /// - 0010 Slow IRC (SIRC_CLK)
    /// - 0011 Fast IRC (FIRC_CLK)
    /// - 0110 System PLL (SPLL_CLK)
    pub const SCS = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 4,
    };
};

/// VLPR Clock Control Register
/// - reset value is 0x2000001
/// - 0000 0010 | 0000 0000 | 0000 0000 | 0000 0001
pub const VCCR_REG = struct {
    pub const reg_ins = RegType.RegIns.init(scg_base_addr + 0x18);
    /// [0..3] Slow Clock Divide Ratio
    /// - 0000 Divide-by-1
    /// - 0001 Divide-by-2
    /// - 0010 Divide-by-3
    /// - 0011 Divide-by-4
    /// - 0100 Divide-by-5
    /// - 0101 Divide-by-6
    /// - 0110 Divide-by-7
    /// - 0111 Divide-by-8
    pub const DIVSLOW = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 4,
    };
    /// [4..7] Bus Clock Divide Ratio
    /// - 0000 Divide-by-1
    /// - 0001 Divide-by-2
    /// - 0010 Divide-by-3
    /// - 0011 Divide-by-4
    /// - 0100 Divide-by-5
    /// - 0101 Divide-by-6
    /// - 0110 Divide-by-7
    /// - 0111 Divide-by-8
    /// - 1000 Divide by 9
    /// - 1001 Divide by 10
    /// - 1010 Divide by 11
    /// - 1011 Divide by 12
    /// - 1100 Divide by 13
    /// - 1101 Divide by 14
    /// - 1110 Divide by 15
    /// - 1111 Divide by 16
    pub const DIVBUS = RegType.FieldDef{
        .bit_start = 4,
        .bit_len = 4,
    };

    /// [16..19] Core Clock Divide Ratio
    /// - 0000 Divide-by-1
    /// - 0001 Divide-by-2
    /// - 0010 Divide-by-3
    /// - 0011 Divide-by-4
    /// - 0100 Divide-by-5
    /// - 0101 Divide-by-6
    /// - 0110 Divide-by-7
    /// - 0111 Divide-by-8
    /// - 1000 Divide by 9
    /// - 1001 Divide by 10
    /// - 1010 Divide by 11
    /// - 1011 Divide by 12
    /// - 1100 Divide by 13
    /// - 1101 Divide by 14
    /// - 1110 Divide by 15
    /// - 1111 Divide by 16
    pub const DIVCORE = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 4,
    };

    /// [24..27] System Clock Source
    /// - 0001 System OSC (SOSC_CLK)
    /// - 0010 Slow IRC (SIRC_CLK)
    /// - 0011 Fast IRC (FIRC_CLK)
    /// - 0110 System PLL (SPLL_CLK)
    pub const SCS = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 4,
    };
};

/// HSRUN Clock Control Register
/// - reset value is 0x3000001
/// - 0000 0011 | 0000 0000 | 0000 0000 | 0000 0001
pub const HCCR_REG = struct {
    pub const reg_ins = RegType.RegIns.init(scg_base_addr + 0x1C);
    /// [0..3] Slow Clock Divide Ratio
    /// - 0000 Divide-by-1
    /// - 0001 Divide-by-2
    /// - 0010 Divide-by-3
    /// - 0011 Divide-by-4
    /// - 0100 Divide-by-5
    /// - 0101 Divide-by-6
    /// - 0110 Divide-by-7
    /// - 0111 Divide-by-8
    pub const DIVSLOW = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 4,
    };
    /// [4..7] Bus Clock Divide Ratio
    /// - 0000 Divide-by-1
    /// - 0001 Divide-by-2
    /// - 0010 Divide-by-3
    /// - 0011 Divide-by-4
    /// - 0100 Divide-by-5
    /// - 0101 Divide-by-6
    /// - 0110 Divide-by-7
    /// - 0111 Divide-by-8
    /// - 1000 Divide by 9
    /// - 1001 Divide by 10
    /// - 1010 Divide by 11
    /// - 1011 Divide by 12
    /// - 1100 Divide by 13
    /// - 1101 Divide by 14
    /// - 1110 Divide by 15
    /// - 1111 Divide by 16
    pub const DIVBUS = RegType.FieldDef{
        .bit_start = 4,
        .bit_len = 4,
    };

    /// [16..19] Core Clock Divide Ratio
    /// - 0000 Divide-by-1
    /// - 0001 Divide-by-2
    /// - 0010 Divide-by-3
    /// - 0011 Divide-by-4
    /// - 0100 Divide-by-5
    /// - 0101 Divide-by-6
    /// - 0110 Divide-by-7
    /// - 0111 Divide-by-8
    /// - 1000 Divide by 9
    /// - 1001 Divide by 10
    /// - 1010 Divide by 11
    /// - 1011 Divide by 12
    /// - 1100 Divide by 13
    /// - 1101 Divide by 14
    /// - 1110 Divide by 15
    /// - 1111 Divide by 16
    pub const DIVCORE = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 4,
    };

    /// [24..27] System Clock Source
    /// - 0001 System OSC (SOSC_CLK)
    /// - 0010 Slow IRC (SIRC_CLK)
    /// - 0011 Fast IRC (FIRC_CLK)
    /// - 0110 System PLL (SPLL_CLK)
    pub const SCS = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 4,
    };
};

/// System OSC Control Status Register
/// - reset value is 0
pub const SOSCCSR_REG = struct {
    pub const reg_ins = RegType.RegIns.init(scg_base_addr + 0x100);
    /// [0] System OSC Enable
    /// - 0 System OSC is disabled
    /// - 1 System OSC is enabled
    pub const SOSCEN = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 1,
    };
    /// [16] System OSC Clock Monitor
    /// - 0 System OSC Clock Monitor is disabled
    /// - 1 System OSC Clock Monitor is enabled
    pub const SOSCCM = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 1,
    };
    /// [17] System OSC Clock Monitor Reset Enable
    /// - 0 Clock Monitor generates interrupt when error detected
    /// - 1 Clock Monitor generates reset when error detected
    pub const SOSCCMRE = RegType.FieldDef{
        .bit_start = 17,
        .bit_len = 1,
    };

    /// [23] Lock Register
    /// - 0 This Control Status Register can be written.
    /// - 1 This Control Status Register cannot be written.
    pub const LK = RegType.FieldDef{
        .bit_start = 23,
        .bit_len = 1,
    };
    /// [24] System OSC Valid
    /// - 0 System OSC is not enabled or clock is not valid
    /// - 1 System OSC is enabled and output clock is valid
    pub const SOSCVLD = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 1,
    };
    /// [25] System OSC Selected
    /// - 0 System OSC is not the system clock source
    /// - 1 System OSC is the system clock source
    pub const SOSCSEL = RegType.FieldDef{
        .bit_start = 25,
        .bit_len = 1,
    };
    /// [26] System OSC Clock Error
    /// - 0 System OSC Clock Monitor is disabled or has not detected an error
    /// - 1 System OSC Clock Monitor is enabled and detected an error
    pub const SOSCERR = RegType.FieldDef{
        .bit_start = 26,
        .bit_len = 1,
    };
};

/// System OSC Divide Register
/// - reset value is 0
pub const SOSCDIV_REG = struct {
    pub const reg_ins = RegType.RegIns.init(scg_base_addr + 0x104);
    /// [0..2] System OSC Clock Divide 1
    /// - 000 Output disabled
    /// - 001 Divide by 1
    /// - 010 Divide by 2
    /// - 011 Divide by 4
    /// - 100 divide by 8
    /// - 101 divide by 16
    /// - 110 divide by 32
    /// - 111 divide by 64
    pub const SOSCDIV1 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 3,
    };

    /// [8..10] System OSC Clock Divide 2
    /// - 000 Output disabled
    /// - 001 Divide by 1
    /// - 010 Divide by 2
    /// - 011 Divide by 4
    /// - 100 divide by 8
    /// - 101 divide by 16
    /// - 110 divide by 32
    /// - 111 divide by 64
    pub const SOSCDIV2 = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 3,
    };
};

/// System Oscillator Configuration Register
/// - reset value is 0x10
/// - 0000 0000 | 0000 0000 | 0000 0000 | 0001 0000
pub const SOSCCFG_REG = struct {
    pub const reg_ins = RegType.RegIns.init(scg_base_addr + 0x108);
    /// [2] External Reference Select
    /// - 0 External reference clock selected
    /// - 1 XTAL crystal oscillator of OSC selected.
    pub const EREFS = RegType.FieldDef{
        .bit_start = 2,
        .bit_len = 1,
    };
    /// [3] High Gain Oscillator Select
    /// - 0 Configure crystal oscillator for low-gain operation
    /// - 1 Configure crystal oscillator for high-gain operation
    pub const HGO = RegType.FieldDef{
        .bit_start = 3,
        .bit_len = 1,
    };
    /// [4..5] System OSC Range Select
    /// - 01 Low frequency range selected for the crystal oscillator
    /// - 10 Medium frequency range selected for the crytstal oscillator 1Mhz-8Mhz
    /// - 11 High frequency range selected for the crystal oscillator
    pub const RANGE = RegType.FieldDef{
        .bit_start = 4,
        .bit_len = 2,
    };
};

/// Slow IRC Control Status Register
/// - reset value is 0x1000005
/// - 0000 0001 | 0000 0000 | 0000 0000 | 0000 0101
pub const SIRCCSR_REG = struct {
    pub const reg_ins = RegType.RegIns.init(scg_base_addr + 0x200);
    /// [0] Slow IRC Enable
    /// - 0 Slow IRC is disabled
    /// - 1 Slow IRC is enabled
    pub const SIRCEN = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 1,
    };
    /// [1] Slow IRC Stop Enable
    /// - 0 Slow IRC is disabled in supported Stop modes
    /// - 1 Slow IRC is enabled in supported Stop modes
    pub const SIRCSTEN = RegType.FieldDef{
        .bit_start = 1,
        .bit_len = 1,
    };
    /// [2] Slow IRC Low Power Enable
    /// - 0 Slow IRC is disabled in VLP modes
    /// - 1 Slow IRC is enabled in VLP modes
    pub const SIRCLPEN = RegType.FieldDef{
        .bit_start = 2,
        .bit_len = 1,
    };

    /// [23] Lock Register
    /// - 0 Control Status Register can be written.
    /// - 1 Control Status Register cannot be written.
    pub const LK = RegType.FieldDef{
        .bit_start = 23,
        .bit_len = 1,
    };
    /// [24] Slow IRC Valid
    /// - 0 Slow IRC is not enabled or clock is not valid
    /// - 1 Slow IRC is enabled and output clock is valid
    pub const SIRCVLD = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 1,
    };
    /// [25] Slow IRC Selected
    /// - 0 Slow IRC is not the system clock source
    /// - 1 Slow IRC is the system clock source
    pub const SIRCSEL = RegType.FieldDef{
        .bit_start = 25,
        .bit_len = 1,
    };
};

/// Slow IRC Divide Register
/// - reset value is 0
pub const SIRCDIV_REG = struct {
    pub const reg_ins = RegType.RegIns.init(scg_base_addr + 0x204);
    /// [0..2] Slow IRC Clock Divide 1
    /// - 000 Output disabled
    /// - 001 Divide by 1
    /// - 010 Divide by 2
    /// - 011 Divide by 4
    /// - 100 divide by 8
    /// - 101 divide by 16
    /// - 110 divide by 32
    /// - 111 divide by 64
    pub const SIRCDIV1 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 3,
    };

    /// [8..10] Slow IRC Clock Divide 2
    /// - 000 Output disabled
    /// - 001 Divide by 1
    /// - 010 Divide by 2
    /// - 011 Divide by 4
    /// - 100 divide by 8
    /// - 101 divide by 16
    /// - 110 divide by 32
    /// - 111 divide by 64
    pub const SIRCDIV2 = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 3,
    };
};

/// Fast IRC Control Status Register
/// - reset value is 0x3000001
/// - 0000 0011 | 0000 0000 | 0000 0000 | 0000 0001
pub const FIRCCSR_REG = struct {
    pub const reg_ins = RegType.RegIns.init(scg_base_addr + 0x300);
    /// [0] Fast IRC Enable
    /// - 0 Fast IRC is disabled
    /// - 1 Fast IRC is enabled
    pub const FIRCEN = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 1,
    };
    /// [3] Fast IRC Regulator Enable
    /// - 0 Fast IRC Regulator is enabled.
    /// - 1 Fast IRC Regulator is disabled.
    pub const FIRCREGOFF = RegType.FieldDef{
        .bit_start = 3,
        .bit_len = 1,
    };

    /// [23] Lock Register
    /// - 0 Control Status Register can be written.
    /// - 1 Control Status Register cannot be written.
    pub const LK = RegType.FieldDef{
        .bit_start = 23,
        .bit_len = 1,
    };
    /// [24] Fast IRC Valid status
    /// - 0 Fast IRC is not enabled or clock is not valid.
    /// - 1 Fast IRC is enabled and output clock is valid. The clock
    /// is valid once there is an output clock from the FIRC analog.
    pub const FIRCVLD = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 1,
    };
    /// [25] Fast IRC Selected status
    /// - 0 Fast IRC is not the system clock source
    /// - 1 Fast IRC is the system clock source
    pub const FIRCSEL = RegType.FieldDef{
        .bit_start = 25,
        .bit_len = 1,
    };
    /// [26] Fast IRC Clock Error
    /// - 0 Error not detected with the Fast IRC trimming.
    /// - 1 Error detected with the Fast IRC trimming.
    pub const FIRCERR = RegType.FieldDef{
        .bit_start = 26,
        .bit_len = 1,
    };
};

/// Fast IRC Divide Register
/// - reset value is 0x0
pub const FIRCDIV_REG = struct {
    pub const reg_ins = RegType.RegIns.init(scg_base_addr + 0x304);
    /// [0..2] Fast IRC Clock Divide 1
    /// - 000 Output disabled
    /// - 001 Divide by 1
    /// - 010 Divide by 2
    /// - 011 Divide by 4
    /// - 100 divide by 8
    /// - 101 divide by 16
    /// - 110 divide by 32
    /// - 111 divide by 64
    pub const FIRCDIV1 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 3,
    };
    /// [8..10] Fast IRC Clock Divide 2
    /// - 000 Output disabled
    /// - 001 Divide by 1
    /// - 010 Divide by 2
    /// - 011 Divide by 4
    /// - 100 divide by 8
    /// - 101 divide by 16
    /// - 110 divide by 32
    /// - 111 divide by 64
    pub const FIRCDIV2 = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 3,
    };
};

/// System PLL Control Status Register
/// - reset value is 0x0
pub const SPLLCSR_REG = struct {
    pub const reg_ins = RegType.RegIns.init(scg_base_addr + 0x600);
    /// [0] System PLL Enable
    /// - 0 System PLL is disabled
    /// - 1 System PLL is enabled
    pub const SPLLEN = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 1,
    };
    /// [16] System PLL Clock Monitor
    /// - 0 System PLL Clock Monitor is disabled
    /// - 1 System PLL Clock Monitor is enabled
    pub const SPLLCM = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 1,
    };
    /// [17] System PLL Clock Monitor Reset Enable
    /// - 0 Clock Monitor generates interrupt when error detected
    /// - 1 Clock Monitor generates reset when error detected
    pub const SPLLCMRE = RegType.FieldDef{
        .bit_start = 17,
        .bit_len = 1,
    };

    /// [23] Lock Register
    /// - 0 Control Status Register can be written.
    /// - 1 Control Status Register cannot be written.
    pub const LK = RegType.FieldDef{
        .bit_start = 23,
        .bit_len = 1,
    };
    /// [24] System PLL Valid
    /// - 0 System PLL is not enabled or clock is not valid
    /// - 1 System PLL is enabled and output clock is valid
    pub const SPLLVLD = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 1,
    };
    /// [25] System PLL Selected
    /// - 0 System PLL is not the system clock source
    /// - 1 System PLL is the system clock source
    pub const SPLLSEL = RegType.FieldDef{
        .bit_start = 25,
        .bit_len = 1,
    };
    /// [26] System PLL Clock Error
    /// - 0 System PLL Clock Monitor is disabled or has not detected an error
    /// - 1 System PLL Clock Monitor is enabled and detected an error.
    /// System PLL Clock Error flag will not set when System OSC
    /// is selected as its source and SOSCERR has set.
    pub const SPLLERR = RegType.FieldDef{
        .bit_start = 26,
        .bit_len = 1,
    };
};

/// System PLL Divide Register
/// - reset value is 0x0
pub const SPLLDIV_REG = struct {
    pub const reg_ins = RegType.RegIns.init(scg_base_addr + 0x604);
    /// [0..2] System PLL Clock Divide 1
    /// - 000 Output disabled
    /// - 001 Divide by 1
    /// - 010 Divide by 2
    /// - 011 Divide by 4
    /// - 100 divide by 8
    /// - 101 divide by 16
    /// - 110 divide by 32
    /// - 111 divide by 64
    pub const SPLLDIV1 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 3,
    };

    /// [8..10] System PLL Clock Divide 2
    /// - 000 Output disabled
    /// - 001 Divide by 1
    /// - 010 Divide by 2
    /// - 011 Divide by 4
    /// - 100 divide by 8
    /// - 101 divide by 16
    /// - 110 divide by 32
    /// - 111 divide by 64
    pub const SPLLDIV2 = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 3,
    };
};

/// System PLL Configuration Register
/// - reset value is 0x0
pub const SPLLCFG_REG = struct {
    pub const reg_ins = RegType.RegIns.init(scg_base_addr + 0x608);

    /// [8..10] PLL Reference Clock Divider
    pub const PREDIV = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 3,
    };

    /// [16..20] System PLL Multiplier
    pub const MULT = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 5,
    };
};
