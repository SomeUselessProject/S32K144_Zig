//! The base timer config of this whole system
//! - include lptmr; lpit timer; ftm flex timer
//! - version: 0.1.0
//! - date: 2025/03/23
//! - author: weng

//#region Import Part
const ClockDefine = @import("../clock_mgr/ClockDefine.zig");
const PCC_ClockSelectT = ClockDefine.PCC_ClockSelectT;
const LptmrUsrConfig = @import("../lptmr_mgr/LptmrMgr.zig").LptmrUsrConfig;
//#endregion
// --------------------------------------------------------

//#region LPTMR Part
pub const lptmr_usr_cfg = LptmrUsrConfig{
    // 8Mhz in this sys
    // prescaler = 64 ; 8000 / 64 = 125_000 hz = 125Khz
    // every counter / 8us
    .pcc_clk_src = PCC_ClockSelectT.SOSCDIV2_CLK,
    // 100ms = 100_000 / 8 = 12_500 count
    // 200ms = 25_000
    // 5ms = 675
    // 10ms = 1_250
    // 20ms = 2_500
    .period_time_count = 1250,
};

//#endregion
// ----------------------------------------------------------
//#region LPIT Part

//#endregion
// ----------------------------------------------------------
