//！ This File is the driver of lpuart of s32k144
//! - version: 0.2.0
//! - author: weng
//! - reference: reference to nxp s32k144 sdk

// Import ---------------------------------------------------------
const GenericSts = @import("s32k144_genericSys_mod").GenericSts;
const RegT = @import("s32k144_regs_mod").RegT;
const FieldSet = RegT.FieldSet;
const LPUART_Regs = @import("s32k144_regs_mod").LPUART_Regs;
const PCC_Regs = @import("s32k144_regs_mod").PCC_Regs;
const BAUD = LPUART_Regs.LPUART_BAUD;
const STAT = LPUART_Regs.LPUART_STAT;
const CTRL = LPUART_Regs.LPUART_CTRL;
const MATCH = LPUART_Regs.LPUART_MATCH;
const MODIR = LPUART_Regs.LPUART_MODIR;
const FIFO = LPUART_Regs.LPUART_FIFO;
const WATER = LPUART_Regs.LPUART_WATER;
const DATA = LPUART_Regs.LPUART_DATA;
// Interrupts
const NVIC_Mgr = @import("s32k144_genericSys_mod").NVIC_Mgr;
const IQRnT = NVIC_Mgr.IQRnType;
const IsrHandlerFunc = NVIC_Mgr.IsrHandlerFunc;
// Lpuart Hardware access
const LpuartHw = @import("./LpuartHwAccess.zig");
const LpuartBitCntPerChar = LpuartHw.LpuartBitCntPerChar;
const LpuartParityMode = LpuartHw.LpuartParityMode;
const LpuartStopCnt = LpuartHw.LpuartStopCnt;
const LpuartBreakLenType = LpuartHw.LpuartBreakCharLenType;
const LpuartInterruptType = LpuartHw.LpuartInterruptType;
const LpuartStsType = LpuartHw.LpuartStsType;
const LpuartTransferType = LpuartHw.LpuartTransferType;

//#region [Interrupts Start]
const lpuart_irq_types: [3]IQRnT = .{
    IQRnT.IRQn_LPUART0_RxTx,
    IQRnT.IRQn_LPUART1_RxTx,
    IQRnT.IRQn_LPUART2_RxTx,
};
const lpuart_irq_handlers: [3]IsrHandlerFunc = .{
    LPUART0_RxTx_IRQHandler,
    LPUART1_RxTx_IRQHandler,
    LPUART2_RxTx_IRQHandler,
};
fn LPUART0_RxTx_IRQHandler() callconv(.C) void {
    LPUART_DRV_IRQHandler(0);
}
fn LPUART1_RxTx_IRQHandler() callconv(.C) void {
    LPUART_DRV_IRQHandler(1);
}
fn LPUART2_RxTx_IRQHandler() callconv(.C) void {
    LPUART_DRV_IRQHandler(2);
}

fn LPUART_DRV_IRQHandler(index: u2) void {
    if (index > 2) return;
    LPUART_DRV_ErrIrqHandler(index);
    // 1 Handle receive data full interrupt
    if (LpuartHw.LPUART_HW_GetInterruptModeIsEnabled(index, LpuartInterruptType.LPUART_INT_RX_DATA_REG_FULL)) {
        if (LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsType.LPUART_RX_DATA_REG_FULL)) {
            // handle the rx
            LPUART_DRV_RxIrqHandler(index);
        }
    }
    // 2 Handle transmitter data register empty interrupt
    if (LpuartHw.LPUART_HW_GetInterruptModeIsEnabled(index, LpuartInterruptType.LPUART_INT_TX_DATA_REG_EMPTY)) {
        if (LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsType.LPUART_TX_DATA_REG_EMPTY)) {
            // handle the tx
            LPUART_DRV_TxEmptyIrqHandler(index);
        }
    }
    // 3 Handle transmission complete interrupt
    if (LpuartHw.LPUART_HW_GetInterruptModeIsEnabled(index, LpuartInterruptType.LPUART_INT_TX_COMPLETE)) {
        if (LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsType.LPUART_TX_COMPLETE)) {
            // handle the tx completed
            LPUART_DRV_TxCompleteIrqHandler(index);
        }
    }
}

/// Function Name : LPUART_DRV_TxEmptyIrqHandler
/// - Description : Tx Empty Interrupt handler for LPUART.
/// This function treats the tx empty interrupt.
fn LPUART_DRV_TxEmptyIrqHandler(index: u2) void {
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    if (lpuart_state_ptr.tx_size > 0) {
        LPUART_DRV_PutData(index);
        if (lpuart_state_ptr.bitCnt_perChar_type == LpuartBitCntPerChar.BITS8) {
            lpuart_state_ptr.tx_buffer += 1;
            lpuart_state_ptr.tx_size -|= 1;
        } else {
            lpuart_state_ptr.tx_buffer = &lpuart_state_ptr.tx_buffer[2];
            lpuart_state_ptr.tx_size -|= 2;
        }

        // the tx buffer has been sent out
        if (lpuart_state_ptr.tx_size == 0) {
            if (lpuart_state_ptr.tx_callBACK != null) {
                lpuart_state_ptr.tx_callBACK(
                    lpuart_state_ptr,
                    UartEvent.UART_EVENT_TX_EMPTY,
                    lpuart_state_ptr.tx_callback_param,
                );
            }
            // check again
            // If there's no new data, disable tx empty interrupt and
            // enable transmission complete interrupt
            if (lpuart_state_ptr.tx_size == 0) {
                LpuartHw.LPUART_HW_SetInterruptMode(index, 0, LpuartInterruptType.LPUART_INT_TX_DATA_REG_EMPTY);
                LpuartHw.LPUART_HW_SetInterruptMode(index, 1, LpuartInterruptType.LPUART_INT_TX_COMPLETE);
            }
        }
    }
}

/// Function Name : LPUART_DRV_TxCompleteIrqHandler
/// - Description   : Tx Complete Interrupt handler for LPUART.
/// This function treats the tx complete interrupt.
fn LPUART_DRV_TxCompleteIrqHandler(index: u2) void {
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    if (lpuart_state_ptr.tx_size == 0) {
        if (lpuart_state_ptr.transfer_type == LpuartTransferType.Interrupts) {
            LPUART_DRV_CompleteSendDataUsingInt(index);
        }
    }
}

/// Function Name : LPUART_DRV_RxIrqHandler
/// - Description   : Rx Interrupt handler for LPUART.
/// - This function treats the rx full interrupt.
fn LPUART_DRV_RxIrqHandler(index: u2) void {
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    LPUART_DRV_GetData(index);
    if (lpuart_state_ptr.bitCnt_perChar_type == LpuartBitCntPerChar.BITS8) {
        // move to next buffer ptr
        lpuart_state_ptr.rx_buffer += 1;
        // tgt receive size -1
        // 此处使用饱和减法
        lpuart_state_ptr.rx_size -|= 1;
    } else {
        lpuart_state_ptr.rx_buffer = &lpuart_state_ptr.rx_buffer[2];
        // tgt receive size -1
        // 此处使用饱和减法
        lpuart_state_ptr.rx_size -|= 2;
    }

    // Check if this was the last byte in the current buffer
    if (lpuart_state_ptr.rx_size == 0) {
        if (lpuart_state_ptr.rx_callback != null) {
            lpuart_state_ptr.rx_callback(
                lpuart_state_ptr,
                UartEvent.UART_EVENT_RX_FULL,
                lpuart_state_ptr.rx_callback_param,
            );
        }
    }
    // check is the reception end after the callback
    // in rx callback the buffer ptr maybe changed by user
    if (lpuart_state_ptr.rx_size == 0) {
        // complete receiveing
        LPUART_DRV_CompleteReceiveDataUsingInt(index);
        if (lpuart_state_ptr.rx_callback != null) {
            lpuart_state_ptr.rx_callback(
                lpuart_state_ptr,
                UartEvent.UART_EVENT_END_TRANSFER,
                lpuart_state_ptr.rx_callback_param,
            );
        }
    }
}

/// Function Name : LPUART_DRV_ErrIrqHandler
/// - Description   : Error Interrupt handler for LPUART.
/// This function treats the error interrupts.
fn LPUART_DRV_ErrIrqHandler(index: u2) void {
    if (index > 2) return;
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    // handle LPUART_RX_OVERRUN / LPUART_FRAME_ERR / LPUART_PARITY_ERR
    // LPUART_NOISE_DETECT
    if (LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsType.LPUART_RX_OVERRUN) or
        LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsType.LPUART_FRAME_ERR) or
        LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsType.LPUART_PARITY_ERR) or
        LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsType.LPUART_NOISE_DETECT))
    {
        lpuart_state_ptr.receive_sts = GenericSts.STATUS_ERROR;
        switch (lpuart_state_ptr.transfer_type) {
            LpuartTransferType.Interrupts => {
                LPUART_DRV_CompleteReceiveDataUsingInt(index);
            },
            LpuartTransferType.DMA => {
                return;
            },
            else => unreachable,
        }
        // raise rx call back if the usr has registered one
        if (lpuart_state_ptr.rx_callback != null) {
            lpuart_state_ptr.rx_callback(
                lpuart_state_ptr,
                UartEvent.UART_EVENT_ERROR,
                lpuart_state_ptr.rx_callback_param,
            );
        }
        LpuartHw.LPUART_HW_ClearErrorFlags(index);
    }
}

//#endregion

//#region LPUART Driver Start ------------------
/// LPUART configuration structure
pub const LpuartUsrConfig = struct {
    baudrate: u32,
    parity_mode: LpuartParityMode,
    stop_bit_cnt: LpuartStopCnt,
    bit_cnt_per_char: LpuartBitCntPerChar,
    transfer_type: LpuartTransferType,
    /// Channel number for DMA rx channel.If DMA mode isn't used this field will be ignored.
    rxDMA_channel: u8,
    /// Channel number for DMA tx channel.If DMA mode isn't used this field will be ignored.
    txDMA_channel: u8,
};

pub const UartEvent = enum {
    UART_EVENT_RX_FULL,
    UART_EVENT_TX_EMPTY,
    UART_EVENT_END_TRANSFER,
    UART_EVENT_ERROR,
};

pub const UartCallbackFunc = fn (
    lpuart_state_ptr: *LpuartDriverState,
    uart_event: UartEvent,
    param: *anyopaque,
) void;

/// This is the most important state of lpuart
pub const LpuartDriverState = struct {
    tx_buffer: *?[]const u8 = null,
    rx_buffer: *?[]const u8 = null,
    tx_size: u32 = 0,
    rx_size: u32 = 0,
    is_tx_busy: bool = false,
    is_rx_busy: bool = false,
    is_tx_blocking: bool = false,
    is_rx_blocking: bool = false,
    bitCnt_perChar_type: LpuartBitCntPerChar = LpuartBitCntPerChar.BITS8,
    rx_callback: ?UartCallbackFunc = null,
    rx_callback_param: *?anyopaque = null,
    tx_callBACK: ?UartCallbackFunc = null,
    tx_callback_param: *?anyopaque = null,
    transfer_type: LpuartTransferType = LpuartTransferType.Interrupts,
    rx_DMAChannel: u8 = 0,
    tx_DMAChannel: u8 = 0,
    transmit_sts: GenericSts = GenericSts.STATUS_SUCCESS,
    receive_sts: GenericSts = GenericSts.STATUS_SUCCESS,
};

/// The state of lpuart ins
/// - get the state ins by index which is mapped to channel0-2
pub const lpuartIns_states: [3]LpuartDriverState = .{
    LpuartDriverState{},
    LpuartDriverState{},
    LpuartDriverState{},
};

/// the clock src frequency of lpuart ins
const lpuart_clock_freqs: [3]u32 = .{ 8_000_000, 8_000_000, 8_000_000 };

/// Initializes the LPUART configuration structure with default values.
pub fn LpuartDriverGetDefaultUsrConfig(usr_config_ptr: *LpuartUsrConfig) void {
    usr_config_ptr.baudrate = 9600;
    usr_config_ptr.transfer_type = LpuartTransferType.Interrupts;
    usr_config_ptr.parity_mode = LpuartParityMode.DISABLED;
    usr_config_ptr.stop_bit_cnt = LpuartStopCnt.ONE_STOP_BIT;
    usr_config_ptr.bit_cnt_per_char = LpuartBitCntPerChar.BITS8;
    usr_config_ptr.rxDMA_channel = 0;
    usr_config_ptr.txDMA_channel = 0;
}

/// Clear the lpuart driver state
fn ClearLpuartDriverState(lpuart_state_ptr: *LpuartDriverState) void {
    lpuart_state_ptr.tx_buffer = null;
    lpuart_state_ptr.rx_buffer = null;
    lpuart_state_ptr.tx_size = 0;
    lpuart_state_ptr.rx_size = 0;
    lpuart_state_ptr.is_tx_busy = false;
    lpuart_state_ptr.is_rx_busy = false;
    lpuart_state_ptr.is_tx_blocking = false;
    lpuart_state_ptr.is_rx_blocking = false;
    lpuart_state_ptr.bitCnt_perChar_type = undefined;
    lpuart_state_ptr.rx_callback = null;
    lpuart_state_ptr.rx_callback_param = null;
    lpuart_state_ptr.tx_callback = null;
    lpuart_state_ptr.tx_callback_param = null;
    lpuart_state_ptr.transfer_type = null;
    lpuart_state_ptr.rx_DMAChannel = 0;
    lpuart_state_ptr.tx_DMAChannel = 0;
    lpuart_state_ptr.transmit_sts = undefined;
    lpuart_state_ptr.receive_sts = undefined;
}

/// Default set the lpuart clock src to SOSCDIV2
fn LPUART_InitClockAsSOSCDIV2(index: u2) void {
    if (index > 2) return;
    PCC_Regs.PCC_LPUART_Regs[index].CGC = 0;
    // clock src soscdiv2
    PCC_Regs.PCC_LPUART_Regs[index].PCS = 0b001;
    PCC_Regs.PCC_LPUART_Regs[index].CGC = 1;
    lpuart_clock_freqs[index] = 8_000_000;
}

/// Calculate the osr and sbr according to the tgt baudrate
/// - find the most close baudrate value
pub fn LPUART_DRV_SetBaudRate(index: u2, tgt_baudrate: u32) GenericSts {
    if (lpuartIns_states[index].is_tx_busy) return GenericSts.STATUS_BUSY;
    if (lpuartIns_states[index].is_rx_busy) return GenericSts.STATUS_BUSY;
    //This lpuart instantiation uses a slightly different baud rate calculation
    //The idea is to use the best OSR (over-sampling rate) possible
    //Note, osr is typically hard-set to 16 in other lpuart instantiations
    //First calculate the baud rate using the minimum OSR possible (4)
    const clock_freq = lpuart_clock_freqs[index];
    const osr: u32 = 4;
    const sbr: u32 = clock_freq / (tgt_baudrate * osr);
    var cal_baudrate: u32 = clock_freq / (sbr * osr);
    const baud_diff: u32 = 0;
    if (cal_baudrate > tgt_baudrate) baud_diff = cal_baudrate - tgt_baudrate;
    if (cal_baudrate < tgt_baudrate) baud_diff = tgt_baudrate - cal_baudrate;
    // calculate the max osr value
    const max_osr: u32 = clock_freq / tgt_baudrate;
    if (max_osr > 32) max_osr = 32;
    // calculate the min baudrate diff
    if (max_osr >= 5) {
        for (5..max_osr + 1) |i| {
            const sbr_temp = clock_freq / (tgt_baudrate * i);
            cal_baudrate = clock_freq / (sbr_temp * i);
            const temp_diff = if (cal_baudrate >= tgt_baudrate)
                cal_baudrate - tgt_baudrate
            else
                tgt_baudrate - cal_baudrate;
            if (temp_diff <= baud_diff) {
                osr = i;
                baud_diff = temp_diff;
                sbr = sbr_temp;
            }
        }
    }
    // Check if osr is between 4x and 7x oversampling.
    // If so, then "BOTHEDGE" sampling must be turned on
    if (osr < 8) LpuartHw.LPUART_HW_EnableBothEdgeSamplingCmd(index);
    BAUD.reg_ins_arr[index].updateFieldValue(BAUD.OSR, osr - 1);
    BAUD.reg_ins_arr[index].updateFieldValue(BAUD.SBR, sbr);
    return GenericSts.STATUS_SUCCESS;
}

/// Function Name : LPUART_DRV_GetBaudRate
/// - Description : Returns the LPUART configured baud rate.
pub fn LPUART_DRV_GetBaudRate(index: u2, crt_baudrate: *u32) GenericSts {
    if (index > 2) return GenericSts.STATUS_ERROR;
    const crt_clock_freq = lpuart_clock_freqs[index];
    const osr: u32 = BAUD.reg_ins_arr[index].getFieldValue(BAUD.OSR);
    const sbr: u32 = BAUD.reg_ins_arr[index].getFieldValue(BAUD.SBR);
    crt_baudrate.* = crt_clock_freq / ((osr + 1) * sbr);
    return GenericSts.STATUS_SUCCESS;
}

/// Init the lpuart driver by user config
pub fn LPUART_DRV_Init(index: u2, usr_config_ptr: *LpuartUsrConfig, isDMA_enabled: bool) GenericSts {
    if (index > 2) return GenericSts.STATUS_ERROR;
    // check if the dma is enabled
    if (isDMA_enabled) {
        // should report the error
        if (usr_config_ptr.transfer_type != LpuartTransferType.DMA) return GenericSts.STATUS_ERROR;
    }
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    // clear the lpuart_state send in
    ClearLpuartDriverState(lpuart_state_ptr);
    // set value
    lpuart_state_ptr.transfer_type = usr_config_ptr.transfer_type;
    lpuart_state_ptr.bitCnt_perChar_type = usr_config_ptr.bit_cnt_per_char;
    if (isDMA_enabled) {
        lpuart_state_ptr.tx_DMAChannel = usr_config_ptr.txDMA_channel;
        lpuart_state_ptr.rx_DMAChannel = usr_config_ptr.rxDMA_channel;
    }
    // Set the clock
    LPUART_InitClockAsSOSCDIV2(index);
    LpuartHw.LPUART_HW_Init(index);
    // Set Baudrate by the usr tgt baudrate
    LPUART_DRV_SetBaudRate(index, usr_config_ptr.baudrate);
    // set the parity
    if (usr_config_ptr.parity_mode != LpuartParityMode.DISABLED) {
        LpuartHw.LPUART_HW_SetBitCountPerChar(index, usr_config_ptr.bit_cnt_per_char, true);
    } else {
        LpuartHw.LPUART_HW_SetBitCountPerChar(index, usr_config_ptr.bit_cnt_per_char, false);
    }
    LpuartHw.LPUART_HW_SetParityMode(index, usr_config_ptr.parity_mode);
    LpuartHw.LPUART_HW_SetStopBitCount(index, usr_config_ptr.stop_bit_cnt);
    lpuart_state_ptr.transmit_sts = GenericSts.STATUS_SUCCESS;
    lpuart_state_ptr.receive_sts = GenericSts.STATUS_SUCCESS;
    // install interrupt handler func
    NVIC_Mgr.Install_IsrHandler(lpuart_irq_types[index], lpuart_irq_handlers[index]);
    // enable interrupts
    NVIC_Mgr.NVIC_EnableInterrupt(lpuart_irq_types[index]);
    return GenericSts.STATUS_SUCCESS;
}

pub fn LPUART_DRV_Deinit(index: u2) GenericSts {
    if (index > 2) return GenericSts.STATUS_ERROR;
    // get lpuart crt state
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    // Wait until the data is completely shifted out of shift register
    while (!LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsType.LPUART_TX_COMPLETE)) {}
    NVIC_Mgr.NVIC_DisableInterrupt(lpuart_irq_types[index]);
    ClearLpuartDriverState(lpuart_state_ptr);
    // should set the interrupt handler to default?
    return GenericSts.STATUS_SUCCESS;
}

pub fn LPUART_DRV_InstallRxCallback(
    index: u2,
    callback_func: UartCallbackFunc,
    callback_param: *anyopaque,
) GenericSts {
    if (index > 2) return GenericSts.STATUS_ERROR;
    lpuartIns_states[index].rx_callback = callback_func;
    lpuartIns_states[index].rx_callback_param = callback_param;
    return GenericSts.STATUS_SUCCESS;
}

pub fn LPUART_DRV_InstallTxCallback(
    index: u2,
    callback_func: UartCallbackFunc,
    callback_param: *anyopaque,
) GenericSts {
    if (index > 2) return GenericSts.STATUS_ERROR;
    lpuartIns_states[index].tx_callback = callback_func;
    lpuartIns_states[index].tx_callback_param = callback_param;
    return GenericSts.STATUS_SUCCESS;
}

/// Function Name : LPUART_DRV_SendData
/// - Description   : This function sends data out through the LPUART module using
/// non-blocking method. The function will return immediately after calling this function.
pub fn LPUART_DRV_SendData(index: u2, tx_buffer: *[]u8, tx_size: u32) GenericSts {
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    var ret_sts = GenericSts.STATUS_SUCCESS;
    lpuart_state_ptr.is_tx_blocking = false;
    if (lpuart_state_ptr.transfer_type == LpuartTransferType.Interrupts) {
        ret_sts = LPUART_DRV_StartSendDataUsingInt(index, tx_buffer, tx_size);
    }
    // check if is send with dma
    if (lpuart_state_ptr.transfer_type == LpuartTransferType.DMA) {
        // send data with dma
        ret_sts = GenericSts.STATUS_ERROR;
    }
    return ret_sts;
}

/// Function Name : LPUART_DRV_SendDataPolling
/// - Description : Send out multiple bytes of data using polling method.
pub fn LPUART_DRV_SendDataPolling(index: u2, tx_buff: *[]u8, tx_size: u32) GenericSts {
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    if (lpuart_state_ptr.is_tx_busy) return GenericSts.STATUS_BUSY;
    // enable transmit
    LpuartHw.LPUART_HW_SetTransmitterCmd(index, 1);
    while (tx_size > 0) {
        // block here
        while (!LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsType.LPUART_TX_DATA_REG_EMPTY)) {}
        lpuart_state_ptr.tx_buffer = tx_buff;
        LPUART_DRV_PutData(index);
        if (lpuart_state_ptr.bitCnt_perChar_type == LpuartBitCntPerChar.BITS8) {
            tx_buff += 1;
            tx_size -|= 1;
        } else {
            tx_buff += 2;
            tx_size -|= 2;
        }
    }
    // disable transmit
    LpuartHw.LPUART_HW_SetTransmitterCmd(index, 0);
    return GenericSts.STATUS_SUCCESS;
}

/// ! **Uncompleted**This function will send the data in blocking
/// - the function may be re-written
pub fn LPUART_DRV_SendDataBlocking(index: u2, tx_buff: *[]u8, tx_size: u32, time_out: u32) GenericSts {
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    lpuart_state_ptr.is_tx_blocking = true;

    var ret_sts = GenericSts.STATUS_SUCCESS;
    if (lpuart_state_ptr.transfer_type == LpuartTransferType.Interrupts) {
        ret_sts = LPUART_DRV_StartSendDataUsingInt(index, tx_buff, tx_size);
    }
    if (lpuart_state_ptr.transfer_type == LpuartTransferType.DMA) {
        // using dma send the data
        // LPUART_DRV_StartSendDataUsingDma
        ret_sts = GenericSts.STATUS_ERROR;
    }

    if (ret_sts == GenericSts.STATUS_SUCCESS) {}

    _ = time_out;
    return GenericSts.STATUS_SUCCESS;
}

/// Function Name : LPUART_DRV_ReceiveData
/// - Description   : This function receives data from LPUART module using
/// non-blocking method.  This function returns immediately after initiating the
/// receive function. The application has to get the receive status to see when
/// the receive is complete. In other words, after calling non-blocking get
/// function, the application must get the receive status to check if receive
/// is completed or not.
/// - **attention**: the dma is not completed yet
pub fn LPUART_DRV_ReceiveData(index: u2, rx_buff: *[]u8, rx_size: u32) GenericSts {
    if (index > 2) return GenericSts.STATUS_ERROR;
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    var ret_sts = GenericSts.STATUS_SUCCESS;
    lpuart_state_ptr.is_rx_blocking = false;
    if (lpuart_state_ptr.transfer_type == LpuartTransferType.Interrupts) {
        ret_sts = LPUART_DRV_StartReceiveDataUsingInt(index, rx_buff, rx_size);
    }
    // check if used as dma
    if (lpuart_state_ptr.transfer_type == LpuartTransferType.DMA) {
        ret_sts = GenericSts.STATUS_ERROR;
    }
    return ret_sts;
}

/// The function not completed yet
///  - don't call this function
pub fn LPUART_DRV_ReceiveDataBlocking(
    index: u2,
    rx_buff: *[]u8,
    rx_size: u32,
    time_out: u32,
) GenericSts {
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    var ret_sts = GenericSts.STATUS_SUCCESS;
    // indicate that is in rx blocking
    lpuart_state_ptr.is_rx_blocking = true;
    if (lpuart_state_ptr.transfer_type == LpuartTransferType.Interrupts) {
        ret_sts = LPUART_DRV_StartReceiveDataUsingInt(index, rx_buff, rx_size);
    }
    // check is using dma
    if (lpuart_state_ptr.transfer_type == LpuartTransferType.DMA) {
        // The DMA Driver not completed
        ret_sts = GenericSts.STATUS_ERROR;
    }
    if (ret_sts == GenericSts.STATUS_SUCCESS) {
        // os blocking
        _ = time_out;
    }
    return lpuart_state_ptr.receive_sts;
}

/// Function Name : LPUART_DRV_ReceiveDataPolling
/// - Description : Receive multiple bytes of data using polling method.
pub fn LPUART_DRV_ReceiveDataPolling(index: u2, rx_buff: *[]u8, rx_size: u32) GenericSts {
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    if (lpuart_state_ptr.is_rx_busy) return GenericSts.STATUS_BUSY;
    LpuartHw.LPUART_HW_SetReceiverCmd(index, 1);
    var ret_sts = GenericSts.STATUS_SUCCESS;
    while (rx_size > 0) {
        while (!LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsType.LPUART_RX_DATA_REG_FULL)) {}
        lpuart_state_ptr.rx_buffer = rx_buff;
        LPUART_DRV_GetData(index);
        if (lpuart_state_ptr.bitCnt_perChar_type == LpuartBitCntPerChar.BITS8) {
            rx_buff += 1;
            rx_size -|= 1;
        } else {
            rx_buff += 2;
            rx_size -|= 2;
        }
        // check if error occurs
        // Frame err
        if (LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsType.LPUART_FRAME_ERR)) {
            // stop receive
            // clear flag
            LpuartHw.LPUART_HW_SetReceiverCmd(index, 0);
            LpuartHw.LPUART_HW_ClearStatusFlag(index, LpuartStsType.LPUART_FRAME_ERR);
            ret_sts = GenericSts.STATUS_ERROR;
            break;
        }
        // Noise detect
        if (LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsType.LPUART_NOISE_DETECT)) {
            // stop receive
            // clear flag
            LpuartHw.LPUART_HW_SetReceiverCmd(index, 0);
            LpuartHw.LPUART_HW_ClearStatusFlag(index, LpuartStsType.LPUART_NOISE_DETECT);
            ret_sts = GenericSts.STATUS_ERROR;
            break;
        }
        // LPUART_PARITY_ERR
        if (LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsType.LPUART_PARITY_ERR)) {
            // stop receive
            // clear flag
            LpuartHw.LPUART_HW_SetReceiverCmd(index, 0);
            LpuartHw.LPUART_HW_ClearStatusFlag(index, LpuartStsType.LPUART_PARITY_ERR);
            ret_sts = GenericSts.STATUS_ERROR;
            break;
        }
        // LPUART_RX_OVERRUN
        if (LpuartHw.LPUART_HW_GetStatusFlag(index, LpuartStsType.LPUART_RX_OVERRUN)) {
            // stop receive
            // clear flag
            LpuartHw.LPUART_HW_SetReceiverCmd(index, 0);
            LpuartHw.LPUART_HW_ClearStatusFlag(index, LpuartStsType.LPUART_RX_OVERRUN);
            if (rx_size == 0) ret_sts = GenericSts.STATUS_SUCCESS;
            break;
        }
    }
    // update receive status
    if (ret_sts == GenericSts.STATUS_SUCCESS) LpuartHw.LPUART_HW_SetReceiverCmd(index, 0);
    return ret_sts;
}

/// Abort the sending task
/// Function Name : LPUART_DRV_AbortSendingData
/// - Description   : This function terminates an non-blocking LPUART transmission
/// early. During a non-blocking LPUART transmission, the user has the option to
/// terminate the transmission early if the transmission is still in progress.
pub fn LPUART_DRV_AbortSendingData(index: u2) GenericSts {
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    if (!lpuart_state_ptr.is_tx_busy) {
        return GenericSts.STATUS_SUCCESS;
    }
    if (lpuart_state_ptr.transfer_type == LpuartTransferType.Interrupts) {
        LPUART_DRV_CompleteSendDataUsingInt(index);
    }
    lpuart_state_ptr.transmit_sts = GenericSts.STATUS_ABORTED;
    // check in dma mode
    if (lpuart_state_ptr.transfer_type == LpuartTransferType.DMA) {
        // do somthing here
        // 暂时返回错误，因为未实现DMA
        return GenericSts.STATUS_ERROR;
    }
    return GenericSts.STATUS_SUCCESS;
}

/// Function Name : LPUART_DRV_AbortReceivingData
/// - Description   : Terminates a non-blocking receive early.
pub fn LPUART_DRV_AbortReceivingData(index: u2) GenericSts {
    if (index > 2) return GenericSts.STATUS_ERROR;
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    // check is in rx
    if (!lpuart_state_ptr.is_rx_busy) return GenericSts.STATUS_SUCCESS;
    lpuart_state_ptr.receive_sts = GenericSts.STATUS_ABORTED;
    if (lpuart_state_ptr.transfer_type == LpuartTransferType.Interrupts) {
        // stop receive completely
        LPUART_DRV_CompleteReceiveDataUsingInt(index);
    }
    if (lpuart_state_ptr.transfer_type == LpuartTransferType.DMA) {
        // Not complete yet
        return GenericSts.STATUS_ERROR;
    }

    return GenericSts.STATUS_SUCCESS;
}

/// Function Name : LPUART_DRV_GetTransmitStatus
/// - Description : This function returns whether the previous LPUART transmit has
/// finished. When performing non-blocking transmit, the user can call this
/// function to ascertain the state of the current transmission:
/// in progress (or busy) or complete (success). In addition, if the transmission
/// is still in progress, the user can obtain the number of words that have been
/// currently transferred.
fn LPUART_DRV_GetTransmitStatus(index: u2, byte_cnt_remain: *?u32) GenericSts {
    if (index > 2) return GenericSts.STATUS_ERROR;
    if (byte_cnt_remain == null) return GenericSts.STATUS_ERROR;
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    if (lpuart_state_ptr.is_tx_busy) {
        if (lpuart_state_ptr.transfer_type == LpuartTransferType.Interrupts) {
            byte_cnt_remain.* = lpuart_state_ptr.tx_size;
        }
        if (lpuart_state_ptr.transfer_type == LpuartTransferType.DMA) {
            // do something
            return GenericSts.STATUS_ERROR;
        }
    } else {
        byte_cnt_remain.* = 0;
    }
    return lpuart_state_ptr.transmit_sts;
}

/// Function Name : LPUART_DRV_GetReceiveStatus
/// - Description : This function returns whether the previous LPUART receive is
/// complete.
/// - When performing a non-blocking receive, the user can call this
/// function to ascertain the state of the current receive progress: in progress
/// or complete. In addition, if the receive is still in progress, the user can
/// obtain the number of words that have been currently received.
fn LPUART_DRV_GetReceiveStatus(index: u2, byte_cnt_remain: *?u32) GenericSts {
    if (index > 2) return GenericSts.STATUS_ERROR;
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    if (byte_cnt_remain != null) {
        if (lpuart_state_ptr.is_rx_busy) {
            if (lpuart_state_ptr.transfer_type == LpuartTransferType.Interrupts) {
                byte_cnt_remain.* = lpuart_state_ptr.rx_size;
            }
            if (lpuart_state_ptr.transfer_type == LpuartTransferType.DMA) {
                // not completely
                return GenericSts.STATUS_ERROR;
            }
        } else {
            byte_cnt_remain.* = 0;
        }
    }
    return lpuart_state_ptr.receive_sts;
}

fn LPUART_DRV_PutData(index: u2) void {
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    //const tx_data: u32 = 0;
    const temp_tx_buffer: *[]u8 = lpuart_state_ptr.tx_buffer;
    if (lpuart_state_ptr.bitCnt_perChar_type == LpuartBitCntPerChar.BITS8) {
        LpuartHw.LPUART_HW_Putchar(index, temp_tx_buffer[0]);
    } else if (lpuart_state_ptr.bitCnt_perChar_type == LpuartBitCntPerChar.BITS9) {
        var data9: u9 = temp_tx_buffer[0];
        temp_tx_buffer += 1;
        data9 |= @as(u9, temp_tx_buffer[0]) << 8;
        LpuartHw.LPUART_HW_Putchar9(index, data9);
    } else if (lpuart_state_ptr.bitCnt_perChar_type == LpuartBitCntPerChar.BITS10) {
        var data10: u10 = temp_tx_buffer[0];
        temp_tx_buffer += 1;
        data10 |= @as(u10, temp_tx_buffer[0]) << 8;
        LpuartHw.LPUART_HW_Putchar10(index, data10);
    }
}

/// Function Name : LPUART_DRV_GetData
/// - Description : Read data from the buffer register, according to configured word length.
pub fn LPUART_DRV_GetData(index: u2) void {
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    const rec_data: u32 = 0;
    const temp_rec_buffer: *[]u8 = lpuart_state_ptr.rx_buffer;
    if (lpuart_state_ptr.bitCnt_perChar_type == LpuartBitCntPerChar.BITS8) {
        LpuartHw.LPUART_HW_Getchar(index, &temp_rec_buffer[0]);
    } else if (lpuart_state_ptr.bitCnt_perChar_type == LpuartBitCntPerChar.BITS9) {
        LpuartHw.LPUART_HW_Getchar9(index, &rec_data);
        temp_rec_buffer[0] = @as(u8, @intCast(rec_data & 0xFF));
        temp_rec_buffer[1] = @as(u8, @intCast(rec_data >> 8));
    } else if (lpuart_state_ptr.bitCnt_perChar_type == LpuartBitCntPerChar.BITS10) {
        LpuartHw.LPUART_HW_Getchar10(index, &rec_data);
        temp_rec_buffer[0] = @as(u8, @intCast(rec_data & 0xFF));
        temp_rec_buffer[1] = @as(u8, @intCast(rec_data >> 8));
    }
}

/// Function Name : LPUART_DRV_StartSendDataUsingInt
/// - Description : Initiate (start) a transmit by beginning the process of
/// sending data and enabling the interrupt.
pub fn LPUART_DRV_StartSendDataUsingInt(
    index: u2,
    tx_buff: *[]u8,
    tx_size: u32,
) GenericSts {
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    if (lpuart_state_ptr.is_tx_busy) return GenericSts.STATUS_BUSY;
    // init send data
    lpuart_state_ptr.tx_buffer = tx_buff;
    lpuart_state_ptr.tx_size = tx_size;
    lpuart_state_ptr.is_tx_busy = true;
    lpuart_state_ptr.transmit_sts = GenericSts.STATUS_BUSY;
    // enable tx transmit
    LpuartHw.LPUART_HW_SetTransmitterCmd(index, 1);
    // enable tx empty interrupts
    LpuartHw.LPUART_HW_SetInterruptMode(index, 1, LpuartInterruptType.LPUART_INT_TX_DATA_REG_EMPTY);
    return GenericSts.STATUS_SUCCESS;
}

pub fn LPUART_DRV_CompleteReceiveDataUsingInt(index: u2) void {
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    LpuartHw.LPUART_HW_SetReceiverCmd(index, 0);
    LpuartHw.LPUART_HW_SetErrorInterrupts(index, 0);
    const temp_value: u8 = 0;
    LpuartHw.LPUART_HW_Getchar(index, &temp_value);
    LpuartHw.LPUART_HW_SetInterruptMode(
        index,
        0,
        LpuartInterruptType.LPUART_INT_RX_DATA_REG_FULL,
    );
    lpuart_state_ptr.is_rx_blocking = false;
    lpuart_state_ptr.is_rx_busy = false;
    lpuart_state_ptr.receive_sts = GenericSts.STATUS_SUCCESS;
}

/// Function Name : LPUART_DRV_CompleteSendDataUsingInt
/// - Description   : Finish up a transmit by completing the process of sending
/// data and disabling the interrupt.
/// This is not a public API as it is called from other driver functions.
pub fn LPUART_DRV_CompleteSendDataUsingInt(index: u2) void {
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    if (lpuart_state_ptr.transmit_sts == GenericSts.STATUS_BUSY) {
        lpuart_state_ptr.transmit_sts = GenericSts.STATUS_SUCCESS;
    } else {
        LpuartHw.LPUART_HW_SetInterruptMode(index, 0, LpuartInterruptType.LPUART_INT_TX_DATA_REG_EMPTY);
    }
    // Disable transmission complete interrupt
    LpuartHw.LPUART_HW_SetInterruptMode(index, 0, LpuartInterruptType.LPUART_INT_TX_COMPLETE);
    // Disable transmitter
    LpuartHw.LPUART_HW_SetTransmitterCmd(index, 0);
    lpuart_state_ptr.is_tx_busy = false;
    // ! this logic should be checked
    // when the block may occur
    lpuart_state_ptr.is_tx_blocking = false;
}

/// Function Name : LPUART_DRV_StartReceiveDataUsingInt
/// - Description   : Initiate (start) a receive by beginning the process of
/// receiving data and enabling the interrupt.
/// This is not a public API as it is called from other driver functions.
pub fn LPUART_DRV_StartReceiveDataUsingInt(index: u2, rx_buff: *[]u8, rx_size: u32) GenericSts {
    if (index > 2) return GenericSts.STATUS_ERROR;
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    // check is current busy
    if (lpuart_state_ptr.is_rx_busy) return GenericSts.STATUS_BUSY;
    // init current lpuart state
    lpuart_state_ptr.is_rx_busy = true;
    lpuart_state_ptr.rx_buffer = rx_buff;
    lpuart_state_ptr.rx_size = rx_size;
    lpuart_state_ptr.receive_sts = GenericSts.STATUS_BUSY;
    // enable the receiver
    LpuartHw.LPUART_HW_SetReceiverCmd(index, 1);
    // enable error interrupts
    LpuartHw.LPUART_HW_SetErrorInterrupts(index, 1);
    // set interrupt mode to full receive mode
    LpuartHw.LPUART_HW_SetInterruptMode(index, 1, LpuartInterruptType.LPUART_INT_RX_DATA_REG_FULL);
    return GenericSts.STATUS_SUCCESS;
}

/// Function Name : LPUART_DRV_SetTxBuffer
/// - Description   : Sets the driver internal reference to the tx buffer.
/// - Can be called from the tx callback to provide a different
/// buffer for continuous transmission.
pub fn LPUART_DRV_SetTxBuffer(index: u2, tx_buff: *?[]u8, tx_size: u32) GenericSts {
    if (index > 2 or tx_buff == null or tx_size == 0) return GenericSts.STATUS_ERROR;
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    lpuart_state_ptr.tx_buffer = tx_buff;
    lpuart_state_ptr.tx_size = tx_size;
    return GenericSts.STATUS_SUCCESS;
}

/// Function Name : LPUART_DRV_SetRxBuffer
/// - Description : Sets the driver internal reference to the rx buffer.
/// - Can be called from the rx callback to provide a different
/// buffer for continuous reception.
pub fn LPUART_DRV_SetRxBuffer(index: u2, rx_buff: *?[]u8, rx_size: u32) GenericSts {
    if (index > 2 or rx_buff == null or rx_size == 0) return GenericSts.STATUS_ERROR;
    const lpuart_state_ptr: *LpuartDriverState = &lpuartIns_states[index];
    lpuart_state_ptr.tx_buffer = rx_buff;
    lpuart_state_ptr.tx_size = rx_size;
    return GenericSts.STATUS_SUCCESS;
}

//#endregion

//#region DMA Operation
fn LPUART_DRV_StartSendDataUsingDma() void {}
fn LPUART_DRV_StartReceiveDataUsingDma() void {}
fn LPUART_DRV_TxDmaCallback() void {}
fn LPUART_DRV_RxDmaCallback() void {}
fn LPUART_DRV_StopTxDma() void {}
fn LPUART_DRV_StopRxDma() void {}
//#endregion
