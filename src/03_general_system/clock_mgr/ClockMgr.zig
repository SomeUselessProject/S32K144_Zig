//! The manager of the system clock
//! - SCG system clock manager
//! - author: weng
//! - date: 20250320
//! - version: 0.2.0
//! - add pcc manager v0.2.0

//#region General Import Part
const GenericSts = @import("../SystemStatus.zig").GeneralSts;
const ClockCfg = @import("../sys_user_config/SysUsrConfig.zig").ClkUsrCfg;
const ClockDefine = @import("./ClockDefine.zig");
const SCG_RunModeT = ClockDefine.SCG_RunModeT;
const SysClockSrcT = ClockDefine.SysClockSrcT;
const SOSC_RangeT = ClockDefine.SOSC_RangeT;
const SIRC_RangeT = ClockDefine.SIRC_RangeT;
const sosc_usr_cfg = ClockCfg.sosc_usr_cfg;
const sirc_usr_cfg = ClockCfg.sirc_usr_cfg;
const firc_usr_cfg = ClockCfg.firc_usr_cfg;
const spll_usr_cfg = ClockCfg.spll_usr_cfg;
const sys_clk_usr_cfg = ClockCfg.sysClk_usr_cfg;

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
const SIRCCSR = SCG_Reg.SIRCCSR_REG;
const SIRCCFG = SCG_Reg.SCG_SIRCCFG_Reg;
const RCCR = SCG_Reg.RCCR_REG;
const CSR = SCG_Reg.CSR_REG;

//#endregion
// --------------------------------------------------------
//#region SCG Part
pub const SCG_Mgr = struct {
    var is_sosc_enabled: bool = false;
    var is_sirc_enabled: bool = false;
    var is_firc_enabled: bool = false;
    var is_spll_enabled: bool = false;
    var is_sys_clk_enabled: bool = false;

    // SOSC Part -------------------------------
    var sosc_clk_freq: u32 = 0;
    pub inline fn GetSoscClkFreq() u32 {
        if (is_sosc_enabled) return sosc_clk_freq;
        return 0;
    }
    var sosc_div1_freq: u32 = 0;
    pub inline fn GetSoscDiv1Freq() u32 {
        if (is_sosc_enabled) return sosc_div1_freq;
        return 0;
    }
    var sosc_div2_freq: u32 = 0;
    pub inline fn GetSoscDiv2Freq() u32 {
        if (is_sosc_enabled) return sosc_div2_freq;
        return 0;
    }

    // SIRC Part ------------------------------
    var sirc_clk_freq: u32 = 0;
    pub inline fn GetSircClkFreq() u32 {
        if (is_sirc_enabled) return sirc_clk_freq;
        return 0;
    }
    var sirc_div1_freq: u32 = 0;
    pub inline fn GetSircDiv1Freq() u32 {
        if (is_sirc_enabled) return sirc_div1_freq;
        return 0;
    }
    var sirc_div2_freq: u32 = 0;
    pub inline fn GetSircDiv2Freq() u32 {
        if (is_sirc_enabled) return sirc_div2_freq;
        return 0;
    }

    // FIRC Part -----------------------------
    const firc_clk_freq: u32 = 48_000_000;
    pub inline fn GetFircClkFreq() u32 {
        if (is_firc_enabled) return firc_clk_freq;
        return 0;
    }
    var firc_div1_freq: u32 = 0;
    pub inline fn GetFircDiv1Freq() u32 {
        if (is_firc_enabled) return firc_div1_freq;
        return 0;
    }
    var firc_div2_freq: u32 = 0;
    pub inline fn GetFircDiv2Freq() u32 {
        if (is_firc_enabled) return firc_div2_freq;
        return 0;
    }

    // SPLL Part -------------------------------
    var spll_vco_clk_freq: u32 = 0;
    pub inline fn GetSpllVcoClkFreq() u32 {
        if (is_spll_enabled) return spll_vco_clk_freq;
        return 0;
    }
    var spll_out_freq: u32 = 0;
    pub inline fn GetSpllOutFreq() u32 {
        if (is_spll_enabled) return spll_out_freq;
        return 0;
    }

    var spll_div1_freq: u32 = 0;
    pub inline fn GetSpllDiv1Freq() u32 {
        if (is_spll_enabled) return spll_div1_freq;
        return 0;
    }
    var spll_div2_freq: u32 = 0;
    pub inline fn GetSpllDiv2Freq() u32 {
        if (is_spll_enabled) return spll_div2_freq;
        return 0;
    }

    // SYSTEM CORE Part ---------------------------
    var sys_core_freq: u32 = 0;
    pub inline fn GetSysCoreFreq() u32 {
        if (is_sys_clk_enabled) return sys_core_freq;
        return 0;
    }
    var bus_clk_freq: u32 = 0;
    pub inline fn GetBusClkFreq() u32 {
        if (is_sys_clk_enabled) return bus_clk_freq;
        return 0;
    }
    var flash_clk_freq: u32 = 0;
    pub inline fn GetFlashClkFreq() u32 {
        if (is_sys_clk_enabled) return flash_clk_freq;
        return 0;
    }

    /// SOSC SYSTEM Config by user config
    fn SCG_SystemSOSC_Config() void {
        is_sosc_enabled = false;
        sosc_clk_freq = ClockCfg.xtal_freq;
        sosc_div1_freq = sosc_clk_freq / @intFromEnum(sosc_usr_cfg.sosc_div1);
        sosc_div2_freq = sosc_clk_freq / @intFromEnum(sosc_usr_cfg.sosc_div2);

        SOSCDIV.reg_ins.updateAllFieldsValue(&[_]FieldSet{
            FieldSet{ .field_def = SOSCDIV.SOSCDIV1, .field_value = @intFromEnum(sosc_usr_cfg.sosc_div1) },
            FieldSet{ .field_def = SOSCDIV.SOSCDIV2, .field_value = @intFromEnum(sosc_usr_cfg.sosc_div2) },
        });
        SOSCCFG.reg_ins.updateAllFieldsValue(&[_]FieldSet{
            FieldSet{ .field_def = SOSCCFG.RANGE, .field_value = @intFromEnum(sosc_usr_cfg.range) },
            FieldSet{ .field_def = SOSCCFG.HGO, .field_value = @intFromEnum(sosc_usr_cfg.hgo) },
            FieldSet{ .field_def = SOSCCFG.EREFS, .field_value = @intFromEnum(sosc_usr_cfg.erefs) },
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
        // Set SOSC ENABLED
        is_sosc_enabled = true;
    }
    fn SCG_SysSIRC_Config() void {
        is_sirc_enabled = false;
        SIRCCSR.reg_ins.updateFieldValue(SIRCCSR.SIRCEN, 0);
        switch (sirc_usr_cfg.range) {
            SIRC_RangeT.SCG_SIRC_2M => {
                SIRCCFG.RANGE = 0;
                sirc_clk_freq = 2_000_000;
            },
            SIRC_RangeT.SCG_SIRC_8M => {
                SIRCCFG.RANGE = 1;
                sirc_clk_freq = 8_000_000;
            },
        }
        const sirc_div1_value: u4 = @intFromEnum(sirc_usr_cfg.sirc_div1);
        const sirc_div2_value: u4 = @intFromEnum(sirc_usr_cfg.sirc_div2);
        SIRCDIV.reg_ins.updateAllFieldsValue(&[_]FieldSet{
            FieldSet{ .field_def = SIRCDIV.SIRCDIV1, .field_value = sirc_div1_value },
            FieldSet{ .field_def = SIRCDIV.SIRCDIV2, .field_value = sirc_div2_value },
        });

        // block here til sosccsr is ready for rewriting
        while (SIRCCSR.reg_ins.getFieldValue(SIRCCSR.LK) == 1) {}
        SIRCCSR.reg_ins.updateAllFieldsValue(&[_]FieldSet{
            FieldSet{ .field_def = SIRCCSR.SIRCEN, .field_value = 1 },
            FieldSet{ .field_def = SIRCCSR.LK, .field_value = 0 },
            FieldSet{ .field_def = SIRCCSR.SIRCSEL, .field_value = 0 },
        });
        // read if soscsr is valid
        while (SIRCCSR.reg_ins.getFieldValue(SIRCCSR.SIRCVLD) == 0) {}
        sirc_div1_freq = sirc_clk_freq / sirc_div1_value;
        sirc_div2_freq = sirc_clk_freq / sirc_div2_value;
        is_sirc_enabled = true;
    }
    fn SCG_SysFIRC_Config() void {}

    fn SCG_SPLL_Config() void {
        is_spll_enabled = false;
        // make sure spll is unlocked
        while (SPLLCSR.reg_ins.getFieldValue(SPLLCSR.LK) == 1) {}
        // disbale the pll
        SPLLCSR.reg_ins.updateFieldValue(SPLLCSR.SPLLEN, 0);
        // set spll source
        // in new version the default spll source is sosc
        // fast irc is disabled

        SPLLDIV.reg_ins.updateAllFieldsValue(&[_]FieldSet{
            FieldSet{ .field_def = SPLLDIV.SPLLDIV1, .field_value = @intFromEnum(spll_usr_cfg.spll_div1) },
            FieldSet{ .field_def = SPLLDIV.SPLLDIV2, .field_value = @intFromEnum(spll_usr_cfg.spll_div2) },
        });

        const prediv: u8 = @intFromEnum(spll_usr_cfg.spll_prediv);
        const mult: u8 = @intFromEnum(spll_usr_cfg.spll_mult);
        SPLLCFG.reg_ins.updateAllFieldsValue(&[_]FieldSet{
            FieldSet{ .field_def = SPLLCFG.PREDIV, .field_value = prediv },
            FieldSet{ .field_def = SPLLCFG.MULT, .field_value = mult },
        });

        // these value should be set at the end
        // 16/2 * 40 = 320Mhz
        spll_vco_clk_freq = sosc_clk_freq / (prediv + 1) * (mult + 16);
        // spll out clock = 320 / 2 = 160Mhz
        spll_out_freq = spll_vco_clk_freq / 2;
        // set spll div
        // spll div1 = 160 / 2 = 80Mhz
        spll_div1_freq = spll_out_freq / @intFromEnum(spll_usr_cfg.spll_div1);
        // spll div2 = 160 / 4 = 40Mhz
        spll_div2_freq = spll_out_freq / @intFromEnum(spll_usr_cfg.spll_div2);

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
        // SET SPLL ENABLED
        is_spll_enabled = true;
    }

    fn SCG_SystemClock_Config() void {
        var scs_value: u4 = @intFromEnum(sys_clk_usr_cfg.clk_src);
        const div_core: u4 = @intFromEnum(sys_clk_usr_cfg.core_div);
        const div_bus: u4 = @intFromEnum(sys_clk_usr_cfg.bus_div);
        const div_slow: u4 = @intFromEnum(sys_clk_usr_cfg.slow_div);
        switch (sys_clk_usr_cfg.run_mode) {
            SCG_RunModeT.NORMAL_RUN_MODE,
            SCG_RunModeT.HSRUN_MODE,
            => {
                RCCR.reg_ins.updateAllFieldsValue(&[_]FieldSet{
                    FieldSet{ .field_def = RCCR.SCS, .field_value = scs_value },
                    FieldSet{ .field_def = RCCR.DIVCORE, .field_value = div_core },
                    FieldSet{ .field_def = RCCR.DIVBUS, .field_value = div_bus },
                    FieldSet{ .field_def = RCCR.DIVSLOW, .field_value = div_slow },
                });
            },
            SCG_RunModeT.VLPR_MODE => {
                // in very low power mode
                // sys src is fixed to sirc
                scs_value = @intFromEnum(SysClockSrcT.SlowIRC);
                RCCR.reg_ins.updateAllFieldsValue(&[_]FieldSet{
                    FieldSet{ .field_def = RCCR.SCS, .field_value = scs_value },
                    FieldSet{ .field_def = RCCR.DIVCORE, .field_value = div_core },
                    FieldSet{ .field_def = RCCR.DIVBUS, .field_value = div_bus },
                    FieldSet{ .field_def = RCCR.DIVSLOW, .field_value = div_slow },
                });
            },
        }
        // wait sys clock src is set to spll
        while (CSR.reg_ins.getFieldValue(CSR.SCS) != scs_value) {}
        // set inited
        var clk_freq_input: u32 = 0;
        switch (@as(SysClockSrcT, @enumFromInt(scs_value))) {
            SysClockSrcT.FastIRC => {
                if (!is_firc_enabled) return;
                clk_freq_input = firc_clk_freq;
            },
            SysClockSrcT.SlowIRC => {
                if (is_sirc_enabled == false) return;
                clk_freq_input = sirc_clk_freq;
            },
            SysClockSrcT.SYS_OSC => {
                if (!is_sosc_enabled) return;
                clk_freq_input = sosc_clk_freq;
            },
            SysClockSrcT.SYS_SPLL => {
                if (!is_spll_enabled) return;
                clk_freq_input = spll_out_freq;
            },
        }
        // attention ! the enum value
        sys_core_freq = clk_freq_input / (div_core + 1);
        bus_clk_freq = clk_freq_input / (div_bus + 1);
        flash_clk_freq = clk_freq_input / (div_slow + 1);
        is_sys_clk_enabled = true;
    }

    /// SCG Default init by the user config
    pub fn SCG_DefaultInit() void {
        SCG_SystemSOSC_Config();
        // sirc should config also
        // in VLPR mode the sirc is used as sys clk src
        SCG_SysSIRC_Config();
        SCG_SPLL_Config();
        SCG_SystemClock_Config();
    }
};

//#endregion
// --------------------------------------------------------

//#region PCC CLOCK Manager
// Import -------------------------------------------------
pub const PCC_ClockSelectT = ClockDefine.PCC_ClockSelectT;
const PCC_Regs = @import("s32k144_regs_mod").PCC_Regs;
// --------------------------------------------------------
pub const PCC_CLK_Mgr = struct {
    /// Check the pcc clock selected
    fn CheckByPccClkSrcSelected(clk_src: PCC_ClockSelectT, out_clk_freq: *u32) GenericSts {
        out_clk_freq.* = 0;
        switch (clk_src) {
            PCC_ClockSelectT.FIRCDIV2_CLK => {
                if (!SCG_Mgr.is_firc_enabled) return GenericSts.STATUS_ERROR;
                out_clk_freq.* = SCG_Mgr.GetFircDiv2Freq();
            },
            PCC_ClockSelectT.SIRCDIV2_CLK => {
                if (!SCG_Mgr.is_sirc_enabled) return GenericSts.STATUS_ERROR;
                out_clk_freq.* = SCG_Mgr.GetSircDiv2Freq();
            },
            PCC_ClockSelectT.SOSCDIV2_CLK => {
                if (!SCG_Mgr.is_sosc_enabled) return GenericSts.STATUS_ERROR;
                out_clk_freq.* = SCG_Mgr.GetSoscDiv2Freq();
            },
            PCC_ClockSelectT.SPLLDIV2_CLK => {
                if (!SCG_Mgr.is_spll_enabled) return GenericSts.STATUS_ERROR;
                out_clk_freq.* = SCG_Mgr.GetSpllDiv2Freq();
            },
        }
        return GenericSts.STATUS_SUCCESS;
    }
    /// Set the tgt lpuart to selected clock source
    /// - if the setting not completed return error status ,the out frequency value is 0
    /// - out_clk_freq is the selected src clock frequency
    pub fn SetLpuartClkSrc(comptime lpuart_index: u2, clk_src: PCC_ClockSelectT, out_clk_freq: *u32) GenericSts {
        comptime {
            if (lpuart_index > 2) {
                @compileError("only 3 lpuart in s32k144");
            }
        }
        out_clk_freq.* = 0;
        var ret_sts = GenericSts.STATUS_SUCCESS;
        ret_sts = CheckByPccClkSrcSelected(clk_src, out_clk_freq);
        if (ret_sts != GenericSts.STATUS_SUCCESS) return ret_sts;

        PCC_Regs.PCC_LPUART_Regs[lpuart_index].CGC = 0;
        PCC_Regs.PCC_LPUART_Regs[lpuart_index].PCS = @intFromEnum(clk_src);
        PCC_Regs.PCC_LPUART_Regs[lpuart_index].CGC = 1;
        return ret_sts;
    }

    pub fn SetCanClkSrc() GenericSts {}

    pub fn SetLptmrClkSrcInPccSelected(comptime lptmr_index: u1, clk_src: PCC_ClockSelectT, out_clk_freq: *u32) GenericSts {
        comptime {
            if (lptmr_index != 0) @compileError("only index0 valid in s32k144");
        }
        out_clk_freq.* = 0;
        var ret_sts = GenericSts.STATUS_SUCCESS;
        ret_sts = CheckByPccClkSrcSelected(clk_src, out_clk_freq);
        if (ret_sts != GenericSts.STATUS_SUCCESS) return ret_sts;
        PCC_Regs.PCC_LPTMR0_Reg.CGC = 0;
        PCC_Regs.PCC_LPTMR0_Reg.PCS = @intFromEnum(clk_src);
        PCC_Regs.PCC_LPTMR0_Reg.CGC = 1;
        return GenericSts.STATUS_SUCCESS;
    }
};
//#endregion
// --------------------------------------------------------
//#region System Tick Part
// Import -------
const SysTick_Regs = @import("s32k144_regs_mod").SysTick_Regs;
const SysTick_CSR = SysTick_Regs.SysTick_CSR;
const SysTick_RVR = SysTick_Regs.SysTick_RVR;
const SysTick_CVR = SysTick_Regs.SysTick_CVR;
// --------------
pub const SysTickMgr = struct {
    var fac_us: u32 = 80_000_000 / 1_000_000;
    var is_systick_inited: bool = false;
    pub fn InitSysTick() void {
        is_systick_inited = false;
        if (!SCG_Mgr.is_sys_clk_enabled) return;
        SysTick_CSR.reg_ins.updateFieldValue(SysTick_CSR.ENABLE, 0);
        SysTick_RVR.reg_ins.updateFieldValue(SysTick_RVR.RELOAD, 0xFF_FFFF);
        SysTick_CVR.reg_ins.updateFieldValue(SysTick_CVR.CURRENT, 0);
        SysTick_CSR.reg_ins.setRaw(0);
        SysTick_CSR.reg_ins.updateAllFieldsValue(&[_]FieldSet{
            FieldSet{ .field_def = SysTick_CSR.TICKINT, .field_value = 0 },
            FieldSet{ .field_def = SysTick_CSR.CLKSOURCE, .field_value = 1 },
            FieldSet{ .field_def = SysTick_CSR.ENABLE, .field_value = 1 },
        });
        // set fac_us according to the system core clock freq
        fac_us = SCG_Mgr.GetSysCoreFreq() / 1_000_000;
        is_systick_inited = true;
    }

    /// block us
    pub fn SysTickDelayMicroseconds(tgt_time: u32) void {
        if (!is_systick_inited) return;
        const reload_time: u32 = SysTick_RVR.reg_ins.getFieldValue(SysTick_RVR.RELOAD);
        var crt_time: u32 = 0;
        const tgt_ticks: u32 = tgt_time * fac_us;
        var last_time: u32 = SysTick_CVR.reg_ins.getFieldValue(SysTick_CVR.CURRENT);
        var time_counter: u32 = 0;
        while (true) {
            crt_time = SysTick_CVR.reg_ins.getFieldValue(SysTick_CVR.CURRENT);
            if (crt_time != last_time) {
                if (crt_time < last_time) {
                    time_counter += (last_time - crt_time);
                } else {
                    time_counter += (reload_time - crt_time + last_time);
                }
            }
            last_time = crt_time;
            if (time_counter >= tgt_ticks) break;
        }
    }

    /// block ms
    pub fn SysTickDelayMilliSeconds(tgt_ms: u32) void {
        if (!is_systick_inited) return;
        for (0..tgt_ms) |i| {
            _ = i;
            SysTickDelayMicroseconds(1000);
        }
    }
    /// block s
    pub fn SysTickDelaySeconds(seconds: u32) void {
        if (!is_systick_inited) return;
        for (0..seconds) |i| {
            _ = i;
            SysTickDelayMilliSeconds(1000);
        }
    }
};

//#endregion
// ----------------------------------------------------------
