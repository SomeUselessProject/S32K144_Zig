//! The base hardware api to achieve the lpit registers
//! author: weng
//! version: 0.1.0
//! date: 2025/03/19

const LPIT_Regs = @import("s32k144_regs_mod").LPIT_Regs;

pub const LpitTmrModesT = enum(u3) {
    /// 32-bit Periodic Counter
    PERIODIC_COUNTER_32BIT = 0,
    /// Dual 16-bit Periodic Counter
    DUAL_PERIODIC_COUNTER_DUAL16 = 1,
    /// 32-bit Trigger Accumulator
    TRIGGER_ACCUMULATOR_32BIT = 2,
    /// 32-bit Trigger Input Capture
    INPUT_CAPTURE_32BIT = 3,
};

pub const LpitTriggerSrcT = enum(u1) {
    EXTERNAL = 0,
    INTERNAL = 1,
};

/// This function enables the functional clock of LPIT module (Note: this function
/// does not un-gate the system clock gating control). It should be called before
/// setup any timer channel.
pub inline fn LPIT_HW_Enable(p_index: u2, delay_time: u32) void {
    _ = p_index;
    LPIT_Regs.LPIT0_MCR.M_CEN = 1;
    // Run this counter down to zero
    // If the delay is 0, the four clock delay between setting and clearing
    // the SW_RST bit is ensured by the read-modify-write operation.
    while (delay_time != 0) {
        // Since we need a four cycle delay, we assume the decrement is one cycle
        // and insert three NOP instructions. The actual delay will be larger because
        // of the loop overhead and the compiler optimization.
        delay_time -|= 1;
        asm volatile ("nop");
        asm volatile ("nop");
        asm volatile ("nop");
    }
}

pub fn LPIT_HW_Disable(p_index: u2) void {
    _ = p_index;
    LPIT_Regs.LPIT0_MCR.M_CEN = 0;
}

pub inline fn LPIT_HW_Reset(p_index: u2, delay_time: u32) void {
    _ = p_index;
    LPIT_Regs.LPIT0_MCR.SW_RST = 1;
    while (delay_time != 0) {
        delay_time -|= 1;
        asm volatile ("nop");
        asm volatile ("nop");
        asm volatile ("nop");
    }
    LPIT_Regs.LPIT0_MCR.SW_RST = 0;
}

pub fn LPIT_HW_StartTimerChannels(p_index: u2, ch_index: u2) void {
    // only got one lpit module in s32k144 lpit0
    _ = p_index;
    switch (ch_index) {
        0 => LPIT_Regs.LPIT0_SETTEN.SET_T_EN_0 = 1,
        1 => LPIT_Regs.LPIT0_SETTEN.SET_T_EN_1 = 1,
        2 => LPIT_Regs.LPIT0_SETTEN.SET_T_EN_2 = 1,
        3 => LPIT_Regs.LPIT0_SETTEN.SET_T_EN_3 = 1,
        else => unreachable,
    }
}

pub fn LPIT_HW_StopTimerChannels(p_index: u2, ch_index: u2) void {
    // only got one lpit module in s32k144 lpit0
    _ = p_index;
    switch (ch_index) {
        0 => LPIT_Regs.LPIT0_CLRTEN.CLR_T_EN_0 = 1,
        1 => LPIT_Regs.LPIT0_CLRTEN.CLR_T_EN_1 = 1,
        2 => LPIT_Regs.LPIT0_CLRTEN.CLR_T_EN_2 = 1,
        3 => LPIT_Regs.LPIT0_CLRTEN.CLR_T_EN_3 = 1,
        else => unreachable,
    }
}

/// This function sets the timer channel period in count unit.
/// The period range depends on the frequency of the LPIT functional clock and
/// operation mode of timer channel.
/// - If the required period is out of range, use the suitable mode if applicable.
/// Timer channel begins counting from the value that is set by this function.
/// - The counter period of a running timer channel can be modified by first setting
/// a new load value, the value will be loaded after the timer channel expires.
/// - To abort the current cycle and start a timer channel period with the new value,
/// the timer channel must be disabled and enabled again.
pub fn LPIT_HW_SetTimerPeriodByCount(p_index: u2, ch_index: u2, count: u32) void {
    _ = p_index;
    LPIT_Regs.LPIT0_TVALS[ch_index].TMR_VAL = count;
}

pub fn LPIT_HW_GetTimerPeriodByCount(p_index: u2, ch_index: u2) u32 {
    _ = p_index;
    return LPIT_Regs.LPIT0_TVALS[ch_index].TMR_VAL;
}

pub fn LPIT_HW_GetCurrentTimerCount(p_index: u2, ch_index: u2) u32 {
    _ = p_index;
    return LPIT_Regs.LPIT0_CVALS[ch_index].TMR_CUR_VAL;
}

pub fn LPIT_HW_EnableInterruptTimerChannels(p_index: u2, ch_index: u2) void {
    _ = p_index;
    switch (ch_index) {
        0 => LPIT_Regs.LPIT0_MIER.TIE0 = 1,
        1 => LPIT_Regs.LPIT0_MIER.TIE1 = 1,
        2 => LPIT_Regs.LPIT0_MIER.TIE2 = 1,
        3 => LPIT_Regs.LPIT0_MIER.TIE3 = 1,
        else => unreachable,
    }
}

pub fn LPIT_HW_DisableInterruptTimerChannels(p_index: u2, ch_index: u2) void {
    _ = p_index;
    switch (ch_index) {
        0 => LPIT_Regs.LPIT0_MIER.TIE0 = 0,
        1 => LPIT_Regs.LPIT0_MIER.TIE1 = 0,
        2 => LPIT_Regs.LPIT0_MIER.TIE2 = 0,
        3 => LPIT_Regs.LPIT0_MIER.TIE3 = 0,
        else => unreachable,
    }
}

pub fn LPIT_HW_GetInterruptFlagTimerChannels(p_index: u2, ch_index: u2) u1 {
    _ = p_index;
    switch (ch_index) {
        0 => return LPIT_Regs.LPIT0_MSR.TIF0,
        1 => return LPIT_Regs.LPIT0_MSR.TIF1,
        2 => return LPIT_Regs.LPIT0_MSR.TIF2,
        3 => return LPIT_Regs.LPIT0_MSR.TIF3,
        else => unreachable,
    }
}

pub fn LPIT_HW_ClearInterruptFlagTimerChannels(p_index: u2, ch_index: u2) void {
    _ = p_index;
    // write 1 to the field to clear the interrupt flag
    switch (ch_index) {
        0 => LPIT_Regs.LPIT0_MSR.TIF0 = 1,
        1 => LPIT_Regs.LPIT0_MSR.TIF1 = 1,
        2 => LPIT_Regs.LPIT0_MSR.TIF2 = 1,
        3 => LPIT_Regs.LPIT0_MSR.TIF3 = 1,
        else => unreachable,
    }
    // read after the write operation
    _ = LPIT_Regs.LPIT0_MSR.*;
}

pub fn LPIT_HW_SetTimerChannelModeCmd(p_index: u2, ch_index: u2, mode: LpitTmrModesT) void {
    _ = p_index;
    LPIT_Regs.LPIT0_TCTRLS[ch_index].MODE = 0;
    switch (mode) {
        LpitTmrModesT.PERIODIC_COUNTER_32BIT => LPIT_Regs.LPIT0_TCTRLS[ch_index].MODE = 0b00,
        LpitTmrModesT.DUAL_PERIODIC_COUNTER_DUAL16 => LPIT_Regs.LPIT0_TCTRLS[ch_index].MODE = 0b01,
        LpitTmrModesT.TRIGGER_ACCUMULATOR_32BIT => LPIT_Regs.LPIT0_TCTRLS[ch_index].MODE = 0b10,
        LpitTmrModesT.INPUT_CAPTURE_32BIT => LPIT_Regs.LPIT0_TCTRLS[ch_index].MODE = 0b11,
        else => unreachable,
    }
}

pub fn LPIT_HW_GetTimerChannelModeCmd(p_index: u2, ch_index: u2) LpitTmrModesT {
    _ = p_index;
    switch (LPIT_Regs.LPIT0_TCTRLS[ch_index].MODE) {
        0b00 => return LpitTmrModesT.PERIODIC_COUNTER_32BIT,
        0b01 => return LpitTmrModesT.DUAL_PERIODIC_COUNTER_DUAL16,
        0b10 => return LpitTmrModesT.TRIGGER_ACCUMULATOR_32BIT,
        0b11 => return LpitTmrModesT.INPUT_CAPTURE_32BIT,
        else => unreachable,
    }
}

/// This function selects one trigger from the set of internal triggers that is
/// generated by other timer channels.
/// - The selected trigger is used for starting and/or reloading the timer channel.
pub fn LPIT_HW_SetTriggerSelectCmd(p_index: u2, ch_index: u2, select_ch_index: u2) void {
    _ = p_index;
    LPIT_Regs.LPIT0_TCTRLS[ch_index].TRG_SEL = 0;
    LPIT_Regs.LPIT0_TCTRLS[ch_index].TRG_SEL = select_ch_index;
}

/// This function sets trigger source of the timer channel to be internal or external trigger.
pub fn LPIT_HW_SetTriggerSourceCmd(p_index: u2, ch_index: u2, trigger_src: LpitTriggerSrcT) void {
    _ = p_index;
    LPIT_Regs.LPIT0_TCTRLS[ch_index].TRG_SRC = 0;
    LPIT_Regs.LPIT0_TCTRLS[ch_index].TRG_SRC = @intFromEnum(trigger_src);
}

/// This function sets the timer channel to reload/don't reload on trigger.
pub fn LPIT_HW_SetReloadOnTriggerCmd(p_index: u2, ch_index: u2, is_reload: bool) void {
    _ = p_index;
    LPIT_Regs.LPIT0_TCTRLS[ch_index].TROT = 0;
    LPIT_Regs.LPIT0_TCTRLS[ch_index].TROT = @intFromBool(is_reload);
}

/// This function sets the timer channel to stop or don't stop after it times out.
/// - stop or not when interrupt occurs
pub fn LPIT_HW_SetStopOnInterruptCmd(p_index: u2, ch_index: u2, is_stopped: bool) void {
    _ = p_index;
    LPIT_Regs.LPIT0_TCTRLS[ch_index].TSOI = 0;
    LPIT_Regs.LPIT0_TCTRLS[ch_index].TSOI = @intFromBool(is_stopped);
}

/// This function sets the timer channel to starts/don't start on trigger.
pub fn LPIT_HW_SetStartOnTriggerCmd(p_index: u2, ch_index: u2, is_started: bool) void {
    _ = p_index;
    LPIT_Regs.LPIT0_TCTRLS[ch_index].TSOT = 0;
    LPIT_Regs.LPIT0_TCTRLS[ch_index].TSOT = @intFromBool(is_started);
}

/// This function sets the timer channel to be chained or not chained.
pub fn LPIT_HW_SetTimerChannelChainCmd(p_index: u2, ch_index: u2, is_channel_chained: bool) void {
    _ = p_index;
    LPIT_Regs.LPIT0_TCTRLS[ch_index].CHAIN = 0;
    LPIT_Regs.LPIT0_TCTRLS[ch_index].CHAIN = @intFromBool(is_channel_chained);
}

/// When the device enters debug mode, the timer channels may or may not be frozen,
/// based on the configuration of this function. This is intended to aid software development,
/// allowing the developer to halt the processor, investigate the current state of
/// the system (for example, the timer channel values), and continue the operation.
pub fn LPIT_HW_SetTimerRunInDebugCmd(p_index: u2, is_run_debug: bool) void {
    _ = p_index;
    LPIT_Regs.LPIT0_MCR.DBG_EN = 0;
    LPIT_Regs.LPIT0_MCR.DBG_EN = @intFromBool(is_run_debug);
}

/// When the device enters debug mode, the timer channels may or may not be frozen,
/// - based on the configuration of this function. The LPIT must use an external or
/// - internal clock source which remains operating during DOZE modes(low power mode).
/// - 休眠模式下禁用定时器的功能
pub fn LPIT_HW_SetTimerRunInDozeCmd(p_index: u2, is_run_doze: bool) void {
    _ = p_index;
    LPIT_Regs.LPIT0_MCR.DOZE_EN = 0;
    LPIT_Regs.LPIT0_MCR.DOZE_EN = @intFromBool(is_run_doze);
}
