//！The clock driver of s32k144
//! - date : 2025/03/10
//! - version : 0.2.0
//! - author : weng

const FieldSet = @import("s32k144_regs_mod").RegT.FieldSet;
const SCG_Reg = @import("s32k144_regs_mod").SCG_Regs;
// SOS
const SOSCDIV = SCG_Reg.SOSCDIV_REG;
const SOSCCFG = SCG_Reg.SOSCCFG_REG;
const SOSCCSR = SCG_Reg.SOSCCSR_REG;
// SPLL
const SPLLCSR = SCG_Reg.SPLLCSR_REG;
const SPLLDIV = SCG_Reg.SPLLDIV_REG;
const SPLLCFG = SCG_Reg.SPLLCFG_REG;
// RUN
const SIRCDIV = SCG_Reg.SIRCDIV_REG;
const RCCR = SCG_Reg.RCCR_REG;
const CSR = SCG_Reg.CSR_REG;

pub fn SOSC_Init() void {
    SOSC_InitAsXTAL16MHz();
    SPLL_InitAs160MHz();
    SetAsNormalRunMode80MHz();
}

fn SOSC_InitAsXTAL16MHz() void {
    // soscdiv1 16mhz
    // soscdiv2 8mhz
    SOSCDIV.reg_ins.updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = SOSCDIV.SOSCDIV1, .field_value = 0b001 },
        FieldSet{ .field_def = SOSCDIV.SOSCDIV2, .field_value = 0b010 },
    });
    // set range to high
    // high range from 8-40mhz
    // config to low gain,set to normal or low power mode
    // use internal xtal
    SOSCCFG.reg_ins.updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = SOSCCFG.RANGE, .field_value = 0b11 },
        FieldSet{ .field_def = SOSCCFG.HGO, .field_value = 0 },
        FieldSet{ .field_def = SOSCCFG.EREFS, .field_value = 1 },
    });
    // block here til sosccsr is ready for rewriting
    while (SOSCCSR.reg_ins.getFieldValue(SOSCCSR.LK) == 1) {}
    SOSCCSR.reg_ins.updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = SOSCCSR.SOSCEN, .field_value = 1 },
        FieldSet{ .field_def = SOSCCSR.LK, .field_value = 0 },
        FieldSet{ .field_def = SOSCCSR.SOSCCMRE, .field_value = 0 },
        FieldSet{ .field_def = SOSCCSR.SOSCCM, .field_value = 0 },
    });
    // read if soscsr is valid
    while (SOSCCSR.reg_ins.getFieldValue(SOSCCSR.SOSCVLD) == 0) {}
}

fn SPLL_InitAs160MHz() void {
    // make sure spll is unlocked
    while (SPLLCSR.reg_ins.getFieldValue(SPLLCSR.LK) == 1) {}
    // disbale the pll
    SPLLCSR.reg_ins.updateFieldValue(SPLLCSR.SPLLEN, 0);
    // set pll div
    // div1 set to 2 16/2 = 8mhz div1 clock
    // div2 set to 4 16/4 = 4mhz div2 clock
    //SCG_Rgstrs.SCG_SPLLDIV_Reg.SPLLDIV1 = 0b010;
    //SCG_Rgstrs.SCG_SPLLDIV_Reg.SPLLDIV2 = 0b011;
    SPLLDIV.reg_ins.updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = SPLLDIV.SPLLDIV1, .field_value = 0b010 },
        FieldSet{ .field_def = SPLLDIV.SPLLDIV2, .field_value = 0b011 },
    });
    // The SPLL_CLK = (VCO_CLK)/2
    // The VCO_CLK = SPLL_SOURCE/(PREDIV + 1) X (MULT + 16)
    // so the spll clock  = 16/2 * (24+16) = 160mhz
    //SCG_Rgstrs.SCG_SPLLCFG_Reg.PREDIV = 1;
    //SCG_Rgstrs.SCG_SPLLCFG_Reg.MULT = 24;
    SPLLCFG.reg_ins.updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = SPLLCFG.PREDIV, .field_value = 1 },
        FieldSet{ .field_def = SPLLCFG.MULT, .field_value = 24 },
    });
    // make sure spll is unlocked
    while (SPLLCSR.reg_ins.getFieldValue(SPLLCSR.LK) == 1) {}
    // enable the spll
    SPLLCSR.reg_ins.updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = SPLLCSR.SPLLEN, .field_value = 1 },
        FieldSet{ .field_def = SPLLCSR.SPLLCM, .field_value = 0 },
        FieldSet{ .field_def = SPLLCSR.SPLLCMRE, .field_value = 0 },
        FieldSet{ .field_def = SPLLCSR.LK, .field_value = 0 },
    });
    // wait until the spll is valid
    while (SPLLCSR.reg_ins.getFieldValue(SPLLCSR.SPLLVLD) == 0) {}
}

fn SetAsNormalRunMode80MHz() void {
    // enable IRC clock source
    SIRCDIV.reg_ins.updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = SIRCDIV.SIRCDIV1, .field_value = 1 },
        FieldSet{ .field_def = SIRCDIV.SIRCDIV2, .field_value = 1 },
    });
    // set clock src to spll
    // SCS 0b0110 - spll
    // divbus 1 - divide 2 bus clock 40mhz
    // divcore 1 - divide 2 system and core clock 80mhz
    // divslow 2 - divide 3 - falsh clock = 80/3
    RCCR.reg_ins.updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = RCCR.SCS, .field_value = 0b0110 },
        FieldSet{ .field_def = RCCR.DIVCORE, .field_value = 1 },
        FieldSet{ .field_def = RCCR.DIVBUS, .field_value = 1 },
        FieldSet{ .field_def = RCCR.DIVSLOW, .field_value = 2 },
    });
    // wait sys clock src is set to spll
    while (CSR.reg_ins.getFieldValue(CSR.SCS) != 0b0110) {}
}

// Share clock info to other drivers ------------------------------------
pub const MainClockNameT = enum(u8) {
    CORE_CLK = 0,
    BUS_CLK = 1,
    SLOW_CLK = 2,
    CLKOUT_CLK = 3,
    // peripheral clock src
    SIRC_CLK = 4,
    FIRC_CLK = 5,
    SOSC_CLK = 6,
    SPLL_CLK = 7,
    RTC_CLKIN_CLK = 8,
    SCG_CLKOUT_CLK = 9,
    SIRCDIV1_CLK = 10,
    SIRCDIV2_CLK = 11,
    FIRCDIV1_CLK = 12,
    FIRCDIV2_CLK = 13,
    SOSCDIV1_CLK = 14,
    SOSCDIV2_CLK = 15,
    SPLLDIV1_CLK = 16,
    SPLLDIV2_CLK = 17,
};
pub const SIMClockNameT = enum(u8) {
    SIM_FTM0_CLOCKSEL = 21,
    SIM_FTM1_CLOCKSEL = 22,
    SIM_FTM2_CLOCKSEL = 23,
    SIM_FTM3_CLOCKSEL = 24,
    SIM_CLKOUTSELL = 25,
    SIM_RTCCLK_CLK = 26,
    SIM_LPO_CLK = 27,
    SIM_LPO_1K_CLK = 28,
    SIM_LPO_32K_CLK = 29,
    SIM_LPO_128K_CLK = 30,
    SIM_EIM_CLK = 31,
    SIM_ERM_CLK = 32,
    SIM_DMA_CLK = 33,
    SIM_MPU_CLK = 34,
    SIM_MSCM_CLK = 35,
};
pub const PccClockNameT = enum(u8) {
    CMP0_CLK = 41,
    CRC0_CLK = 42,
    DMAMUX0_CLK = 43,
    EWM0_CLK = 44,
    PORTA_CLK = 45,
    PORTB_CLK = 46,
    PORTC_CLK = 47,
    PORTD_CLK = 48,
    PORTE_CLK = 49,
    RTC0_CLK = 50,
    PCC_END_OF_BUS_CLOCKS = 51,
    FlexCAN0_CLK = 52,
    FlexCAN1_CLK = 53,
    FlexCAN2_CLK = 54,
    PDB0_CLK = 55,
    PDB1_CLK = 56,
    PCC_END_OF_SYS_CLOCKS = 57,
    FTFC0_CLK = 58,
    PCC_END = 59,
    FTM0_CLK = 60,
    FTM1_CLK = 61,
    FTM2_CLK = 62,
    FTM3_CLK = 63,
    PCC_END_OF_ASYNCH_DIV1_CLOCKS = 64,
    ADC0_CLK = 65,
    ADC1_CLK = 66,
    FLEXIO0_CLK = 67,
    LPI2C0_CLK = 68,
    LPIT0_CLK = 69,
    LPSPI0_CLK = 70,
    LPSPI1_CLK = 71,
    LPSPI2_CLK = 72,
    LPTMR0_CLK = 73,
    LPUART0_CLK = 74,
    LPUART1_CLK = 75,
    LPUART2_CLK = 76,
    PCC_END_OF_ASYNCH_DIV2_CLOCKS = 77,
    PCC_END_OF_CLOCKS = 78,
    CLOCK_NAME_COUNT = 79,
};

/// Function Name : CLOCK_SYS_GetSysOscFreq
/// - Description   : Gets SCG System OSC clock frequency (SYSOSC).
pub fn CLOCK_SYS_GetSysOscFreq() u32 {}

pub fn CLOCK_SYS_GetFreq() void {}
