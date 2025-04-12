//! System tick driver
//! - simply used as delay test
//! - author: weng
//! - date: 2025/02/25
//! - version: 0.1.0

const FieldSet = @import("s32k144_regs_mod").RegT.FieldSet;
const SysTick_Regs = @import("s32k144_regs_mod").SysTick_Regs;
const CSR = SysTick_Regs.SysTick_CSR;
const RVR = SysTick_Regs.SysTick_RVR;
const CVR = SysTick_Regs.SysTick_CVR;

// clock src is 80mhz 80_000_000
const fac_us: u32 = 80_000_000 / 1_000_000;

pub fn InitSysTick() void {
    CSR.reg_ins.updateFieldValue(CSR.ENABLE, 0);
    RVR.reg_ins.updateFieldValue(RVR.RELOAD, 0xFF_FFFF);
    CVR.reg_ins.updateFieldValue(CVR.CURRENT, 0);
    CSR.reg_ins.setRaw(0);
    CSR.reg_ins.updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = CSR.TICKINT, .field_value = 0 },
        FieldSet{ .field_def = CSR.CLKSOURCE, .field_value = 1 },
        FieldSet{ .field_def = CSR.ENABLE, .field_value = 1 },
    });
}

pub fn SysTickDelayMicroseconds(tgt_time: u32) void {
    const reload_time: u32 = RVR.reg_ins.getFieldValue(RVR.RELOAD);
    var crt_time: u32 = 0;
    const tgt_ticks: u32 = tgt_time * fac_us;
    var last_time: u32 = CVR.reg_ins.getFieldValue(CVR.CURRENT);
    var time_counter: u32 = 0;
    while (true) {
        crt_time = CVR.reg_ins.getFieldValue(CVR.CURRENT);
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

pub fn SysTickDelayMilliSeconds(tgt_ms: u32) void {
    for (0..tgt_ms) |i| {
        _ = i;
        SysTickDelayMicroseconds(1000);
    }
}

pub fn SysTickDelaySeconds(seconds: u32) void {
    for (0..seconds) |i| {
        _ = i;
        SysTickDelayMilliSeconds(1000);
    }
}
