//! The Lin1 Channel of this ECU
//! - version:0.1.0
//! - date: 20250321
//! - author: weng

const S32K_DRV = @import("s32k144_drivers_mod");
const S32K_SYS = @import("s32k144_genericSys_mod");
const PinDef = S32K_DRV.PIN.PinDefine;
const GpioGrp = S32K_DRV.PIN.GPIO_Group;
// LIN DRIVER IMPORT
const LinUsrCfg = S32K_DRV.LIN.LinUsrConfig;
const LinActorT = S32K_DRV.LIN.LinActorT;
const LinChecksumT = S32K_DRV.LIN.LinChecksumT;
const LinUserHandler = S32K_DRV.LIN.LinUserHandler;
const LinStatusT = S32K_DRV.LIN.LinStatusT;
// rtt
const ZigRtt = @import("root").ZigRtt;

/// This channel use TJA1021 As LIN Transister
const NXP_TJA1021 = struct {
    const LIN_TX0: PinDef = PinDef{
        .group = GpioGrp.PTC,
        .num = 3,
    };
    const LIN_RX0: PinDef = PinDef{
        .group = GpioGrp.PTC,
        .num = 2,
    };
    const LIN_SLP0: PinDef = PinDef{
        .group = GpioGrp.PTB,
        .num = 4,
    };

    pub fn TransformToNormalMode() void {
        S32K_DRV.PIN.SetPinGpioOutMode(LIN_SLP0);
        S32K_DRV.PIN.SetPinOutHigh(LIN_SLP0);
        // set mode
        // set LIN_TX0 and LIN_RX0 to lpuart mode
        S32K_DRV.PIN.SetPinLpuart0ModeWithoutHwCtl(LIN_TX0.group);
    }
    pub fn TransformToSleepMode() void {}
    pub fn TransformToStandbyMode() void {}
};

const bind_lpuart_index: u2 = 0;
var src_clk_freq: u32 = 0;
var bind_tx_buffer = [8]u8{ 0x00, 0x01, 0x02, 0x03, 0x44, 0x55, 0x00, 0x00 };
var bind_rx_buffer = [8]u8{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };

var lin1_usr_cfg: LinUsrCfg = LinUsrCfg{
    .lin_actor = LinActorT.SlAVE,
    .tgt_baudrate = 19200,
    .src_clk_type = S32K_SYS.ClockMgr.PCC_ClockSelectT.SOSCDIV2_CLK,

    .usr_handler = LinUserHandler{
        .OnMasterPubFrameEnd = &OnMasterPublishFrameEnd,
        .OnMasterSubHeadSentEnd = &OnMasterSubsHeadSentEnd,
        .OnMasterSubFrameTimeout = &OnMasterSubsFrameTimeout,

        .OnLinSubFrameEnd = &OnLinSubsFrameEnd,
        .OnLinSubFrameError = &OnLinSubsFrameError,

        .OnSlaveGotPID = &OnSlaveGotPID,
    },
};

/// Return false means not rec the data
fn OnSlaveGotPID(pid_got: u8, tgt_index_ptr: *u3, check_ptr: *LinChecksumT) bool {
    if (pid_got == 0x50) {
        tgt_index_ptr.* = 0;
        check_ptr.* = LinChecksumT.ENHANCED;
        ZigRtt.RTT_WriteIn0Channel(" id:0x10 - pid:0x50 got; len 5 ; enhanced \n");
        // Only for test whether this will trigger the rdrf interrupt again
        S32K_DRV.LIN.Lin_SlaveResponseBlockInRxInterrupt(
            bind_lpuart_index,
            pid_got,
            &bind_tx_buffer,
            5,
            LinChecksumT.ENHANCED,
        );
        return false;
    }
    return false;
}

fn OnMasterPublishFrameEnd(id_sent: u8, pid_sent: u8) void {
    _ = id_sent;
    _ = pid_sent;
}

fn OnMasterSubsHeadSentEnd(id_sent: u8, pid_sent: u8) void {
    _ = id_sent;
    _ = pid_sent;
    ZigRtt.RTT_WriteIn0Channel(" id 0x15 start read data \n");
}

fn OnLinSubsFrameEnd(pid: u8, rec_datas: []u8) void {
    _ = pid;
    _ = rec_datas;
    ZigRtt.RTT_WriteIn0Channel(" id 0x15 received response \n");
}

fn OnLinSubsFrameError(pid: u8, rec_datas: []u8, checksum_rec: u8) void {
    _ = pid;
    //_ = rec_datas;
    _ = checksum_rec;
    _ = rec_datas;
    ZigRtt.RTT_WriteIn0Channel(" id 0x12 received data is error \n");
}

fn OnMasterSubsFrameTimeout(pid: u8) void {
    _ = pid;
    ZigRtt.RTT_WriteIn0Channel(" id 0x12 received timeout\n");
}

pub fn InitChannel() void {
    NXP_TJA1021.TransformToNormalMode();
    _ = S32K_DRV.LIN.LIN_Init(bind_lpuart_index, &lin1_usr_cfg);
    //_ = S32K_SYS.LPTMR_Mgr.LPTMR0_RegisterTask(&LIN1_Lptmr0Task);
}

fn LIN1_Lptmr0Task() void {
    //S32K_DRV.LIN.Lin_MasterPublishFrame(bind_lpuart_index, 0x22, &bind_tx_buffer, 7, LinChecksumT.ENHANCED);
    S32K_DRV.LIN.Lin_MasterSendSubscribeHeadBlock(bind_lpuart_index, 0x12, 4, LinChecksumT.ENHANCED);
}

pub fn MasterTestSending() void {
    //S32K_DRV.LIN.Lin_MasterSendSubscribeHead(bind_lpuart_index, 0x15, 4, LinChecksumT.ENHANCED);
    //S32K_DRV.LIN.Lin_MasterSendSubscribeHead(bind_lpuart_index, 0x12, 3, LinChecksumT.ENHANCED);
}
