//! General Clock Define of s32k144

//#region SCG Define Part
/// Used for general registers div
pub const SCG_xDIV_T = enum(u3) {
    Disabled = 0,
    DIV1 = 1,
    DIV2 = 2,
    DIV4 = 3,
    DIV8 = 4,
    DIV16 = 5,
    DIV32 = 6,
    DIV64 = 7,
};

pub const CORE_DIV_T = enum(u4) {
    DIV1 = 0,
    DIV2 = 1,
    DIV3 = 2,
    DIV4 = 3,
    DIV5 = 4,
    DIV6 = 5,
    DIV7 = 6,
    DIV8 = 7,
    DIV9 = 8,
    DIV10 = 9,
    DIV11 = 10,
    DIV12 = 11,
    DIV13 = 12,
    DIV14 = 13,
    DIV15 = 14,
    DIV16 = 15,
};

/// used for spll prediv
/// - the real pre-div value will add 1
pub const SPLL_PREDIV_T = enum(u3) {
    PREDIV1 = 0,
    PREDIV2 = 1,
    PREDIV3 = 2,
    PREDIV4 = 3,
    PREDIV5 = 4,
    PREDIV6 = 5,
    PREDIV7 = 6,
    PREDIV8 = 7,
};

pub const SPLL_MULT_T = enum(u5) {
    MULT16 = 0,
    MULT17 = 1,
    MULT18 = 2,
    MULT19 = 3,
    MULT20 = 4,
    MULT21 = 5,
    MULT22 = 6,
    MULT23 = 7,
    MULT24 = 8,
    MULT25 = 9,
    MULT26 = 10,
    MULT27 = 11,
    MULT28 = 12,
    MULT29 = 13,
    MULT30 = 14,
    MULT31 = 15,
    MULT32 = 16,
    MULT33 = 17,
    MULT34 = 18,
    MULT35 = 19,
    MULT36 = 20,
    MULT37 = 21,
    MULT38 = 22,
    MULT39 = 23,
    MULT40 = 24,
    MULT41 = 25,
    MULT42 = 26,
    MULT43 = 27,
    MULT44 = 28,
    MULT45 = 29,
    MULT46 = 30,
    MULT47 = 31,
};

pub const SPLL_SrcT = enum(u1) {
    SRC_SOSC = 0,
    SRC_FIRC = 1,
};

pub const SCG_EREFS_T = enum(u1) {
    /// the external clock src
    EXTERNAL_CLK_REF = 0,
    /// XTAL crystal oscillator of OSC selected.
    XTAL_OR_OSC = 1,
};

pub const SysClockSrcT = enum(u4) {
    SYS_OSC = 0b0001,
    SlowIRC = 0b0010,
    FastIRC = 0b0011,
    SYS_SPLL = 0b0110,
};

pub const HighGainOSC_T = enum(u1) {
    /// Configure crystal oscillator for low-gain operation
    LowGain = 0,
    /// Configure crystal oscillator for high-gain operation
    HighGain = 1,
};

pub const SOSC_RangeT = enum(u2) {
    SCG_SOSC_RES = 0,
    /// Low frequency range selected for the crystal oscillator
    SCG_SOSC_LOW_FRE = 1,
    /// Medium frequency range selected for the crytstal oscillator
    /// - 1Mhz-8Mhz
    SCG_SOSC_MIDIUM_FRE = 2,
    /// High frequency range selected for the crystal oscillator
    /// - 8Mhz-40Mhz
    SCG_SOSC_HIGH_FRE = 3,
};

pub const SIRC_RangeT = enum(u2) {
    SCG_SIRC_2M = 0,
    SCG_SIRC_8M = 1,
};

pub const SCG_RunModeT = enum(u2) {
    /// normal run mode max 80Mhz
    NORMAL_RUN_MODE = 0,
    /// very low power mode max 4Mhz
    VLPR_MODE = 1,
    /// high speed run mode max 112Mhz
    HSRUN_MODE = 2,
};

pub const SCG_SleepModeT = enum(u2) {
    STOP1 = 0,
    STOP2 = 1,
    VLPS = 2,
};

/// The general user config for sosc initialization
pub const SOSC_UsrCfg = struct {
    erefs: SCG_EREFS_T,
    hgo: HighGainOSC_T,
    range: SOSC_RangeT,
    sosc_div1: SCG_xDIV_T,
    sosc_div2: SCG_xDIV_T,
};

pub const SlowIRC_UsrCfg = struct {
    range: SIRC_RangeT,
    sirc_div1: SCG_xDIV_T,
    sirc_div2: SCG_xDIV_T,
};

pub const FastIRC_UsrCfg = struct {
    firc_div1: SCG_xDIV_T,
    firc_div2: SCG_xDIV_T,
};

pub const SPLL_UsrCfg = struct {
    spll_src: SPLL_SrcT,
    spll_prediv: SPLL_PREDIV_T,
    spll_mult: SPLL_MULT_T,
    spll_div1: SCG_xDIV_T,
    spll_div2: SCG_xDIV_T,
};

pub const SysClk_UsrCfg = struct {
    run_mode: SCG_RunModeT,
    clk_src: SysClockSrcT,
    slow_div: CORE_DIV_T,
    bus_div: CORE_DIV_T,
    core_div: CORE_DIV_T,
};

//#endregion
// ----------------------------------------------------------
//#region PCC Clock Define
pub const PCC_ClockSelectT = enum(u3) {
    SOSCDIV2_CLK = 0b001,
    SIRCDIV2_CLK = 0b010,
    FIRCDIV2_CLK = 0b011,
    SPLLDIV2_CLK = 0b110,
};
//#endregion
// ----------------------------------------------------------

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

pub const PeriphClockSrcT = enum(u8) {
    CLK_SRC_OFF = 0,
    CLK_SRC_SOSC = 1,
    CLK_SRC_SIRC = 2,
    CLK_SRC_FIRC = 3,
    CLK_SRC_SPLL = 6,
};

pub const PeripheralClockCfg = struct {
    pcc_clock_name: PccClockNameT,
    is_clock_gate: bool,
    clock_src: PeriphClockSrcT,
    /// Peripheral clock fractional value
    frac_value: u1 = 0,
    div_value: u3 = 0,
};
