//! The ADC registers of s32k144
//! - Analog-to-Digital Converter
//! - date : 2025/03/02
//! - author : weng
//! - version : 0.1.0
//! - adc registers may update the fields at same time, so they are all reg ins

const RegType = @import("./RegType.zig");

const adc0_base_addr: u32 = 0x4003_B000;
const adc1_base_addr: u32 = 0x4002_7000;

/// ADC Status and Control Register 1
/// - reset value is 0x0
/// - number 16
/// - dimIncrement 0x4
pub const ADC_SC1_Arr = struct {
    pub const reg_ins_arr: [2][16]RegType.RegIns = [2][16]RegType.RegIns{
        RegType.RegIns.initRange(adc0_base_addr, 0x4, 16),
        RegType.RegIns.initRange(adc1_base_addr, 0x4, 16),
    };

    /// Input channel select
    /// - This field is different in s32k14x series
    /// - for s32k144 the info
    /// - 00000 ~ 10011(0-19) - Exernal channel 0-19 is selected as input.
    /// - 10101 ~ 10111(21-23) Internal channel 0-2 is selected as input.
    /// - 11010 Temp Sensor
    /// - 11011 Band Gap
    /// - 11100 Internal channel 3 is selected as input.
    /// - 11101 VREFSH is selected as input. Voltage reference selected is
    /// determined by SC2[REFSEL].
    /// - 11110 VREFSL is selected as input. Voltage reference selected is
    /// determined by SC2[REFSEL].
    /// - 11111 Module is disabled
    pub const ADCH = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 5,
    };

    /// Interrupt Enable
    /// - 0 Conversion complete interrupt is disabled.
    /// - 1 Conversion complete interrupt is enabled.
    pub const AIEN = RegType.FieldDef{
        .bit_start = 6,
        .bit_len = 1,
    };

    /// Conversion Complete Flag
    /// - 0 Conversion is not completed.
    /// - 1 Conversion is completed.
    pub const COCO = RegType.FieldDef{
        .bit_start = 7,
        .bit_len = 1,
    };
};

/// ADC Configuration Register 1
/// - address offset 0x40
/// - reset value is 0
pub const ADC_CFG1 = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0x40),
        RegType.RegIns.init(adc1_base_addr + 0x40),
    };
    /// Input Clock Select
    /// - 00 Alternate clock 1 (ADC_ALTCLK1)
    /// - 01 Alternate clock 2 (ADC_ALTCLK2)
    /// - 10 Alternate clock 3 (ADC_ALTCLK3)
    /// - 11 Alternate clock 4 (ADC_ALTCLK4)
    pub const ADICLK = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 2,
    };

    /// Conversion mode selection
    /// - 00 8-bit conversion.
    /// - 01 12-bit conversion.
    /// - 10 10-bit conversion.
    pub const MODE = RegType.FieldDef{
        .bit_start = 2,
        .bit_len = 2,
    };

    /// Clock Divide Select
    /// - 00 The divide ratio is 1 and the clock rate is input clock.
    /// - 01 The divide ratio is 2 and the clock rate is (input clock)/2.
    /// - 10 The divide ratio is 4 and the clock rate is (input clock)/4.
    /// - 11 The divide ratio is 8 and the clock rate is (input clock)/8.
    pub const ADIV = RegType.FieldDef{
        .bit_start = 5,
        .bit_len = 2,
    };

    /// Clear Latch Trigger in Trigger Handler Block
    pub const CLRLTRG = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 1,
    };
};

/// ADC Configuration Register 2
/// - address offset is 0x44
/// - reset value is 0xC
pub const ADC_CFG2 = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0x44),
        RegType.RegIns.init(adc1_base_addr + 0x44),
    };
    /// Sample Time Select
    pub const SMPLTS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 8,
    };
};

/// ADC Data Result Registers
/// - address offset 0x48
/// - reset value is 0
pub const ADC_RS_Arr = struct {
    pub const reg_ins_arr: [2][16]RegType.RegIns = [2][16]RegType.RegIns{
        RegType.RegIns.initRange(adc0_base_addr + 0x48, 0x4, 16),
        RegType.RegIns.initRange(adc1_base_addr + 0x48, 0x4, 16),
    };

    /// Data result
    pub const DataResult = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 12,
    };
};

/// Compare Value Registers
/// - address offset is 0x88
/// - reset value is 0
pub const ADC_CVS_Arr = struct {
    pub const reg_ins_arr: [2][2]RegType.RegIns = [2][2]RegType.RegIns{
        RegType.RegIns.initRange(adc0_base_addr + 0x88, 0x4, 2),
        RegType.RegIns.initRange(adc1_base_addr + 0x88, 0x4, 2),
    };
    /// Compare Value
    pub const CV = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 16,
    };
};

/// Status and Control Register 2
/// - address offset is 0x90
/// - reset value is 0
pub const ADC_SC2 = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0x90),
        RegType.RegIns.init(adc1_base_addr + 0x90),
    };

    /// Voltage Reference Selection
    /// - 0 Default voltage reference pin pair, that is, external pins VREFH and VREFL
    /// - 1 Alternate reference voltage, that is, VALTH. This voltage may be additional external pin or internal source
    /// depending on the MCU configuration. See the chip configuration information for details specific to this MCU.
    pub const REFSEL = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 2,
    };

    /// DMA Enable
    /// - 0 DMA is disabled.
    /// - 1 DMA is enabled and will assert the ADC DMA request during
    /// an ADC conversion complete event , which is indicated when
    /// any SC1n[COCO] flag is asserted.
    pub const DMAEN = RegType.FieldDef{
        .bit_start = 2,
        .bit_len = 1,
    };

    /// Compare Function Range Enable
    pub const ACREN = RegType.FieldDef{
        .bit_start = 3,
        .bit_len = 1,
    };

    /// Compare Function Greater Than Enable
    pub const ACFGT = RegType.FieldDef{
        .bit_start = 4,
        .bit_len = 1,
    };

    /// Compare Function Enable
    /// - 0 Compare function disabled.
    /// - 1 Compare function enabled.
    pub const ACFE = RegType.FieldDef{
        .bit_start = 5,
        .bit_len = 1,
    };

    /// Conversion Trigger Select
    /// - 0 Software trigger selected.
    /// - 1 Hardware trigger selected.
    pub const ADTRG = RegType.FieldDef{
        .bit_start = 6,
        .bit_len = 1,
    };

    /// Conversion Active
    /// - 0 Conversion not in progress.
    /// - 1 Conversion in progress.
    pub const ADACT = RegType.FieldDef{
        .bit_start = 7,
        .bit_len = 1,
    };

    /// Trigger Process Number
    pub const TRGPRNUM = RegType.FieldDef{
        .bit_start = 13,
        .bit_len = 2,
    };

    /// Trigger Status
    /// - 0000 No trigger request has been latched
    /// - 0001 A trigger request has been latched
    pub const TRGSTLAT = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 4,
    };

    /// Error in Multiplexed Trigger Request
    /// - 0000 No error has occurred
    /// - 0001 An error has occurred
    pub const TRGSTERR = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 4,
    };
};

/// Status and Control Register 3
/// - address offset is 0x94
/// - reset value is 0
pub const ADC_SC3 = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0x94),
        RegType.RegIns.init(adc1_base_addr + 0x94),
    };
    /// Hardware Average Select
    /// - 00 4 samples averaged.
    /// - 01 8 samples averaged.
    /// - 10 16 samples averaged.
    /// - 11 32 samples averaged.
    pub const AVGS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 2,
    };

    /// Hardware Average Enable
    /// - 0 Hardware average function disabled.
    /// - 1 Hardware average function enabled.
    pub const AVGE = RegType.FieldDef{
        .bit_start = 2,
        .bit_len = 1,
    };

    /// Continuous Conversion Enable
    /// - 0 One conversion will be performed (or one set of conversions, if AVGE is set) after a conversion is initiated.
    /// - 1  Continuous conversions will be performed (or continuous
    /// sets of conversions, if AVGE is set) after a conversion is initiated.
    pub const ADCO = RegType.FieldDef{
        .bit_start = 3,
        .bit_len = 1,
    };

    /// Calibration
    pub const CAL = RegType.FieldDef{
        .bit_start = 7,
        .bit_len = 1,
    };
};

/// BASE Offset Register
/// - offset is 0x98
/// - reset value is 0x40
pub const ADC_BASE_OFS = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0x98),
        RegType.RegIns.init(adc1_base_addr + 0x98),
    };

    /// Base Offset Error Correction Value
    pub const BA_OFS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 8,
    };
};

/// ADC Offset Correction Register
/// - offset is 0x9C
/// - reset value is 0
pub const ADC_OFS = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0x9C),
        RegType.RegIns.init(adc1_base_addr + 0x9C),
    };
    /// Offset Error Correction Value
    pub const OFS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 16,
    };
};

/// USER Offset Correction Register
/// - offset is 0xA0
/// - reset value is 0
pub const ADC_USR_OFS = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xA0),
        RegType.RegIns.init(adc1_base_addr + 0xA0),
    };
    /// USER Offset Error Correction Value
    pub const USR_OFS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 8,
    };
};

/// ADC X Offset Correction Register
/// - address offset is 0xA4
/// - reset value is 0x30
pub const ADC_XOFS = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xA4),
        RegType.RegIns.init(adc1_base_addr + 0xA4),
    };
    /// X offset error correction value
    pub const XOFS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 6,
    };
};

/// ADC Y Offset Correction Register
/// - address offset is 0xA8
/// - reset value is 0x37
pub const ADC_YOFS = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xA8),
        RegType.RegIns.init(adc1_base_addr + 0xA8),
    };
    /// Y offset error correction value
    pub const YOFS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 8,
    };
};

/// ADC Gain Register
/// - address offset is 0xAC
/// - reset value is 0x2F0
pub const ADC_G = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xAC),
        RegType.RegIns.init(adc1_base_addr + 0xAC),
    };
    /// Gain error adjustment factor for the overall conversion
    pub const G = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 11,
    };
};

/// ADC User Gain Register
/// - address offset is 0xB0
/// - reset value is 0x04
pub const ADC_UG = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xB0),
        RegType.RegIns.init(adc1_base_addr + 0xB0),
    };
    /// User gain error correction value
    pub const UG = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 10,
    };
};

/// ADC General Calibration Value Register S
/// - address offset is 0xB4
/// - reset value is 0x2E
pub const ADC_CLPS = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xB4),
        RegType.RegIns.init(adc1_base_addr + 0xB4),
    };
    /// Calibration Value
    pub const CLPS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 7,
    };
};

/// ADC Plus-Side General Calibration Value Register 3
/// - address offset is 0xB8
/// - reset value is 0x180
pub const ADC_CLP3 = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xB8),
        RegType.RegIns.init(adc1_base_addr + 0xB8),
    };
    /// Calibration Value
    pub const CLP3 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 10,
    };
};

/// ADC Plus-Side General Calibration Value Register 2
/// - address offset is 0xBC
/// - reset value is 0xB8
pub const ADC_CLP2 = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xBC),
        RegType.RegIns.init(adc1_base_addr + 0xBC),
    };
    /// Calibration Value
    pub const CLP2 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 10,
    };
};

/// ADC Plus-Side General Calibration Value Register 1
/// - address offset is 0xC0
/// - reset value is 0x5C
pub const ADC_CLP1 = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xC0),
        RegType.RegIns.init(adc1_base_addr + 0xC0),
    };
    /// Calibration Value
    pub const CLP1 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 9,
    };
};

/// ADC Plus-Side General Calibration Value Register 0
/// - address offset is 0xC4
/// - reset value is 0x2E
pub const ADC_CLP0 = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xC4),
        RegType.RegIns.init(adc1_base_addr + 0xC4),
    };
    /// Calibration Value
    pub const CLP0 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 8,
    };
};

/// ADC Plus-Side General Calibration Value Register X
/// - address offset is 0xC8
/// - reset value is 0x0
pub const ADC_CLPX = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xC8),
        RegType.RegIns.init(adc1_base_addr + 0xC8),
    };
    /// Calibration Value
    pub const CLPX = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 7,
    };
};

/// ADC Plus-Side General Calibration Value Register 9
/// - address offset is 0xCC
/// - reset value is 0
pub const ADC_CLP9 = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xCC),
        RegType.RegIns.init(adc1_base_addr + 0xCC),
    };
    /// Calibration Value
    pub const CLP9 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 7,
    };
};

/// ADC General Calibration Offset Value Register S
/// - address offset is 0xD0
/// - reset value is 0x0
pub const ADC_CLPS_OFS = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xD0),
        RegType.RegIns.init(adc1_base_addr + 0xD0),
    };
    /// CLPS Offset
    pub const CLPS_OFS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 4,
    };
};

/// ADC Plus-Side General Calibration Offset Value Register 3
/// - address offset is 0xD4
/// - reset value is 0x0
pub const ADC_CLP3_OFS = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xD4),
        RegType.RegIns.init(adc1_base_addr + 0xD4),
    };
    /// CLP3 Offset
    pub const CLP3_OFS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 4,
    };
};

/// ADC Plus-Side General Calibration Offset Value Register 2
/// - address offset is 0xD8
/// - reset value is 0x0
pub const ADC_CLP2_OFS = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xD8),
        RegType.RegIns.init(adc1_base_addr + 0xD8),
    };
    /// CLP2 Offset
    pub const CLP2_OFS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 4,
    };
};

/// ADC Plus-Side General Calibration Offset Value Register 1
/// - address offset is 0xDC
/// - reset value is 0
pub const ADC_CLP1_OFS = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xDC),
        RegType.RegIns.init(adc1_base_addr + 0xDC),
    };
    /// CLP1 Offset
    pub const CLP1_OFS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 4,
    };
};

/// ADC Plus-Side General Calibration Offset Value Register 0
/// - address offset is 0xE0
/// - reset value is 0
pub const ADC_CLP0_OFS = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xE0),
        RegType.RegIns.init(adc1_base_addr + 0xE0),
    };
    /// CLP0 Offset
    pub const CLP0_OFS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 4,
    };
};

/// ADC Plus-Side General Calibration Offset Value Register X
/// - address offset is 0xE4
/// - reset value is 0x440
pub const ADC_CLPX_OFS = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xE4),
        RegType.RegIns.init(adc1_base_addr + 0xE4),
    };
    /// CLPX Offset
    pub const CLPX_OFS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 12,
    };
};

/// ADC Plus-Side General Calibration Offset Value Register 9
/// - address offset is 0xE8
/// - reset value is 0x240
pub const ADC_CLP9_OFS = struct {
    pub const reg_ins_arr: [2]RegType.RegIns = [2]RegType.RegIns{
        RegType.RegIns.init(adc0_base_addr + 0xE8),
        RegType.RegIns.init(adc1_base_addr + 0xE8),
    };
    /// CLP9 Offset
    pub const CLP9_OFS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 12,
    };
};
