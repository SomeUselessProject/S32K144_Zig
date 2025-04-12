//! The base driver and control of lptmr
//! - low power timer of s32k144
//! - the timer will work as period interrupt mode (trigger unit is ms)
//! - the clock source is set to pcc selected default
//! - the timer is working in interrupt mode as default
//! - the clock is not so accurate so just use it in some unsensitive case
//! - version: 0.1.0
//! - date: 2025/03/23
//! - author: weng

//#region Import
const GenericSts = @import("../SystemStatus.zig").GeneralSts;
const LPTMR_Regs = @import("s32k144_regs_mod").LPTMR_Regs;
const NVIC_Mgr = @import("../nvic_mgr/NvicMgr.zig");
const ClockMgr = @import("../clock_mgr/ClockMgr.zig");
const ClockDefine = @import("../clock_mgr/ClockDefine.zig");
const PCC_ClockSelectT = ClockDefine.PCC_ClockSelectT;
const IQRnType = NVIC_Mgr.IQRnType;
const IsrHandlerFunc = NVIC_Mgr.IsrHandlerFunc;
const lptmr_usr_cfg = @import("../sys_user_config/TimerUsrConfig.zig").lptmr_usr_cfg;
//#endregion
// ----------------------------------------------------------------------
//#region General Define
pub const LptmrClkSrcT = enum(u2) {
    SIRCDIV2 = 0,
    LPO_1KHZ = 1,
    RTC = 2,
    PCC_SELECTED = 3,
};

pub const LptmrUsrConfig = struct {
    /// 周期触发的时间计数
    /// - the period time interval count (ms)
    /// - u16 max 65_535
    period_time_count: u16 = 10_000,
    pcc_clk_src: PCC_ClockSelectT = PCC_ClockSelectT.SOSCDIV2_CLK,
};

pub const LptmrUsrTaskCallback = *const fn () void;
//#endregion
// ----------------------------------------------------------------------

var lptmr0_clk_frq: u32 = 0;
var lptmr0_usr_tasks: [3]?LptmrUsrTaskCallback = .{ null, null, null };

pub inline fn GetLptmr0PeriodMsInterval() u32 {
    return 100;
}

fn ClearLptmr0CompareFlag() void {
    if (LPTMR_Regs.LPTMR0_CSR.TCF == 1) {
        // clear it by writing a logic 1
        LPTMR_Regs.LPTMR0_CSR.TCF = 1;
    }
    // Read-after-write sequence to guarantee required serialization of memory operations
    _ = LPTMR_Regs.LPTMR0_CSR.*;
}

comptime {
    @export(&LPTMR0_IRQHandler, .{ .name = "LPTMR0_IRQHandler", .linkage = .strong });
}

/// the function override the handler
fn LPTMR0_IRQHandler() callconv(.C) void {
    // coding
    ClearLptmr0CompareFlag();
    // user's operation
    for (lptmr0_usr_tasks) |taskCallback| {
        // 解包这个可能为空的用户回调
        if (taskCallback) |callback| {
            callback();
        }
    }
}

/// User can register a period task to lptmr0
/// - when the registered task is > 3 ; an error will be return
pub fn LPTMR0_RegisterTask(task_callback: LptmrUsrTaskCallback) GenericSts {
    for (0..lptmr0_usr_tasks.len) |i| {
        if (lptmr0_usr_tasks[0] == null) {
            lptmr0_usr_tasks[i] = task_callback;
            return GenericSts.STATUS_SUCCESS;
        }
    }
    return GenericSts.STATUS_ERROR;
}

/// These registers cannot be attached at first
fn LPTMR_Reset() void {
    // disable dma
    LPTMR_Regs.LPTMR0_CSR.TDRE = 0;
    // disable free running mode ; compare the value
    LPTMR_Regs.LPTMR0_CSR.TFC = 0;
    // set working mode to timer
    LPTMR_Regs.LPTMR0_CSR.TMS = 0;
    LPTMR_Regs.LPTMR0_CMR.COMPARE = 0;
}

pub fn LPTMR_InitAsPccSelected(comptime lptmr_index: u1) void {
    comptime {
        if (lptmr_index != 0) @compileError("only lptmr0 in s32k144");
    }

    _ = ClockMgr.PCC_CLK_Mgr.SetLptmrClkSrcInPccSelected(
        0,
        lptmr_usr_cfg.pcc_clk_src,
        &lptmr0_clk_frq,
    );
    LPTMR_Regs.LPTMR0_PSR.PCS = @intFromEnum(LptmrClkSrcT.PCC_SELECTED);
    // using prescaler 64
    LPTMR_Regs.LPTMR0_PSR.PRESCALE = 0b0101;
    LPTMR_Regs.LPTMR0_PSR.PBYP = 0;
    LPTMR_Regs.LPTMR0_CMR.COMPARE = lptmr_usr_cfg.period_time_count;
    // enable interrupt
    LPTMR_Regs.LPTMR0_CSR.TIE = 1;
    // enable the lptmr
    LPTMR_Regs.LPTMR0_CSR.TEN = 1;
    NVIC_Mgr.NVIC_EnableInterrupt(IQRnType.IRQn_LPTMR0);
}
