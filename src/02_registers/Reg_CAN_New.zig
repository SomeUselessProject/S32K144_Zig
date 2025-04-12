//! Created by Weng
//! - 2025/02/24
//! - New CAN Registers

const RegType = @import("./RegType.zig");
const can0_base_address: u32 = 0x4002_4000;
const can1_base_address: u32 = 0x4002_5000;
const can2_base_address: u32 = 0x4002_B000;

/// Module Configuration Register
/// - reset value is 0xD890_000F
pub const CAN_MCM = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0x00),
        RegType.RegIns.init(can1_base_address + 0x00),
        RegType.RegIns.init(can2_base_address + 0x00),
    };

    /// [0..6]
    /// - Number Of The Last Message Buffer
    pub const MAXM = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 7,
    };
    /// [8..9] ID Acceptance Mode
    /// - 0b00 - One full ID (standard and extended) per ID Filter Table element.
    /// - 0b01 - Two full standard IDs or two partial 14-bit
    /// (standard and extended) IDs per ID Filter Table element.
    /// - 0b10 - Four partial 8-bit Standard IDs per ID Filter Table element.
    /// - 0b11 - All frames rejected.
    pub const IDAM = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 2,
    };
    /// [11]
    /// - CAN FD operation enable
    /// - 1 CAN FD is enabled. FlexCAN is able to receive and transmit messages in both CAN FD and CAN 2.0 formats.
    /// - 0 CAN FD is disabled. FlexCAN is able to receive and transmit messages in CAN 2.0 format.
    pub const FDEN = RegType.FieldDef{
        .bit_start = 11,
        .bit_len = 1,
    };
    /// [12] Abort Enable
    /// - 0 Abort disabled
    /// - 1 Abort enabled.
    pub const ABEN = RegType.FieldDef{
        .bit_start = 12,
        .bit_len = 1,
    };
    /// [13] Local Priority Enable
    /// - 0 Local Priority disabled
    /// - 1 Local Priority enabled
    pub const LPRIOEN = RegType.FieldDef{
        .bit_start = 13,
        .bit_len = 1,
    };
    /// [14] Pretended Networking Enable
    /// - 0 Pretended Networking mode is disabled.
    /// - 1 Pretended Networking mode is enabled.
    pub const PNET_EN = RegType.FieldDef{
        .bit_start = 14,
        .bit_len = 1,
    };
    /// [15] DMA Enable
    /// - 0 DMA feature for RX FIFO disabled.
    /// - 1 DMA feature for RX FIFO enabled.
    pub const DMA = RegType.FieldDef{
        .bit_start = 15,
        .bit_len = 1,
    };
    /// [16] Individual Rx Masking And Queue Enable
    /// - 0 Individual Rx masking and queue feature are disabled. For
    /// backward compatibility with legacy applications, the
    /// reading of C/S word locks the MB even if it is EMPTY.
    /// - 1 Individual Rx masking and queue feature are enabled.
    pub const IRMQ = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 1,
    };
    /// [17] Self Reception Disable
    /// - 0 Self reception enabled.
    /// - 1 Self reception disabled.
    pub const SRXDIS = RegType.FieldDef{
        .bit_start = 17,
        .bit_len = 1,
    };

    /// [20] Low-Power Mode Acknowledge
    /// - 0 FlexCAN is not in a low-power mode.
    /// - 1 FlexCAN is in a low-power mode.
    pub const LPMACK = RegType.FieldDef{
        .bit_start = 20,
        .bit_len = 1,
    };
    /// [21] Warning Interrupt Enable
    /// - 0 TWRNINT and RWRNINT bits are zero, independent of the
    /// values in the error counters.
    /// - 1 TWRNINT and RWRNINT bits are set when the respective error
    /// counter transitions from less than 96 to greater than or equal to 96.
    pub const WRNEN = RegType.FieldDef{
        .bit_start = 21,
        .bit_len = 1,
    };

    /// [23] Supervisor Mode
    pub const SUPV = RegType.FieldDef{
        .bit_start = 23,
        .bit_len = 1,
    };
    /// [24] Freeze Mode Acknowledge
    /// - 0 FlexCAN not in Freeze mode, prescaler running.
    /// - 1 FlexCAN in Freeze mode, prescaler stopped.
    pub const FRZACK = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 1,
    };
    /// [25] Soft Reset
    /// - 0 No reset request
    /// - 1 Resets the registers affected by soft reset.
    pub const SOFTRST = RegType.FieldDef{
        .bit_start = 25,
        .bit_len = 1,
    };
    /// [27] FlexCAN Not Ready
    /// - 0 FlexCAN module is either in Normal mode, Listen-Only mode or
    /// Loop-Back mode.
    pub const NOTRDY = RegType.FieldDef{
        .bit_start = 27,
        .bit_len = 1,
    };
    /// [28] Halt FlexCAN
    /// - 0 No Freeze mode request.
    /// - 1 Enters Freeze mode if the FRZ bit is asserted.
    pub const HALT = RegType.FieldDef{
        .bit_start = 28,
        .bit_len = 1,
    };
    /// [29] Rx FIFO Enable
    /// - 0 Rx FIFO not enabled.
    /// - 1 Rx FIFO enabled.
    pub const RFEN = RegType.FieldDef{
        .bit_start = 29,
        .bit_len = 1,
    };
    /// [30] Freeze Enable
    /// - 0 Not enabled to enter Freeze mode.
    /// - 1 Enabled to enter Freeze mode.
    pub const FRZ = RegType.FieldDef{
        .bit_start = 30,
        .bit_len = 1,
    };
    /// [31] Module Disable
    /// - 0 Enable the FlexCAN module.
    /// - 1 Disable the FlexCAN module.
    pub const MDIS = RegType.FieldDef{
        .bit_start = 31,
        .bit_len = 1,
    };
};

/// Control 1 register
/// - address offset is 0x4
/// - reset value is 0
pub const CAN_CTRL1 = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0x04),
        RegType.RegIns.init(can1_base_address + 0x04),
        RegType.RegIns.init(can2_base_address + 0x04),
    };
    /// [0..2] Propagation Segment
    pub const PROPSEG = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 3,
    };
    /// [3] Listen-Only Mode
    /// - 0 Listen-Only mode is deactivated.
    /// - 1 FlexCAN module operates in Listen-Only mode.
    pub const LOM = RegType.FieldDef{
        .bit_start = 3,
        .bit_len = 1,
    };
    /// [4] Lowest Buffer Transmitted First
    /// - 0 Buffer with highest priority is transmitted first.
    /// - 1 Lowest number buffer is transmitted first.
    pub const LBUF = RegType.FieldDef{
        .bit_start = 4,
        .bit_len = 1,
    };
    /// [5] Timer Sync
    /// - 0 Timer Sync feature disabled
    /// - 1 Timer Sync feature enabled
    pub const TSYN = RegType.FieldDef{
        .bit_start = 5,
        .bit_len = 1,
    };
    /// [6] Bus Off Recovery
    /// - 0 Automatic recovering from Bus Off state enabled.
    /// - 1 Automatic recovering from Bus Off state disabled.
    pub const BOFFREC = RegType.FieldDef{
        .bit_start = 6,
        .bit_len = 1,
    };
    /// [7] CAN Bit Sampling
    /// - 0 Just one sample is used to determine the bit value.
    /// - 1 Three samples are used to determine the value of the
    /// received bit: the regular one (sample point) and 2
    /// preceding samples; a majority rule is used.
    pub const SMP = RegType.FieldDef{
        .bit_start = 7,
        .bit_len = 1,
    };

    /// [10] Rx Warning Interrupt Mask
    /// - 0 Rx Warning Interrupt disabled.
    /// - 1 Rx Warning Interrupt enabled.
    pub const RWRNMSK = RegType.FieldDef{
        .bit_start = 10,
        .bit_len = 1,
    };
    /// [11] Tx Warning Interrupt Mask
    /// - 0 Tx Warning Interrupt disabled.
    /// - 1 Tx Warning Interrupt enabled.
    pub const TWRNMSK = RegType.FieldDef{
        .bit_start = 11,
        .bit_len = 1,
    };
    /// [12] Loop Back Mode
    /// - 0 Loop Back disabled.
    /// - 1 Loop Back enabled.
    pub const LPB = RegType.FieldDef{
        .bit_start = 12,
        .bit_len = 1,
    };
    /// [13] CAN Engine Clock Source
    /// - 0 The CAN engine clock source is the oscillator clock.(SOSCDIV2)
    /// Under this condition, the oscillator clock frequency must be
    /// lower than the bus clock.
    /// - 1 The CAN engine clock source is the peripheral clock.
    pub const CLKSRC = RegType.FieldDef{
        .bit_start = 13,
        .bit_len = 1,
    };
    /// [14] Error Interrupt Mask
    /// - 0 Error interrupt disabled.
    /// - 1 Error interrupt enabled.
    pub const ERRMSK = RegType.FieldDef{
        .bit_start = 14,
        .bit_len = 1,
    };
    /// [15] Bus Off Interrupt Mask
    /// - 0 Bus Off interrupt disabled.
    /// - 1 Bus Off interrupt enabled.
    pub const BOFFMSK = RegType.FieldDef{
        .bit_start = 15,
        .bit_len = 1,
    };
    /// [16..18] Phase Segment 2
    pub const PSEG2 = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 3,
    };
    /// [19..21] Phase Segment 1
    pub const PSEG1 = RegType.FieldDef{
        .bit_start = 19,
        .bit_len = 3,
    };
    /// [22..23] Resync Jump Width
    pub const RJW = RegType.FieldDef{
        .bit_start = 22,
        .bit_len = 2,
    };
    /// [24..31] Prescaler Division Factor
    pub const PRESDIV = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 8,
    };
};

/// Free Running Timer
/// - address value is 0x8
/// - reset value is 0
pub const CAN_TIMER = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0x08),
        RegType.RegIns.init(can1_base_address + 0x08),
        RegType.RegIns.init(can2_base_address + 0x08),
    };
    /// [0..15] Timer Value
    pub const TIMER = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 16,
    };
};

/// Rx Mailboxes Global Mask Register
/// - address offset is 0x10
/// - reset value is 0
pub const CAN_RXMGMASK_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0x10),
        RegType.RegIns.init(can1_base_address + 0x10),
        RegType.RegIns.init(can2_base_address + 0x10),
    };
    /// [0..31] Rx Mailboxes Global Mask Bits
    pub const MG = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 32,
    };
};

/// Rx 14 Mask register
/// - address offset is 0x14
/// - reset value is 0
pub const CAN_RX14MASK_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0x14),
        RegType.RegIns.init(can1_base_address + 0x14),
        RegType.RegIns.init(can2_base_address + 0x14),
    };
    /// [0..31] Rx Buffer 14 Mask Bits
    pub const RX14M = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 32,
    };
};

/// Rx 15 Mask register
/// - address offset is 0x18
/// - reset value is 0
pub const CAN_RX15MASK_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0x18),
        RegType.RegIns.init(can1_base_address + 0x18),
        RegType.RegIns.init(can2_base_address + 0x18),
    };
    /// [0..31] Rx Buffer 15 Mask Bits
    pub const RX15M = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 32,
    };
};

/// Error Counter
/// - address offset is 0x1C
/// - reset value is 0
pub const CAN_ECR_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0x1C),
        RegType.RegIns.init(can1_base_address + 0x1C),
        RegType.RegIns.init(can2_base_address + 0x1C),
    };
    /// [0..7] Transmit Error Counter
    pub const TXERRCNT = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 8,
    };
    /// [8..15] Receive Error Counter
    pub const RXERRCNT = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 8,
    };
    /// [16..23] Transmit Error Counter for fast bits
    pub const TXERRCNT_FAST = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 8,
    };
    /// [24..31] Receive Error Counter for fast bits
    pub const RXERRCNT_FAST = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 8,
    };
};

/// Error and Status 1 register
/// - address offset is 0x20
/// - reset value is 0
pub const CAN_ESR1_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0x20),
        RegType.RegIns.init(can1_base_address + 0x20),
        RegType.RegIns.init(can2_base_address + 0x20),
    };

    /// [1] Error Interrupt
    /// - 0 No such occurrence.
    /// - 1 Indicates setting of any Error Bit in the Error and Status Register.
    pub const ERRINT = RegType.FieldDef{
        .bit_start = 1,
        .bit_len = 1,
    };
    /// [2] Bus Off Interrupt
    ///  - 0 No such occurrence.
    ///  - 1 FlexCAN module entered Bus Off state.
    pub const BOFFINT = RegType.FieldDef{
        .bit_start = 2,
        .bit_len = 1,
    };
    /// [3] FlexCAN In Reception
    ///  - 0 FlexCAN is not receiving a message.
    ///  - 1 FlexCAN is receiving a message.
    pub const RX = RegType.FieldDef{
        .bit_start = 3,
        .bit_len = 1,
    };
    /// [4..5] Fault Confinement State
    /// - 00 Error Active
    /// - 01 Error Passive
    /// - 1x Bus Off
    pub const FLTCONF = RegType.FieldDef{
        .bit_start = 4,
        .bit_len = 2,
    };
    /// [6] FlexCAN In Transmission
    /// - 0 FlexCAN is not transmitting a message.
    /// - 1 FlexCAN is transmitting a message.
    pub const TX = RegType.FieldDef{
        .bit_start = 6,
        .bit_len = 1,
    };
    /// [7] IDLE descrip the bus is idle or not
    /// - 0 No such occurrence.
    /// - 1 CAN bus is now IDLE.
    pub const IDLE = RegType.FieldDef{
        .bit_start = 7,
        .bit_len = 1,
    };
    /// [8] Rx Error Warning
    /// - 0 No such occurrence.
    /// - 1 RXERRCNT is greater than or equal to 96.
    pub const RXWRN = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 1,
    };
    /// [9] TX Error Warning
    /// - 0 No such occurrence.
    /// - 1 TXERRCNT is greater than or equal to 96.
    pub const TXWRN = RegType.FieldDef{
        .bit_start = 9,
        .bit_len = 1,
    };
    /// [10] Stuffing Error
    /// - 0 No such occurrence
    /// - 1 A Stuffing Error occurred since last read of this register.
    pub const STFERR = RegType.FieldDef{
        .bit_start = 10,
        .bit_len = 1,
    };
    /// [11] Form Error
    /// - 0 No such occurrence.
    /// - 1 A Form Error occurred since last read of this register.
    pub const FRMERR = RegType.FieldDef{
        .bit_start = 11,
        .bit_len = 1,
    };
    /// [12] Cyclic Redundancy Check Error
    /// - 0 No such occurrence.
    /// - 1 A CRC error occurred since last read of this register.
    pub const CRCERR = RegType.FieldDef{
        .bit_start = 12,
        .bit_len = 1,
    };
    /// [13] Acknowledge Error
    /// - 0 No such occurrence.
    /// - 1 An ACK error occurred since last read of this register.
    pub const ACKERR = RegType.FieldDef{
        .bit_start = 13,
        .bit_len = 1,
    };
    /// [14] Bit0 Error
    /// - 0 No such occurrence.
    /// - 1 At least one bit sent as dominant is received as recessive.
    pub const BIT0ERR = RegType.FieldDef{
        .bit_start = 14,
        .bit_len = 1,
    };
    /// [15] Bit1 Error
    /// - 0 No such occurrence.
    /// - 1 At least one bit sent as recessive is received as dominant.
    pub const BIT1ERR = RegType.FieldDef{
        .bit_start = 15,
        .bit_len = 1,
    };
    /// [16] Rx Warning Interrupt Flag
    /// - 0 No such occurrence.
    /// - 1 The Rx error counter transitioned from less than 96 to greater than or equal to 96.
    pub const RWRNINT = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 1,
    };
    /// [17] Tx Warning Interrupt Flag
    /// - 0 No such occurrence.
    /// - 1 The Tx error counter transitioned from less than 96 to greater than or equal to 96.
    pub const TWRNINT = RegType.FieldDef{
        .bit_start = 17,
        .bit_len = 1,
    };
    /// [18] CAN Synchronization Status
    /// - 0 FlexCAN is not synchronized to the CAN bus.
    /// - 1 FlexCAN is synchronized to the CAN bus.
    pub const SYNCH = RegType.FieldDef{
        .bit_start = 18,
        .bit_len = 1,
    };
    /// [19] Bus Off Done Interrupt
    /// - 0 No such occurrence.
    /// - 1 FlexCAN module has completed Bus Off process.
    pub const BOFFDONEINT = RegType.FieldDef{
        .bit_start = 19,
        .bit_len = 1,
    };
    /// [20] Error Interrupt for errors detected in the Data Phase of CAN FD
    /// frames with the BRS bit set
    /// - 0 No such occurrence.
    /// - 1 Indicates setting of any Error Bit detected in the Data
    /// Phase of CAN FD frames with the BRS bit set.
    pub const ERRINT_FAST = RegType.FieldDef{
        .bit_start = 20,
        .bit_len = 1,
    };
    /// [21] Error Overrun bit
    /// - 0 Overrun has not occurred.
    /// - 1 Overrun has occurred.
    pub const ERROVR = RegType.FieldDef{
        .bit_start = 21,
        .bit_len = 1,
    };

    /// [26] Stuffing Error in the Data Phase of CAN FD frames with the BRS bit set
    /// - 0 No such occurrence.
    /// - 1 A Stuffing Error occurred since last read of this register.
    pub const STFERR_FAST = RegType.FieldDef{
        .bit_start = 26,
        .bit_len = 1,
    };
    /// [27] Form Error in the Data Phase of CAN FD frames with the BRS bit set
    /// - 0 No such occurrence.
    /// - 1 A Form Error occurred since last read of this register.
    pub const FRMERR_FAST = RegType.FieldDef{
        .bit_start = 27,
        .bit_len = 1,
    };
    /// [28] Cyclic Redundancy Check Error in the CRC field of CAN FD frames
    /// with the BRS bit set
    /// - 0 No such occurrence.
    /// - 1 A CRC error occurred since last read of this register.
    pub const CRCERR_FAST = RegType.FieldDef{
        .bit_start = 28,
        .bit_len = 1,
    };

    /// [30] Bit0 Error in the Data Phase of CAN FD frames with the BRS bit set
    /// - 0 No such occurrence.
    /// - 1 At least one bit sent as dominant is received as recessive.
    pub const BIT0ERR_FAST = RegType.FieldDef{
        .bit_start = 30,
        .bit_len = 1,
    };
    /// [31] Bit1 Error in the Data Phase of CAN FD frames with the BRS bit set
    /// - 0 No such occurrence.
    /// - 1 At least one bit sent as recessive is received as dominant.
    pub const BIT1ERR_FAST = RegType.FieldDef{
        .bit_start = 31,
        .bit_len = 1,
    };
};

/// Interrupt Masks 1 register
/// - address offset is 0x28
/// - reset value is 0
pub const CAN_IMASK1_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0x28),
        RegType.RegIns.init(can1_base_address + 0x28),
        RegType.RegIns.init(can2_base_address + 0x28),
    };
    /// [0..31] Buffer MB i Mask
    pub const BUF31TO0M = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 32,
    };
};

/// Interrupt Flags 1 register
/// - address offset is 0x30
/// - reset value is 0
pub const CAN_IFLAG1_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0x30),
        RegType.RegIns.init(can1_base_address + 0x30),
        RegType.RegIns.init(can2_base_address + 0x30),
    };
    /// [0] Buffer MB0 Interrupt Or Clear FIFO bit
    /// - 0 The corresponding buffer has no occurrence of successfully
    /// completed transmission or reception when MCR[RFEN]=0.
    /// - 1 The corresponding buffer has successfully completed
    /// transmission or reception when MCR[RFEN]=0.
    pub const BUF0I = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 1,
    };
    /// [1..4] Buffer MB i Interrupt Or "reserved"
    /// - 0b - The corresponding buffer has no occurrence of successfully completed transmission or
    /// reception when MCR[RFEN]=0.
    /// - 1b - The corresponding buffer has successfully completed transmission or reception when
    /// MCR[RFEN]=0.
    pub const BUF4TO1I = RegType.FieldDef{
        .bit_start = 1,
        .bit_len = 4,
    };
    /// [5] Buffer MB5 Interrupt Or "Frames available in Rx FIFO"
    /// - 0 No occurrence of MB5 completing transmission/reception
    /// when MCR[RFEN]=0, or of frame(s) available in the FIFO,
    /// when MCR[RFEN]=1
    /// - 1 MB5 completed transmission/reception when MCR[RFEN]=0, or
    /// frame(s) available in the Rx FIFO when MCR[RFEN]=1. It
    /// generates a DMA request in case of MCR[RFEN] and MCR[DMA] are enabled.
    pub const BUF5I = RegType.FieldDef{
        .bit_start = 5,
        .bit_len = 1,
    };
    /// [6] Buffer MB6 Interrupt Or "Rx FIFO Warning"
    /// - 0 No occurrence of MB6 completing transmission/reception
    /// when MCR[RFEN]=0, or of Rx FIFO almost full when MCR[RFEN]=1
    /// - 1 MB6 completed transmission/reception when MCR[RFEN]=0, or
    /// Rx FIFO almost full when MCR[RFEN]=1
    pub const BUF6I = RegType.FieldDef{
        .bit_start = 6,
        .bit_len = 1,
    };
    /// [7] Buffer MB7 Interrupt Or "Rx FIFO Overflow"
    /// - 0 No occurrence of MB7 completing transmission/reception
    /// when MCR[RFEN]=0, or of Rx FIFO overflow when MCR[RFEN]=1
    /// -1 MB7 completed transmission/reception when MCR[RFEN]=0, or
    /// Rx FIFO overflow when MCR[RFEN]=1
    pub const BUF7I = RegType.FieldDef{
        .bit_start = 7,
        .bit_len = 1,
    };
    /// [8..31] Buffer MBi Interrupt
    pub const BUF31TO8I = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 24,
    };
};

/// Control 2 register
/// - address offset is 0x34
/// - reset value is 0
pub const CAN_CTRL2_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0x34),
        RegType.RegIns.init(can1_base_address + 0x34),
        RegType.RegIns.init(can2_base_address + 0x34),
    };

    /// [11] Edge Filter Disable
    /// - 0 Edge Filter is enabled.
    /// - 1 Edge Filter is disabled.
    pub const EDFLTDIS = RegType.FieldDef{
        .bit_start = 11,
        .bit_len = 1,
    };
    /// [12] ISO CAN FD Enable
    /// - 0 FlexCAN operates using the non-ISO CAN FD protocol.
    /// - 1 FlexCAN operates using the ISO CAN FD protocol (ISO 11898-1).
    pub const ISOCANFDEN = RegType.FieldDef{
        .bit_start = 12,
        .bit_len = 1,
    };

    /// [14] Protocol Exception Enable
    /// - 0 Protocol Exception is disabled.
    /// - 1 Protocol Exception is enabled.
    pub const PREXCEN = RegType.FieldDef{
        .bit_start = 14,
        .bit_len = 1,
    };
    /// [15] Timer Source
    /// - 0 - The Free Running Timer is clocked by the CAN bit clock,
    /// which defines the baud rate on the CAN bus.
    /// - 1 The Free Running Timer is clocked by an external time
    /// tick. The period can be either adjusted to be equal to the
    /// baud rate on the CAN bus, or a different value as
    /// required. See the device specific section for details
    /// about the external time tick.
    pub const TIMER_SRC = RegType.FieldDef{
        .bit_start = 15,
        .bit_len = 1,
    };
    /// [16] Entire Frame Arbitration Field Comparison Enable For Rx Mailboxes
    /// - 0 Rx Mailbox filter's IDE bit is always compared and RTR is
    /// never compared despite mask bits.
    /// - 1 Enables the comparison of both Rx Mailbox filter's IDE and
    /// RTR bit with their corresponding bits within the incoming
    /// frame. Mask bits do apply.
    pub const EACEN = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 1,
    };
    /// [17] Remote Request Storing
    /// - 0 Remote Response Frame is generated.
    /// - 1 Remote Request Frame is stored.
    pub const RRS = RegType.FieldDef{
        .bit_start = 17,
        .bit_len = 1,
    };
    /// [18] Mailboxes Reception Priority
    /// - 0 Matching starts from Rx FIFO and continues on Mailboxes.
    /// - 1 Matching starts from Mailboxes and continues on Rx FIFO.
    pub const MRP = RegType.FieldDef{
        .bit_start = 18,
        .bit_len = 1,
    };
    /// [19..23] Tx Arbitration Start Delay
    pub const TASD = RegType.FieldDef{
        .bit_start = 19,
        .bit_len = 5,
    };
    /// [24..27] Number Of Rx FIFO Filters
    pub const RFFN = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 4,
    };
    /// [30] Bus Off Done Interrupt Mask
    /// - 0 Bus Off Done interrupt disabled.
    /// - 1 Bus Off Done interrupt enabled.
    pub const BOFFDONEMSK = RegType.FieldDef{
        .bit_start = 30,
        .bit_len = 1,
    };
    /// [31] Error Interrupt Mask for errors detected in the Data Phase of
    /// fast CAN FD frames
    /// - 0 ERRINT_FAST Error interrupt disabled.
    /// - 1 ERRINT_FAST Error interrupt enabled.
    pub const ERRMSK_FAST = RegType.FieldDef{
        .bit_start = 31,
        .bit_len = 1,
    };
};

/// Error and Status 2 register
/// - address offset 0x38
/// - reset value is 0
pub const CAN_ESR2_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0x38),
        RegType.RegIns.init(can1_base_address + 0x38),
        RegType.RegIns.init(can2_base_address + 0x38),
    };

    /// [13] Inactive Mailbox
    /// - 0  If ESR2[VPS] is asserted, the ESR2[LPTM] is not an inactive Mailbox.
    /// - 1  If ESR2[VPS] is asserted, there is at least one inactive
    /// Mailbox. LPTM content is the number of the first one.
    pub const IMB = RegType.FieldDef{
        .bit_start = 13,
        .bit_len = 1,
    };
    /// [14] Valid Priority Status
    /// - 0 Contents of IMB and LPTM are invalid.
    /// - 1 Contents of IMB and LPTM are valid.
    pub const VPS = RegType.FieldDef{
        .bit_start = 14,
        .bit_len = 1,
    };
    /// [16..22] Lowest Priority Tx Mailbox
    pub const LPTM = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 7,
    };
};

/// CRC Register
/// - address offset is 0x44
/// - reset value is 0
pub const CRCR_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0x44),
        RegType.RegIns.init(can1_base_address + 0x44),
        RegType.RegIns.init(can2_base_address + 0x44),
    };
    /// [0..14] Transmitted CRC value
    pub const TXCRC = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 15,
    };
    /// [16..22] CRC Mailbox
    pub const MBCRC = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 7,
    };
};

/// Rx FIFO Global Mask register
/// - address offset is 0x48
/// - reset value is 0
pub const CAN_RXFGMASK_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0x48),
        RegType.RegIns.init(can1_base_address + 0x48),
        RegType.RegIns.init(can2_base_address + 0x48),
    };
    /// [0..31] Rx FIFO Global Mask Bits
    pub const FGM = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 32,
    };
};

/// Rx FIFO Information Register
/// - address offset is 0x4c
/// - reset value is 0
pub const CAN_RXFIR_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0x4C),
        RegType.RegIns.init(can1_base_address + 0x4C),
        RegType.RegIns.init(can2_base_address + 0x4C),
    };
    /// [0..8] Identifier Acceptance Filter Hit Indicator
    pub const IDHIT = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 9,
    };
};

/// CAN Bit Timing Register
/// - address offset is 0x50
/// - reset value is 0
pub const CAN_CBT_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0x50),
        RegType.RegIns.init(can1_base_address + 0x50),
        RegType.RegIns.init(can2_base_address + 0x50),
    };
    /// [0..4] Extended Phase Segment 2
    pub const EPSEG2 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 5,
    };
    /// [5..9] Extended Phase Segment 1
    pub const EPSEG1 = RegType.FieldDef{
        .bit_start = 5,
        .bit_len = 5,
    };
    /// [10..15] Extended Propagation Segment
    pub const EPROPSEG = RegType.FieldDef{
        .bit_start = 10,
        .bit_len = 6,
    };
    /// [16..20] Extended Resync Jump Width
    pub const ERJW = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 5,
    };
    /// [21..30] Extended Prescaler Division Factor
    pub const EPRESDIV = RegType.FieldDef{
        .bit_start = 21,
        .bit_len = 10,
    };
    /// [31] Bit Timing Format Enable
    /// - 0 Extended bit time definitions disabled.
    /// - 1 Extended bit time definitions enabled.
    pub const BTF = RegType.FieldDef{
        .bit_start = 31,
        .bit_len = 1,
    };
};

/// Embedded RAM
/// - CAN0 512 byte / CAN1 and CAN2 256 byte
/// - address offset start is 0x80
/// - align 4
/// - reset value is 0
/// - range from RAMn0 - 127; total count is 128 can0
/// - range from RAMn0 - 63 ; total count is 64 can1 and can2
pub const CAN_RAMn_REGS = struct {
    pub const can0_regs: [128]RegType.RegIns = RegType.RegIns.initRange(
        can0_base_address + 0x80,
        0x4,
        128,
    );
    pub const can1_regs: [64]RegType.RegIns = RegType.RegIns.initRange(
        can1_base_address + 0x80,
        0x4,
        64,
    );
    pub const can2_regs: [64]RegType.RegIns = RegType.RegIns.initRange(
        can2_base_address + 0x80,
        0x4,
        64,
    );

    // data define part -------------------------------------------
    pub const DataSt = struct {
        /// [0..7] Data byte 4N + 3 of Rx/Tx frame.
        pub const DATA_BYTE_N4Add3 = RegType.FieldDef{
            .bit_start = 0,
            .bit_len = 8,
        };
        /// [8..15] Data byte N4 + 2 of Rx/Tx frame.
        pub const DATA_BYTE_N4Add2 = RegType.FieldDef{
            .bit_start = 8,
            .bit_len = 8,
        };
        /// [16..23] Data byte N4 + 1 of Rx/Tx frame.
        pub const DATA_BYTE_N4Add1 = RegType.FieldDef{
            .bit_start = 16,
            .bit_len = 8,
        };
        /// [24..31] Data byte N4 + 0 of Rx/Tx frame.
        pub const DATA_BYTE_N4Add0 = RegType.FieldDef{
            .bit_start = 24,
            .bit_len = 8,
        };
    };

    // first header define part ----------------------------------
    /// The fisrt header fields define structure
    pub const Hd1St = struct {
        /// [0..15]
        pub const TIME_STAMP = RegType.FieldDef{
            .bit_start = 0,
            .bit_len = 16,
        };
        /// [16..19] CAN Mesage data length
        /// - 0 none
        /// - 1-8 len 1-8
        /// - 9 len 12
        /// - 10 len 16
        /// - 11 len 20
        /// - 12 len 24
        /// - 13 len 32
        /// - 14 len 48
        /// - 15 len 64
        pub const DLC = RegType.FieldDef{
            .bit_start = 16,
            .bit_len = 4,
        };
        /// [20] Remote Transmission Request
        /// - This bit affects the behavior of remote frames and is part of the reception filter. See Table
        /// 55-27, Table 55-28, and the description of the RRS field in Control 2 register (CTRL2)
        ///for additional details.
        ///If FlexCAN transmits this bit as '1' (recessive) and receives it as '0' (dominant), it is
        ///interpreted as an arbitration loss. If this bit is transmitted as '0' (dominant), then if it is
        ///received as '1' (recessive), the FlexCAN module treats it as a bit error. If the value
        ///received matches the value transmitted, it is considered a successful bit transmission.
        /// - 1 = Indicates the current MB may have a remote request frame to be transmitted if MB is
        /// Tx. If the MB is Rx then incoming remote request frames may be stored.
        /// - 0 = Indicates the current MB has a data frame to be transmitted. In Rx MB it may be
        /// considered in matching processes.
        pub const RTR = RegType.FieldDef{
            .bit_start = 20,
            .bit_len = 1,
        };
        /// [21] ID Extended Bit
        /// This field identifies whether the frame format is standard or extended.
        /// - 1 = Frame format is extended
        /// - 0 = Frame format is standard
        pub const IDE = RegType.FieldDef{
            .bit_start = 21,
            .bit_len = 1,
        };
        /// [22]  Substitute Remote Request
        /// Fixed recessive bit, used only in extended format. **It must be set to one by the user for
        /// transmission (Tx Buffers) and will be stored with the value received on the CAN bus for
        /// Rx receiving buffers**. It can be received as either recessive or dominant. If FlexCAN
        /// receives this bit as dominant, then it is interpreted as an arbitration loss.
        /// - 1 = Recessive value is compulsory for transmission in extended format frames
        /// - 0 = Dominant is not a valid value for transmission in extended format frames
        pub const SRR = RegType.FieldDef{
            .bit_start = 22,
            .bit_len = 1,
        };
        /// [24..27] Message Buffer Code
        /// - This 4-bit field can be accessed (read or write) by the CPU and by the FlexCAN module
        /// itself, as part of the message buffer matching and arbitration process. The encoding is
        /// shown in Table 55-27 and Table 55-28. See Functional description for additional
        /// information.
        /// ***
        /// - **For rx buffer**
        /// - 0b0000 :0 INACTIVE — MB is not active
        /// - 0b0100 :4 EMPTY — MB is active and empty.
        /// - 0b0010 :2 FULL
        /// - 0b0110 :6 OVERRUN MB is being overwritten into a full buffer.
        /// - 0b1010 :10 RANSWER4 — A frame was configured to recognize a Remote Request frame and transmit
        /// a Response frame in return
        /// - 0b0001 :1 BUSY — FlexCAN is updating the contents of the MB.
        /// The CPU must not access the MB.
        /// ***
        /// - **For TX Buffer**
        /// - 1000 : 8 INACTIVE
        /// - 1001 : 9 ABORT - MB is aborted
        /// - 1100 : 12 DATA - MB is a Tx data frame (MB RTR must be 0)
        /// - 1100 : 12 REMOTE - MB is a Tx Remote Request frame (MB RTR must be 1)
        /// - 1110 : 14 TANSWER — MB is a Tx Response frame from an incoming Remote Request frame
        pub const CODE = RegType.FieldDef{
            .bit_start = 24,
            .bit_len = 4,
        };
        /// [29] Error State Indicator
        /// - This bit indicates if the transmitting node is error active or error passive.
        pub const ESI = RegType.FieldDef{
            .bit_start = 29,
            .bit_len = 1,
        };
        /// [30] Bit Rate Switch
        /// - This bit defines whether the bit rate is switched inside a CAN FD format frame.
        /// - 0 close speed up
        /// - 1 start speed up
        pub const BRS = RegType.FieldDef{
            .bit_start = 30,
            .bit_len = 1,
        };
        /// [31] Extended Data Length
        /// - **distinguishes between CAN format and CAN FD format**
        /// - This bit distinguishes between CAN format and CAN FD format frames. The EDL bit
        /// must not be set for message buffers configured to RANSWER with code field 1010b
        pub const EDL = RegType.FieldDef{
            .bit_start = 31,
            .bit_len = 1,
        };
    };

    /// The second header fileds define in a can mailbox
    pub const Hd2St = struct {
        /// [0..17]
        pub const ID_EXTEND = RegType.FieldDef{
            .bit_start = 0,
            .bit_len = 18,
        };
        /// [18..28]
        pub const ID_STD = RegType.FieldDef{
            .bit_start = 18,
            .bit_len = 11,
        };
        /// [29..31] Local priority
        /// - This 3-bit field is used only when MCR[LPRIO_EN] is set, and it only makes sense for
        /// Tx mailboxes. These bits are not transmitted. They are appended to the regular ID to
        /// define the transmission priority. See Arbitration process.
        pub const PRIO = RegType.FieldDef{
            .bit_start = 29,
            .bit_len = 3,
        };
    };
};

/// Rx Individual Mask Registers
/// - address offset is 0x880
/// - align 4
/// - reset value is 0
/// - range from 0 - 31
pub const CAN_RXIMR_REGS = struct {
    pub const can0_regs: [32]RegType.RegIns = RegType.RegIns.initRange(
        can0_base_address + 0x880,
        0x4,
        32,
    );
    pub const can1_regs: [16]RegType.RegIns = RegType.RegIns.initRange(
        can1_base_address + 0x880,
        0x4,
        16,
    );
    pub const can2_regs: [16]RegType.RegIns = RegType.RegIns.initRange(
        can2_base_address + 0x880,
        0x4,
        16,
    );
    /// [0..31] Individual Mask Bits
    pub const MI = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 32,
    };
};

/// Pretended Networking Control 1 Register
/// - address offset is 0xB00
/// - reset value is 0
pub const CAN_CTRL1_PN = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0xB00),
        RegType.RegIns.init(can1_base_address + 0xB00),
        RegType.RegIns.init(can2_base_address + 0xB00),
    };
    /// [0..1] Filtering Combination Selection
    /// - 00 Message ID filtering only
    /// - 01 Message ID filtering and payload filtering
    /// - 10 Message ID filtering occurring a specified number of times.
    /// - 11 Message ID filtering and payload filtering a specified number of times
    pub const FCS = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 2,
    };
    /// [2..3] ID Filtering Selection
    /// - 00 Match upon a ID contents against an exact target value
    /// - 01 Match upon a ID value greater than or equal to a specified target value
    /// - 10 Match upon a ID value smaller than or equal to a specified target value
    /// - 11 Match upon a ID value inside a range, greater than or
    /// equal to a specified lower limit and smaller than or equal
    /// a specified upper limit
    pub const IDFS = RegType.FieldDef{
        .bit_start = 2,
        .bit_len = 2,
    };
    /// [4..5] Payload Filtering Selection
    /// - 00 Match upon a payload contents against an exact target value
    /// - 01 Match upon a payload value greater than or equal to a specified target value
    /// - 10 Match upon a payload value smaller than or equal to a
    /// specified target value
    /// - 11 Match upon a payload value inside a range, greater than or
    /// equal to a specified lower limit and smaller than or equal
    /// a specified upper limit
    pub const PLFS = RegType.FieldDef{
        .bit_start = 4,
        .bit_len = 2,
    };
    /// [8..15] Number of Messages Matching the Same Filtering Criteria
    /// - 00000001 Received message must match the predefined filtering
    /// criteria for ID and/or PL once before generating a wake up event.
    /// - 00000010 Received message must match the predefined filtering
    /// criteria for ID and/or PL twice before generating a wake up event.
    /// - 11111111 Received message must match the predefined filtering
    /// criteria for ID and/or PL 255 times before generating a wake up event.
    pub const NMATCH = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 8,
    };
    /// [16] Wake Up by Match Flag Mask Bit
    /// - 0 Wake up match event is disabled
    /// - 1 Wake up match event is enabled
    pub const WUMF_MSK = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 1,
    };
    /// [17] Wake Up by Timeout Flag Mask Bit
    /// - 0 Timeout wake up event is disabled
    /// - 1 Timeout wake up event is enabled
    pub const WTOF_MSK = RegType.FieldDef{
        .bit_start = 17,
        .bit_len = 1,
    };
};

/// Pretended Networking Control 2 Register
/// - address offset is 0xB04
/// - reset value is 0
const CAN_CTRL2_PN = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0xB04),
        RegType.RegIns.init(can1_base_address + 0xB04),
        RegType.RegIns.init(can2_base_address + 0xB04),
    };
    /// [0..15] Timeout for No Message Matching the Filtering Criteria
    pub const MATCHTO = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 16,
    };
};

/// Pretended Networking Wake Up Match Register
/// - address offset is 0xB08
/// - reset value is 0
pub const WU_MTC_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0xB08),
        RegType.RegIns.init(can1_base_address + 0xB08),
        RegType.RegIns.init(can2_base_address + 0xB08),
    };
    /// [8..15] Number of Matches while in Pretended Networking
    pub const MCOUNTER = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 8,
    };
    /// [16] Wake Up by Match Flag Bit
    /// - 0 No wake up by match event detected
    /// - 1 Wake up by match event detected
    pub const WUMF = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 1,
    };
    /// [17] Wake Up by Timeout Flag Bit
    /// - 0 No wake up by timeout event detected
    /// - 1 Wake up by timeout event detected
    pub const WTOF = RegType.FieldDef{
        .bit_start = 17,
        .bit_len = 1,
    };
};

/// Pretended Networking ID Filter 1 Register
/// - address offset is 0xB0C
/// - reset value is 0
pub const FLT_ID1_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0xB0C),
        RegType.RegIns.init(can1_base_address + 0xB0C),
        RegType.RegIns.init(can2_base_address + 0xB0C),
    };
    /// [0..28] ID Filter 1 for Pretended Networking filtering
    pub const FLT_ID1 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 29,
    };
    /// [29] Remote Transmission Request Filter
    /// - 0 Reject remote frame (accept data frame)
    /// - 1 Accept remote frame
    pub const FLT_RTR = RegType.FieldDef{
        .bit_start = 29,
        .bit_len = 1,
    };
    /// [30] ID Extended Filter
    /// - 0 Accept standard frame format
    /// - 1 Accept extended frame format
    pub const FLT_IDE = RegType.FieldDef{
        .bit_start = 30,
        .bit_len = 1,
    };
};

/// Pretended Networking DLC Filter Register
/// - address offset is 0xB10
/// - reset value is 0x8
pub const FLT_DLC_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0xB10),
        RegType.RegIns.init(can1_base_address + 0xB10),
        RegType.RegIns.init(can2_base_address + 0xB10),
    };
    /// [0..3] Upper Limit for Length of Data Bytes Filter
    pub const FLT_DLC_HI = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 4,
    };
    /// [16..19] Lower Limit for Length of Data Bytes Filter
    pub const FLT_DLC_LO = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 4,
    };
};

/// Pretended Networking Payload Low Filter 1 Register
/// - address offset is 0xB14
/// - reset value is 0
pub const PL1_LO_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0xB14),
        RegType.RegIns.init(can1_base_address + 0xB14),
        RegType.RegIns.init(can2_base_address + 0xB14),
    };
    /// [0..7] Payload Filter 1 low order bits for Pretended Networking payload
    /// filtering corresponding to the data byte 3.
    pub const Data_byte_3 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 8,
    };
    /// [8..15] Payload Filter 1 low order bits for Pretended Networking payload
    /// filtering corresponding to the data byte 2.
    pub const Data_byte_2 = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 8,
    };
    /// [16..23] Payload Filter 1 low order bits for Pretended Networking payload
    /// filtering corresponding to the data byte 1.
    pub const Data_byte_1 = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 8,
    };
    /// [24..31] Payload Filter 1 low order bits for Pretended Networking payload
    /// filtering corresponding to the data byte 0.
    pub const Data_byte_0 = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 8,
    };
};

/// Pretended Networking Payload High Filter 1 Register
/// - address offset is 0xB18
/// - reset value is 0
pub const PL1_HI_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0xB18),
        RegType.RegIns.init(can1_base_address + 0xB18),
        RegType.RegIns.init(can2_base_address + 0xB18),
    };
    /// [0..7] Payload Filter 1 high order bits for Pretended Networking
    /// payload filtering corresponding to the data byte 7.
    pub const Data_byte_7 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 8,
    };
    /// [8..15] Payload Filter 1 high order bits for Pretended Networking
    /// payload filtering corresponding to the data byte 6.
    pub const Data_byte_6 = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 8,
    };
    /// [16..23] Payload Filter 1 high order bits for Pretended Networking
    /// payload filtering corresponding to the data byte 5.
    pub const Data_byte_5 = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 8,
    };
    /// [24..31] Payload Filter 1 high order bits for Pretended Networking
    /// payload filtering corresponding to the data byte 4.
    pub const Data_byte_4 = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 8,
    };
};

/// Pretended Networking ID Filter 2 Register / ID Mask Register
/// - address offset is 0xB1C
/// - reset value is 0
pub const FLT_ID2_IDMASK_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0xB1C),
        RegType.RegIns.init(can1_base_address + 0xB1C),
        RegType.RegIns.init(can2_base_address + 0xB1C),
    };
    /// [0..28] ID Filter 2 for Pretended Networking Filtering / ID Mask Bits
    /// for Pretended Networking ID Filtering
    pub const FLT_ID2_IDMASK = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 29,
    };
    /// [29] Remote Transmission Request Mask Bit
    /// - 0 The corresponding bit in the filter is "don't care"
    /// - 1 The corresponding bit in the filter is checked
    pub const RTR_MSK = RegType.FieldDef{
        .bit_start = 29,
        .bit_len = 1,
    };
    /// [30] ID Extended Mask Bit
    /// - 0 The corresponding bit in the filter is "don't care"
    /// - 1 The corresponding bit in the filter is checked
    pub const IDE_MSK = RegType.FieldDef{
        .bit_start = 30,
        .bit_len = 1,
    };
};

/// Pretended Networking Payload Low Filter 2 Register / Payload Low Mask Register
/// - address offset is 0xB20
/// - reset value is 0
pub const PL2_PLMASK_LO_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0xB20),
        RegType.RegIns.init(can1_base_address + 0xB20),
        RegType.RegIns.init(can2_base_address + 0xB20),
    };
    /// [0..7]  Payload Filter 2 low order bits / Payload Mask low order bits
    /// for Pretended Networking payload filtering corresponding to the data byte 3.
    pub const Data_byte_3 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 8,
    };
    /// [8..15] Payload Filter 2 low order bits / Payload Mask low order bits
    /// for Pretended Networking payload filtering corresponding to the
    /// data byte 2.
    pub const Data_byte_2 = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 8,
    };
    /// [16..23] Payload Filter 2 low order bits / Payload Mask low order bits
    /// for Pretended Networking payload filtering corresponding to the data byte 1.
    pub const Data_byte_1 = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 8,
    };
    /// [24..31] Payload Filter 2 low order bits / Payload Mask low order bits
    /// for Pretended Networking payload filtering corresponding to the data byte 0.
    pub const Data_byte_0 = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 8,
    };
};

/// Pretended Networking Payload High Filter 2 low order bits / Payload High Mask Register
/// - address offset is 0xB24
/// - reset value is 0
pub const PL2_PLMASK_HI_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0xB24),
        RegType.RegIns.init(can1_base_address + 0xB24),
        RegType.RegIns.init(can2_base_address + 0xB24),
    };
    /// [0..7] Payload Filter 2 high order bits / Payload Mask high order bits
    /// for Pretended Networking payload filtering corresponding to the
    /// data byte 7.
    pub const Data_byte_7 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 8,
    };
    /// [8..15] Payload Filter 2 high order bits / Payload Mask high order bits
    /// for Pretended Networking payload filtering corresponding to the data byte 6.
    pub const Data_byte_6 = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 8,
    };
    /// [16..23] Payload Filter 2 high order bits / Payload Mask high order bits
    /// for Pretended Networking payload filtering corresponding to the
    /// data byte 5.
    pub const Data_byte_5 = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 8,
    };
    /// [24..31] Payload Filter 2 high order bits / Payload Mask high order bits
    /// for Pretended Networking payload filtering corresponding to the
    /// data byte 4.
    pub const Data_byte_4 = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 8,
    };
};

/// Wake Up Message Buffer Register for C/S
/// - address offset is 0xB40
/// - reset value is 0
pub const WMB0_CS_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0xB40),
        RegType.RegIns.init(can1_base_address + 0xB40),
        RegType.RegIns.init(can2_base_address + 0xB40),
    };
    /// [16..19] Length of Data in Bytes
    pub const DLC = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 4,
    };
    /// [20] Remote Transmission Request Bit
    /// - 0 Frame is data one (not remote)
    /// - 1 Frame is a remote one
    pub const RTR = RegType.FieldDef{
        .bit_start = 20,
        .bit_len = 1,
    };
    /// [21] ID Extended Bit
    /// - 0 Frame format is standard
    /// - 1 Frame format is extended
    pub const IDE = RegType.FieldDef{
        .bit_start = 21,
        .bit_len = 1,
    };
    /// [22] Substitute Remote Request
    pub const SRR = RegType.FieldDef{
        .bit_start = 22,
        .bit_len = 1,
    };
};

/// Wake Up Message Buffer Register for ID
/// - address offset is 0xB44
/// - reset value is 0
pub const WMB0_ID_REG = struct {
    pub const reg_ins_arr = [3]RegType.RegIns{
        RegType.RegIns.init(can0_base_address + 0xB44),
        RegType.RegIns.init(can1_base_address + 0xB44),
        RegType.RegIns.init(can2_base_address + 0xB44),
    };
    /// [0..28] Received ID under Pretended Networking mode
    pub const ID = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 29,
    };
};
