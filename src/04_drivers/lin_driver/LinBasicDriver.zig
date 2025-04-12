//! The basic lin driver
//! - default use interrupt to receive the msg
//! - send response in block
//! - version: 0.1.0
//! - date: 2025/03/24
//! - author: weng

// ----------------------------------------------------------------
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
// ----------------------------------------------------------------
// ----------------------------------------------------------------
//#region General Define
pub const LinActorT = enum(u1) {
    MASTER = 0,
    SlAVE = 1,
};

pub const LinChecksumT = enum(u1) {
    CLASSIC = 0,
    ENHANCED = 1,
};

pub const LinStatusT = enum(u8) {
    IDLE = 0,

    SEND_BREAK = 1,
    BREAK_DETECTED = 2,
    SEND_SYNC = 3,
    SYNC_DETECTED = 4,
    SEND_PID = 5,
    PID_RECEIVED = 6,
    SEND_HEAD_END = 7,

    IN_PUBLISH = 8,
    PUBLISH_BYTE_END = 9,
    IN_SUBSCRIBE = 10,
    FRAME_DATA_END = 11,

    SEND_CHECKSUM = 12,
    REC_CHECKSUM = 13,
    LIN_FRAME_END = 14,

    SLEEP = 20,
    WAKEUP = 21,
    ERROR_DETECTED = 22,
};

// master call back
// -----------------------------
pub const LinMasterPublishFrameEndCallback = *const fn (id_sent: u8, pid_sent: u8) void;
pub const LinMasterPublishFrameTimeoutCallback = *const fn (pid: u8) void;
pub const LinMasterSubscribeHeaderSentEndCallback = *const fn (id_sent: u8, pid_sent: u8) void;
pub const LinMasterSubscribeTimeoutCallback = *const fn (pid: u8) void;

// slave mode call back
// -----------------------------
/// Slave get a pid
/// - user should return the wanted byte index and checksum type
/// - return whether to receive the pid data
pub const LinSlaveOnGetPidCallback = *const fn (pid: u8, tgt_index: *u3, check_t_ptr: *LinChecksumT) bool;
pub const LinSlavePublishFrameEndCallback = *const fn (pid: u8) void;
// general mode callback
// -----------------------------
pub const LinSubscribeFrameEndCallback = *const fn (pid: u8, received_data_slice: []u8) void;
pub const LinSubscribeFrameErrorCallback = *const fn (pid: u8, rec_data_slice: []u8, rec_checksum: u8) void;

pub const LinUserHandler = struct {
    OnMasterPubFrameEnd: ?LinMasterPublishFrameEndCallback = null,
    OnMasterPubFrameTimeout: ?LinMasterPublishFrameTimeoutCallback = null,
    OnMasterSubHeadSentEnd: ?LinMasterSubscribeHeaderSentEndCallback = null,
    OnMasterSubFrameTimeout: ?LinMasterSubscribeTimeoutCallback = null,

    OnSlaveGotPID: ?LinSlaveOnGetPidCallback = null,
    OnSlavePubFrameEnd: ?LinSlavePublishFrameEndCallback = null,

    OnLinSubFrameEnd: ?LinSubscribeFrameEndCallback = null,
    OnLinSubFrameError: ?LinSubscribeFrameErrorCallback = null,
};

pub const LinUsrConfig = struct {
    lin_actor: LinActorT = LinActorT.MASTER,
    tgt_baudrate: u32 = 19200,
    src_clk_type: PCC_ClockSelectT = PCC_ClockSelectT.SOSCDIV2_CLK,
    usr_handler: LinUserHandler,
};

pub const LinCrtState = struct {
    src_clk_freq: u32 = 8_000_000,
    crt_lin_actor: LinActorT = LinActorT.MASTER,
    crt_lin_status: LinStatusT = LinStatusT.IDLE,
    is_linbus_inited: bool = false,
    // user handling
    usr_handler_ptr: *LinUserHandler = undefined,
    // basic data needed
    crt_pid: u8 = 0x00,
    crt_rx_bytes: [8]u8 = .{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
    crt_rx_index: u3 = 0,
    tgt_rx_index: u3 = 0,
    tgt_checksum_t: LinChecksumT = LinChecksumT.ENHANCED,
};

var lin_states: [3]LinCrtState = .{
    LinCrtState{},
    LinCrtState{},
    LinCrtState{},
};

//#endregion
// ----------------------------------------------------------------
// ----------------------------------------------------------------
//#region Interrupts
comptime {
    @export(&LIN0_RxTx_IRQHandler, .{
        .name = "LPUART0_RxTx_IRQHandler",
        .linkage = .strong,
    });
}

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

fn LIN_IRQHandler(comptime index: u2) void {
    comptime {
        if (index > 2) @compileError("only 3 lin resources in s32k144");
    }
    // 1 check breck flag is detected
    LIN_BreakInterruptCheck(index);
    // 3 check frame error flag
    LIN_FrameErrorInterruptCheck(index);
    // 5 receive data is full
    LIN_RxFullInterruptCheck(index);
    // 4 check over run flag
    LIN_OverRunInterruptCheck(index);

    LIN_IdleInterruptCheck(index);

    if (lin_states[index].crt_lin_status == LinStatusT.ERROR_DETECTED) {
        LIN_StateToIdle(index);
    }
}

/// Check Break detect flag
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
        //lin_states[index].crt_lin_status = LinStatusT.ERROR_DETECTED;
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
        const raw_value = DATA.reg_ins_arr[index].getRaw();
        //const rxempt_value = RegT.RegIns.GetFieldValueByRawData(DATA.RXEMPT, raw_value);
        //if (rxempt_value == 1) return;
        const read_value: u8 = @truncate(raw_value);
        // new logic here
        switch (lin_states[index].crt_lin_status) {
            LinStatusT.BREAK_DETECTED, // for slave
            LinStatusT.SEND_SYNC, // for master to get the sync byte sent by self
            => {
                if (read_value == 0x55) {
                    lin_states[index].crt_lin_status = LinStatusT.SYNC_DETECTED;
                } else {
                    lin_states[index].crt_lin_status = LinStatusT.ERROR_DETECTED;
                }
            },
            LinStatusT.SYNC_DETECTED, // for slave
            LinStatusT.SEND_PID, // for master to get the pid sent by self
            => {
                // The PID GOT
                if (lin_states[index].crt_lin_actor == LinActorT.MASTER) {
                    lin_states[index].crt_lin_status = LinStatusT.PID_RECEIVED;
                }

                if (lin_states[index].crt_lin_actor == LinActorT.SlAVE) {
                    lin_states[index].crt_lin_status = LinStatusT.PID_RECEIVED;
                    // call back if it is not null
                    if (lin_states[index].usr_handler_ptr.OnSlaveGotPID) |callback| {
                        var tgt_index: u3 = 0;
                        var checksum_t: LinChecksumT = LinChecksumT.ENHANCED;
                        // user return true to inform to receive the frame
                        if (callback(read_value, &tgt_index, &checksum_t)) {
                            // ready to receive the data
                            lin_states[index].crt_pid = read_value;
                            lin_states[index].crt_rx_index = 0;
                            lin_states[index].tgt_rx_index = tgt_index;
                            lin_states[index].tgt_checksum_t = checksum_t;
                            lin_states[index].crt_lin_status = LinStatusT.IN_SUBSCRIBE;
                        } else {
                            // ignore this pid
                            LIN_StateToIdle(index);
                        }
                    } else {
                        // user not register a pid got handler
                        // turn into idle mode
                        LIN_StateToIdle(index);
                    }
                }
            },
            LinStatusT.IN_PUBLISH,
            => {
                // The published byte was received by self
                lin_states[index].crt_lin_status = LinStatusT.PUBLISH_BYTE_END;
            },
            LinStatusT.IN_SUBSCRIBE,
            => {
                // receive the data
                if (lin_states[index].crt_rx_index < lin_states[index].tgt_rx_index) {
                    // rec
                    lin_states[index].crt_rx_bytes[lin_states[index].crt_rx_index] = read_value;
                    lin_states[index].crt_rx_index += 1;
                } else if (lin_states[index].crt_rx_index == lin_states[index].tgt_rx_index) {
                    lin_states[index].crt_rx_bytes[lin_states[index].crt_rx_index] = read_value;
                    // end rec
                    lin_states[index].crt_lin_status = LinStatusT.REC_CHECKSUM;
                }
            },
            LinStatusT.SEND_CHECKSUM,
            => {
                // The checksum was received by self
                lin_states[index].crt_lin_status = LinStatusT.LIN_FRAME_END;
            },
            LinStatusT.REC_CHECKSUM, // for subscribe the frame
            => {
                // 1 check the checksum is correct or not
                // 2 if it is correct callback
                // 3 the wrong checksum, call rec frame error callback
                const hope_checksum: u8 = LIN_GetChecksum(
                    lin_states[index].tgt_checksum_t,
                    lin_states[index].crt_pid,
                    &lin_states[index].crt_rx_bytes,
                    (1 + lin_states[index].tgt_rx_index),
                );
                if (read_value == hope_checksum) {
                    // get a frame successfully
                    if (lin_states[index].usr_handler_ptr.OnLinSubFrameEnd) |callback| {
                        const len: u8 = 1 + lin_states[index].tgt_rx_index;
                        callback(
                            lin_states[index].crt_pid,
                            lin_states[index].crt_rx_bytes[0..len],
                        );
                    }
                } else {
                    // the checksum is not correct
                    if (lin_states[index].usr_handler_ptr.OnLinSubFrameError) |callback| {
                        const len: u8 = 1 + lin_states[index].tgt_rx_index;
                        callback(
                            lin_states[index].crt_pid,
                            lin_states[index].crt_rx_bytes[0..len],
                            read_value,
                        );
                    }
                }
                LIN_StateToIdle(index);
            },
            LinStatusT.IDLE => {
                // in idle status should not receive anything
                // The byte received is ignored

            },
            else => unreachable,
        }
    }
}
//#endregion
// ----------------------------------------------------------------
// ----------------------------------------------------------------
//#region LIN DRIVER Self
fn LIN_StateToIdle(index: u2) void {
    if (lin_states[index].crt_lin_status == LinStatusT.IDLE) return;
    lin_states[index].crt_pid = 0x00;
    inline for (0..8) |i| {
        lin_states[index].crt_rx_bytes[i] = 0x00;
    }
    lin_states[index].crt_rx_index = 0;
    lin_states[index].tgt_rx_index = 0;
    lin_states[index].tgt_checksum_t = LinChecksumT.ENHANCED;
    lin_states[index].crt_lin_status = LinStatusT.IDLE;
    // set the break detection interrupt again
    if (STAT.reg_ins_arr[index].getFieldValue(STAT.LBKDE) == 0) {
        STAT.reg_ins_arr[index].updateFieldValue(STAT.LBKDE, 1);
    }
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

fn LIN_MakeClassicChecksum(data_buff: *[8]u8, len: u4) u8 {
    if (len > 8) return 0;
    var checksum: u16 = 0;
    for (0..len) |i| {
        checksum += data_buff[i];
        if (checksum > 0xFF) {
            checksum -= 0xFF;
        }
    }
    return @as(u8, @truncate(~checksum));
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
    return @as(u8, @truncate(~checksum));
}

fn LIN_GetChecksum(check_type: LinChecksumT, pid: u8, data_buff: *[8]u8, data_len: u4) u8 {
    const checksum = switch (check_type) {
        LinChecksumT.CLASSIC => LIN_MakeClassicChecksum(data_buff, data_len),
        LinChecksumT.ENHANCED => LIN_MakeEnhancedChecksum(pid, data_buff, data_len),
    };
    return checksum;
}

inline fn DisableRIE(index: u2) void {
    // close rec interrupt
    // Clear RDRF interrupt flag
    //_ = DATA.reg_ins_arr[index].getRaw();
    CTRL.reg_ins_arr[index].updateFieldValue(CTRL.RIE, 0);
}

inline fn EnableRIE(index: u2) void {
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) == 0) {}
    CTRL.reg_ins_arr[index].updateFieldValue(CTRL.RIE, 1);
    // clear at once
    _ = DATA.reg_ins_arr[index].getRaw();
}

inline fn DisableReceive(index: u2) void {
    CTRL.reg_ins_arr[index].updateFieldValue(CTRL.RE, 0);
}

inline fn EnableReceive(index: u2) void {
    //CTRL.reg_ins_arr[index].updateFieldValue(CTRL.RE, 1);
    //CTRL.reg_ins_arr[index].updateFieldValue(CTRL.RIE, 1);
    CTRL.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = CTRL.RIE, .field_value = 1 },
        FieldSet{ .field_def = CTRL.RE, .field_value = 1 },
    });
}

fn LIN_PutCharInData(index: u2, data: u8) void {
    //var raw_data: u32 = DATA.reg_ins_arr[index].getRaw();
    //raw_data = (0xFFFF_FF00 & raw_data) | data;
    //DATA.reg_ins_arr[index].setRaw(raw_data);
    const ptr: *volatile [4]u8 = @ptrCast(DATA.reg_ins_arr[index].raw_ptr);
    ptr[0] = data;
    //_ = ptr[0];
}

fn LIN_PutCharWhenEmpty(index: u2, byte_data: u8) void {
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    const ptr: *volatile [4]u8 = @ptrCast(DATA.reg_ins_arr[index].raw_ptr);
    ptr[0] = byte_data;
}

/// Send the Lin Master Head with block sequence
/// - the status will be changed by the rx interrupt handler
fn LIN_MasterSendHeaderInBlock(index: u2, pid: u8) void {
    // 1 send break
    // wait until the tx buffer is empty
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    // queue the break characters
    lin_states[index].crt_lin_status = LinStatusT.SEND_BREAK;
    CTRL.reg_ins_arr[index].updateFieldValue(CTRL.SBK, 1);
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TDRE) != 1) {}
    CTRL.reg_ins_arr[index].updateFieldValue(CTRL.SBK, 0);
    // 2 send sync byte
    // need to block here to confirm master has detected the break
    while (lin_states[index].crt_lin_status != LinStatusT.BREAK_DETECTED) {
        if (lin_states[index].crt_lin_status == LinStatusT.ERROR_DETECTED) return;
    }
    lin_states[index].crt_lin_status = LinStatusT.SEND_SYNC;
    LIN_PutCharWhenEmpty(index, 0x55);
    // 3 send pid
    // block here to confirm that the sync has already received by master
    while (lin_states[index].crt_lin_status != LinStatusT.SYNC_DETECTED) {
        if (lin_states[index].crt_lin_status == LinStatusT.ERROR_DETECTED) return;
    }
    lin_states[index].crt_lin_status = LinStatusT.SEND_PID;
    LIN_PutCharWhenEmpty(index, pid);
    // 4 check if the head is end
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TC) != 1) {}
    while (lin_states[index].crt_lin_status != LinStatusT.PID_RECEIVED) {
        if (lin_states[index].crt_lin_status == LinStatusT.ERROR_DETECTED) return;
    }
}

fn LIN_PublishFrameInBlock(index: u2, pid: u8, tx_data: *[8]u8, tx_len: u4, checksum_type: LinChecksumT) void {
    //DisableRIE(index);
    for (0..tx_len) |i| {
        lin_states[index].crt_lin_status = LinStatusT.IN_PUBLISH;
        LIN_PutCharWhenEmpty(index, tx_data[i]);
        // block here to wait rx interrupt
        while (lin_states[index].crt_lin_status != LinStatusT.PUBLISH_BYTE_END) {
            if (lin_states[index].crt_lin_status == LinStatusT.ERROR_DETECTED) return;
        }
    }
    // send checksum
    const check_value: u8 = LIN_GetChecksum(checksum_type, pid, tx_data, tx_len);
    lin_states[index].crt_lin_status = LinStatusT.SEND_CHECKSUM;
    LIN_PutCharWhenEmpty(index, check_value);
    // check frame sent out
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TC) != 1) {}
    while (lin_states[index].crt_lin_status != LinStatusT.LIN_FRAME_END) {
        if (lin_states[index].crt_lin_status == LinStatusT.ERROR_DETECTED) return;
    }
}

/// Set the baudrate of lin bus by the setting from users
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
            if (temp_diff <= baud_diff) {
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

//#endregion
// ----------------------------------------------------------------
// ----------------------------------------------------------------
//#region LIN Driver Public
pub fn Lin_MasterPublishFrameBlock(index: u2, id: u8, tx_data: *[8]u8, tx_len: u4, checksum_type: LinChecksumT) void {
    if (lin_states[index].is_linbus_inited == false) return;
    if (lin_states[index].crt_lin_actor != LinActorT.MASTER) return;
    if (lin_states[index].crt_lin_status != LinStatusT.IDLE) {
        // A LIN Frame didn't sent out completely
        // call the OnMasterPubFrameTimeout func
        if (lin_states[index].usr_handler_ptr.OnMasterPubFrameTimeout) |callback| {
            callback(lin_states[index].crt_pid);
        }
        LIN_StateToIdle(index);
    }
    const pid_sent: u8 = LIN_GetPID(id);
    LIN_MasterSendHeaderInBlock(index, pid_sent);
    LIN_PublishFrameInBlock(index, pid_sent, tx_data, tx_len, checksum_type);
    // call back
    if (lin_states[index].usr_handler_ptr.OnMasterPubFrameEnd) |callback| {
        callback(id, pid_sent);
    }
    // to idle
    LIN_StateToIdle(index);
}

pub fn Lin_MasterSendSubscribeHeadBlock(index: u2, id: u8, tgt_len: u4, checksum_type: LinChecksumT) void {
    if (lin_states[index].is_linbus_inited == false) return;
    if (lin_states[index].crt_lin_actor != LinActorT.MASTER) return;
    if (lin_states[index].crt_lin_status != LinStatusT.IDLE) {
        switch (lin_states[index].crt_lin_status) {
            LinStatusT.IN_SUBSCRIBE,
            LinStatusT.REC_CHECKSUM,
            => {
                // the subscribe task was not completed yet
                // it is a timout error
                if (lin_states[index].usr_handler_ptr.OnMasterSubFrameTimeout) |callback| {
                    callback(lin_states[index].crt_pid);
                }
                LIN_StateToIdle(index);
            },
            // In other status, should not break the process
            else => return,
        }
    }

    const pid_sent: u8 = LIN_GetPID(id);
    // set rec data
    lin_states[index].crt_pid = pid_sent;
    lin_states[index].tgt_checksum_t = checksum_type;
    lin_states[index].tgt_rx_index = @truncate(tgt_len - 1);
    lin_states[index].crt_rx_index = 0;
    LIN_MasterSendHeaderInBlock(index, pid_sent);
    lin_states[index].crt_lin_status = LinStatusT.IN_SUBSCRIBE;
    // Call the subs head sent out
    if (lin_states[index].usr_handler_ptr.OnMasterSubHeadSentEnd) |callback| {
        callback(id, pid_sent);
    }
}

/// This Function should not be used
/// - Cause it relays on rdrf interrupt to change the correct status
pub fn Lin_SlaveResponseFrame(index: u2, pid: u8, tx_data: *[8]u8, tx_len: u4, checksum_type: LinChecksumT) void {
    if (lin_states[index].is_linbus_inited == false) return;
    if (lin_states[index].crt_lin_actor != LinActorT.SlAVE) return;
    if (lin_states[index].crt_lin_status != LinStatusT.PID_RECEIVED) return;
    LIN_PublishFrameInBlock(index, pid, tx_data, tx_len, checksum_type);
    LIN_StateToIdle(index);
    if (lin_states[index].usr_handler_ptr.OnSlavePubFrameEnd) |callback| {
        callback(pid);
    }
}

/// This Function was tested and could be used in RDRF interrupt
/// - The RDRF interrupt will not trigger itself again if the nested interrrupts were closed
pub fn Lin_SlaveResponseBlockInRxInterrupt(index: u2, pid: u8, tx_data: *[8]u8, tx_len: u4, checksum_type: LinChecksumT) void {
    lin_states[index].crt_lin_status = LinStatusT.IN_PUBLISH;
    for (0..tx_len) |i| {
        LIN_PutCharWhenEmpty(index, tx_data[i]);
    }
    // send checksum
    const check_value: u8 = LIN_GetChecksum(checksum_type, pid, tx_data, tx_len);
    lin_states[index].crt_lin_status = LinStatusT.SEND_CHECKSUM;
    LIN_PutCharWhenEmpty(index, check_value);
    // check frame sent out
    while (STAT.reg_ins_arr[index].getFieldValue(STAT.TC) != 1) {}
    LIN_StateToIdle(index);
    if (lin_states[index].usr_handler_ptr.OnSlavePubFrameEnd) |callback| {
        callback(pid);
    }
}

/// Init the target lin by user config
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
    //GLOBAL.reg_ins_arr[index].updateFieldValue(GLOBAL.RST, 1);
    //GLOBAL.reg_ins_arr[index].updateFieldValue(GLOBAL.RST, 0);

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
        // edege
        FieldSet{ .field_def = BAUD.BOTHEDGE, .field_value = 0 },
    });

    _ = LIN_SetBaudrate(index, usr_cfg_ptr.tgt_baudrate);
    // disable parity
    //CTRL.reg_ins_arr[index].updateFieldValue(CTRL.PE, 0);
    // state define
    // set lsb bit0
    STAT.reg_ins_arr[index].updateFieldValue(STAT.MSBF, 0);
    STAT.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
        // 13bits break
        FieldSet{ .field_def = STAT.BRK13, .field_value = 1 },
        // detect lin break
        FieldSet{ .field_def = STAT.LBKDE, .field_value = 1 },
    });

    // close fifo
    FIFO.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = FIFO.TXFE, .field_value = 0 },
        FieldSet{ .field_def = FIFO.RXFE, .field_value = 0 },
    });
    // finally enable TE and RE
    CTRL.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
        // enable rx and tx
        FieldSet{ .field_def = CTRL.RE, .field_value = 1 },
        FieldSet{ .field_def = CTRL.TE, .field_value = 1 },
    });

    // set ctrl register
    CTRL.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = CTRL.M, .field_value = 0 },
        FieldSet{ .field_def = CTRL.PE, .field_value = 0 },
        // diable loop
        FieldSet{ .field_def = CTRL.LOOPS, .field_value = 0 },
        FieldSet{ .field_def = CTRL.RSRC, .field_value = 0 },
        // enable overrun interrupt
        FieldSet{ .field_def = CTRL.ORIE, .field_value = 0 },
        // enable frame error interrupt
        FieldSet{ .field_def = CTRL.FEIE, .field_value = 1 },
        FieldSet{ .field_def = CTRL.PEIE, .field_value = 0 },
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
    });

    NVIC_Mgr.NVIC_EnableInterrupt(lin_irq_types[index]);
    lin_states[index].is_linbus_inited = true;
    lin_states[index].crt_lin_status = LinStatusT.IDLE;
    return GenericSts.STATUS_SUCCESS;
}
//#endregion
// ----------------------------------------------------------------
