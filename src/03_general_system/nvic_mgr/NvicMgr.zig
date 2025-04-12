//! Handle all the NVIC of this mcu
//! - version : 0.2.0
//! - author : weng
//! - date : 2025/03/07

const FieldSet = @import("s32k144_regs_mod").RegT.FieldSet;
const NVIC_Regs = @import("s32k144_regs_mod").NVIC_Regs;
pub const IQRnType = NVIC_Regs.IRQnType;
// Interrupt
const StartMod = @import("start_mod");
const Vector = StartMod.Vector;
pub const IsrHandlerFunc = Vector.IsrFunction;
const vector_tables = Vector.Vector_Table;
const VECTOR_LIST_PTR = Vector.VECTOR_LIST_PTR;
// User Config
const NvicUsrConfig = @import("../sys_user_config/NvicUsrConfig.zig");

/// defult interrupt is open
var is_global_interrupt_enabled: bool = true;

pub fn InitNVIC_Mgr() void {
    is_global_interrupt_enabled = true;
}

pub fn NVIC_DisableGlobalInterrupt() void {
    if (is_global_interrupt_enabled) {
        is_global_interrupt_enabled = false;
        StartMod.Entry.DisableGlobalInterrupts();
    }
}

pub fn NVIC_EnableGlobalInterrupt() void {
    if (is_global_interrupt_enabled == false) {
        is_global_interrupt_enabled = true;
        StartMod.Entry.EnableGlobalInterrupts();
    }
}

/// Install a default interrupt handler with IQRnNumber
/// - attention `IQRnType` should be larger than -16
/// - the function should not be used cause flash operation is not permitted
pub fn Install_IsrHandler(comptime iqr_type: IQRnType, new_handler_func: IsrHandlerFunc) void {
    const iqr_value: i32 = @intFromEnum(iqr_type);
    comptime {
        // should raise a error here
        if (iqr_value < -16) @compileError("the number of iqrValue should >= -16");
    }
    const iqr_index: u32 = @intCast(iqr_value + 16);
    NVIC_DisableGlobalInterrupt();
    VECTOR_LIST_PTR[iqr_index] = new_handler_func;
}

/// This function will return the register index of nvic
/// - iqr_type _id / 32
/// - every registers have 32bit to map the interrupt
fn GetIQRnIDRightShift5(iqr_type: IQRnType) u32 {
    return @as(u32, @intCast(@intFromEnum(iqr_type))) >> 5;
}
/// This function will change the bit in registers
/// - if iqr_type is dec value 48 00110000 & 00011111
/// - 48 & 31 = 0001 0000 = 16
/// - it is same to 48 % 32
fn GetNvicSetValue(iqr_type: IQRnType) u32 {
    const left_shift: u32 = (@as(u32, @intCast(@intFromEnum(iqr_type))) & @as(u32, 0x1F));
    return @as(u32, 1) << @as(u5, @intCast(left_shift));
}

pub fn NVIC_EnableInterrupt(iqr_type: IQRnType) void {
    const iser_id: u32 = GetIQRnIDRightShift5(iqr_type);
    NVIC_Regs.NVICISER_N[iser_id].SETENA |= GetNvicSetValue(iqr_type);
    NVIC_EnableGlobalInterrupt();

    // set the priority by user config
    const pri_value = NvicUsrConfig.GetPriorityByType(iqr_type);
    NVIC_SetPriority(iqr_type, pri_value);
}

pub fn NVIC_DisableInterrupt(iqr_type: IQRnType) void {
    const iser_id: u32 = GetIQRnIDRightShift5(iqr_type);
    NVIC_Regs.NVICICER_N[iser_id].SETENA |= GetNvicSetValue(iqr_type);
}

pub fn NVIC_SetPriority(iqr_type: IQRnType, priority: u4) void {
    const ip_index: u32 = @intCast(@intFromEnum(iqr_type));
    // may get error here
    if (ip_index >= 240) return;
    const shift: u4 = 4;
    const set_value: u8 = @intCast((@as(u32, priority) << shift) & @as(u32, 0xFF));
    NVIC_Regs.NVICIP_N[ip_index].PRI = set_value;
}

pub fn NVIC_SetPending(iqr_type: IQRnType) void {
    const reg_id: u32 = GetIQRnIDRightShift5(iqr_type);
    NVIC_Regs.NVICISPR_N[reg_id].SETPEND = GetNvicSetValue(iqr_type);
}

pub fn NVIC_ClearPending(iqr_type: IQRnType) void {
    const reg_id: u32 = GetIQRnIDRightShift5(iqr_type);
    NVIC_Regs.NVICICPR_N[reg_id].CLRPEND = GetNvicSetValue(iqr_type);
}
