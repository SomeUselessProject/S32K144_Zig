//! The general system clock config by usr
//! - version: 0.1.0
//! - date: 20250321
//! - author: weng

//#region Import Part
const ClockDefine = @import("../clock_mgr/ClockDefine.zig");
// SOSC USER CONFIG
const SOSC_UsrCfg = ClockDefine.SOSC_UsrCfg;
const SCG_EREFS_T = ClockDefine.SCG_EREFS_T;
const HighGainOSC_T = ClockDefine.HighGainOSC_T;
const SOSC_RangeT = ClockDefine.SOSC_RangeT;
const SIRC_RangeT = ClockDefine.SIRC_RangeT;
const SCG_xDIV_T = ClockDefine.SCG_xDIV_T;
const CORE_DIV_T = ClockDefine.CORE_DIV_T;
// SIRC USER CONFIG
const SIRC_UsrCfg = ClockDefine.SlowIRC_UsrCfg;
// FIRC USER CONFIG
const FIRC_UsrCfg = ClockDefine.FastIRC_UsrCfg;
// SPLL USER CONFIG
const SPLL_UsrCfg = ClockDefine.SPLL_UsrCfg;
const SPLL_SrcT = ClockDefine.SPLL_SrcT;
const SPLL_PREDIV_T = ClockDefine.SPLL_PREDIV_T;
const SPLL_MULT_T = ClockDefine.SPLL_MULT_T;
// SYSTEM CLOCK CONFIG
const SysClk_UsrCfg = ClockDefine.SysClk_UsrCfg;
const SCG_RunModeT = ClockDefine.SCG_RunModeT;
const SysClockSrcT = ClockDefine.SysClockSrcT;
//#endregion
// -------------------------------------------------------
//#region SOSC CONFIG PART

/// The external xtal frequency is 16Mhz
/// - sosc 16Mhz
/// - soscdiv1 = 16 / (div1=1) = 16Mhz
/// - soscdiv2 = 16 / (div=2) = 8Mhz
/// ***
/// - spll_vco_clk = 16/(prediv + 1)*(16 + mult) = 16/2x40 = 320Mhz
/// - spll_out = spll_vco_clk / 2 = 160Mhz
/// - splldiv1 = spll_out / 2 = 80Mhz
/// - splldiv2 = spll_out / 4 = 40Mhz
/// ***
/// - core_clk(sys_clk) = spll_out / 2 = 160 / 2 = 80Mhz
/// - bus_clk = core_clk / 2 = 40Mhz
/// - flash_clk = core_clk / 3 = 80 /3 = 26.7Mhz
pub const xtal_freq: u32 = 16_000_000;

/// User Config for this board
/// - 16Mhz external xtal
/// - set range to 16Mhz
/// - set soscdiv1 = 16/1 = 16Mhz
/// - set soscdiv2 = 16/2 = 8Mhz
pub const sosc_usr_cfg: SOSC_UsrCfg = SOSC_UsrCfg{
    .erefs = SCG_EREFS_T.XTAL_OR_OSC,
    .hgo = HighGainOSC_T.LowGain,
    .range = SOSC_RangeT.SCG_SOSC_HIGH_FRE,
    .sosc_div1 = SCG_xDIV_T.DIV1,
    .sosc_div2 = SCG_xDIV_T.DIV2,
};

pub const sirc_usr_cfg: SIRC_UsrCfg = SIRC_UsrCfg{
    .range = SIRC_RangeT.SCG_SIRC_2M,
    .sirc_div1 = SCG_xDIV_T.DIV1,
    .sirc_div2 = SCG_xDIV_T.DIV1,
};

pub const firc_usr_cfg: FIRC_UsrCfg = FIRC_UsrCfg{
    .firc_div1 = SCG_xDIV_T.DIV1,
    .firc_div2 = SCG_xDIV_T.DIV1,
};

pub const spll_usr_cfg: SPLL_UsrCfg = SPLL_UsrCfg{
    .spll_src = SPLL_SrcT.SRC_SOSC,
    .spll_prediv = SPLL_PREDIV_T.PREDIV2,
    .spll_mult = SPLL_MULT_T.MULT40,
    .spll_div1 = SCG_xDIV_T.DIV2,
    .spll_div2 = SCG_xDIV_T.DIV4,
};

pub const sysClk_usr_cfg: SysClk_UsrCfg = SysClk_UsrCfg{
    .run_mode = SCG_RunModeT.NORMAL_RUN_MODE,
    .clk_src = SysClockSrcT.SYS_SPLL,
    .core_div = CORE_DIV_T.DIV2,
    .bus_div = CORE_DIV_T.DIV2,
    .slow_div = CORE_DIV_T.DIV3,
};
//#endregion
// --------------------------------------------------------
