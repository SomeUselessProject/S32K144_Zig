const S32K_DRV = @import("s32k144_drivers_mod");
const S32K_SYS = @import("s32k144_genericSys_mod");
const EcuDevices = @import("./EcuDevices.zig");

pub fn InitTheECU() void {
    // System init
    S32K_DRV.WDOG.DisableWdog();
    S32K_SYS.NVIC_Mgr.InitNVIC_Mgr();
    S32K_SYS.ClockMgr.SCG_Mgr.SCG_DefaultInit();
    S32K_SYS.ClockMgr.SysTickMgr.InitSysTick();
    S32K_SYS.LPTMR_Mgr.LPTMR_InitAsPccSelected(0);
    // System Init End ---------------

    // ECU Device init
    EcuDevices.InitAllEcuDevices();
    //S32K_SYS.ClockMgr.SysTickMgr.SysTickDelayMilliSeconds(100);
}

pub fn EcuLoopHandle() void {
    S32K_SYS.ClockMgr.SysTickMgr.SysTickDelaySeconds(1);
    //S32K_DRV.CAN.SendClassicCanMsg(1, 0, 0x300, [8]u8{ 0x01, 0x02, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00 });
    //EcuDevices.Lin1Channel.MasterTestSending();
}
