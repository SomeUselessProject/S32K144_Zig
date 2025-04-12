//! The Hardware Access Layer to lpuart registers

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

//#region General Define
pub const LpuartParityMode = enum(u2) { DISABLED = 0, EVEN = 2, ODD = 3 };
pub const LpuartStopCnt = enum(u1) { ONE_STOP_BIT = 0, TWO_STOP_BIT = 1 };
pub const LpuartTransferType = enum(u1) { DMA = 0, Interrupts = 1 };
pub const LpuartBitCntPerChar = enum(u2) { BITS8 = 0, BITS9 = 1, BITS10 = 2 };
pub const LpuartInterruptType = enum(u4) {
    LPUART_INT_LIN_BREAK_DETECT,
    LPUART_INT_RX_ACTIVE_EDGE,
    LPUART_INT_TX_DATA_REG_EMPTY,
    LPUART_INT_TX_COMPLETE,
    LPUART_INT_RX_DATA_REG_FULL,
    LPUART_INT_IDLE_LINE,
    LPUART_INT_RX_OVERRUN,
    LPUART_INT_NOISE_ERR_FLAG,
    LPUART_INT_FRAME_ERR_FLAG,
    LPUART_INT_PARITY_ERR_FLAG,
    LPUART_INT_MATCH_ADDR_ONE,
    LPUART_INT_MATCH_ADDR_TWO,
    LPUART_INT_FIFO_TXOF,
    LPUART_INT_FIFO_RXUF,
};
pub const LpuartStsType = enum {
    LPUART_TX_DATA_REG_EMPTY,
    LPUART_TX_COMPLETE,
    LPUART_RX_DATA_REG_FULL,
    LPUART_IDLE_LINE_DETECT,
    LPUART_RX_OVERRUN,
    LPUART_NOISE_DETECT,
    LPUART_FRAME_ERR,
    LPUART_PARITY_ERR,
    LPUART_LIN_BREAK_DETECT,
    LPUART_RX_ACTIVE_EDGE_DETECT,
    LPUART_RX_ACTIVE,
    LPUART_NOISE_IN_CURRENT_WORD,
    LPUART_PARITY_ERR_IN_CURRENT_WORD,
    LPUART_MATCH_ADDR_ONE,
    LPUART_MATCH_ADDR_TWO,
    LPUART_FIFO_TX_OF,
    LPUART_FIFO_RX_UF,
};

pub const LpuartBreakCharLenType = enum(u1) {
    /// LPUART break char length
    /// - 10 bit times (if M = 0, SBNS = 0)
    /// - or 11 (if M = 1, SBNS = 0 or M = 0, SBNS = 1)
    /// - or 12 (if M = 1, SBNS = 1 or M10 = 1, SNBS = 0)
    /// - or 13 (if M10 = 1, SNBS = 1)
    LPUART_BREAK_CHAR_10_BIT_MINIMUM = 0,
    /// LPUART break char length
    /// - 13 bit times (if M = 0, SBNS = 0 or M10 = 0, SBNS = 1)
    /// - or 14 (if M = 1, SBNS = 0 or M = 1, SBNS = 1)
    /// - or 15 (if M10 = 1, SBNS = 1 or M10 = 1, SNBS = 0)
    LPUART_BREAK_CHAR_13_BIT_MINIMUM = 1,
};

//#endregion

/// Initializes the LPUART controller to known state, using
/// register reset values defined in the reference manual.
/// - `index` the index of s32k144 lpuart peripheral
pub fn LPUART_HW_Init(index: u2) void {
    if (index > 2) return;
    // Set the default oversampling ratio (16) and baud-rate divider (4)
    BAUD.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = BAUD.OSR, .field_value = 16 },
        FieldSet{ .field_def = BAUD.SBR, .field_value = 4 },
    });
    // Clear the error/interrupt flags
    STAT.reg_ins_arr[index].setRaw(0xC01F_C000);
    CTRL.reg_ins_arr[index].setRaw(0);
    MATCH.reg_ins_arr[index].setRaw(0);
    MODIR.reg_ins_arr[index].setRaw(0);
    FIFO.reg_ins_arr[index].setRaw(0x0003_C000);
    WATER.reg_ins_arr[index].setRaw(0);
}

/// !Function Name : LPUART_SetBitCountPerChar
/// **这个方法可能有问题**
/// - Description   : Configures the number of bits per char in LPUART controller.
/// - In some LPUART instances, the user should disable the transmitter/receiver before calling this function.
/// - Generally, this may be applied to all LPUARTs to ensure safe operation.
pub fn LPUART_HW_SetBitCountPerChar(
    index: u2,
    bitCnt_perChar: LpuartBitCntPerChar,
    is_parity: bool,
) void {
    const tmp_bitCnt_PerChar = @intFromEnum(bitCnt_perChar);
    if (is_parity) {
        tmp_bitCnt_PerChar += 1;
    }
    if (tmp_bitCnt_PerChar == @intFromEnum(LpuartBitCntPerChar.BITS10)) {
        BAUD.reg_ins_arr[index].updateFieldValue(BAUD.M10, 1);
    } else {
        // config 8-bit (M=0) or 9-bits (M=1)
        // clear M10 to make sure not 10-bit mode
        CTRL.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
            FieldSet{ .field_def = CTRL.M, .field_value = 0 },
        });
        BAUD.reg_ins_arr[index].updateFieldValue(BAUD.M10, 0);
    }
}

/// Function Name : LPUART_SetParityMode
/// - Description   : Configures parity mode in the LPUART controller.
/// - In some LPUART instances, the user should disable the transmitter/receiver
/// before calling this function.
/// - Generally, this may be applied to all LPUARTs to ensure safe operation.
pub fn LPUART_HW_SetParityMode(index: u2, parity_type: LpuartParityMode) void {
    switch (parity_type) {
        LpuartParityMode.DISABLED => {
            CTRL.reg_ins_arr[index].updateFieldValue(CTRL.PE, 0);
        },
        LpuartParityMode.EVEN => {
            CTRL.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
                FieldSet{ .field_def = CTRL.PE, .field_value = 1 },
                FieldSet{ .field_def = CTRL.PT, .field_value = 0 },
            });
        },
        LpuartParityMode.ODD => {
            CTRL.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
                FieldSet{ .field_def = CTRL.PE, .field_value = 1 },
                FieldSet{ .field_def = CTRL.PT, .field_value = 1 },
            });
        },
    }
}

/// data to send (8-bit)
pub fn LPUART_HW_Putchar(index: u2, data: u8) void {
    DATA.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = DATA.R0T0, .field_value = (data >> 0) & 1 },
        FieldSet{ .field_def = DATA.R1T1, .field_value = (data >> 1) & 1 },
        FieldSet{ .field_def = DATA.R2T2, .field_value = (data >> 2) & 1 },
        FieldSet{ .field_def = DATA.R3T3, .field_value = (data >> 3) & 1 },
        FieldSet{ .field_def = DATA.R4T4, .field_value = (data >> 4) & 1 },
        FieldSet{ .field_def = DATA.R5T5, .field_value = (data >> 5) & 1 },
        FieldSet{ .field_def = DATA.R6T6, .field_value = (data >> 6) & 1 },
        FieldSet{ .field_def = DATA.R7T7, .field_value = (data >> 7) & 1 },
    });
}

/// Function Name : LPUART_Putchar9
/// - Description   : Sends the LPUART 9-bit character.
pub fn LPUART_HW_Putchar9(index: u2, data: u9) void {
    const bit9_value = @as(u16, (data >> 8) & 1);
    DATA.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = DATA.R0T0, .field_value = @as(u16, (data >> 0) & 1) },
        FieldSet{ .field_def = DATA.R1T1, .field_value = @as(u16, (data >> 1) & 1) },
        FieldSet{ .field_def = DATA.R2T2, .field_value = @as(u16, (data >> 2) & 1) },
        FieldSet{ .field_def = DATA.R3T3, .field_value = @as(u16, (data >> 3) & 1) },
        FieldSet{ .field_def = DATA.R4T4, .field_value = @as(u16, (data >> 4) & 1) },
        FieldSet{ .field_def = DATA.R5T5, .field_value = @as(u16, (data >> 5) & 1) },
        FieldSet{ .field_def = DATA.R6T6, .field_value = @as(u16, (data >> 6) & 1) },
        FieldSet{ .field_def = DATA.R7T7, .field_value = @as(u16, (data >> 7) & 1) },
        FieldSet{ .field_def = DATA.R8T8, .field_value = bit9_value },
    });
    // write to ninth data bit T8(where T[0:7]=8-bits, T8=9th bit)
    CTRL.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = CTRL.R9T8, .field_value = bit9_value },
    });
}

/// Function Name : LPUART_Putchar10
/// - Description   : Sends the LPUART 10-bit character.
pub fn LPUART_HW_Putchar10(index: u2, data: u10) void {
    const bit9_value = @as(u16, (data >> 8) & 1);
    const bit10_value = @as(u16, (data >> 9) & 1);
    DATA.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = DATA.R0T0, .field_value = @as(u16, (data >> 0) & 1) },
        FieldSet{ .field_def = DATA.R1T1, .field_value = @as(u16, (data >> 1) & 1) },
        FieldSet{ .field_def = DATA.R2T2, .field_value = @as(u16, (data >> 2) & 1) },
        FieldSet{ .field_def = DATA.R3T3, .field_value = @as(u16, (data >> 3) & 1) },
        FieldSet{ .field_def = DATA.R4T4, .field_value = @as(u16, (data >> 4) & 1) },
        FieldSet{ .field_def = DATA.R5T5, .field_value = @as(u16, (data >> 5) & 1) },
        FieldSet{ .field_def = DATA.R6T6, .field_value = @as(u16, (data >> 6) & 1) },
        FieldSet{ .field_def = DATA.R7T7, .field_value = @as(u16, (data >> 7) & 1) },
        FieldSet{ .field_def = DATA.R8T8, .field_value = bit9_value },
        FieldSet{ .field_def = DATA.R9T9, .field_value = bit10_value },
    });
    // write to ninth data bit T8(where T[0:7]=8-bits, T8=9th bit)
    CTRL.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = CTRL.R9T8, .field_value = bit9_value },
        FieldSet{ .field_def = CTRL.R8T9, .field_value = bit10_value },
    });
}

/// ReadData Data read from receive (8-bit)
pub fn LPUART_HW_Getchar(index: u2, out_data: *u8) void {
    out_data.* = @as(u8, @intCast(DATA.reg_ins_arr[index].getRaw()));
}

/// Function Name : LPUART_Getchar9
/// - Description   : Gets the LPUART 9-bit character.
pub fn LPUART_HW_Getchar9(index: u2, out_data: *u32) void {
    // get ninth data from ctrl register
    out_data.* = CTRL.reg_ins_arr[index].getFieldValue(CTRL.R8T9) << 8;
    // get 0-7 data from data register
    out_data.* |= @as(u8, @intCast(DATA.reg_ins_arr[index].getRaw()));
}

/// Function Name : LPUART_Getchar10
/// - Description   : Gets the LPUART 10-bit character
pub fn LPUART_HW_Getchar10(index: u2, out_data: *u32) void {
    // get tenth data from ctrl register
    out_data.* = CTRL.reg_ins_arr[index].getFieldValue(CTRL.R9T8) << 9;
    // get ninth data from ctrl register
    out_data.* |= CTRL.reg_ins_arr[index].getFieldValue(CTRL.R8T9) << 8;
    // get 0-7 data from data register
    out_data.* |= @as(u8, @intCast(DATA.reg_ins_arr[index].getRaw()));
}

/// Function Name : LPUART_SetIntMode
/// - Description   : Configures the LPUART module interrupts to enable/disable
/// various interrupt sources.
pub fn LPUART_HW_SetInterruptMode(index: u2, enabled: u1, inter_type: LpuartInterruptType) void {
    switch (inter_type) {
        LpuartInterruptType.LPUART_INT_LIN_BREAK_DETECT => {
            BAUD.reg_ins_arr[index].updateFieldValue(BAUD.LBKDIE, enabled);
        },
        LpuartInterruptType.LPUART_INT_RX_ACTIVE_EDGE => {
            BAUD.reg_ins_arr[index].updateFieldValue(BAUD.RXEDGIE, enabled);
        },
        LpuartInterruptType.LPUART_INT_TX_DATA_REG_EMPTY => {
            CTRL.reg_ins_arr[index].updateFieldValue(CTRL.TIE, enabled);
        },
        LpuartInterruptType.LPUART_INT_TX_COMPLETE => {
            CTRL.reg_ins_arr[index].updateFieldValue(CTRL.TCIE, enabled);
        },
        LpuartInterruptType.LPUART_INT_RX_DATA_REG_FULL => {
            CTRL.reg_ins_arr[index].updateFieldValue(CTRL.RIE, enabled);
        },
        LpuartInterruptType.LPUART_INT_IDLE_LINE => {
            CTRL.reg_ins_arr[index].updateFieldValue(CTRL.ILIE, enabled);
        },
        LpuartInterruptType.LPUART_INT_RX_OVERRUN => {
            CTRL.reg_ins_arr[index].updateFieldValue(CTRL.ORIE, enabled);
        },
        LpuartInterruptType.LPUART_INT_NOISE_ERR_FLAG => {
            CTRL.reg_ins_arr[index].updateFieldValue(CTRL.NEIE, enabled);
        },
        LpuartInterruptType.LPUART_INT_FRAME_ERR_FLAG => {
            CTRL.reg_ins_arr[index].updateFieldValue(CTRL.FEIE, enabled);
        },
        LpuartInterruptType.LPUART_INT_PARITY_ERR_FLAG => {
            CTRL.reg_ins_arr[index].updateFieldValue(CTRL.PEIE, enabled);
        },
        LpuartInterruptType.LPUART_INT_MATCH_ADDR_ONE => {
            CTRL.reg_ins_arr[index].updateFieldValue(CTRL.MA1IE, enabled);
        },
        LpuartInterruptType.LPUART_INT_MATCH_ADDR_TWO => {
            CTRL.reg_ins_arr[index].updateFieldValue(CTRL.MA2IE, enabled);
        },
        LpuartInterruptType.LPUART_INT_FIFO_TXOF => {
            FIFO.reg_ins_arr[index].updateFieldValue(FIFO.TXOFE, enabled);
        },
        LpuartInterruptType.LPUART_INT_FIFO_RXUF => {
            FIFO.reg_ins_arr[index].updateFieldValue(FIFO.RXUFE, enabled);
        },
        else => unreachable,
    }
}

/// Function Name : LPUART_GetIntMode
/// - Description   : Returns whether LPUART module interrupt is enabled/disabled.
pub fn LPUART_HW_GetInterruptModeIsEnabled(index: u2, inter_type: LpuartInterruptType) bool {
    switch (inter_type) {
        LpuartInterruptType.LPUART_INT_LIN_BREAK_DETECT => {
            return BAUD.reg_ins_arr[index].getFieldValue(BAUD.LBKDIE) != 0;
        },
        LpuartInterruptType.LPUART_INT_RX_ACTIVE_EDGE => {
            return BAUD.reg_ins_arr[index].updateFieldValue(BAUD.RXEDGIE) != 0;
        },
        LpuartInterruptType.LPUART_INT_TX_DATA_REG_EMPTY => {
            return CTRL.reg_ins_arr[index].updateFieldValue(CTRL.TIE) != 0;
        },
        LpuartInterruptType.LPUART_INT_TX_COMPLETE => {
            return CTRL.reg_ins_arr[index].updateFieldValue(CTRL.TCIE) != 0;
        },
        LpuartInterruptType.LPUART_INT_RX_DATA_REG_FULL => {
            return CTRL.reg_ins_arr[index].updateFieldValue(CTRL.RIE) != 0;
        },
        LpuartInterruptType.LPUART_INT_IDLE_LINE => {
            return CTRL.reg_ins_arr[index].updateFieldValue(CTRL.ILIE) != 0;
        },
        LpuartInterruptType.LPUART_INT_RX_OVERRUN => {
            return CTRL.reg_ins_arr[index].updateFieldValue(CTRL.ORIE) != 0;
        },
        LpuartInterruptType.LPUART_INT_NOISE_ERR_FLAG => {
            return CTRL.reg_ins_arr[index].updateFieldValue(CTRL.NEIE) != 0;
        },
        LpuartInterruptType.LPUART_INT_FRAME_ERR_FLAG => {
            return CTRL.reg_ins_arr[index].updateFieldValue(CTRL.FEIE) != 0;
        },
        LpuartInterruptType.LPUART_INT_PARITY_ERR_FLAG => {
            return CTRL.reg_ins_arr[index].updateFieldValue(CTRL.PEIE) != 0;
        },
        LpuartInterruptType.LPUART_INT_MATCH_ADDR_ONE => {
            return CTRL.reg_ins_arr[index].updateFieldValue(CTRL.MA1IE) != 0;
        },
        LpuartInterruptType.LPUART_INT_MATCH_ADDR_TWO => {
            return CTRL.reg_ins_arr[index].updateFieldValue(CTRL.MA2IE) != 0;
        },
        LpuartInterruptType.LPUART_INT_FIFO_TXOF => {
            return FIFO.reg_ins_arr[index].updateFieldValue(FIFO.TXOFE) != 0;
        },
        LpuartInterruptType.LPUART_INT_FIFO_RXUF => {
            return FIFO.reg_ins_arr[index].updateFieldValue(FIFO.RXUFE) != 0;
        },
        else => unreachable,
    }
    return false;
}

/// Function Name : LPUART_GetStatusFlag
/// - Description   : LPUART get status flag by passing flag enum.
pub fn LPUART_HW_GetStatusFlag(index: u2, sts_type: LpuartStsType) bool {
    if (sts_type == LpuartStsType.LPUART_NOISE_IN_CURRENT_WORD) {
        return DATA.reg_ins_arr[index].getFieldValue(DATA.NOISY) != 0;
    }
    if (sts_type == LpuartStsType.LPUART_PARITY_ERR_IN_CURRENT_WORD) {
        return DATA.reg_ins_arr[index].getFieldValue(DATA.PARITYE) != 0;
    }
    if (sts_type == LpuartStsType.LPUART_FIFO_TX_OF) {
        return FIFO.reg_ins_arr[index].getFieldValue(FIFO.TXOF) != 0;
    }
    if (sts_type == LpuartStsType.LPUART_FIFO_RX_UF) {
        return FIFO.reg_ins_arr[index].getFieldValue(FIFO.RXUF) != 0;
    }

    var tgt_field: RegT.FieldDef = undefined;
    switch (sts_type) {
        LpuartStsType.LPUART_TX_DATA_REG_EMPTY => tgt_field = STAT.TDRE,
        LpuartStsType.LPUART_TX_COMPLETE => tgt_field = STAT.TC,
        LpuartStsType.LPUART_RX_DATA_REG_FULL => tgt_field = STAT.TDRF,
        LpuartStsType.LPUART_IDLE_LINE_DETECT => tgt_field = STAT.IDLE,
        LpuartStsType.LPUART_RX_OVERRUN => tgt_field = STAT.OR,
        LpuartStsType.LPUART_NOISE_DETECT => tgt_field = STAT.NF,
        LpuartStsType.LPUART_FRAME_ERR => tgt_field = STAT.FE,
        LpuartStsType.LPUART_PARITY_ERR => tgt_field = STAT.PF,
        LpuartStsType.LPUART_LIN_BREAK_DETECT => tgt_field = STAT.LBKDIF,
        LpuartStsType.LPUART_RX_ACTIVE_EDGE_DETECT => tgt_field = STAT.RXEDGIF,
        LpuartStsType.LPUART_RX_ACTIVE => tgt_field = STAT.RAF,
        LpuartStsType.LPUART_MATCH_ADDR_ONE => tgt_field = STAT.MA1F,
        LpuartStsType.LPUART_MATCH_ADDR_TWO => tgt_field = STAT.MA2F,
        else => unreachable,
    }
    return STAT.reg_ins_arr[index].getFieldValue(tgt_field) != 0;
}

/// Function Name : LPUART_HW_ClearStatusFlag
/// - Description : LPUART clears an individual status flag
/// (see lpuart_status_flag_t for list of status bits).
pub fn LPUART_HW_ClearStatusFlag(index: u2, sts_type: LpuartStsType) GenericSts {
    var tgt_field: RegT.FieldDef = undefined;
    switch (sts_type) {
        LpuartStsType.LPUART_TX_DATA_REG_EMPTY,
        LpuartStsType.LPUART_TX_COMPLETE,
        LpuartStsType.LPUART_RX_DATA_REG_FULL,
        LpuartStsType.LPUART_RX_ACTIVE,
        LpuartStsType.LPUART_NOISE_IN_CURRENT_WORD,
        LpuartStsType.LPUART_PARITY_ERR_IN_CURRENT_WORD,
        => {
            // These flags are cleared automatically by other lpuart operations
            // and cannot be manually cleared, return error code
            return GenericSts.STATUS_ERROR;
        },
        LpuartStsType.LPUART_FIFO_TX_OF => {
            FIFO.reg_ins_arr[index].updateFieldValue(FIFO.TXOF, 0);
            return GenericSts.STATUS_SUCCESS;
        },
        LpuartStsType.LPUART_FIFO_RX_UF => {
            FIFO.reg_ins_arr[index].updateFieldValue(FIFO.RXUF, 0);
            return GenericSts.STATUS_SUCCESS;
        },
        LpuartStsType.LPUART_IDLE_LINE_DETECT => tgt_field = STAT.IDLE,
        LpuartStsType.LPUART_RX_OVERRUN => tgt_field = STAT.OR,
        LpuartStsType.LPUART_NOISE_DETECT => tgt_field = STAT.NF,
        LpuartStsType.LPUART_FRAME_ERR => tgt_field = STAT.FE,
        LpuartStsType.LPUART_PARITY_ERR => tgt_field = STAT.PF,
        LpuartStsType.LPUART_LIN_BREAK_DETECT => tgt_field = STAT.LBKDIF,
        LpuartStsType.LPUART_RX_ACTIVE_EDGE_DETECT => tgt_field = STAT.RXEDGIF,
        LpuartStsType.LPUART_MATCH_ADDR_ONE => tgt_field = STAT.MA1F,
        LpuartStsType.LPUART_MATCH_ADDR_TWO => tgt_field = STAT.MA2F,
        else => unreachable,
    }
    STAT.reg_ins_arr[index].updateFieldValue(tgt_field, 0);
    return GenericSts.STATUS_SUCCESS;
}

/// Function Name : LPUART_HW_SetErrorInterrupts
/// Description   : Enable or disable the LPUART error interrupts.
pub fn LPUART_HW_SetErrorInterrupts(index: u2, enabled: u1) void {
    LPUART_HW_SetInterruptMode(index, enabled, LpuartInterruptType.LPUART_INT_RX_OVERRUN);
    LPUART_HW_SetInterruptMode(index, enabled, LpuartInterruptType.LPUART_INT_PARITY_ERR_FLAG);
    LPUART_HW_SetInterruptMode(index, enabled, LpuartInterruptType.LPUART_INT_NOISE_ERR_FLAG);
    LPUART_HW_SetInterruptMode(index, enabled, LpuartInterruptType.LPUART_INT_FRAME_ERR_FLAG);
}

/// Enable (1) or Disable (0) Both Edge Sampling
pub fn LPUART_HW_EnableBothEdgeSamplingCmd(index: u2) void {
    BAUD.reg_ins_arr[index].updateFieldValue(BAUD.BOTHEDGE, 1);
}

/// Set the oversampling ratio osr
pub fn LPUART_HW_SetOversamplingRatio(index: u2, overSample_ratio: u32) void {
    BAUD.reg_ins_arr[index].updateFieldValue(BAUD.OSR, overSample_ratio);
}

pub fn LPUART_HW_SetStopBitCount(index: u2, stop_bit_t: LpuartStopCnt) void {
    BAUD.reg_ins_arr[index].updateFieldValue(BAUD.SBNS, @intFromEnum(stop_bit_t));
}

/// enable Enable(true) or disable(false) transmitter.
pub fn LPUART_HW_SetTransmitterCmd(index: u2, enabled: u1) void {
    // Wait for the register write operation to write the correct value
    while (CTRL.reg_ins_arr[index].getFieldValue(CTRL.TE) != enabled) {
        CTRL.reg_ins_arr[index].updateFieldValue(CTRL.TE, enabled);
    }
}

pub fn LPUART_HW_SetReceiverCmd(index: u2, enabled: u1) void {
    while (CTRL.reg_ins_arr[index].getFieldValue(CTRL.RE) != enabled) {
        CTRL.reg_ins_arr[index].updateFieldValue(CTRL.RE, enabled);
    }
}

/// This function clears the error flags treated by the driver.
pub fn LPUART_HW_ClearErrorFlags(index: u2) void {
    if (index > 2) return;
    STAT.reg_ins_arr[index].updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = STAT.OR, .field_value = 0 },
        FieldSet{ .field_def = STAT.NF, .field_value = 0 },
        FieldSet{ .field_def = STAT.FE, .field_value = 0 },
        FieldSet{ .field_def = STAT.PF, .field_value = 0 },
    });
}

pub fn LPUART_HW_SetBreakCharTransmitLength(
    index: u2,
    break_len: LpuartBreakCharLenType,
) void {
    if (index > 2) return;
    STAT.reg_ins_arr[index].updateFieldValue(STAT.BRK13, @intFromEnum(break_len));
}

pub fn LPUART_HW_SetBreakCharDetectLength(
    index: u2,
    break_len: LpuartBreakCharLenType,
) void {
    if (index > 2) return;
    STAT.reg_ins_arr[index].updateFieldValue(STAT.LBKDE, @intFromEnum(break_len));
}

/// Returns whether the receive data is inverted or not.
/// - This function returns the polarity of the receive data.
/// - 获取rx接收数据的极性
pub fn LPUART_HW_GetRxDataPolarity(index: u2) bool {
    if (index > 2) return false;
    return (STAT.reg_ins_arr[index].getFieldValue(STAT.RXINV) > 0);
}

/// Sets whether the recevie data is inverted or not.
/// - This function sets the polarity of the receive data.
pub fn LPUART_HW_SetRxDataPolarity(index: u2, is_polarity: u1) void {
    if (index > 2) return;
    STAT.reg_ins_arr[index].updateFieldValue(STAT.RXINV, is_polarity);
}

/// LPUART transmit sends break character configuration.
/// - This function sets break character transmission in queue mode.
pub fn LPUART_HW_QueueBreakField(index: u2) void {
    // 0x2000
    // 0010 0000 0000 0000
    DATA.reg_ins_arr[index].setRaw(0x2000);
}
