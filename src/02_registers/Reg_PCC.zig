//! The PCC registers of s32k144
//! - the registers can be configured with single field
//! - date : 2025/02/21
//! - author : weng
//! - version : 0.2.0
//! - combine the registers which have sequence address

/// reset value is 0xC000_0000
const PCC_FTFC_REG = packed struct(u32) {
    _unused0_29: u30 = 0,
    /// [30]
    /// - Clock Gate Control / read-write
    /// - 0-Clock disabled
    /// - 1-Clock enabled. The current clock selection and divider options are locked.
    CGC: u1 = 1,
    /// [31]
    /// - Present / read-only
    /// - 0 Peripheral is not present.
    /// - 1 Peripheral is present.
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_DMAMUX_REG = packed struct(u32) {
    _unused0_29: u30 = 0,
    /// [30]
    /// Clock Gate Control / read-write
    /// - 0-Clock disabled
    /// - 1-Clock enabled. The current clock selection and divider options are locked.
    CGC: u1 = 0,
    /// [31]
    /// Present / read-only
    /// - 0 Peripheral is not present.
    /// - 1 Peripheral is present.
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_FlexCAN0_REG = packed struct(u32) {
    _unused0_29: u30 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_FlexCAN1_REG = packed struct(u32) {
    _unused0_29: u30 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_FTM3_REG = packed struct(u32) {
    _unused0_23: u24 = 0,
    /// [24..26]
    /// Peripheral Clock Source Select
    ///
    /// 000 - Clock is off. An external clock can be enabled for this peripheral.
    ///
    /// 001 - 111 Clock option 1-7
    PCS: u3 = 0,
    /// [27..29]
    _unused27_29: u3 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_ADC1_REG = packed struct(u32) {
    _unused0_23: u24 = 0,
    /// [24..26]
    /// - Peripheral Clock Source Select
    /// - 000 - Clock is off. An external clock can be enabled for this peripheral.
    /// - 001 - 111 Clock option 1-7
    PCS: u3 = 0,
    /// [27..29]
    _unused27_29: u3 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_FlexCAN2_REG = packed struct(u32) {
    _unused0_29: u30 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_LPSPI_REG = packed struct(u32) {
    _unused0_23: u24 = 0,
    /// [24..26]
    /// - Peripheral Clock Source Select
    /// - 000 - Clock is off. An external clock can be enabled for this peripheral.
    /// - 001 - 111 Clock option 1-7
    PCS: u3 = 0,
    /// [27..29]
    _unused27_29: u3 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_PDB1_REG = packed struct(u32) {
    _unused0_29: u30 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_CRC_REG = packed struct(u32) {
    _unused0_29: u30 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_PDB0_REG = packed struct(u32) {
    _unused0_29: u30 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_LPIT_REG = packed struct(u32) {
    _unused0_23: u24 = 0,
    /// [24..26]
    /// - Peripheral Clock Source Select
    /// - 000 - Clock is off. An external clock can be enabled for this peripheral.
    /// - 001 - 111 Clock option 1-7
    PCS: u3 = 0,
    /// [27..29]
    _unused27_29: u3 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_FTM_REG = packed struct(u32) {
    _unused0_23: u24 = 0,
    /// [24..26]
    /// - Peripheral Clock Source Select
    /// - 000 - Clock is off. An external clock can be enabled for this peripheral.
    /// - 001 - 111 Clock option 1-7
    PCS: u3 = 0,
    /// [27..29]
    _unused27_29: u3 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_ADC0_REG = packed struct(u32) {
    _unused0_23: u24 = 0,
    /// [24..26]
    /// - Peripheral Clock Source Select
    /// - 000 - Clock is off. An external clock can be enabled for this peripheral.
    /// - 001 - 111 Clock option 1-7
    PCS: u3 = 0,
    /// [27..29]
    _unused27_29: u3 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_RTC_REG = packed struct(u32) {
    _unused0_29: u30 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_LPTMR0_REG = packed struct(u32) {
    /// [0..2]
    /// - Peripheral Clock Divider Select
    /// - 000-111 divide 1 -8
    PCD: u3 = 0,
    /// [3]
    /// - Peripheral Clock Divider Fraction;
    /// - Fractional value is 0 or 1
    FRAC: u1 = 0,
    /// [4..23]
    _unused4_23: u20 = 0,
    /// [24..26]
    /// - Peripheral Clock Source Select
    /// - 000 - Clock is off. An external clock can be enabled for this peripheral.
    /// - 001 - 111 Clock option 1-7
    PCS: u3 = 0,
    /// [27..29]
    _unused27_29: u3 = 0,
    /// [30]
    /// - 0-clock disable;
    /// - 1-clock enable
    CGC: u1 = 0,
    /// [31]
    /// - 0-not;
    /// - 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_PORT_REG = packed struct(u32) {
    /// [0..29]
    _unused0_29: u30 = 0,
    /// [30]
    /// - 0-clock disable;
    /// - 1-clock enable
    CGC: u1 = 0,
    /// [31]
    /// - 0-not;
    /// - 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_FlexIO_REG = packed struct(u32) {
    _unused0_23: u24 = 0,
    /// [24..26]
    /// - Peripheral Clock Source Select
    /// - 000 - Clock is off. An external clock can be enabled for this peripheral.
    /// - 001 - 111 Clock option 1-7
    PCS: u3 = 0,
    /// [27..29]
    _unused27_29: u3 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_EWM_REG = packed struct(u32) {
    /// [0..29]
    _unused0_29: u30 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_LPI2C0_REG = packed struct(u32) {
    _unused0_23: u24 = 0,
    /// [24..26]
    /// - Peripheral Clock Source Select
    /// - 000 - Clock is off. An external clock can be enabled for this peripheral.
    /// - 001 - 111 Clock option 1-7
    PCS: u3 = 0,
    /// [27..29]
    _unused27_29: u3 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_LPUART_REG = packed struct(u32) {
    _unused0_23: u24 = 0,
    /// [24..26]
    /// - Peripheral Clock Source Select
    /// - 000 - Clock is off. An external clock can be enabled for this peripheral.
    /// - 001 - 111 Clock option 1-7
    PCS: u3 = 0,
    /// [27..29]
    _unused27_29: u3 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

/// reset value is 0x8000_0000
const PCC_CMP0_REG = packed struct(u32) {
    _unused0_29: u30 = 0,
    /// 0-clock disable; 1-clock enable
    CGC: u1 = 0,
    /// 0-not; 1-present
    PR: u1 = 1,
};

const baseAddress: u32 = 0x4006_5000;
pub const PCC_FTFC_Reg: *volatile PCC_FTFC_REG = @ptrFromInt(baseAddress + 0x80);
pub const PCC_DMAMUX_Reg: *volatile PCC_DMAMUX_REG = @ptrFromInt(baseAddress + 0x84);
pub const PCC_FlexCAN0_Reg: *volatile PCC_FlexCAN0_REG = @ptrFromInt(baseAddress + 0x90);
pub const PCC_FlexCAN1_Reg: *volatile PCC_FlexCAN1_REG = @ptrFromInt(baseAddress + 0x94);
pub const PCC_FTM3_Reg: *volatile PCC_FTM3_REG = @ptrFromInt(baseAddress + 0x98);
pub const PCC_ADC1_Reg: *volatile PCC_ADC1_REG = @ptrFromInt(baseAddress + 0x9C);
pub const PCC_FlexCAN2_Reg: *volatile PCC_FlexCAN2_REG = @ptrFromInt(baseAddress + 0xAC);

/// LPSPI Registers
pub const PCC_LPSPI_Regs: *volatile [3]PCC_LPSPI_REG = @ptrFromInt(baseAddress + 0xB0);
//pub const PCC_LPSPI0_Reg: *volatile PCC_LPSPI0_REG = @ptrFromInt(baseAddress + 0xB0);
//pub const PCC_LPSPI1_Reg: *volatile PCC_LPSPI1_REG = @ptrFromInt(baseAddress + 0xB4);
//pub const PCC_LPSPI2_Reg: *volatile PCC_LPSPI2_REG = @ptrFromInt(baseAddress + 0xB8);
pub const PCC_PDB1_Reg: *volatile PCC_PDB1_REG = @ptrFromInt(baseAddress + 0xC4);
pub const PCC_CRC_Reg: *volatile PCC_CRC_REG = @ptrFromInt(baseAddress + 0xC8);
pub const PCC_PDB0_Reg: *volatile PCC_PDB0_REG = @ptrFromInt(baseAddress + 0xD8);
pub const PCC_LPIT_Reg: *volatile PCC_LPIT_REG = @ptrFromInt(baseAddress + 0xDC);

// FTM regs
pub const PCC_FTM_Regs: *volatile [3]PCC_FTM_REG = @ptrFromInt(baseAddress + 0xE0);
//pub const PCC_FTM0_Reg: *volatile PCC_FTM0_REG = @ptrFromInt(baseAddress + 0xE0);
//pub const PCC_FTM1_Reg: *volatile PCC_FTM1_REG = @ptrFromInt(baseAddress + 0xE4);
//pub const PCC_FTM2_Reg: *volatile PCC_FTM2_REG = @ptrFromInt(baseAddress + 0xE8);
pub const PCC_ADC0_Reg: *volatile PCC_ADC0_REG = @ptrFromInt(baseAddress + 0xEC);
pub const PCC_RTC_Reg: *volatile PCC_RTC_REG = @ptrFromInt(baseAddress + 0xF4);

pub const PCC_LPTMR0_Reg: *volatile PCC_LPTMR0_REG = @ptrFromInt(baseAddress + 0x100);
/// PORT REGSs 0-4 map PORTA - PORTE
/// - PORTA - 0
/// - PORTB - 1
/// - PORTC - 2
/// - PORTD - 3
/// - PORTE - 4
pub const PCC_PORT_Regs: *volatile [5]PCC_PORT_REG = @ptrFromInt(baseAddress + 0x124);
//pub const PCC_PORTA_Reg: *volatile PCC_PORTA_REG = @ptrFromInt(baseAddress + 0x124);
//pub const PCC_PORTB_Reg: *volatile PCC_PORTB_REG = @ptrFromInt(baseAddress + 0x128);
//pub const PCC_PORTC_Reg: *volatile PCC_PORTC_REG = @ptrFromInt(baseAddress + 0x12C);
//pub const PCC_PORTD_Reg: *volatile PCC_PORTD_REG = @ptrFromInt(baseAddress + 0x130);
//pub const PCC_PORTE_Reg: *volatile PCC_PORTE_REG = @ptrFromInt(baseAddress + 0x134);

pub const PCC_FlexIO_Reg: *volatile PCC_FlexIO_REG = @ptrFromInt(baseAddress + 0x168);
pub const PCC_EWM_Reg: *volatile PCC_EWM_REG = @ptrFromInt(baseAddress + 0x184);
pub const PCC_LPI2C0_Reg: *volatile PCC_LPI2C0_REG = @ptrFromInt(baseAddress + 0x198);

// Lpuart registers
pub const PCC_LPUART_Regs: *volatile [3]PCC_LPUART_REG = @ptrFromInt(baseAddress + 0x1A8);
//pub const PCC_LPUART0_Reg: *volatile PCC_LPUART0_REG = @ptrFromInt(baseAddress + 0x1A8);
//pub const PCC_LPUART1_Reg: *volatile PCC_LPUART1_REG = @ptrFromInt(baseAddress + 0x1AC);
//pub const PCC_LPUART2_Reg: *volatile PCC_LPUART2_REG = @ptrFromInt(baseAddress + 0x1B0);
pub const PCC_CMP0_Reg: *volatile PCC_CMP0_REG = @ptrFromInt(baseAddress + 0x1CC);
