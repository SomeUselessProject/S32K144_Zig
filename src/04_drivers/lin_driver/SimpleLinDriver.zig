//! Depreciated!
//! The Simple Lin driver of s32k144
//! - default use interrupt to receive the msg
//! - version: 0.1.0
//! - date: 2025/03/24
//! - author: weng

//#region General Import
const GenericSts = @import("s32k144_genericSys_mod").GenericSts;
const RegT = @import("s32k144_regs_mod").RegT;
const FieldSet = RegT.FieldSet;
const LPUART_Regs = @import("s32k144_regs_mod").LPUART_Regs;
const BAUD = LPUART_Regs.LPUART_BAUD;
const STAT = LPUART_Regs.LPUART_STAT;
const CTRL = LPUART_Regs.LPUART_CTRL;
const MATCH = LPUART_Regs.LPUART_MATCH;
const MODIR = LPUART_Regs.LPUART_MODIR;
const FIFO = LPUART_Regs.LPUART_FIFO;
const WATER = LPUART_Regs.LPUART_WATER;
const DATA = LPUART_Regs.LPUART_DATA;
const GLOBAL = LPUART_Regs.LPUART_GLOBAL;
// Interrupts
const NVIC_Mgr = @import("s32k144_genericSys_mod").NVIC_Mgr;
const IQRnT = NVIC_Mgr.IQRnType;
const IsrHandlerFunc = NVIC_Mgr.IsrHandlerFunc;
// System clock
const ClockMgr = @import("s32k144_genericSys_mod").ClockMgr;
const PCC_ClockSelectT = ClockMgr.PCC_ClockSelectT;
//#endregion
//---------------------------------------------
//#region General Define
pub const LinActorT = enum(u1) {
    MASTER = 0,
    SlAVE = 1,
};

pub const LinFrameActionT = enum(u1) {
    SUBSCRIBE = 0,
    PUBLISH = 1,
};

pub const LinChecksumT = enum(u1) {
    CLASSIC = 0,
    ENHANCED = 1,
};

pub const LinStatusT = enum(u4) {
    IDLE = 0,
    SEND_BREAK = 1,
    BREAK_DETECTED = 2,
    SEND_SYNC = 3,
    SYNC_DETECTED = 4,
    SEND_PID = 5,
    PID_RECEIVED = 6,
    IN_PUBLISH = 7,
    IN_SUBSCRIBE = 8,
    FRAME_DATA_END = 9,

    SEND_CHECKSUM = 10,
    REC_CHECKSUM = 11,
    LIN_FRAME_END = 12,

    SLEEP = 13,
    WAKEUP = 14,
    ERROR_DETECTED = 15,
};

pub const LinUserHandler = struct {
    tx_buffer: *[8]u8 = undefined,
    rx_buffer: *[8]u8 = undefined,
    frame_end_callback: LinFrameTxRxEndCallback = undefined,
    pid_got_callback: LinPidGotCallback = undefined,
};

pub const LinUsrConfig = struct {
    lin_actor: LinActorT = LinActorT.MASTER,
    tgt_baudrate: u32 = 19200,
    src_clk_type: PCC_ClockSelectT = PCC_ClockSelectT.SOSCDIV2_CLK,
    usr_handler: LinUserHandler,
};

pub const LinDataOptState = struct {
    tgt_bytes_len: u4 = 0,
    crt_byte_index: u4 = 0,
    crt_id: u8 = 0,
    crt_pid: u8 = 0,
    checksum_type: LinChecksumT = LinChecksumT.ENHANCED,
};

pub const LinCrtState = struct {
    src_clk_freq: u32 = 8_000_000,
    crt_lin_actor: LinActorT = LinActorT.MASTER,
    crt_lin_status: LinStatusT = LinStatusT.IDLE,
    is_linbus_inited: bool = false,
    // user handling
    usr_handler_ptr: *LinUserHandler = undefined,
    data_opt_state: LinDataOptState = LinDataOptState{},
};

/// This callback is defined as comptime known
pub const LinFrameTxRxEndCallback = *const fn (data_state: *LinDataOptState) void;
/// if the a pid is received will call this function
/// - return the length of bytes need to be operated
pub const LinPidGotCallback = *const fn (crt_sts_ptr: *LinStatusT, data_state: *LinDataOptState) void;

//#endregion
// --------------------------------------------
/// The clock frequency of lin
var lin_states: [3]LinCrtState = .{
    LinCrtState{},
    LinCrtState{},
    LinCrtState{},
};

//#region Interrupt Part ----------------------------------
const lin_irq_types: [3]IQRnT = .{
    IQRnT.IRQn_LPUART0_RxTx,
    IQRnT.IRQn_LPUART1_RxTx,
    IQRnT.IRQn_LPUART2_RxTx,
};
const lin_irq_handlers: [3]IsrHandlerFunc = .{
    LIN0_RxTx_IRQHandler,
    LIN1_RxTx_IRQHandler,
    LIN2_RxTx_IRQHandler,
};

/// The interrupt handler to be exported
fn LIN0_RxTx_IRQHandler() callconv(.C) void {
    LIN_IRQHandler(0);
}
fn LIN1_RxTx_IRQHandler() callconv(.C) void {
    LIN_IRQHandler(1);
}
fn LIN2_RxTx_IRQHandler() callconv(.C) void {
    LIN_IRQHandler(2);
}

fn LIN_BreakInterruptCheck(index: u2) void {
    // 1 check breck flag is detected
    if (STAT.reg_ins_arr[index].getFieldValue(STAT.LBKDIF) == 1) {
        // handle break event
        // write 1 to clear the flag
        STAT.reg_ins_arr[index].updateFieldValue(STAT.LBKDIF, 1);
        // read the registers to ensure the flag was cleared
        _ = STAT.reg_ins_arr[index].getRaw();
        // set break interrupt disabled
        // 必须关闭不然不能识别后续的东西
        STAT.reg_ins_arr[index].updateFieldValue(STAT.LBKDE, 0);
        // 收到break，如果是主节点会直接调用发送sync
        // not handle now
        //LIN_OnBreakReceived(index);
        lin_states[index].crt_lin_status = LinStatusT.BREAK_DETECTED;
    }
}

fn LIN_FrameErrorInterruptCheck(index: u2) void {
    if (STAT.reg_ins_arr[index].getFieldValue(STAT.FE) == 1) {
        STAT.reg_ins_arr[index].updateFieldValue(STAT.FE, 1);
        // read the registers to ensure the flag was cleared
        _ = STAT.reg_ins_arr[index].getRaw();
        lin_states[index].crt_lin_status = LinStatusT.ERROR_DETECTED;
    }
}

fn LIN_OverRunInterruptCheck(index: u2) void {
    if (STAT.reg_ins_arr[index].getFieldValue(STAT.OR) == 1) {
        STAT.reg_ins_arr[index].updateFieldValue(STAT.OR, 1);
        // read the registers to ensure the flag was cleared
        _ = STAT.reg_ins_arr[index].getRaw();
        lin_states[index].crt_lin_status = LinStatusT.ERROR_DETECTED;
    }
}

fn LIN_IdleInterruptCheck(index: u2) void {
    if (STAT.reg_ins_arr[index].getFieldValue(STAT.IDLE) == 1) {
        STAT.reg_ins_arr[index].updateFieldValue(STAT.IDLE, 1);
        // read the registers to ensure the flag was cleared
        _ = STAT.reg_ins_arr[index].getRaw();
        // handle the idle status
        //lin_states[index].crt_lin_status = LinStatusT.IDLE;
    }
}

fn LIN_RxFullInterruptCheck(index: u2) void {
    if (STAT.reg_ins_arr[index].getFieldValue(STAT.RDRF) == 1) {
        const read_value: u8 = @intCast(DATA.reg_ins_arr[index].getRaw());
        // new logic here
        switch (lin_states[index].crt_lin_status) {
            LinStatusT.BREAK_DETECTED,
            LinStatusT.SEND_SYNC,
            => {
                LIN_OnSyncByteReceived(index, read_value);
            },
            LinStatusT.SYNC_DETECTED,
            LinStatusT.SEND_PID,
            => {
                LIN_OnPidReceived(index, read_value);
                // check the next operation set by user
                // user should set publish or subscribe
                if (lin_states[index].crt_lin_status == LinStatusT.IN_PUBLISH) {
                    LIN_PublishDataByte(index);
                }
            },
            LinStatusT.IN_PUBLISH,
            LinStatusT.IN_SUBSCRIBE,
            => {
                LIN_OnDataByteReceived(index, read_value);
            },
            LinStatusT.REC_CHECKSUM,
            LinStatusT.SEND_CHECKSUM,
            => {
                LIN_OnChecksumReceived(index, read_value);
            },
            LinStatusT.IDLE => {
                // in idle status should not receive anything
                lin_states[index].crt_lin_status = LinStatusT.ERROR_DETECTED;
            },
            else => unreachable,
        }
    }
}

fn LIN_IRQHandler(comptime index: u2) void {
    comptime {
        if (index > 2) @compileError("only 3 lin resources in s32k144");
    }
    // 1 check breck flag is detected
    LIN_BreakInterruptCheck(index);
    // 3 check frame error flag
    LIN_FrameErrorInterruptCheck(index);
    // 4 check over run flag
    LIN_OverRunInterruptCheck(index);
    // 5 receive data is full
    LIN_RxFullInterruptCheck(index);
    // 2 check idle flag
    // the idle interrupt is not enabled
    // attention to handle it if the bus is idle
    //LIN_IdleInterruptCheck(index);

    if (lin_states[index].crt_lin_status == LinStatusT.LIN_FRAME_END) {
        LIN_OnLinFrameEnd(index);
        //LIN_StateToIdle(index);
    }

    if (lin_states[index].crt_lin_status == LinStatusT.ERROR_DETECTED) {
        LIN_StateToIdle(index);
    }
}

//#endregion
// --------------------------------------------------------------------------------

/// Init the target lin by user config
/// - checked ok
pub fn LIN_Init(comptime index: u2, usr_cfg_ptr: *LinUsrConfig) GenericSts {
    comptime {
        if (index > 2) @compileError("Only got 3(0,1,2) lpuart work as lin in s32k144");
    }
    // if the lin has been inited return error
    // the lin ins musted be stopped at first
    if (lin_states[index].is_linbus_inited) return GenericSts.STATUS_REINIT;
    //lin_states[index].is_linbus_inited = false;
    lin_states[index].crt_lin_actor = usr_cfg_ptr.lin_actor;
    // init other from lin user config
    lin_states[index].usr_handler_ptr = &usr_cfg_ptr.usr_handler;
    // set pcc clock
    _ = ClockMgr.PCC_CLK_Mgr.SetLpuartClkSrc(
        index,
        usr_cfg_ptr.src_clk_type,
        &lin_states[index].src_clk_freq,
    );

    // init operation
    GLOBAL.reg_ins_arr[index].updateFieldValue(GLOBAL.RST, 1);
    GLOBAL.reg_ins_arr[index].updateFieldValue(GLOBAL.RST, 0);

    // set baudrate
    BAUD.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
        // one stop bit for lin
        FieldSet{ .field_def = BAUD.SBNS, .field_value = 0 },
        // clear sbr
        FieldSet{ .field_def = BAUD.SBR, .field_value = 0 },
        // lin use 7-9 bits
        FieldSet{ .field_def = BAUD.M10, .field_value = 0 },
        // enable break interrupt
        FieldSet{ .field_def = BAUD.LBKDIE, .field_value = 1 },
        FieldSet{ .field_def = BAUD.RESYNCDIS, .field_value = 0 },
        // disable rx input interrupt
        FieldSet{ .field_def = BAUD.RXEDGIE, .field_value = 0 },
        // disable  dma
        FieldSet{ .field_def = BAUD.TDMAE, .field_value = 0 },
        FieldSet{ .field_def = BAUD.RDMAE, .field_value = 0 },
        // disable matching mode
        FieldSet{ .field_def = BAUD.MAEN1, .field_value = 0 },
        FieldSet{ .field_def = BAUD.MAEN2, .field_value = 0 },
        FieldSet{ .field_def = BAUD.MATCFG, .field_value = 0 },
    });
    _ = LIN_SetBaudrate(index, usr_cfg_ptr.tgt_baudrate);
    // disable parity
    CTRL.reg_ins_arr[index].updateFieldValue(CTRL.PE, 0);
    // state define
    // set lsb bit0
    STAT.reg_ins_arr[index].updateFieldValue(STAT.MSBF, 0);
    STAT.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
        // 13bits break
        FieldSet{ .field_def = STAT.BRK13, .field_value = 1 },
        // detect lin break
        FieldSet{ .field_def = STAT.LBKDE, .field_value = 1 },
    });

    // set ctrl register
    CTRL.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
        // enable overrun interrupt
        FieldSet{ .field_def = CTRL.ORIE, .field_value = 1 },
        // enable frame error interrupt
        FieldSet{ .field_def = CTRL.PEIE, .field_value = 1 },
        // enable receive interrupt
        FieldSet{ .field_def = CTRL.RIE, .field_value = 1 },
        // disable transmit interrupt
        FieldSet{ .field_def = CTRL.TIE, .field_value = 0 },
        // 128 idle characters
        FieldSet{ .field_def = CTRL.IDLECFG, .field_value = 0b111 },
        FieldSet{ .field_def = CTRL.ILT, .field_value = 1 },
        // enable line idle interrupt
        // changed 0327 disable idle interrupt
        FieldSet{ .field_def = CTRL.ILIE, .field_value = 0 },
        // enable rx and tx
        FieldSet{ .field_def = CTRL.RE, .field_value = 1 },
        FieldSet{ .field_def = CTRL.TE, .field_value = 1 },
    });

    NVIC_Mgr.NVIC_EnableInterrupt(lin_irq_types[index]);
    lin_states[index].is_linbus_inited = true;
    lin_states[index].crt_lin_status = LinStatusT.IDLE;
    return GenericSts.STATUS_SUCCESS;
}

/// Set the baudrate of lin bus by the setting from users
/// - checked ok
fn LIN_SetBaudrate(comptime index: u2, tgt_baudrate: u32) GenericSts {
    comptime {
        if (index > 2) @compileError("Only got 3(0,1,2) lpuart work as lin in s32k144");
        //if (tgt_baudrate > 19200) @compileError("LIN MAX Baudrate in lin2.X is 19200");
    }

    const clock_freq = lin_states[index].src_clk_freq;
    var osr: u32 = 4;
    // sbr = 104
    var sbr: u32 = clock_freq / (tgt_baudrate * osr);
    // cal_baudrate = 19230
    var cal_baudrate: u32 = clock_freq / (sbr * osr);
    var baud_diff: u32 = 0;
    // baud_diff = 30
    if (cal_baudrate > tgt_baudrate) baud_diff = cal_baudrate - tgt_baudrate;
    if (cal_baudrate < tgt_baudrate) baud_diff = tgt_baudrate - cal_baudrate;
    // calculate the max osr value
    var max_osr: u32 = clock_freq / tgt_baudrate;
    if (max_osr > 32) max_osr = 32;
    // calculate the min baudrate diff
    if (max_osr >= 5) {
        for (5..max_osr + 1) |i| {
            const sbr_temp = clock_freq / (tgt_baudrate * i);
            cal_baudrate = clock_freq / (sbr_temp * i);
            var temp_diff: u32 = 0;
            if (cal_baudrate >= tgt_baudrate) temp_diff = cal_baudrate - tgt_baudrate;
            if (cal_baudrate < tgt_baudrate) temp_diff = tgt_baudrate - cal_baudrate;
            // check the new diff is more small
            if (temp_diff < baud_diff) {
                osr = i;
                baud_diff = temp_diff;
                sbr = sbr_temp;
            }
        }
    }
    // Check if osr is between 4x and 7x oversampling.
    // If so, then "BOTHEDGE" sampling must be turned on
    if (osr < 8) {
        BAUD.reg_ins_arr[index].updateFieldValue(BAUD.BOTHEDGE, 1);
    }
    // 0x1f real 32
    BAUD.reg_ins_arr[index].updateFieldValue(BAUD.OSR, osr - 1);
    // 0xd real 13
    BAUD.reg_ins_arr[index].updateFieldValue(BAUD.SBR, sbr);
    return GenericSts.STATUS_SUCCESS;
}

/// Get tgt bit in a value
inline fn GetBit(value: u8, bit: u3) u8 {
    return (value >> bit) & 0x01;
}

fn LIN_GetPID(id: u8) u8 {
    if (id > 0x3F) {
        return 0x00;
    }
    // P0: ID[0] ^ ID[1] ^ ID[2] ^ ID[4]
    const p0 = (id & 0x01) ^ ((id >> 1) & 0x01) ^ ((id >> 2) & 0x01) ^ ((id >> 4) & 0x01);
    // P1: !(ID[1] ^ ID[3] ^ ID[4] ^ ID[5])
    const p1 = ~((id >> 1) & 0x01) ^ ((id >> 3) & 0x01) ^ ((id >> 4) & 0x01) ^ ((id >> 5) & 0x01) & 0x01;
    // PID: P1 bit 7,P0 bit 6 (ID range 0..5)
    const pid = (p1 << 7) | (p0 << 6) | id;
    return pid & 0xFF;
}

fn LIN_GetID(pid: u8) u8 {
    // Get ID
    const id = pid & 0x3F;
    // Double check the pid
    const p0_received = (pid >> 6) & 0x01;
    const p1_received = (pid >> 7) & 0x01;
    const p0_calculated = (id & 0x01) ^ ((id >> 1) & 0x01) ^ ((id >> 2) & 0x01) ^ ((id >> 4) & 0x01);
    const p1_calculated = ~((id >> 1) & 0x01) ^ ((id >> 3) & 0x01) ^ ((id >> 4) & 0x01) ^ ((id >> 5) & 0x01) & 0x01;
    if (p0_received != p0_calculated or p1_received != p1_calculated) {
        return 0x00;
    }
    return id;
}

fn LIN_StateToIdle(index: u2) void {
    lin_states[index].data_opt_state.checksum_type = LinChecksumT.ENHANCED;
    lin_states[index].data_opt_state.crt_id = 0;
    lin_states[index].data_opt_state.crt_pid = 0;
    lin_states[index].data_opt_state.tgt_bytes_len = 0;
    lin_states[index].data_opt_state.crt_byte_index = 0;
    lin_states[index].crt_lin_status = LinStatusT.IDLE;
    // set the break detection interrupt again
    if (STAT.reg_ins_arr[index].getFieldValue(STAT.LBKDE) == 0) {
        STAT.reg_ins_arr[index].updateFieldValue(STAT.LBKDE, 1);
    }
}

pub fn LIN_MasterSendHeaderInBlock(index: u2, id: u8) void {
    if (lin_states[index].is_linbus_inited == false) return;
    if (lin_states[index].crt_lin_actor != LinActorT.MASTER) return;
    if (lin_states[index].crt_lin_status != LinStatusT.IDLE) return;
    // 1 send break
    // wait until the tx buffer is empty
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    // queue the break characters
    lin_states[index].crt_lin_status = LinStatusT.SEND_BREAK;
    CTRL.reg_ins_arr[index].updateFieldValue(CTRL.SBK, 1);
    CTRL.reg_ins_arr[index].updateFieldValue(CTRL.SBK, 0);
    // 2 send sync byte
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    lin_states[index].crt_lin_status = LinStatusT.SEND_SYNC;
    DATA.reg_ins_arr[index].setRaw(0x55);
    // 3 send pid
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    const pid_sent: u8 = LIN_GetPID(id);
    lin_states[index].crt_lin_status = LinStatusT.SEND_PID;
    DATA.reg_ins_arr[index].setRaw(pid_sent);
    // 4 re enable the break detect
    if (STAT.reg_ins_arr[index].getFieldValue(STAT.LBKDE) == 0) {
        STAT.reg_ins_arr[index].updateFieldValue(STAT.LBKDE, 1);
    }
    lin_states[index].crt_lin_status = LinStatusT.IDLE;
}

/// send a master frame in block
/// - tx_data is []u8 slice, so the length is already known
pub fn LIN_MasterPublishAFrameInBlock(
    index: u2,
    comptime id: u8,
    tx_data: *[8]u8,
    comptime tx_len: u4,
    checksum_type: LinChecksumT,
) void {
    comptime {
        if (tx_len > 8 or tx_len == 0) @compileError("TX Length error");
        if (id > 0x3F) @compileError("LIN ID can't larger than 0x3F");
    }
    if (lin_states[index].is_linbus_inited == false) return;
    if (lin_states[index].crt_lin_actor != LinActorT.MASTER) return;
    if (lin_states[index].crt_lin_status != LinStatusT.IDLE) return;
    // 1 send break
    // wait until the tx buffer is empty
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    // queue the break characters
    lin_states[index].crt_lin_status = LinStatusT.SEND_BREAK;
    CTRL.reg_ins_arr[index].updateFieldValue(CTRL.SBK, 1);
    CTRL.reg_ins_arr[index].updateFieldValue(CTRL.SBK, 0);
    // 2 send sync byte
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    lin_states[index].crt_lin_status = LinStatusT.SEND_SYNC;
    DATA.reg_ins_arr[index].setRaw(0x55);
    // 3 send pid
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    const pid_sent: u8 = LIN_GetPID(id);
    lin_states[index].crt_lin_status = LinStatusT.SEND_PID;
    DATA.reg_ins_arr[index].setRaw(pid_sent);
    // 4 publish frame datas
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    lin_states[index].crt_lin_status = LinStatusT.IN_PUBLISH;
    for (0..tx_len) |i| {
        DATA.reg_ins_arr[index].setRaw(tx_data[i]);
        while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    }
    // 5 send checksum
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    const check_value = LIN_GetChecksum(checksum_type, pid_sent, tx_data, tx_len);
    lin_states[index].crt_lin_status = LinStatusT.SEND_CHECKSUM;
    DATA.reg_ins_arr[index].setRaw(check_value);

    // 6 open break detect and turn into idle
    // 4 re enable the break detect
    if (STAT.reg_ins_arr[index].getFieldValue(STAT.LBKDE) == 0) {
        STAT.reg_ins_arr[index].updateFieldValue(STAT.LBKDE, 1);
    }
    lin_states[index].crt_lin_status = LinStatusT.IDLE;
    // 7 call the LinMasterPublishEndCallBack

}

pub fn LIN_MasterSubscribeAFrame() void {}

pub fn LIN_SlavePublishAFrame() void {}

pub fn LIN_SlaveSubscribeAFrame() void {}

// old coding ------------------------------------------------

fn LIN_MasterSendBreak(index: u2) void {
    if (lin_states[index].is_linbus_inited == false) return;
    if (lin_states[index].crt_lin_actor != LinActorT.MASTER) return;
    // wait until the tx buffer is empty
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    // queue the break characters
    lin_states[index].crt_lin_status = LinStatusT.SEND_BREAK;
    CTRL.reg_ins_arr[index].updateFieldValue(CTRL.SBK, 1);
    CTRL.reg_ins_arr[index].updateFieldValue(CTRL.SBK, 0);
}

fn LIN_OnBreakReceived(index: u2) void {
    CTRL.reg_ins_arr[index].updateFieldValue(CTRL.SBK, 0);
    lin_states[index].crt_lin_status = LinStatusT.BREAK_DETECTED;
    if (lin_states[index].crt_lin_actor == LinActorT.MASTER) {
        LIN_MasterSendSyncByte(index);
    }
}

fn LIN_MasterSendSyncByte(index: u2) void {
    if (lin_states[index].crt_lin_status != LinStatusT.BREAK_DETECTED) {
        // the sync byte must follow break
        // set crt status to error
        lin_states[index].crt_lin_status = LinStatusT.ERROR_DETECTED;
        return;
    }
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    lin_states[index].crt_lin_status = LinStatusT.SEND_SYNC;
    DATA.reg_ins_arr[index].setRaw(0x55);
}

fn LIN_OnSyncByteReceived(index: u2, byte_value: u8) void {
    if (byte_value != 0x55) {
        lin_states[index].crt_lin_status = LinStatusT.ERROR_DETECTED;
        return;
    }
    lin_states[index].crt_lin_status = LinStatusT.SYNC_DETECTED;
    if (lin_states[index].crt_lin_actor == LinActorT.MASTER) {
        LIN_MasterSendPID(index);
    }
}

fn LIN_MasterSendPID(index: u2) void {
    if (lin_states[index].crt_lin_status != LinStatusT.SYNC_DETECTED) {
        // pid must be sent out after a sync byte
        lin_states[index].crt_lin_status = LinStatusT.ERROR_DETECTED;
        return;
    }
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    lin_states[index].crt_lin_status = LinStatusT.SEND_PID;
    DATA.reg_ins_arr[index].setRaw(lin_states[index].data_opt_state.crt_pid);
}

fn LIN_OnPidReceived(index: u2, pid: u8) void {
    lin_states[index].crt_lin_status = LinStatusT.PID_RECEIVED;
    lin_states[index].data_opt_state.crt_pid = pid;
    lin_states[index].data_opt_state.crt_id = LIN_GetID(pid);
    // call user to handle the pid got
    // user need to reset the lin status and data
    // the final status must be in publish or in subscribe
    lin_states[index].usr_handler_ptr.pid_got_callback(
        &lin_states[index].crt_lin_status,
        &lin_states[index].data_opt_state,
    );
}

fn LIN_PublishDataByte(index: u2) void {
    if (lin_states[index].crt_lin_status != LinStatusT.IN_PUBLISH) {
        lin_states[index].crt_lin_status = LinStatusT.ERROR_DETECTED;
        return;
    }
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    const crt_index = lin_states[index].data_opt_state.crt_byte_index;
    if (crt_index < lin_states[index].data_opt_state.tgt_bytes_len) {
        DATA.reg_ins_arr[index].setRaw(lin_states[index].usr_handler_ptr.tx_buffer[crt_index]);
        //lin_states[index].data_opt_state.crt_byte_index += 1;
    }
}

fn LIN_OnDataByteReceived(index: u2, new_byte: u8) void {
    const crt_index = lin_states[index].data_opt_state.crt_byte_index;
    const is_frame_end: bool = crt_index >= (lin_states[index].data_opt_state.tgt_bytes_len - 1);
    // must in publishing or subscribing
    if (lin_states[index].crt_lin_status == LinStatusT.IN_PUBLISH) {
        // publishing
        // check is reaching end of opt bytes
        // in publishing mode the rx buffer was also used to store the data
        if (is_frame_end) {
            lin_states[index].usr_handler_ptr.rx_buffer[crt_index] = new_byte;
            lin_states[index].crt_lin_status = LinStatusT.FRAME_DATA_END;
            // SEND CHECK SUM
            LIN_SendChecksum(index);
        } else {
            lin_states[index].usr_handler_ptr.rx_buffer[crt_index] = new_byte;
            lin_states[index].data_opt_state.crt_byte_index += 1;
            // sending data byte
            LIN_PublishDataByte(index);
        }
    } else if (lin_states[index].crt_lin_status == LinStatusT.IN_SUBSCRIBE) {
        // write the data to buffer
        if (is_frame_end) {
            lin_states[index].usr_handler_ptr.rx_buffer[crt_index] = new_byte;
            lin_states[index].crt_lin_status = LinStatusT.REC_CHECKSUM;
            // waiting to receive the checksum
        } else {
            lin_states[index].usr_handler_ptr.rx_buffer[crt_index] = new_byte;
            lin_states[index].data_opt_state.crt_byte_index += 1;
        }
    } else {
        lin_states[index].crt_lin_status = LinStatusT.ERROR_DETECTED;
    }
}

fn LIN_MakeClassicChecksum(data_buff: *[8]u8, len: u4) u8 {
    if (len > 8) return 0;
    var checksum: u16 = 0;
    for (0..len) |i| {
        checksum += data_buff[i];
        if (checksum > 0xFF) {
            checksum -= 0xFF;
        }
    }
    return @as(u8, @intCast(~checksum));
}

fn LIN_MakeEnhancedChecksum(pid: u8, data_buff: *[8]u8, len: u4) u8 {
    if (len > 8) return 0;
    var checksum: u16 = 0;
    // For PID is 0x3C (ID 0x3C) or 0x7D (ID 0x3D) or 0xFE (ID 0x3E) or 0xBF (ID 0x3F)
    // apply classic checksum and apply enhanced checksum for other PID
    if ((0x3C != pid) and (0x7D != pid) and (0xFE != pid) and (0xBF != pid)) {
        // For PID other than 0x3C, 0x7D, 0xFE and 0xBF: Add PID in checksum calculation */
        checksum = pid;
    } else {
        // For 0x3C, 0x7D, 0xFE and 0xBF: Do not add PID in checksum calculation
        checksum = 0;
    }

    for (0..len) |i| {
        checksum += data_buff[i];
        if (checksum > 0xFF) {
            checksum -= 0xFF;
        }
    }
    return @as(u8, @intCast(~checksum));
}

fn LIN_GetChecksum(check_type: LinChecksumT, pid: u8, data_buff: *[8]u8, data_len: u4) u8 {
    const checksum = switch (check_type) {
        LinChecksumT.CLASSIC => LIN_MakeClassicChecksum(data_buff, data_len),
        LinChecksumT.ENHANCED => LIN_MakeEnhancedChecksum(pid, data_buff, data_len),
    };
    return checksum;
}

fn LIN_SendChecksum(index: u2) void {
    if (lin_states[index].crt_lin_status != LinStatusT.FRAME_DATA_END) {
        lin_states[index].crt_lin_status = LinStatusT.ERROR_DETECTED;
        return;
    }
    const checksum = LIN_GetChecksum(
        lin_states[index].data_opt_state.checksum_type,
        lin_states[index].data_opt_state.crt_pid,
        lin_states[index].usr_handler_ptr.tx_buffer,
        lin_states[index].data_opt_state.tgt_bytes_len,
    );
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    lin_states[index].crt_lin_status = LinStatusT.SEND_CHECKSUM;
    DATA.reg_ins_arr[index].setRaw(checksum);
}

fn LIN_OnChecksumReceived(index: u2, checksum_value: u8) void {
    if (lin_states[index].crt_lin_status != LinStatusT.SEND_CHECKSUM or
        lin_states[index].crt_lin_status != LinStatusT.REC_CHECKSUM)
    {
        lin_states[index].crt_lin_status = LinStatusT.ERROR_DETECTED;
        return;
    }
    // need to check the checksum received is equal to calculated value
    const rx_checksum = LIN_GetChecksum(
        lin_states[index].data_opt_state.checksum_type,
        lin_states[index].data_opt_state.crt_pid,
        lin_states[index].usr_handler_ptr.rx_buffer,
        lin_states[index].data_opt_state.tgt_bytes_len,
    );
    if (checksum_value == rx_checksum) {
        // a lin frame is complete
        lin_states[index].crt_lin_status = LinStatusT.LIN_FRAME_END;
    } else {
        lin_states[index].crt_lin_status = LinStatusT.ERROR_DETECTED;
    }
}

fn LIN_OnLinFrameEnd(index: u2) void {
    if (lin_states[index].crt_lin_status != LinStatusT.LIN_FRAME_END) {
        lin_states[index].crt_lin_status = LinStatusT.ERROR_DETECTED;
        return;
    }
    // call user to handle the ending
    lin_states[index].usr_handler_ptr.frame_end_callback(
        &lin_states[index].data_opt_state,
    );
    LIN_StateToIdle(index);
}

/// This Function will block the time during sending header
/// - the block time is 19200bps
/// - 13 + 8 + 8 = 29bits cost 156us
pub fn LIN_MasterStartSendingHeader(comptime index: u2, id: u8) void {
    comptime {
        if (index > 2) @compileError("Only 3 lin resources in s32k144");
    }
    if (lin_states[index].is_linbus_inited == false) return;
    if (lin_states[index].crt_lin_actor != LinActorT.MASTER) return;
    LIN_StateToIdle(index);

    lin_states[index].data_opt_state.crt_pid = LIN_GetPID(id);
    lin_states[index].data_opt_state.crt_id = id;
    LIN_MasterSendBreak(index);
}

// old part
// -----------------------------------------
pub fn LIN_SendResponse(comptime index: u2, send_bytes: *[]u8, comptime send_len: u4) void {
    comptime {
        if (index > 2) @compileError("Only 3 lin resources in s32k144");
        if (send_len > 8 or send_len == 0) @compileError("sending bytes length is not correct");
    }
    // send frame data
    for (0..send_len) |i| {
        while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
        DATA.reg_ins_arr[index].setRaw(send_bytes[i]);
        lin_states[index].crt_lin_status = LinStatusT.IN_PUBLISH;
    }
    // also need to send checksum

    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TC) == 0) {}
}

pub fn LIN_PublishDataInBuffer(comptime index: u2) void {
    comptime {
        if (index > 2) @compileError("Only 3 lin resources in s32k144");
    }

    if (lin_states[index].crt_lin_status != LinStatusT.IN_PUBLISH) return;

    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    if (lin_states[index].crt_opt_len < lin_states[index].tgt_opt_len) {
        DATA.reg_ins_arr[index].setRaw(lin_states[index].bind_tx_buff[lin_states[index].crt_opt_len]);
        lin_states[index].crt_lin_status = LinStatusT.IN_PUBLISH;
        lin_states[index].crt_opt_len += 1;
    } else {
        // reach the end
        lin_states[index].crt_lin_status = LinStatusT.PUBLISH_DATA_END;
    }
}
