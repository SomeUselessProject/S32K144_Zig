//！This file is the pin driver of s32k144
//! - date : 2025/03/11
//! - author : weng

const PCC_Regs = @import("s32k144_regs_mod").PCC_Regs;
const PORT_Regs = @import("s32k144_regs_mod").PORT_Regs;
const GPIO_Regs = @import("s32k144_regs_mod").GPIO_Regs;

pub const GPIO_Group = enum(u3) {
    PTA = 0,
    PTB = 1,
    PTC = 2,
    PTD = 3,
    PTE = 4,
};

/// The actual pin define of S32k144
/// - set Port Number
/// - set pin number
pub const PinDefine = struct {
    group: GPIO_Group,
    num: u5,
};

pub const PORT_RG_TYPE = enum {
    PORTA,
    PORTB,
    PORTC,
    PORTD,
    PORTE,
};

pub const GPIO_OutStrength_TYPE = enum(u1) {
    LOW,
    HIGH,
};

/// Enable all pins clock
/// - This function should be raised at first
pub fn EnableAllPortClock() void {
    // enable clock to gpio
    for (PCC_Regs.PCC_PORT_Regs.*) |port| {
        port.CGC = 1;
    }
}

/// Set the target gpio pin to digital output mode
pub fn SetPinGpioOutMode(pin_def: PinDefine) void {
    // set pin output accoring to the define
    const grp_index = @intFromEnum(pin_def.group);
    PCC_Regs.PCC_PORT_Regs[grp_index].CGC = 1;
    switch (pin_def.group) {
        GPIO_Group.PTA => {
            GPIO_Regs.PTA_PDDR_Reg.PDD |= @as(u32, 1) << pin_def.num;
            PORT_Regs.PORTA_PCR_Regs[pin_def.num].MUX = 0b001;
        },
        GPIO_Group.PTB => {
            GPIO_Regs.PTB_PDDR_Reg.PDD |= @as(u32, 1) << pin_def.num;
            PORT_Regs.PORTB_PCR_Regs[pin_def.num].MUX = 0b001;
        },
        GPIO_Group.PTC => {
            GPIO_Regs.PTC_PDDR_Reg.PDD |= @as(u32, 1) << pin_def.num;
            PORT_Regs.PORTC_PCR_Regs[pin_def.num].MUX = 0b001;
        },
        GPIO_Group.PTD => {
            GPIO_Regs.PTD_PDDR_Reg.PDD |= @as(u32, 1) << pin_def.num;
            PORT_Regs.PORTD_PCR_Regs[pin_def.num].MUX = 0b001;
        },
        GPIO_Group.PTE => {
            GPIO_Regs.PTE_PDDR_Reg.PDD |= @as(u32, 1) << pin_def.num;
            PORT_Regs.PORTE_PCR_Regs[pin_def.num].MUX = 0b001;
        },
    }
}

/// Use PSOR set pin output high
/// - write 1
pub fn SetPinOutHigh(pin_def: PinDefine) void {
    switch (pin_def.group) {
        GPIO_Group.PTA => GPIO_Regs.PTA_PSOR_Reg.PTSO |= @as(u32, 1) << pin_def.num,
        GPIO_Group.PTB => GPIO_Regs.PTB_PSOR_Reg.PTSO |= @as(u32, 1) << pin_def.num,
        GPIO_Group.PTC => GPIO_Regs.PTC_PSOR_Reg.PTSO |= @as(u32, 1) << pin_def.num,
        GPIO_Group.PTD => GPIO_Regs.PTD_PSOR_Reg.PTSO |= @as(u32, 1) << pin_def.num,
        GPIO_Group.PTE => GPIO_Regs.PTE_PSOR_Reg.PTSO |= @as(u32, 1) << pin_def.num,
    }
}
/// Use PCOR to clear pin output ; set low
/// - write 1
pub fn SetPinOutLow(pin_def: PinDefine) void {
    switch (pin_def.group) {
        GPIO_Group.PTA => GPIO_Regs.PTA_PCOR_Reg.PTCO |= (@as(u32, 1) << pin_def.num),
        GPIO_Group.PTB => GPIO_Regs.PTB_PCOR_Reg.PTCO |= (@as(u32, 1) << pin_def.num),
        GPIO_Group.PTC => GPIO_Regs.PTC_PCOR_Reg.PTCO |= (@as(u32, 1) << pin_def.num),
        GPIO_Group.PTD => GPIO_Regs.PTD_PCOR_Reg.PTCO |= (@as(u32, 1) << pin_def.num),
        GPIO_Group.PTE => GPIO_Regs.PTE_PCOR_Reg.PTCO |= (@as(u32, 1) << pin_def.num),
    }
}

/// write 1 to reverse the ouput sts of pin
pub fn TogglePinOut(pin_def: PinDefine) void {
    switch (pin_def.group) {
        GPIO_Group.PTA => GPIO_Regs.PTA_PTOR_Reg.PTTO |= (@as(u32, 1) << pin_def.num),
        GPIO_Group.PTB => GPIO_Regs.PTB_PTOR_Reg.PTTO |= (@as(u32, 1) << pin_def.num),
        GPIO_Group.PTC => GPIO_Regs.PTC_PTOR_Reg.PTTO |= (@as(u32, 1) << pin_def.num),
        GPIO_Group.PTD => GPIO_Regs.PTD_PTOR_Reg.PTTO |= (@as(u32, 1) << pin_def.num),
        GPIO_Group.PTE => GPIO_Regs.PTE_PTOR_Reg.PTTO |= (@as(u32, 1) << pin_def.num),
    }
}

pub fn SetPinCan1Mode(pt_grp: GPIO_Group) void {
    switch (pt_grp) {
        GPIO_Group.PTA => {
            PCC_Regs.PCC_PORT_Regs[0].CGC = 1;
            // can1 rx
            PORT_Regs.PORTA_PCR_Regs[12].MUX = 3;
            // can1 tx
            PORT_Regs.PORTA_PCR_Regs[13].MUX = 3;
        },
        else => unreachable,
    }
}

/// This function jsut init the tx and rx without init cts and rts
pub fn SetPinLpuart0ModeWithoutHwCtl(comptime pt_grp: GPIO_Group) void {
    switch (pt_grp) {
        GPIO_Group.PTA => {
            PCC_Regs.PCC_PORT_Regs[0].CGC = 1;
            // PTA2 lpuart0 rx
            PORT_Regs.PORTA_PCR_Regs[2].MUX = 0b110;
            // PTA3 lpuart0 tx
            PORT_Regs.PORTA_PCR_Regs[3].MUX = 0b110;
        },
        GPIO_Group.PTC => {
            PCC_Regs.PCC_PORT_Regs[2].CGC = 1;
            // lpuart0 rx
            PORT_Regs.PORTC_PCR_Regs[2].MUX = 0b100;
            // lpuart0 tx
            PORT_Regs.PORTC_PCR_Regs[3].MUX = 0b100;
        },
        else => {
            comptime {
                @compileError("These gpio grp can't be configed as lpuart0 in s32k144");
            }
        },
    }
}
