//! The base driver and manager of low power interrupt timer
//! - p_index in this file means peripheral index, s32k144 only got one lpit module
//! - ch_index means channel index in lpit module
//! author: weng
//! date: 2025/03/19
//! version: 0.1.0

const GenericSts = @import("../SystemStatus.zig").GenericSts;
const LpitHW = @import("./LpitHwAccess.zig");
const LpitTmrModesT = LpitHW.LpitTmrModesT;
const LpitTriggerSrcT = LpitHW.LpitTriggerSrcT;
// Interrupt manager
const NVIC_Mgr = @import("s32k144_genericSys_mod").NVIC_Mgr;
const IQRnT = NVIC_Mgr.IQRnType;
const IsrHandlerFunc = NVIC_Mgr.IsrHandlerFunc;

//#region General Define
/// The LPIT Freq configured
const crt_lpit_freq: u32 = 0;
const MAX_PERIOD_COUNT: u32 = 0xFFFF_FFFF;
const MAX_PERIOD_COUNT_IN_DUAL_16BIT_MODE: u32 = 0x1_FFFE;
const MAX_PERIOD_COUNT_16_BIT: u32 = 0xFFFF;

pub const LpitUsrConfig = struct {
    EnableRunInDebug: bool = false,
    EnableRunInDoze: bool = false,
};

pub const LpitPeriodicUnitsT = enum(u1) {
    /// counter
    UNITS_COUNT = 0,
    /// us
    UNITS_MICROSECONDS = 1,
};

pub const LpitUsrChannelCfg = struct {
    timer_mode: LpitTmrModesT = LpitTmrModesT.PERIODIC_COUNTER_32BIT,
    period_units: LpitPeriodicUnitsT = LpitPeriodicUnitsT.UNITS_MICROSECONDS,
    period_value: u32 = 1_000_000,
    trig_src: LpitTriggerSrcT = LpitTriggerSrcT.EXTERNAL,
    /// Selects one trigger from the internal trigger sources
    /// this field makes sense if trigger source is internal
    trig_select: u2 = 0,
    is_reloadOnTrig: bool = false,
    is_stopOnInterrupt: bool = false,
    is_startOnTrig: bool = false,
    is_chainChannel_enabled: bool = false,
    is_interrupt_enabled: bool = false,
};

//#endregion
// ----------------------------------------------------------------------------------
//#region Interrupt Part
const lpit0_irq_types: [4]IQRnT = .{
    IQRnT.IRQn_LPIT0_Ch0,
    IQRnT.IRQn_LPIT0_Ch1,
    IQRnT.IRQn_LPIT0_Ch2,
    IQRnT.IRQn_LPIT0_Ch3,
};

const lpit0_irq_handlers: [4]IsrHandlerFunc = .{
    LPIT0_CH0_IRQHandler,
    LPIT0_CH1_IRQHandler,
    LPIT0_CH2_IRQHandler,
    LPIT0_CH3_IRQHandler,
};

fn LPIT0_CH0_IRQHandler() callconv(.C) void {
    // do something here...
    if (LPIT_DRV_GetInterruptFlagTimerChannels(0, 0) == 1) {
        LPIT_DRV_ClearInterruptFlagTimerChannels(0, 0);
        // the usr lpit call back here
    }
}
fn LPIT0_CH1_IRQHandler() callconv(.C) void {
    // do something here...
}
fn LPIT0_CH2_IRQHandler() callconv(.C) void {
    // do something here...
}
fn LPIT0_CH3_IRQHandler() callconv(.C) void {
    // do something here...
}
//#endregion
// ----------------------------------------------------------------------------------
//#region LPIT Driver and other api
pub fn LPIT_DRV_GetDefaultConfig(usr_cfg: *LpitUsrConfig) void {
    usr_cfg.EnableRunInDebug = false;
    usr_cfg.EnableRunInDoze = false;
}

/// Function Name : LPIT_DRV_GetDefaultChanConfig
/// - Description   : This function gets default timer channel configuration structure.
/// - the function can also used to clear the config to default value
pub fn LPIT_DRV_GetDefaultChanConfig(usr_ch_cfg: *LpitUsrChannelCfg) void {
    usr_ch_cfg.timer_mode = LpitTmrModesT.PERIODIC_COUNTER_32BIT;
    usr_ch_cfg.period_units = LpitPeriodicUnitsT.UNITS_MICROSECONDS;
    usr_ch_cfg.period_value = 1_000_000;
    usr_ch_cfg.trig_src = LpitTriggerSrcT.EXTERNAL;
    usr_ch_cfg.trig_select = 0;
    usr_ch_cfg.is_reloadOnTrig = false;
    usr_ch_cfg.is_stopOnInterrupt = false;
    usr_ch_cfg.is_startOnTrig = false;
    usr_ch_cfg.is_chainChannel_enabled = false;
    usr_ch_cfg.is_interrupt_enabled = false;
}

pub fn LPIT_DRV_Init(p_index: u2, usr_cfg: *LpitUsrConfig, core_clk_freq: u32, lpit_freq: u32) GenericSts {
    if (lpit_freq == 0) return GenericSts.STATUS_ERROR;
    crt_lpit_freq = lpit_freq;
    const core_to_per_clock_ratio: u32 = (core_clk_freq + lpit_freq >> 1) / lpit_freq;
    LpitHW.LPIT_HW_Reset(p_index, core_to_per_clock_ratio);
    LpitHW.LPIT_HW_Enable(p_index, core_to_per_clock_ratio);
    // run mode
    LpitHW.LPIT_HW_SetTimerRunInDebugCmd(p_index, usr_cfg.EnableRunInDebug);
    LpitHW.LPIT_HW_SetTimerRunInDozeCmd(p_index, usr_cfg.EnableRunInDoze);
    return GenericSts.STATUS_SUCCESS;
}

pub fn LPIT_DRV_Deinit(p_index: u2) GenericSts {
    LpitHW.LPIT_HW_Disable(p_index);
}

pub fn LPIT_DRV_SetTimerPeriodByUs(p_index: u2, ch_index: u2, period_us: u32) GenericSts {
    if (crt_lpit_freq == 0) return GenericSts.STATUS_ERROR;
    var count: u64 = @as(u64, period_us) * @as(u64, crt_lpit_freq);
    count = (count / 1_000_000) - 1;
    const crt_timer_mode = LpitHW.LPIT_HW_GetTimerChannelModeCmd(p_index, ch_index);
    // bigger than the max 32bit value
    if (count > MAX_PERIOD_COUNT) return GenericSts.STATUS_ERROR;
    if (crt_timer_mode == LpitTmrModesT.DUAL_PERIODIC_COUNTER_DUAL16) {
        if (count > MAX_PERIOD_COUNT_IN_DUAL_16BIT_MODE) return GenericSts.STATUS_ERROR;
        if (count > MAX_PERIOD_COUNT_16_BIT) {
            count = (count - (MAX_PERIOD_COUNT_16_BIT + 1)) << 16 | MAX_PERIOD_COUNT_16_BIT;
        }
    }
    LpitHW.LPIT_HW_SetTimerPeriodByCount(p_index, ch_index, @as(u32, @intCast(count)));
    return GenericSts.STATUS_SUCCESS;
}

pub fn LPIT_DRV_InitChannel(p_index: u2, ch_index: u2, usr_ch_cfg: *LpitUsrChannelCfg) GenericSts {
    var ret_sts = GenericSts.STATUS_SUCCESS;
    // channel 0 cannot be configured as chain mode
    if (ch_index == 0 and usr_ch_cfg.is_chainChannel_enabled) return GenericSts.STATUS_ERROR;
    // Setups the timer channel chaining
    LpitHW.LPIT_HW_SetTimerChannelChainCmd(p_index, ch_index, usr_ch_cfg.is_chainChannel_enabled);
    // Setups the timer channel operation mode
    LpitHW.LPIT_HW_SetTimerChannelModeCmd(p_index, ch_index, usr_ch_cfg.timer_mode);
    if (usr_ch_cfg.period_units == LpitPeriodicUnitsT.UNITS_MICROSECONDS) {
        ret_sts = LPIT_DRV_SetTimerPeriodByUs(
            p_index,
            ch_index,
            usr_ch_cfg.period_value,
        );
    } else {
        // only use the lpit in counter mode
        LpitHW.LPIT_HW_SetTimerPeriodByCount(p_index, ch_index, usr_ch_cfg.period_value);
    }
    if (ret_sts == GenericSts.STATUS_SUCCESS) {
        // Setups the timer channel trigger source, trigger select,
        // is reload on trigger,
        // is stop on timeout, start on trigger and channel chaining
        LpitHW.LPIT_HW_SetTriggerSourceCmd(p_index.ch_index, usr_ch_cfg.trig_src);
        LpitHW.LPIT_HW_SetTriggerSelectCmd(p_index, ch_index, usr_ch_cfg.trig_select);
        LpitHW.LPIT_HW_SetReloadOnTriggerCmd(p_index, ch_index, usr_ch_cfg.is_reloadOnTrig);
        LpitHW.LPIT_HW_SetStopOnInterruptCmd(p_index, ch_index, usr_ch_cfg.is_stopOnInterrupt);
        LpitHW.LPIT_HW_SetStartOnTriggerCmd(p_index, ch_index, usr_ch_cfg.is_startOnTrig);
        //LpitHW.LPIT_HW_SetTimerChannelChainCmd(p_index, ch_index, usr_ch_cfg.is_chainChannel_enabled);
        if (usr_ch_cfg.is_interrupt_enabled) {
            // enable the interrupt
            LpitHW.LPIT_HW_EnableInterruptTimerChannels(p_index, ch_index);
            // install the interrupt handler function
            NVIC_Mgr.Install_IsrHandler(lpit0_irq_types[ch_index], lpit0_irq_handlers[ch_index]);
            NVIC_Mgr.NVIC_EnableInterrupt(lpit0_irq_types[ch_index]);
        } else {
            // disable the interrupt
            LpitHW.LPIT_HW_DisableInterruptTimerChannels(p_index, ch_index);
            NVIC_Mgr.NVIC_DisableInterrupt(lpit0_irq_types[ch_index]);
        }
    }
    return ret_sts;
}

pub fn LPIT_DRV_StartTimerChannels(p_index: u2, ch_index: u2) void {
    LpitHW.LPIT_HW_StartTimerChannels(p_index, ch_index);
}

pub fn LPIT_DRV_StopTimerChannels(p_index: u2, ch_index: u2) void {
    LpitHW.LPIT_HW_StopTimerChannels(p_index, ch_index);
}

pub fn LPIT_DRV_GetInterruptFlagTimerChannels(p_index: u2, ch_index: u2) u1 {
    return LpitHW.LPIT_HW_GetInterruptFlagTimerChannels(p_index, ch_index);
}

pub fn LPIT_DRV_ClearInterruptFlagTimerChannels(p_index: u2, ch_index: u2) void {
    LpitHW.LPIT_HW_ClearInterruptFlagTimerChannels(p_index, ch_index);
}

//#endregion
