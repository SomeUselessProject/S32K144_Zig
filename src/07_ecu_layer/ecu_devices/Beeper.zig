//! The Beeper of this ECU
//! - version:0.1.0
//! - date: 20250321
//! - author: weng

const S32K_DRV = @import("s32k144_drivers_mod");
const PinDef = S32K_DRV.PIN.PinDefine;
const GpioGrp = S32K_DRV.PIN.GPIO_Group;

const pin_def: PinDef = PinDef{
    .group = GpioGrp.PTD,
    .num = 13,
};

pub fn InitBeeper() void {
    //set PTD13 to gpio mode output
    S32K_DRV.PIN.SetPinGpioOutMode(pin_def);
}

pub fn MakeNoise() void {
    S32K_DRV.PIN.SetPinOutHigh(pin_def);
}

pub fn KeepSilent() void {
    S32K_DRV.PIN.SetPinOutLow(pin_def);
}

pub fn CloseCompletely() void {
    // disable PTD13
}

fn Beeper_Lptmr0Task() void {
    MakeNoise();
}
