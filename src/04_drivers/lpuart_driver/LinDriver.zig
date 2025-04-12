//! The Lin driver based on lpuart
//! - reference: S32K144 SDK 4.03
//! - version: 0.1.0
//! - author: weng

const GenericSts = @import("s32k144_genericSys_mod").GenericSts;
const LpuartHw = @import("./LpuartHwAccess.zig");
const LpuartBitCntPerCharT = LpuartHw.LpuartBitCntPerChar;
const LpuartParityMode = LpuartHw.LpuartParityMode;
const LpuartStopCntT = LpuartHw.LpuartStopCnt;
const LpuartBreakLenT = LpuartHw.LpuartBreakCharLenType;
const LpuartInterruptT = LpuartHw.LpuartInterruptType;
const LpuartStsT = LpuartHw.LpuartStsType;
const LpuartDrv = @import("./LpuartDriver.zig");
// Interrupts
const NVIC_Mgr = @import("s32k144_genericSys_mod").NVIC_Mgr;
const IQRnT = NVIC_Mgr.IQRnType;
const IsrHandlerFunc = NVIC_Mgr.IsrHandlerFunc;
// ---------------------------------------------------------------------
//#region LIN Driver General Define
pub const LinOptType = enum(u1) {
    Master,
    Slave,
};
/// Callback function to get time interval in nanoseconds
pub const LinGetTimeInterval = fn (nanoseconds: *u32) u32;
pub const LinHandleCallBack = fn (index: u2, lin_state_ptr: *?LinInsState) void;

/// Defines types for an enumerating event related to an Identifier.
pub const LinEventType = enum(u4) {
    LIN_NO_EVENT = 0,
    /// Received a wakeup signal
    /// - 收到了唤醒的信号
    LIN_WAKEUP_SIGNAL = 1,
    /// Indicate that baudrate was adjusted to Master's baudrate
    /// - 代表已经调节到主节点的波特率
    LIN_BAUDRATE_ADJUSTED = 2,
    LIN_RECV_BREAK_FIELD_OK = 3,
    LIN_SYNC_OK = 4,
    LIN_SYNC_ERROR = 5,
    LIN_PID_OK = 6,
    LIN_PID_ERROR = 7,
    LIN_FRAME_ERROR = 8,
    LIN_READBACK_ERROR = 9,
    LIN_CHECKSUM_ERROR = 0xA,
    LIN_TX_COMPLETED = 0xB,
    LIN_RX_COMPLETED = 0xC,
    LIN_RX_OVERRUN = 0xD,
};

pub const LinNodeStateType = enum(u4) {
    LIN_NODE_STATE_UNINIT = 0,
    LIN_NODE_STATE_SLEEP_MODE,
    LIN_NODE_STATE_IDLE,
    LIN_NODE_STATE_SEND_BREAK_FIELD,
    LIN_NODE_STATE_RECV_SYNC,
    LIN_NODE_STATE_SEND_PID,
    LIN_NODE_STATE_RECV_PID,
    LIN_NODE_STATE_RECV_DATA,
    LIN_NODE_STATE_RECV_DATA_COMPLETED,
    LIN_NODE_STATE_SEND_DATA,
    LIN_NODE_STATE_SEND_DATA_COMPLETED,
};

pub const LinUsrConfig = struct {
    baudrate: u32 = 19200,
    node_actor: LinOptType = LinOptType.Master,
    enable_auto_baud: bool = false,
    LinGetTimeIntervalCallback: ?LinGetTimeInterval = null,
    /// List of PIDs use classic checksum
    classic_pid: *?[]u8 = null,
    /// Number of PIDs use classic checksum
    num_classic_pid: u8 = 255,
};

/// Runtime state of the LIN driver.
/// - Note that the caller provides memory for the driver state structures during
/// initialization because the driver does not statically allocate memory.
pub const LinInsState = struct {
    tx_buff: *?[]u8 = null,
    rx_buff: *?[]u8 = null,
    /// To count number of bytes already transmitted or received.
    byte_cnt: u8 = 0,
    tx_size: u8 = 0,
    rx_size: u8 = 0,
    checksum: u8 = 0,
    is_tx_busy: bool = false,
    is_rx_busy: bool = false,
    is_bus_busy: bool = false,
    is_tx_block: bool = false,
    is_rx_block: bool = false,
    /// Callback function to invoke after receiving a byte or transmitting a byte.
    lin_callback: ?LinHandleCallBack = null,
    crt_id: u8 = 0,
    crt_pid: u8 = 0,
    crt_event_type: LinEventType = LinEventType.LIN_NO_EVENT,
    crt_node_state: LinNodeStateType = LinNodeStateType.LIN_NODE_STATE_UNINIT,
    timeout_cnter: u32 = 0,
    timeout_flag: bool = false,
    /// Baudrate Evaluation Process Enable
    baudrate_eval_enable: bool = false,
    /// Falling Edge count of a sync byte
    falling_edge_cnt: u8 = 0,
    /// default to use soscdiv2
    /// - maybe 8Mhz
    src_clock_freq: u32 = 8_000_000,
    // osif tx/rx completed
    // not achieved now
};
//#endregion
// ---------------------------------------------------------------------
//#region LIN Interrupts Handle Part
const LinIntertuptHandle = struct {
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
    fn LIN0_RxTx_IRQHandler() callconv(.C) void {
        LIN_DRV_IRQHandler(0);
    }
    fn LIN1_RxTx_IRQHandler() callconv(.C) void {
        LIN_DRV_IRQHandler(1);
    }
    fn LIN2_RxTx_IRQHandler() callconv(.C) void {
        LIN_DRV_IRQHandler(2);
    }

    /// Function Name : LIN_LPUART_DRV_IRQHandler
    /// Description   : Interrupt handler for LPUART.
    /// This handler uses the buffers stored in the lin_state_t struct to transfer
    /// data. This is not a public API as it is called by IRQ whenever an interrupt occurs.
    fn LIN_DRV_IRQHandler(index: u2) void {
        if (index > 2) return;
        const temp_value: u8 = 0;
        // Check RX Input Active Edge interrupt enabled
        const active_edge_int_enabled = LpuartHw.LPUART_HW_GetInterruptModeIsEnabled(
            index,
            LpuartInterruptT.LPUART_INT_RX_ACTIVE_EDGE,
        );
        // check if lin breack character is detected
        if (LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsT.LPUART_LIN_BREAK_DETECT)) {
            LinDrvIns.LIN_LPUART_DRV_ProcessBreakDetect(index);
        } else {
            // If LPUART_RX Pin Active Edge has been detected
            if (LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsT.LPUART_RX_ACTIVE_EDGE_DETECT) and
                active_edge_int_enabled)
            {
                // clear rx edge detect interrupts
                LpuartHw.LPUART_HW_ClearStatusFlag(index, LpuartStsT.LPUART_RX_ACTIVE_EDGE_DETECT);
                // check if a wakeup signal has been received
                LinDrvIns.LIN_LPUART_DRV_CheckWakeupSignal(index);
            } else {
                // if a frame error was detected
                if (LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsT.LPUART_FRAME_ERR)) {
                    // clear frame error
                    LpuartHw.LPUART_HW_ClearStatusFlag(index, LpuartStsT.LPUART_FRAME_ERR);
                    // Read dummy to clear LPUART_RX_DATA_REG_FULL flag
                    LpuartHw.LPUART_HW_Getchar(index, &temp_value);
                    // set current node state
                    LinDrvIns.lin_ins_states[index].crt_event_type = LinEventType.LIN_FRAME_ERROR;
                    // check if is in sending data or receving data
                    // info user to handle the frame error
                    if (LinDrvIns.lin_ins_states[index].crt_node_state == LinNodeStateType.LIN_NODE_STATE_SEND_DATA or
                        LinDrvIns.lin_ins_states[index].crt_node_state == LinNodeStateType.LIN_NODE_STATE_RECV_DATA)
                    {
                        if (LinDrvIns.lin_ins_states[index].lin_callback != null) {
                            LinDrvIns.lin_ins_states[index].lin_callback(index, &LinDrvIns.lin_ins_states[index]);
                        }
                    }
                    // go to idle
                    LinDrvIns.LIN_LPUART_DRV_GotoIdleState(index);
                } else {
                    // no frame error
                    // if the lpuart receive reg is full
                    if (LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsT.LPUART_RX_DATA_REG_FULL)) {
                        LpuartHw.LPUART_HW_Getchar(index, &temp_value);
                        // process the frame data get
                    }
                }
            }
        }

        // get rx overrun flag
        if (LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsT.LPUART_RX_OVERRUN)) {
            // clear overrun flag
            LpuartHw.LPUART_HW_ClearStatusFlag(index, LpuartStsT.LPUART_RX_OVERRUN);
            LinDrvIns.lin_ins_states[index].crt_event_type = LinEventType.LIN_RX_OVERRUN;
            if (LinDrvIns.lin_ins_states[index].lin_callback != null) {
                LinDrvIns.lin_ins_states[index].lin_callback(index, &LinDrvIns.lin_ins_states[index]);
            }
        }
    }
};
//#endregion
// ---------------------------------------------------------------------
//#region LinDvIns Part

pub const LinDrvIns = struct {
    const previous_2bitTime_len: [3]u32 = .{ 0, 0, 0 };
    const wakeup_signals: [3]u8 = .{ 0, 0, 0 };
    const count_measure: [3]u8 = .{ 0, 0, 0 };
    const time_measure: [3]u8 = .{ 0, 0, 0 };
    /// The lin instance state
    const lin_ins_states: [3]LinInsState = .{
        LinInsState{},
        LinInsState{},
        LinInsState{},
    };
    const usr_cfg_ptrs: [3]*LinUsrConfig = .{
        &LinUsrConfig{},
        &LinUsrConfig{},
        &LinUsrConfig{},
    };

    /// Function Name : LIN_LPUART_DRV_Init
    /// - Description   : This function initializes a LPUART instance for operation.
    /// This function will initialize the run-time state structure to keep track of
    /// the on-going transfers, initialize the module to user defined settings and
    /// default settings, set break field length to be 13 bit times minimum, enable
    /// the break detect interrupt, Rx complete interrupt, frame error detect interrupt,
    /// and enable the LPUART module transmitter and receiver.
    pub fn LIN_LPUART_DRV_Init(index: u2, usr_config_ptr: *?LinUsrConfig, clock_freq: u32) GenericSts {
        if (index > 2 or clock_freq == 0) return GenericSts.STATUS_ERROR;
        if (usr_config_ptr == null) return GenericSts.STATUS_ERROR;
        if (lin_ins_states[index].crt_node_state != LinNodeStateType.LIN_NODE_STATE_UNINIT) {
            // this lin instance has been inited
            return GenericSts.STATUS_REINIT;
        }
        lin_ins_states[index].src_clock_freq = clock_freq;
        // init the lpuart hardware
        LpuartHw.LPUART_HW_Init(index);
        // os if logic in sdk
        const real_usrconfig_ptr: *LinUsrConfig = undefined;
        for (usr_config_ptr.*) |not_null_value| {
            real_usrconfig_ptr = &not_null_value;
        }
        // save the lin user config ptrs
        usr_cfg_ptrs[index] = real_usrconfig_ptr;
        // in slave mode and auto baudrate
        if (real_usrconfig_ptr.enable_auto_baud and
            real_usrconfig_ptr.node_actor == LinOptType.Slave)
        {
            real_usrconfig_ptr.baudrate = 19200;
            lin_ins_states[index].falling_edge_cnt = 0;
            lin_ins_states[index].baudrate_eval_enable = true;
            previous_2bitTime_len[index] = 0;
            count_measure[index] = 0;
            time_measure[index] = 0;
        }
        // access lpuart driver layer to set baudrate
        LpuartDrv.LPUART_DRV_SetBaudRate(index, real_usrconfig_ptr.baudrate);
        // set 8 bit for lin
        LpuartHw.LPUART_HW_SetBitCountPerChar(
            index,
            LpuartBitCntPerCharT.BITS8,
            false,
        );
        // disable parity in lin
        LpuartHw.LPUART_HW_SetParityMode(index, LpuartParityMode.DISABLED);
        // set stop bit to one
        LpuartHw.LPUART_HW_SetStopBitCount(index, LpuartStopCntT.ONE_STOP_BIT);
        // check if is in lin master opt
        if (real_usrconfig_ptr.node_actor == LinOptType.Master) {
            LpuartHw.LPUART_HW_SetBreakCharTransmitLength(
                index,
                LpuartBreakLenT.LPUART_BREAK_CHAR_13_BIT_MINIMUM,
            );
        }
        // set break char detect as 13bit
        LpuartHw.LPUART_HW_SetBreakCharDetectLength(
            index,
            LpuartBreakLenT.LPUART_BREAK_CHAR_13_BIT_MINIMUM,
        );

        // enable rx complete interrupt
        LpuartHw.LPUART_HW_SetInterruptMode(
            index,
            1,
            LpuartInterruptT.LPUART_INT_RX_DATA_REG_FULL,
        );
        // enable frame error interrupt
        LpuartHw.LPUART_HW_SetInterruptMode(
            index,
            1,
            LpuartInterruptT.LPUART_INT_FRAME_ERR_FLAG,
        );
        // Enable LIN break detect interrupt
        LpuartHw.LPUART_HW_SetInterruptMode(
            index,
            1,
            LpuartInterruptT.LPUART_INT_LIN_BREAK_DETECT,
        );
        // install lin rx and tx interrupts handler
        NVIC_Mgr.Install_IsrHandler(
            LinIntertuptHandle.lin_irq_types[index],
            LinIntertuptHandle.lin_irq_handlers[index],
        );
        // enable the interrupts for lin
        NVIC_Mgr.NVIC_EnableInterrupt(LinIntertuptHandle.lin_irq_types[index]);
        // turn current to idle
        lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_IDLE;
        // clear state flags in current lin state
        lin_ins_states[index].is_tx_busy = false;
        lin_ins_states[index].is_rx_busy = false;
        lin_ins_states[index].is_bus_busy = false;
        lin_ins_states[index].is_tx_block = false;
        lin_ins_states[index].is_rx_block = false;
        lin_ins_states[index].timeout_cnter = 0;
        lin_ins_states[index].timeout_flag = false;
        // Assign wakeup signal to satisfy LIN Specifications specifies that
        // wakeup signal shall be in range from 250us to 5 ms.
        if (real_usrconfig_ptr.baudrate > 10000) {
            // Wakeup signal will be range from 400us to 800us depend on baudrate
            wakeup_signals[index] = 0x80;
        } else {
            // Wakeup signal will be range from 400us to 4ms depend on baudrate
            wakeup_signals[index] = 0xF8;
        }
        // Not in autobaudrate and not in slave mode
        if (!(real_usrconfig_ptr.enable_auto_baud and
            real_usrconfig_ptr.node_actor == LinOptType.Slave))
        {
            // Enable Lpuart transmit and receive
            LpuartHw.LPUART_HW_SetTransmitterCmd(index, 1);
            LpuartHw.LPUART_HW_SetReceiverCmd(index, 1);
        }

        return GenericSts.STATUS_SUCCESS;
    }

    /// Function Name : LIN_LPUART_DRV_Deinit
    /// - Description   : This function shuts down the LPUART by disabling interrupts and transmitter/receiver.
    pub fn LIN_LPUART_DRV_Deinit(index: u2) GenericSts {
        if (index > 2) return GenericSts.STATUS_ERROR;
        // Wait until the data is completely shifted out of shift register
        while (!LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsT.LPUART_TX_COMPLETE)) {}
        // disable tx and rx cmd
        LpuartHw.LPUART_HW_SetTransmitterCmd(index, 0);
        LpuartHw.LPUART_HW_SetReceiverCmd(index, 0);

        // disable the interrupts
        NVIC_Mgr.NVIC_DisableInterrupt(LinIntertuptHandle.lin_irq_types[index]);
        // disable error handle interrupts
        // coding here...
        // turn state to uninit
        lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_UNINIT;
        // clear the state to null
        // in nxp sdk this will be set to null
        // but in this driver , the state is recommended not set to null
    }

    /// Function Name : LIN_LPUART_DRV_InstallCallback
    /// - Description   : This function installs the callback function that is used for LIN_LPUART_DRV_IRQHandler.
    /// Pass in Null pointer as callback will uninstall.
    pub fn LIN_LPUART_DRV_InstallCallback(index: u2, new_lin_callback: ?LinHandleCallBack) GenericSts {
        if (index > 2 or new_lin_callback == null) return GenericSts.STATUS_ERROR;
        lin_ins_states[index].lin_callback = new_lin_callback;
    }

    /// The function is used to get default lin user config
    pub fn LIN_LPUART_DRV_GetDefaultConfig(tgt_actor: LinOptType, out_cfg_ptr: *LinUsrConfig) void {
        out_cfg_ptr.baudrate = 19200;
        out_cfg_ptr.enable_auto_baud = false;
        out_cfg_ptr.LinGetTimeIntervalCallback = null;
        out_cfg_ptr.node_actor = tgt_actor;
    }

    /// Function Name : LIN_DRV_MakeChecksumByte
    /// Description   : Makes the checksum byte for a frame. For PID of identifiers,
    /// if PID is 0x3C (ID 0x3C) or 0x7D (ID 0x3D) or 0xFE (ID 0x3E) or 0xBF (ID 0x3F)
    /// apply classic checksum and apply enhanced checksum for other PID.
    /// In case user want to calculate classic checksum please set PID to zero.
    fn LIN_DRV_MakeChecksumByte(buffer: *[]u8, buff_size: u8, pid: u8) u8 {
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

        for (buff_size..0) |_| {
            checksum += buffer[0];
            buffer += 1;
            if (checksum > 0xFF) {
                checksum -= 0xFF;
            }
        }
        const ret_value = @as(u8, @intCast(~checksum));
        return ret_value;
    }

    /// Function Name : LIN_LPUART_DRV_MakeChecksumByte
    /// Description   : This function calculate checksum for a frame. This function
    /// will return classic or enhanced checksum base on data in usr config
    pub fn LIN_LPUART_DRV_MakeChecksumByte(index: u2, buffer: *[]u8, buff_size: u8, pid: u8) u8 {
        const classic_pid = usr_cfg_ptrs[index].classic_pid;
        const classic_pid_num = usr_cfg_ptrs[index].num_classic_pid;
        var checksum: u8 = pid;
        var ret_value: u8 = 0;
        if (classic_pid_num == 255) {
            // all frame use enhanced checksum
            checksum = 0;
        } else {
            if (classic_pid != null) {
                for (0..classic_pid_num) |i| {
                    ret_value = i;
                    if (checksum == classic_pid[ret_value]) {
                        checksum = 0;
                        break;
                    }
                }
            }
        }
        ret_value = LIN_DRV_MakeChecksumByte(buffer, buff_size, pid);
        return ret_value;
    }

    /// Function Name : LIN_LPUART_DRV_SendFrameData
    /// - Description   : This function sends data out through the LPUART module using
    /// non-blocking method.
    /// - This function will calculate the checksum byte and send
    /// it with the frame data. The function will return immediately after calling
    /// this function.
    /// - If txSize is equal to 0 or greater than 8  or node's current
    /// state is in SLEEP mode then the function will return STATUS_ERROR. If
    /// isBusBusy is currently true then the function will return STATUS_BUSY.
    pub fn LIN_LPUART_DRV_SendFrameData(index: u2, tx_buff: *[]u8, tx_size: u8) GenericSts {
        if (index > 2) return GenericSts.STATUS_ERROR;
        var ret_sts: GenericSts = GenericSts.STATUS_SUCCESS;
        const is_in_sleep = lin_ins_states[index].crt_node_state == LinNodeStateType.LIN_NODE_STATE_SLEEP_MODE;
        // check tx size and is in sleep mode
        if (tx_size > 8 or tx_size == 0 or is_in_sleep) {
            ret_sts = GenericSts.STATUS_ERROR;
        } else {
            if (lin_ins_states[index].is_tx_busy) return GenericSts.STATUS_BUSY;
            // send data
            // 1 calculate the checksum
            lin_ins_states[index].checksum = LIN_LPUART_DRV_MakeChecksumByte(
                index,
                tx_buff,
                tx_size,
                lin_ins_states[index].crt_pid,
            );
            // 2 update current lin state
            lin_ins_states[index].tx_buff = tx_buff;
            // 3 add the length for tx size,cause the data frame will append a checksum after the datas
            lin_ins_states[index].tx_size = tx_size + 1;
            lin_ins_states[index].byte_cnt = 0;
            lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_SEND_DATA;
            lin_ins_states[index].crt_event_type = LinEventType.LIN_NO_EVENT;
            lin_ins_states[index].is_tx_busy = true;
            lin_ins_states[index].is_bus_busy = true;

            // 4 Set Break char detect length as 10 bits minimum
            LpuartHw.LPUART_HW_SetBreakCharDetectLength(index, LpuartBreakLenT.LPUART_BREAK_CHAR_10_BIT_MINIMUM);
            // 5 Start Send Data
            // !! Issue?
            LpuartHw.LPUART_HW_Putchar(
                index,
                tx_buff[0],
            );
        }

        return ret_sts;
    }

    /// Function Name : LPUART_DRV_AbortTransferData
    /// - Description   : Aborts an on-going non-blocking transmission/reception.
    /// While performing a non-blocking transferring data, users can call this
    /// function to terminate immediately the transferring.
    pub fn LIN_LPUART_DRV_AbortTransferData(index: u2) GenericSts {
        if (index > 2) return GenericSts.STATUS_ERROR;
        LIN_LPUART_DRV_GotoIdleState(index);
        lin_ins_states[index].is_tx_busy = false;
        lin_ins_states[index].is_rx_busy = false;
        return GenericSts.STATUS_SUCCESS;
    }

    /// Function Name : LIN_LPUART_DRV_GetTransmitStatus
    /// - Description   : This function returns whether the previous LPUART transmit has
    /// finished. When performing non-blocking transmit, the user can call this
    /// function to ascertain the state of the current transmission:
    pub fn LIN_LPUART_DRV_GetTransmitStatus(index: u2, bytes_remain: *u8) GenericSts {
        if (index > 2) return GenericSts.STATUS_ERROR;
        bytes_remain.* = lin_ins_states[index].tx_size - lin_ins_states[index].byte_cnt;
        if (lin_ins_states[index].crt_event_type == LinEventType.LIN_NO_EVENT and
            bytes_remain.* != 0)
        {
            if (lin_ins_states[index].timeout_flag == false) return GenericSts.STATUS_BUSY;
            return GenericSts.STATUS_TIMEOUT;
        }
        return GenericSts.STATUS_SUCCESS;
    }

    /// Function Name : LIN_LPUART_DRV_RecvFrmData
    /// - Description   : This function receives data from LPUART module using
    /// non-blocking method. This function returns immediately after initiating the
    /// receive function.
    pub fn LIN_LPUART_DRV_RecvFrameData(index: u2, tgt_rx_buff: *[]u8, tgt_rx_size: u8) GenericSts {
        if (index > 2) return GenericSts.STATUS_ERROR;
        const is_slept: bool = (lin_ins_states[index].crt_node_state == LinNodeStateType.LIN_NODE_STATE_SLEEP_MODE);
        if (tgt_rx_size > 8 or is_slept or tgt_rx_size == 0) return GenericSts.STATUS_ERROR;
        if (lin_ins_states[index].is_bus_busy) return GenericSts.STATUS_BUSY;
        // update the state rx information
        lin_ins_states[index].rx_buff = tgt_rx_buff;
        lin_ins_states[index].rx_size = tgt_rx_size + 1;
        lin_ins_states[index].byte_cnt = 0;
        // start receving data
        lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_RECV_DATA;
        lin_ins_states[index].crt_event_type = LinEventType.LIN_NO_EVENT;
        lin_ins_states[index].is_bus_busy = true;
        lin_ins_states[index].is_rx_busy = true;
        lin_ins_states[index].is_rx_block = false;
        LpuartHw.LPUART_HW_SetBreakCharDetectLength(index, LpuartBreakLenT.LPUART_BREAK_CHAR_10_BIT_MINIMUM);
        return GenericSts.STATUS_SUCCESS;
    }

    /// Function Name : LIN_LPUART_DRV_GetReceiveStatus
    /// - Description   : This function returns whether the previous LPUART reception is complete.
    pub fn LIN_LPUART_DRV_GetReceiveStatus(index: u2, bytes_remain: *u8) GenericSts {
        if (index > 2) return GenericSts.STATUS_ERROR;
        bytes_remain.* = lin_ins_states[index].rx_size - lin_ins_states[index].byte_cnt;
        if (bytes_remain.* != 0 and lin_ins_states[index].crt_event_type == LinEventType.LIN_NO_EVENT) {
            if (lin_ins_states[index].timeout_flag) return GenericSts.STATUS_TIMEOUT;
            return GenericSts.STATUS_BUSY;
        }
        return GenericSts.STATUS_SUCCESS;
    }

    /// Function Name : LIN_LPUART_DRV_SendWakeupSignal
    /// Description   : This function sends a wakeup signal through the LPUART interface.
    pub fn LIN_LPUART_DRV_SendWakeupSignal(index: u2) GenericSts {
        if (index > 2) return GenericSts.STATUS_ERROR;
        if (lin_ins_states[index].is_tx_busy == false) return GenericSts.STATUS_BUSY;
        LpuartHw.LPUART_HW_Putchar(index, wakeup_signals[index]);
        return GenericSts.STATUS_SUCCESS;
    }

    /// Function Name : LIN_LPUART_DRV_MasterSendHeader
    /// - Description   : This function sends frame header out through the LPUART module
    /// using a non-blocking method. Non-blocking  means that the function returns immediately.
    pub fn LIN_LPUART_DRV_MasterSendHeader(index: u2, send_id: u8) GenericSts {
        if (index > 2) return GenericSts.STATUS_ERROR;
        const is_slept: bool = lin_ins_states[index].crt_node_state == LinNodeStateType.LIN_NODE_STATE_SLEEP_MODE;
        // if is in slave node
        // if the tgt send id > 0x3F
        // if the lin bus is in sleep mode now
        if (usr_cfg_ptrs[index].node_actor == LinOptType.Slave or
            is_slept or
            send_id > 0x3F)
        {
            return GenericSts.STATUS_ERROR;
        }
        if (lin_ins_states[index].is_bus_busy) return GenericSts.STATUS_BUSY;
        lin_ins_states[index].crt_id = send_id;
        // calculate the pid from tgt sending id
        lin_ins_states[index].crt_pid = LIN_DRV_ProcessParity(send_id, 0);
        // set current node state is to send break field
        lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_SEND_BREAK_FIELD;
        lin_ins_states[index].crt_event_type = LinEventType.LIN_NO_EVENT;
        lin_ins_states[index].is_bus_busy = true;
        // Set Break char detect length as 13 bits minimum
        LpuartHw.LPUART_HW_SetBreakCharDetectLength(index, LpuartBreakLenT.LPUART_BREAK_CHAR_13_BIT_MINIMUM);
        LpuartHw.LPUART_HW_SetInterruptMode(index, 1, LpuartInterruptT.LPUART_INT_LIN_BREAK_DETECT);
        // Send break char by using queue mode
        LpuartHw.LPUART_HW_QueueBreakField(index);
        return GenericSts.STATUS_SUCCESS;
    }

    /// Function Name : LIN_LPUART_DRV_GoToSleepMode
    /// - Description   : This function puts current LIN node to sleep mode.
    /// This function changes current node state to LIN_NODE_STATE_SLEEP_MODE.
    pub fn LIN_LPUART_DRV_GoToSleepMode(index: u2) GenericSts {
        if (index > 2) return GenericSts.STATUS_ERROR;
        lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_SLEEP_MODE;
        // remove all busy status
        lin_ins_states[index].is_bus_busy = false;
        lin_ins_states[index].is_tx_busy = false;
        lin_ins_states[index].is_rx_busy = false;
        LpuartHw.LPUART_HW_ClearStatusFlag(index, LpuartStsT.LPUART_RX_ACTIVE_EDGE_DETECT);
        LpuartHw.LPUART_HW_SetRxDataPolarity(index, 0);
        // Disable RX complete interrupt
        LpuartHw.LPUART_HW_SetInterruptMode(index, 0, LpuartInterruptT.LPUART_INT_RX_DATA_REG_FULL);
        // Enable RX Input Active Edge interrupt
        LpuartHw.LPUART_HW_SetInterruptMode(index, 1, LpuartInterruptT.LPUART_INT_RX_ACTIVE_EDGE);
        // Disable frame error interrupt
        LpuartHw.LPUART_HW_SetInterruptMode(index, 0, LpuartInterruptT.LPUART_INT_FRAME_ERR_FLAG);
        // Disable LIN break detect interrupt
        LpuartHw.LPUART_HW_SetInterruptMode(index, 0, LpuartInterruptT.LPUART_INT_LIN_BREAK_DETECT);
        return GenericSts.STATUS_SUCCESS;
    }

    /// Function Name : LIN_LPUART_DRV_ProcessBreakDetect
    /// Description   : This function process break detect for LIN communication.
    fn LIN_LPUART_DRV_ProcessBreakDetect(index: u2) void {
        if (index > 2) return;
        // 1 Clear LIN Break Detect Interrupt Flag
        // 清除同步段的标识
        LpuartHw.LPUART_HW_ClearStatusFlag(
            index,
            LpuartStsT.LPUART_LIN_BREAK_DETECT,
        );
        // 2 Set Break char detect length as 10 bits minimum
        // 设置同步段为最小10位
        LpuartHw.LPUART_HW_SetBreakCharDetectLength(index, LpuartBreakLenT.LPUART_BREAK_CHAR_10_BIT_MINIMUM);
        // 3 Disable LIN Break Detect Interrupt
        // 关闭同步段触发的中断
        LpuartHw.LPUART_HW_SetInterruptMode(
            index,
            0,
            LpuartInterruptT.LPUART_INT_LIN_BREAK_DETECT,
        );
        // 4 check current node is working as master
        // Master Node should send the break field and sync field in frame header
        if (usr_cfg_ptrs[index].node_actor == LinOptType.Master) {
            // Check if LIN current node state is LIN_NODE_STATE_SEND_BREAK_FIELD
            if (lin_ins_states[index].crt_node_state == LinNodeStateType.LIN_NODE_STATE_SEND_BREAK_FIELD) {
                lin_ins_states[index].is_bus_busy = true;
                // Change the node's current state to SENDING PID to send PID after send SYNC
                lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_SEND_PID;
                // send sync field 0x55
                // 0101 0101 to sync the bus signal
                LpuartHw.LPUART_HW_Putchar(index, 0x55);
            }
        }
        // 5 if current node is working as slave
        if (usr_cfg_ptrs[index].node_actor == LinOptType.Slave) {
            lin_ins_states[index].is_bus_busy = true;
            lin_ins_states[index].crt_event_type = LinEventType.LIN_RECV_BREAK_FIELD_OK;
            // callback the user's function to handle this event
            if (lin_ins_states[index].lin_callback != null) {
                lin_ins_states[index].lin_callback(
                    index,
                    &lin_ins_states[index],
                );
            }
            // turn the state to receive sync field
            lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_RECV_SYNC;
        }
    }

    /// Function Name : LIN_LPUART_DRV_CheckWakeupSignal
    /// Description   : This function check if a dominant signal received is a wakeup signal.
    fn LIN_LPUART_DRV_CheckWakeupSignal(index: u2) void {
        if (index > 2) return;
        const wakeup_sig_time_len: u32 = 0;
        if (LpuartHw.LPUART_HW_GetRxDataPolarity(index) == false) {
            if (usr_cfg_ptrs[index].LinGetTimeIntervalCallback != null) {
                usr_cfg_ptrs[index].LinGetTimeIntervalCallback(&wakeup_sig_time_len);
            }
            LpuartHw.LPUART_HW_SetRxDataPolarity(index, 1);
        } else {
            LpuartHw.LPUART_HW_SetRxDataPolarity(index, 0);
            if (usr_cfg_ptrs[index].LinGetTimeIntervalCallback != null) {
                usr_cfg_ptrs[index].LinGetTimeIntervalCallback(&wakeup_sig_time_len);
            }
            // check if length of the dominant signal is longer than 150us(150_000 ns), it is a wakeup signal
            if (wakeup_sig_time_len > 150_000) {
                lin_ins_states[index].crt_event_type = LinEventType.LIN_WAKEUP_SIGNAL;
                // usr callback to handle wakeup event
                if (lin_ins_states[index].lin_callback != null) {
                    lin_ins_states[index].lin_callback(
                        index,
                        &lin_ins_states[index],
                    );
                }
                // set current lin ins to idle status
                LIN_LPUART_DRV_GotoIdleState(index);
            }
        }
    }

    /// Function Name : LIN_LPUART_DRV_GotoIdleState
    /// - Description   : This function puts current node to Idle state.
    pub fn LIN_LPUART_DRV_GotoIdleState(index: u2) GenericSts {
        if (index > 2) return GenericSts.STATUS_ERROR;
        lin_ins_states[index].crt_event_type = LinEventType.LIN_NO_EVENT;
        // set breack fields detect to 13bit
        LpuartHw.LPUART_HW_SetBreakCharDetectLength(
            index,
            LpuartBreakLenT.LPUART_BREAK_CHAR_13_BIT_MINIMUM,
        );
        LpuartHw.LPUART_HW_SetRxDataPolarity(index, 0);
        // enable rx complete interrupts
        LpuartHw.LPUART_HW_SetInterruptMode(
            index,
            1,
            LpuartInterruptT.LPUART_INT_RX_DATA_REG_FULL,
        );
        LpuartHw.LPUART_HW_SetInterruptMode(
            index,
            0,
            LpuartInterruptT.LPUART_INT_RX_ACTIVE_EDGE,
        );
        // enable frame error interrupts
        LpuartHw.LPUART_HW_SetInterruptMode(
            index,
            1,
            LpuartInterruptT.LPUART_INT_FRAME_ERR_FLAG,
        );
        // enable break interrupts
        LpuartHw.LPUART_HW_SetInterruptMode(
            index,
            1,
            LpuartInterruptT.LPUART_INT_LIN_BREAK_DETECT,
        );
        lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_IDLE;
        lin_ins_states[index].is_bus_busy = false;
        return GenericSts.STATUS_SUCCESS;
    }

    /// Function Name : LIN_LPUART_DRV_ProcessFrame
    /// - Description   : Part of Interrupt handler for receiving and sending data.
    /// Receive Header, Data and Send Data.
    pub fn LIN_LPUART_DRV_ProcessFrame(index: u2, temp_value: u8) void {
        if (index > 2) return;
        // check current node state
        switch (lin_ins_states[index].crt_node_state) {
            LinNodeStateType.LIN_NODE_STATE_RECV_SYNC,
            LinNodeStateType.LIN_NODE_STATE_SEND_PID,
            LinNodeStateType.LIN_NODE_STATE_RECV_PID,
            => {
                // handle the header
                LIN_LPUART_DRV_ProcessFrameHeader(index, temp_value);
            },
            LinNodeStateType.LIN_NODE_STATE_RECV_DATA => {
                LIN_LPUART_DRV_ProcessReceiveFrameData(index, temp_value);
            },
            LinNodeStateType.LIN_NODE_STATE_SEND_DATA => {
                LIN_LPUART_DRV_ProcessSendFrameData(index, temp_value);
            },
            else => return,
        }
    }

    /// Function Name : LIN_LPUART_DRV_ProcessFrameHeader
    /// - Description   : Part of Interrupt handler for receiving and sending data.
    /// Receive Sync byte, PID and Send PID.
    fn LIN_LPUART_DRV_ProcessFrameHeader(index: u2, temp_value: u8) void {
        switch (lin_ins_states[index].crt_node_state) {
            LinNodeStateType.LIN_NODE_STATE_RECV_SYNC => {
                if (temp_value == 0x55) {
                    lin_ins_states[index].crt_event_type = LinEventType.LIN_SYNC_OK;
                    lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_RECV_PID;
                } else {
                    lin_ins_states[index].crt_event_type = LinEventType.LIN_SYNC_ERROR;
                    if (lin_ins_states[index].lin_callback != null) {
                        lin_ins_states[index].lin_callback(index, &lin_ins_states[index]);
                    }
                    // go to idle
                    LIN_LPUART_DRV_GotoIdleState(index);
                }
            },
            LinNodeStateType.LIN_NODE_STATE_SEND_PID => {
                // check the sync field was sent correctly
                if (temp_value == 0x55) {
                    // change the state to recv pid
                    lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_RECV_PID;
                    LpuartHw.LPUART_HW_Putchar(index, lin_ins_states[index].crt_pid);
                } else {
                    // In case of errors during header transmission, it is up to the implementer
                    // how to handle these errors (stop/continue transmission) and to decide if the
                    // corresponding response is valid or not.
                    // By default, LIN Driver set isBusBusy to false, and change node's state to IDLE.
                    lin_ins_states[index].crt_event_type = LinEventType.LIN_SYNC_ERROR;
                    lin_ins_states[index].is_bus_busy = false;
                    lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_IDLE;
                    // Callback function to handle event SENT SYNC BYTE ERROR
                    if (lin_ins_states[index].lin_callback != null) {
                        lin_ins_states[index].lin_callback(index, &lin_ins_states[index]);
                    }
                }
            },
            LinNodeStateType.LIN_NODE_STATE_RECV_PID => {
                // if node is working as master
                if (usr_cfg_ptrs[index].node_actor == LinOptType.Master) {
                    // check temp_value is pid
                    if (temp_value == lin_ins_states[index].crt_pid) {
                        lin_ins_states[index].crt_event_type = LinEventType.LIN_PID_OK;
                        // check whether is blocking receive data
                        if (lin_ins_states[index].is_rx_block) {
                            lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_RECV_DATA;
                            lin_ins_states[index].is_bus_busy = true;
                            lin_ins_states[index].is_rx_busy = true;
                            LpuartHw.LPUART_HW_SetBreakCharDetectLength(
                                index,
                                LpuartBreakLenT.LPUART_BREAK_CHAR_10_BIT_MINIMUM,
                            );
                        } else {
                            lin_ins_states[index].is_bus_busy = false;
                            // call back to handle correct pid
                            if (lin_ins_states[index].lin_callback != null) {
                                lin_ins_states[index].lin_callback(index, &lin_ins_states[index]);
                            }
                        }
                    } else {
                        lin_ins_states[index].crt_event_type = LinEventType.LIN_PID_ERROR;
                        lin_ins_states[index].is_bus_busy = false;
                        lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_IDLE;
                        if (lin_ins_states[index].lin_callback != null) {
                            lin_ins_states[index].lin_callback(index, &lin_ins_states[index]);
                        }
                    }
                }
                // if node is working as slave
                if (usr_cfg_ptrs[index].node_actor == LinOptType.Slave) {
                    lin_ins_states[index].crt_id = LIN_DRV_ProcessParity(temp_value, 1);
                    lin_ins_states[index].crt_pid = temp_value;
                    if (lin_ins_states[index].crt_id != 0xFF) {
                        lin_ins_states[index].crt_event_type = LinEventType.LIN_PID_OK;
                        // check whether is blocking receive data
                        if (lin_ins_states[index].is_rx_block) {
                            lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_RECV_DATA;
                            lin_ins_states[index].is_bus_busy = true;
                            lin_ins_states[index].is_rx_busy = true;
                            LpuartHw.LPUART_HW_SetBreakCharDetectLength(
                                index,
                                LpuartBreakLenT.LPUART_BREAK_CHAR_10_BIT_MINIMUM,
                            );
                        } else {
                            lin_ins_states[index].is_bus_busy = false;
                            // call back to handle correct pid
                            if (lin_ins_states[index].lin_callback != null) {
                                lin_ins_states[index].lin_callback(index, &lin_ins_states[index]);
                            }
                        }
                    } else {
                        // get the wrong id from pid
                        lin_ins_states[index].crt_event_type = LinEventType.LIN_PID_ERROR;
                        if (lin_ins_states[index].lin_callback != null) {
                            lin_ins_states[index].lin_callback(index, &lin_ins_states[index]);
                        }
                        // go to idle
                        LIN_LPUART_DRV_GotoIdleState(index);
                    }
                }
            },
            else => return,
        }
    }

    /// Get tgt bit in a value
    fn GetBit(value: u8, bit: u3) u8 {
        return (value >> bit) & 0x01;
    }

    /// Function Name : LIN_DRV_ProcessParity
    /// - Description   : Makes or checks parity bits.
    /// - If action is checking parity, the function returns **ID value** if parity bits are correct
    /// - or **0xFF** if parity bits are incorrect.
    /// ***
    /// - If action is making parity bits, then from input value of ID, the function returns PID.
    pub fn LIN_DRV_ProcessParity(pid: u8, is_check_parity: u1) u8 {
        var parity_value: u8 = 0;
        var ret_value: u8 = 0;
        const temp_v1: u8 = (0xFF & GetBit(pid, 0) ^ GetBit(pid, 1) ^ GetBit(pid, 2) ^ GetBit(pid, 4)) << 6;
        const temp_v2: u8 = (0xFF & GetBit(pid, 1) ^ GetBit(pid, 3) ^ GetBit(pid, 4) ^ GetBit(pid, 5)) << 7;
        parity_value = temp_v1 | temp_v2;
        if (is_check_parity == 1) {
            if ((pid & 0xC0) != parity_value) {
                ret_value = 0xFF;
            } else {
                ret_value = parity_value & 0x3F;
            }
        } else {
            ret_value = pid | parity_value;
        }
        return ret_value;
    }

    /// Function Name : LIN_LPUART_DRV_ProcessReceiveFrameData
    /// - Description   : Part of Interrupt handler for receiving.
    pub fn LIN_LPUART_DRV_ProcessReceiveFrameData(index: u2, temp_value: u8) void {
        if (lin_ins_states[index].rx_size > (lin_ins_states[index].byte_cnt + 1)) {
            lin_ins_states[index].rx_buff[0] = temp_value;
            lin_ins_states[index].rx_buff += 1;
        } else {
            if ((lin_ins_states[index].rx_size - lin_ins_states[index].byte_cnt) == 1) {
                lin_ins_states[index].checksum = temp_value;
            }
        }

        // change the current state byte_count
        lin_ins_states[index].byte_cnt += 1;
        if (lin_ins_states[index].rx_size == lin_ins_states[index].byte_cnt) {
            // restore rx buffer pointer
            lin_ins_states[index].rx_buff -= (lin_ins_states[index].rx_size - 1);
            // calculate the checksum of received data
            const cal_checksum: u8 = LIN_LPUART_DRV_MakeChecksumByte(
                index,
                lin_ins_states[index].rx_buff,
                lin_ins_states[index].rx_size - 1,
                lin_ins_states[index].crt_pid,
            );
            if (cal_checksum == lin_ins_states[index].checksum) {
                // check ok
                lin_ins_states[index].crt_event_type = LinEventType.LIN_RX_COMPLETED;
                lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_RECV_DATA_COMPLETED;
                // info user to handle the rx completed event
                if (lin_ins_states[index].lin_callback != null) {
                    lin_ins_states[index].lin_callback(index, &lin_ins_states[index]);
                }
                // check if is not rx blocking
                if (lin_ins_states[index].is_rx_block == false) {
                    lin_ins_states[index].is_bus_busy = false;
                    lin_ins_states[index].is_rx_busy = false;
                    // In case of receiving a go to sleep request, after callback, node is in SLEEP MODE */
                    // In this case, node is in SLEEP MODE state
                    if (lin_ins_states[index].crt_node_state != LinNodeStateType.LIN_NODE_STATE_SLEEP_MODE) {
                        LIN_LPUART_DRV_GotoIdleState(index);
                    }
                }
            } else {
                // check failed
                lin_ins_states[index].crt_event_type = LinEventType.LIN_CHECKSUM_ERROR;
                // info user to handle the checksum error
                if (lin_ins_states[index].lin_callback != null) {
                    lin_ins_states[index].lin_callback(index, &lin_ins_states[index]);
                }
                lin_ins_states[index].is_rx_busy = false;
                LIN_LPUART_DRV_GotoIdleState(index);
            }
        }
    }

    /// Function Name : LIN_LPUART_DRV_ProcessSendFrameData
    /// - Description   : Part of Interrupt handler for sending data.
    pub fn LIN_LPUART_DRV_ProcessSendFrameData(index: u2, temp_value: u8) void {
        var send_flag: bool = true;
        var temp_size: u8 = 0;
        var temp_checksum_and_size: bool = false;
        var temp_buff_and_size: bool = false;
        // check tx reg is empty or not
        if (LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsT.LPUART_TX_DATA_REG_EMPTY) == false) {
            lin_ins_states[index].crt_event_type = LinEventType.LIN_READBACK_ERROR;
            // info user to handle readback error
            if (lin_ins_states[index].lin_callback != null) {
                lin_ins_states[index].lin_callback(index, &lin_ins_states[index]);
            }
            // check is not tx blocking
            if (lin_ins_states[index].is_tx_block == false) {
                lin_ins_states[index].is_tx_busy = false;
                LIN_LPUART_DRV_GotoIdleState(index);
            }
            send_flag = false;
        } else {
            // tx reg is empty now
            temp_size = lin_ins_states[index].tx_size - lin_ins_states[index].byte_cnt;
            // This condition will check if the last byte checksum is correct or not
            temp_checksum_and_size = (temp_size == 1) and (lin_ins_states[index].checksum != temp_value);
            // This condition will check if the current byte to be sent is correct or not
            temp_buff_and_size = (temp_size != 1) and (lin_ins_states[index].tx_buff[0] != temp_value);
            if (temp_checksum_and_size or temp_buff_and_size) {
                // These error will be called readback error
                lin_ins_states[index].crt_event_type = LinEventType.LIN_READBACK_ERROR;
                // info user to handle readback error
                if (lin_ins_states[index].lin_callback != null) {
                    lin_ins_states[index].lin_callback(index, &lin_ins_states[index]);
                }
                if (lin_ins_states[index].is_tx_block == false) {
                    lin_ins_states[index].is_tx_busy = false;
                    LIN_LPUART_DRV_GotoIdleState(index);
                }
                send_flag = false;
            } else {
                // common logic
                // move to next data
                lin_ins_states[index].tx_buff += 1;
                lin_ins_states[index].byte_cnt += 1;
            }
        }

        if (send_flag) {
            if (lin_ins_states[index].byte_cnt < lin_ins_states[index].tx_size) {
                if ((lin_ins_states[index].tx_size - lin_ins_states[index].byte_cnt) == 1) {
                    // send the last byte checksum
                    LpuartHw.LPUART_HW_Putchar(index, lin_ins_states[index].checksum);
                } else {
                    // still sending data
                    LpuartHw.LPUART_HW_Putchar(index, lin_ins_states[index].tx_buff[0]);
                }
            } else {
                // the data sent is the last
                lin_ins_states[index].crt_event_type = LinEventType.LIN_TX_COMPLETED;
                lin_ins_states[index].crt_node_state = LinNodeStateType.LIN_NODE_STATE_SEND_DATA_COMPLETED;
                LpuartHw.LPUART_HW_SetInterruptMode(
                    index,
                    0,
                    LpuartInterruptT.LPUART_INT_RX_DATA_REG_FULL,
                );
                // info the user to handle the tx completed event
                if (lin_ins_states[index].lin_callback != null) {
                    lin_ins_states[index].lin_callback(index, &lin_ins_states[index]);
                }
                // check if is not tx blocking
                if (lin_ins_states[index].is_tx_block == false) {
                    lin_ins_states[index].is_tx_busy = false;
                    // in this case, node is in SLEEP MODE state
                    if (lin_ins_states[index].crt_node_state != LinNodeStateType.LIN_NODE_STATE_SLEEP_MODE) {
                        LIN_LPUART_DRV_GotoIdleState(index);
                    }
                } else {
                    // in block status
                }
            }
        }
    }

    /// Function Name : LIN_LPUART_DRV_GetCurrentNodeState
    /// - Description   : This function gets the current LIN node state.
    pub fn LIN_LPUART_DRV_GetCurrentNodeState(index: u2) LinNodeStateType {
        if (index > 2) return LinNodeStateType.LIN_NODE_STATE_UNINIT;
        return lin_ins_states[index].crt_node_state;
    }

    /// Function Name : LIN_LPUART_DRV_EnableIRQ
    /// - Description   : This function enables LPUART hardware interrupts.
    pub fn LIN_LPUART_DRV_EnableIRQ(index: u2) GenericSts {
        if (index > 2) return GenericSts.STATUS_ERROR;
        if (lin_ins_states[index].crt_node_state == LinNodeStateType.LIN_NODE_STATE_SLEEP_MODE) {
            // in sleep
            LpuartHw.LPUART_HW_SetInterruptMode(index, 1, LpuartInterruptT.LPUART_INT_RX_ACTIVE_EDGE);
        } else {
            // Enable RX complete interrupt
            // Enable frame error interrupt
            // Enable LIN break detect interrupt
            LpuartHw.LPUART_HW_SetInterruptMode(index, 1, LpuartInterruptT.LPUART_INT_RX_DATA_REG_FULL);
            LpuartHw.LPUART_HW_SetInterruptMode(index, 1, LpuartInterruptT.LPUART_INT_FRAME_ERR_FLAG);
            LpuartHw.LPUART_HW_SetInterruptMode(index, 1, LpuartInterruptT.LPUART_INT_LIN_BREAK_DETECT);
        }
        // enable lpuart interrupts
        NVIC_Mgr.NVIC_EnableInterrupt(LinIntertuptHandle.lin_irq_types[index]);
        // enable lpuart error handler interrupts
        return GenericSts.STATUS.SUCCESS;
    }

    pub fn LIN_LPUART_DRV_DisableIRQ(index: u2) GenericSts {
        if (index > 2) return GenericSts.STATUS_ERROR;
        if (lin_ins_states[index].crt_node_state == LinNodeStateType.LIN_NODE_STATE_SLEEP_MODE) {
            // in sleep
            LpuartHw.LPUART_HW_SetInterruptMode(index, 0, LpuartInterruptT.LPUART_INT_RX_ACTIVE_EDGE);
        } else {
            // disable RX complete interrupt
            // disable frame error interrupt
            // disable LIN break detect interrupt
            LpuartHw.LPUART_HW_SetInterruptMode(index, 0, LpuartInterruptT.LPUART_INT_RX_DATA_REG_FULL);
            LpuartHw.LPUART_HW_SetInterruptMode(index, 0, LpuartInterruptT.LPUART_INT_FRAME_ERR_FLAG);
            LpuartHw.LPUART_HW_SetInterruptMode(index, 0, LpuartInterruptT.LPUART_INT_LIN_BREAK_DETECT);
        }
        // disable lpuart interrupts
        NVIC_Mgr.NVIC_DisableInterrupt(LinIntertuptHandle.lin_irq_types[index]);
        // disable lpuart error handler interrupts
        return GenericSts.STATUS.SUCCESS;
    }
};

//#endregion
// ---------------------------------------------------------------------
