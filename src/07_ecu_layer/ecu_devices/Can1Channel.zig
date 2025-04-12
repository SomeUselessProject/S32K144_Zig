//! The CAN1 CHANNEL of this ECU
//! - version:0.1.0
//! - date: 20250321
//! - author: weng

const S32K_DRV = @import("s32k144_drivers_mod");
const S32K_SYS = @import("s32k144_genericSys_mod");
const PinDef = S32K_DRV.PIN.PinDefine;
const GpioGrp = S32K_DRV.PIN.GPIO_Group;

/// This channel use 1043t as physical
const NXP1043T = struct {
    const EN_pin: PinDef = PinDef{
        .group = GpioGrp.PTA,
        .num = 11,
    };
    const STB_N_pin: PinDef = PinDef{
        .group = GpioGrp.PTE,
        .num = 0,
    };

    pub fn SetToNormal() void {
        S32K_DRV.PIN.SetPinGpioOutMode(EN_pin);
        S32K_DRV.PIN.SetPinOutHigh(EN_pin);
        S32K_DRV.PIN.SetPinGpioOutMode(STB_N_pin);
        S32K_DRV.PIN.SetPinOutHigh(STB_N_pin);
    }
};

const rx_pin = PinDef{
    .group = GpioGrp.PTA,
    .num = 12,
};
const tx_pin = PinDef{
    .group = GpioGrp.PTA,
    .num = 13,
};

const can_index: u2 = 1;

pub fn InitChannel() void {
    NXP1043T.SetToNormal();
    S32K_DRV.PIN.SetPinCan1Mode(rx_pin.group);
    S32K_DRV.CAN.InitClassicCanWith500K(can_index);
    //_ = S32K_SYS.LPTMR_Mgr.LPTMR0_RegisterTask(&CAN1_Lptmr0Task);
    //S32K_DRV.NVIC.Install_IsrHandler(IRQnType.IRQn_CAN1_ORed, CAN1_ORed_IRQHandler);
}

fn CAN1_Lptmr0Task() void {
    S32K_DRV.CAN.SendClassicCanMsg(1, 0, 0x200, [8]u8{ 0x01, 0x02, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00 });
}

pub fn CAN1_ORed_IRQHandler() callconv(.C) void {
    // do something here ...
}
