//! Created by Weng
//! 2025/02/24
//! CAN Registers
//! - the regs should be rewritten cause the stack on mcu may be large

pub const IDAM_MODE_TYPE = enum(u2) {
    /// One full ID (standard and extended) per ID Filter Table element.
    FORMAT_A = 0b00,
    /// Two full standard IDs or two partial 14-bit
    /// (standard and extended) IDs per ID Filter Table element.
    FORMAT_B = 0b01,
    /// Four partial 8-bit Standard IDs per ID Filter Table element.
    FORMAT_C = 0b10,
    /// All frames rejected.
    FORMAT_D = 0b11,
};

/// Module Configuration Register
/// - reset value is 0xD890_000F
const MCM_REG = packed struct(u32) {
    /// [0..6]
    /// - Number Of The Last Message Buffer
    /// - the last index of mailbox
    MAXM: u7 = 0,
    /// [7..8]
    /// - ID Acceptance Mode
    IDAM: IDAM_MODE_TYPE = IDAM_MODE_TYPE.FORMAT_A,
    /// [9..10]
    RES9_10: u2 = 0,
    /// [11]
    /// - CAN FD operation enable
    /// - 1 CAN FD is enabled. FlexCAN is able to receive and transmit messages in both CAN FD and CAN 2.0 formats.
    /// - 0 CAN FD is disabled. FlexCAN is able to receive and transmit messages in CAN 2.0 format.
    FDEN: u1 = 0,
    /// [12] Abort Enable
    /// - 0 Abort disabled
    /// - 1 Abort enabled.
    ABEN: u1 = 0,
    /// [13] Local Priority Enable
    /// - 0 Local Priority disabled
    /// - 1 Local Priority enabled
    LPRIOEN: u1 = 0,
    /// [14] Pretended Networking Enable
    /// - 0 Pretended Networking mode is disabled.
    /// - 1 Pretended Networking mode is enabled.
    PNET_EN: u1 = 0,
    /// [15] DMA Enable
    /// - 0 DMA feature for RX FIFO disabled.
    /// - 1 DMA feature for RX FIFO enabled.
    DMA: u1 = 0,
    /// [16] Individual Rx Masking And Queue Enable
    /// - 0 Individual Rx masking and queue feature are disabled. For
    /// backward compatibility with legacy applications, the
    /// reading of C/S word locks the MB even if it is EMPTY.
    /// - 1 Individual Rx masking and queue feature are enabled.
    IRMQ: u1 = 0,
    /// [17] Self Reception Disable
    /// - 0 Self reception enabled.
    /// - 1 Self reception disabled.
    SRXDIS: u1 = 0,
    /// [18..19]
    RES18_19: u2 = 0,
    /// [20] Low-Power Mode Acknowledge
    /// - 0 FlexCAN is not in a low-power mode.
    /// - 1 FlexCAN is in a low-power mode.
    LPMACK: u1 = 0,
    /// [21] Warning Interrupt Enable
    /// - 0 TWRNINT and RWRNINT bits are zero, independent of the
    /// values in the error counters.
    /// - 1 TWRNINT and RWRNINT bits are set when the respective error
    /// counter transitions from less than 96 to greater than or equal to 96.
    WRNEN: u1 = 0,
    /// [22]
    RES22: u1 = 0,
    /// [23] Supervisor Mode
    SUPV: u1 = 0,
    /// [24] Freeze Mode Acknowledge
    /// - 0 FlexCAN not in Freeze mode, prescaler running.
    /// - 1 FlexCAN in Freeze mode, prescaler stopped.
    FRZACK: u1 = 0,
    /// [25] Soft Reset
    /// - 0 No reset request
    /// - 1 Resets the registers affected by soft reset.
    SOFTRST: u1 = 0,
    /// [26]
    RES26: u1 = 0,
    /// [27] FlexCAN Not Ready
    /// - 0 FlexCAN module is either in Normal mode, Listen-Only mode or
    /// Loop-Back mode.
    /// - 1 FlexCAN Module is not ready yet
    NOTRDY: u1 = 0,
    /// [28] Halt FlexCAN
    /// - 0 No Freeze mode request.
    /// - 1 Enters Freeze mode if the FRZ bit is asserted.
    HALT: u1 = 0,
    /// [29] Rx FIFO Enable
    /// - 0 Rx FIFO not enabled.
    /// - 1 Rx FIFO enabled.
    RFEN: u1 = 0,
    /// [30] Freeze Enable
    /// - 0 Not enabled to enter Freeze mode.
    /// - 1 Enabled to enter Freeze mode.
    FRZ: u1 = 0,
    /// [31] Module Disable
    /// - 0 Enable the FlexCAN module.
    /// - 1 Disable the FlexCAN module.
    MDIS: u1 = 0,
};

/// Control 1 register
/// - address offset is 0x4
/// - reset value is 0
const CTRL1_REG = packed struct(u32) {
    /// [0..2] Propagation Segment
    PROPSEG: u3 = 0,
    /// [3] Listen-Only Mode
    /// - 0 Listen-Only mode is deactivated.
    /// - 1 FlexCAN module operates in Listen-Only mode.
    LOM: u1 = 0,
    /// [4] Lowest Buffer Transmitted First
    /// - 0 Buffer with highest priority is transmitted first.
    /// - 1 Lowest number buffer is transmitted first.
    LBUF: u1 = 0,
    /// [5] Timer Sync
    /// - 0 Timer Sync feature disabled
    /// - 1 Timer Sync feature enabled
    TSYN: u1 = 0,
    /// [6] Bus Off Recovery
    /// - 0 Automatic recovering from Bus Off state enabled.
    /// - 1 Automatic recovering from Bus Off state disabled.
    BOFFREC: u1 = 0,
    /// [7] CAN Bit Sampling
    /// - 0 Just one sample is used to determine the bit value.
    /// - 1 Three samples are used to determine the value of the
    /// received bit: the regular one (sample point) and 2
    /// preceding samples; a majority rule is used.
    SMP: u1 = 0,
    /// [8..9]
    RES8_9: u2 = 0,
    /// [10] Rx Warning Interrupt Mask
    /// - 0 Rx Warning Interrupt disabled.
    /// - 1 Rx Warning Interrupt enabled.
    RWRNMSK: u1 = 0,
    /// [11] Tx Warning Interrupt Mask
    /// - 0 Tx Warning Interrupt disabled.
    /// - 1 Tx Warning Interrupt enabled.
    TWRNMSK: u1 = 0,
    /// [12] Loop Back Mode
    /// - 0 Loop Back disabled.
    /// - 1 Loop Back enabled.
    LPB: u1 = 0,
    /// [13] CAN Engine Clock Source
    /// - 0 The CAN engine clock source is the oscillator clock.(SOSCDIV2)
    /// Under this condition, the oscillator clock frequency must be
    /// lower than the bus clock.
    /// - 1 The CAN engine clock source is the peripheral clock.
    CLKSRC: u1 = 0,
    /// [14] Error Interrupt Mask
    /// - 0 Error interrupt disabled.
    /// - 1 Error interrupt enabled.
    ERRMSK: u1 = 0,
    /// [15] Bus Off Interrupt Mask
    /// - 0 Bus Off interrupt disabled.
    /// - 1 Bus Off interrupt enabled.
    BOFFMSK: u1 = 0,
    /// [16..18] Phase Segment 2
    PSEG2: u3 = 0,
    /// [19..21] Phase Segment 1
    PSEG1: u3 = 0,
    /// [22..23] Resync Jump Width
    RJW: u2 = 0,
    /// [24..31] Prescaler Division Factor
    PRESDIV: u8 = 0,
};

/// Free Running Timer
/// - address value is 0x8
/// - reset value is 0
const TIMER_REG = packed struct(u32) {
    /// [0..15] Timer Value
    TIMER: u16 = 0,
    RES17_31: u16 = 0,
};

/// Rx Mailboxes Global Mask Register
/// - address offset is 0x10
/// - reset value is 0
const RXMGMASK_REG = packed struct(u32) {
    /// [0..31] Rx Mailboxes Global Mask Bits
    MG: u32 = 0,
};

/// Rx 14 Mask register
/// - address offset is 0x14
/// - reset value is 0
const RX14MASK_REG = packed struct(u32) {
    /// [0..31] Rx Buffer 14 Mask Bits
    RX14M: u32 = 0,
};

/// Rx 15 Mask register
/// - address offset is 0x18
/// - reset value is 0
const RX15MASK_REG = packed struct(u32) {
    /// [0..31] Rx Buffer 15 Mask Bits
    RX15M: u32 = 0,
};

/// Error Counter
/// - address offset is 0x1C
/// - reset value is 0
const ECR_REG = packed struct(u32) {
    /// [0..7] Transmit Error Counter
    TXERRCNT: u8 = 0,
    /// [8..15] Receive Error Counter
    RXERRCNT: u8 = 0,
    /// [16..23] Transmit Error Counter for fast bits
    TXERRCNT_FAST: u8 = 0,
    /// [24..31] Receive Error Counter for fast bits
    RXERRCNT_FAST: u8 = 0,
};

/// Error and Status 1 register
/// - address offset is 0x20
/// - reset value is 0
const ESR1_REG = packed struct(u32) {
    /// [0]
    RES0: u1 = 0,
    /// [1] Error Interrupt
    /// - 0 No such occurrence.
    /// - 1 Indicates setting of any Error Bit in the Error and Status Register.
    ERRINT: u1 = 0,
    /// [2] Bus Off Interrupt
    ///  - 0 No such occurrence.
    ///  - 1 FlexCAN module entered Bus Off state.
    BOFFINT: u1 = 0,
    /// [3] FlexCAN In Reception
    ///  - 0 FlexCAN is not receiving a message.
    ///  - 1 FlexCAN is receiving a message.
    RX: u1 = 0,
    /// [4..5] Fault Confinement State
    /// - 00 Error Active
    /// - 01 Error Passive
    /// - 1x Bus Off
    FLTCONF: u2 = 0,
    /// [6] FlexCAN In Transmission
    /// - 0 FlexCAN is not transmitting a message.
    /// - 1 FlexCAN is transmitting a message.
    TX: u1 = 0,
    /// [7] IDLE descrip the bus is idle or not
    /// - 0 No such occurrence.
    /// - 1 CAN bus is now IDLE.
    IDLE: u1 = 0,
    /// [8] Rx Error Warning
    /// - 0 No such occurrence.
    /// - 1 RXERRCNT is greater than or equal to 96.
    RXWRN: u1 = 0,
    /// [9] TX Error Warning
    /// - 0 No such occurrence.
    /// - 1 TXERRCNT is greater than or equal to 96.
    TXWRN: u1 = 0,
    /// [10] Stuffing Error
    /// - 0 No such occurrence
    /// - 1 A Stuffing Error occurred since last read of this register.
    STFERR: u1 = 0,
    /// [11] Form Error
    /// - 0 No such occurrence.
    /// - 1 A Form Error occurred since last read of this register.
    FRMERR: u1 = 0,
    /// [12] Cyclic Redundancy Check Error
    /// - 0 No such occurrence.
    /// - 1 A CRC error occurred since last read of this register.
    CRCERR: u1 = 0,
    /// [13] Acknowledge Error
    /// - 0 No such occurrence.
    /// - 1 An ACK error occurred since last read of this register.
    ACKERR: u1 = 0,
    /// [14] Bit0 Error
    /// - 0 No such occurrence.
    /// - 1 At least one bit sent as dominant is received as recessive.
    BIT0ERR: u1 = 0,
    /// [15] Bit1 Error
    /// - 0 No such occurrence.
    /// - 1 At least one bit sent as recessive is received as dominant.
    BIT1ERR: u1 = 0,
    /// [16] Rx Warning Interrupt Flag
    /// - 0 No such occurrence.
    /// - 1 The Rx error counter transitioned from less than 96 to greater than or equal to 96.
    RWRNINT: u1 = 0,
    /// [17] Tx Warning Interrupt Flag
    /// - 0 No such occurrence.
    /// - 1 The Tx error counter transitioned from less than 96 to greater than or equal to 96.
    TWRNINT: u1 = 0,
    /// [18] CAN Synchronization Status
    /// - 0 FlexCAN is not synchronized to the CAN bus.
    /// - 1 FlexCAN is synchronized to the CAN bus.
    SYNCH: u1 = 0,
    /// [19] Bus Off Done Interrupt
    /// - 0 No such occurrence.
    /// - 1 FlexCAN module has completed Bus Off process.
    BOFFDONEINT: u1 = 0,
    /// [20] Error Interrupt for errors detected in the Data Phase of CAN FD
    /// frames with the BRS bit set
    /// - 0 No such occurrence.
    /// - 1 Indicates setting of any Error Bit detected in the Data
    /// Phase of CAN FD frames with the BRS bit set.
    ERRINT_FAST: u1 = 0,
    /// [21] Error Overrun bit
    /// - 0 Overrun has not occurred.
    /// - 1 Overrun has occurred.
    ERROVR: u1 = 0,
    /// [22..25]
    RES22_25: u4 = 0,
    /// [26] Stuffing Error in the Data Phase of CAN FD frames with the BRS bit set
    /// - 0 No such occurrence.
    /// - 1 A Stuffing Error occurred since last read of this register.
    STFERR_FAST: u6 = 0,
    /// [27] Form Error in the Data Phase of CAN FD frames with the BRS bit set
    /// - 0 No such occurrence.
    /// - 1 A Form Error occurred since last read of this register.
    FRMERR_FAST: u1 = 0,
    /// [28] Cyclic Redundancy Check Error in the CRC field of CAN FD frames
    /// with the BRS bit set
    /// - 0 No such occurrence.
    /// - 1 A CRC error occurred since last read of this register.
    CRCERR_FAST: u1 = 0,
    /// [29]
    RES29: u1 = 0,
    /// [30] Bit0 Error in the Data Phase of CAN FD frames with the BRS bit set
    /// - 0 No such occurrence.
    /// - 1 At least one bit sent as dominant is received as recessive.
    BIT0ERR_FAST: u1 = 0,
    /// [31] Bit1 Error in the Data Phase of CAN FD frames with the BRS bit set
    /// - 0 No such occurrence.
    /// - 1 At least one bit sent as recessive is received as dominant.
    BIT1ERR_FAST: u1 = 0,
};

/// Interrupt Masks 1 register
/// - address offset is 0x28
/// - reset value is 0
const IMASK1_REG = packed struct(u32) {
    /// [0..31] Buffer MB i Mask
    BUF31TO0M: u32 = 0,
};

/// Interrupt Flags 1 register
/// - address offset is 0x30
/// - reset value is 0
const IFLAG1_REG = packed struct(u32) {
    /// [0] Buffer MB0 Interrupt Or Clear FIFO bit
    /// - 0 The corresponding buffer has no occurrence of successfully
    /// completed transmission or reception when MCR[RFEN]=0.
    /// - 1 The corresponding buffer has successfully completed
    /// transmission or reception when MCR[RFEN]=0.
    BUF0I: u1 = 0,
    /// [1..4] Buffer MB i Interrupt Or "reserved"
    /// - 0b - The corresponding buffer has no occurrence of successfully completed transmission or
    /// reception when MCR[RFEN]=0.
    /// - 1b - The corresponding buffer has successfully completed transmission or reception when
    /// MCR[RFEN]=0.
    BUF4TO1I: u4 = 0,
    /// [5] Buffer MB5 Interrupt Or "Frames available in Rx FIFO"
    /// - 0 No occurrence of MB5 completing transmission/reception
    /// when MCR[RFEN]=0, or of frame(s) available in the FIFO,
    /// when MCR[RFEN]=1
    /// - 1 MB5 completed transmission/reception when MCR[RFEN]=0, or
    /// frame(s) available in the Rx FIFO when MCR[RFEN]=1. It
    /// generates a DMA request in case of MCR[RFEN] and MCR[DMA] are enabled.
    BUF5I: u1 = 0,
    /// [6] Buffer MB6 Interrupt Or "Rx FIFO Warning"
    /// - 0 No occurrence of MB6 completing transmission/reception
    /// when MCR[RFEN]=0, or of Rx FIFO almost full when MCR[RFEN]=1
    /// - 1 MB6 completed transmission/reception when MCR[RFEN]=0, or
    /// Rx FIFO almost full when MCR[RFEN]=1
    BUF6I: u1 = 0,
    /// [7] Buffer MB7 Interrupt Or "Rx FIFO Overflow"
    /// - 0 No occurrence of MB7 completing transmission/reception
    /// when MCR[RFEN]=0, or of Rx FIFO overflow when MCR[RFEN]=1
    /// -1 MB7 completed transmission/reception when MCR[RFEN]=0, or
    /// Rx FIFO overflow when MCR[RFEN]=1
    BUF7I: u1 = 0,
    /// [8..31] Buffer MBi Interrupt
    BUF31TO8I: u24 = 0,
};

/// Control 2 register
/// - address offset is 0x34
/// - reset value is 0
const CTRL2_REG = packed struct(u32) {
    /// [0..10]
    RES0_10: u11 = 0,
    /// [11] Edge Filter Disable
    /// - 0 Edge Filter is enabled.
    /// - 1 Edge Filter is disabled.
    EDFLTDIS: u1 = 0,
    /// [12] ISO CAN FD Enable
    /// - 0 FlexCAN operates using the non-ISO CAN FD protocol.
    /// - 1 FlexCAN operates using the ISO CAN FD protocol (ISO 11898-1).
    ISOCANFDEN: u1 = 0,
    /// [13]
    RES13: u1 = 0,
    /// [14] Protocol Exception Enable
    /// - 0 Protocol Exception is disabled.
    /// - 1 Protocol Exception is enabled.
    PREXCEN: u1 = 0,
    /// [15] Timer Source
    /// - 0 - The Free Running Timer is clocked by the CAN bit clock,
    /// which defines the baud rate on the CAN bus.
    /// - 1 The Free Running Timer is clocked by an external time
    /// tick. The period can be either adjusted to be equal to the
    /// baud rate on the CAN bus, or a different value as
    /// required. See the device specific section for details
    /// about the external time tick.
    TIMER_SRC: u1 = 0,
    /// [16] Entire Frame Arbitration Field Comparison Enable For Rx Mailboxes
    /// - 0 Rx Mailbox filter's IDE bit is always compared and RTR is
    /// never compared despite mask bits.
    /// - 1 Enables the comparison of both Rx Mailbox filter's IDE and
    /// RTR bit with their corresponding bits within the incoming
    /// frame. Mask bits do apply.
    EACEN: u1 = 0,
    /// [17] Remote Request Storing
    /// - 0 Remote Response Frame is generated.
    /// - 1 Remote Request Frame is stored.
    RRS: u1 = 0,
    /// [18] Mailboxes Reception Priority
    /// - 0 Matching starts from Rx FIFO and continues on Mailboxes.
    /// - 1 Matching starts from Mailboxes and continues on Rx FIFO.
    MRP: u1 = 0,
    /// [19..23] Tx Arbitration Start Delay
    TASD: u5 = 0,
    /// [24..27] Number Of Rx FIFO Filters
    RFFN: u4 = 0,
    /// [28..29]
    RES28_29: u2 = 0,
    /// [30] Bus Off Done Interrupt Mask
    /// - 0 Bus Off Done interrupt disabled.
    /// - 1 Bus Off Done interrupt enabled.
    BOFFDONEMSK: u1 = 0,
    /// [31] Error Interrupt Mask for errors detected in the Data Phase of
    /// fast CAN FD frames
    /// - 0 ERRINT_FAST Error interrupt disabled.
    /// - 1 ERRINT_FAST Error interrupt enabled.
    ERRMSK_FAST: u1 = 0,
};

/// Error and Status 2 register
/// - address offset 0x38
/// - reset value is 0
const ESR2_REG = packed struct(u32) {
    /// [0..12]
    RES0_12: u13 = 0,
    /// [13] Inactive Mailbox
    /// - 0  If ESR2[VPS] is asserted, the ESR2[LPTM] is not an inactive Mailbox.
    /// - 1  If ESR2[VPS] is asserted, there is at least one inactive
    /// Mailbox. LPTM content is the number of the first one.
    IMB: u1 = 0,
    /// [14] Valid Priority Status
    /// - 0 Contents of IMB and LPTM are invalid.
    /// - 1 Contents of IMB and LPTM are valid.
    VPS: u1 = 0,
    /// [15]
    RES15: u1 = 0,
    /// [16..22] Lowest Priority Tx Mailbox
    LPTM: u7 = 0,
    /// [23..31]
    RES23_31: u9 = 0,
};

/// CRC Register
/// - address offset is 0x44
/// - reset value is 0
const CRCR_REG = packed struct(u32) {
    /// [0..14] Transmitted CRC value
    TXCRC: u15 = 0,
    /// [15]
    RES15: u1 = 0,
    /// [16..22] CRC Mailbox
    MBCRC: u7 = 0,
    /// [23..31]
    RES23_31: u9 = 0,
};

/// Rx FIFO Global Mask register
/// - address offset is 0x48
/// - reset value is 0
const RXFGMASK_REG = packed struct(u32) {
    /// [0..31] Rx FIFO Global Mask Bits
    FGM: u32 = 0,
};

/// Rx FIFO Information Register
/// - address offset is 0x4c
/// - reset value is 0
const RXFIR_REG = packed struct(u32) {
    /// [0..8] Identifier Acceptance Filter Hit Indicator
    IDHIT: u9 = 0,
    /// [9..31]
    RES9_31: u23 = 0,
};

/// CAN Bit Timing Register
/// - address offset is 0x50
/// - reset value is 0
const CBT_REG = packed struct(u32) {
    /// [0..4] Extended Phase Segment 2
    EPSEG2: u5 = 0,
    /// [5..9] Extended Phase Segment 1
    EPSEG1: u5 = 0,
    /// [10..15] Extended Propagation Segment
    EPROPSEG: u6 = 0,
    /// [16..20] Extended Resync Jump Width
    ERJW: u5 = 0,
    /// [21..30] Extended Prescaler Division Factor
    EPRESDIV: u10 = 0,
    /// [31] Bit Timing Format Enable
    /// - 0 Extended bit time definitions disabled.
    /// - 1 Extended bit time definitions enabled.
    BTF: u1 = 0,
};

/// Embedded RAM
/// - CAN0 512 byte
/// - address offset start is 0x80
/// - align 4
/// - reset value is 0
/// - range from RAMn0 - 127; total count is 128
pub const RAMn_REGS = packed struct(u32) {
    /// [0..7] Data byte 3 of Rx/Tx frame.
    DATA_BYTE_3: u8 = 0,
    /// [8..15] Data byte 2 of Rx/Tx frame.
    DATA_BYTE_2: u8 = 0,
    /// [16..23] Data byte 1 of Rx/Tx frame.
    DATA_BYTE_1: u8 = 0,
    /// [24..31] Data byte 0 of Rx/Tx frame.
    DATA_BYTE_0: u8 = 0,
};

/// Rx Individual Mask Registers
/// - address offset is 0x880
/// - align 4
/// - reset value is 0
/// - range from 0 - 31
const RXIMR_REGS = packed struct(u32) {
    /// [0..31] Individual Mask Bits
    MI: u32 = 0,
};

/// Pretended Networking Control 1 Register
/// - address offset is 0xB00
/// - reset value is 0
const CTRL1_PN_REG = packed struct(u32) {
    /// [0..1] Filtering Combination Selection
    /// - 00 Message ID filtering only
    /// - 01 Message ID filtering and payload filtering
    /// - 10 Message ID filtering occurring a specified number of times.
    /// - 11 Message ID filtering and payload filtering a specified number of times
    FCS: u2 = 0,
    /// [2..3] ID Filtering Selection
    /// - 00 Match upon a ID contents against an exact target value
    /// - 01 Match upon a ID value greater than or equal to a specified target value
    /// - 10 Match upon a ID value smaller than or equal to a specified target value
    /// - 11 Match upon a ID value inside a range, greater than or
    /// equal to a specified lower limit and smaller than or equal
    /// a specified upper limit
    IDFS: u2 = 0,
    /// [4..5] Payload Filtering Selection
    /// - 00 Match upon a payload contents against an exact target value
    /// - 01 Match upon a payload value greater than or equal to a specified target value
    /// - 10 Match upon a payload value smaller than or equal to a
    /// specified target value
    /// - 11 Match upon a payload value inside a range, greater than or
    /// equal to a specified lower limit and smaller than or equal
    /// a specified upper limit
    PLFS: u2 = 0,
    /// [6..7]
    RES6_7: u2 = 0,
    /// [8..15] Number of Messages Matching the Same Filtering Criteria
    /// - 00000001 Received message must match the predefined filtering
    /// criteria for ID and/or PL once before generating a wake up event.
    /// - 00000010 Received message must match the predefined filtering
    /// criteria for ID and/or PL twice before generating a wake up event.
    /// - 11111111 Received message must match the predefined filtering
    /// criteria for ID and/or PL 255 times before generating a wake up event.
    NMATCH: u8 = 0,
    /// [16] Wake Up by Match Flag Mask Bit
    /// - 0 Wake up match event is disabled
    /// - 1 Wake up match event is enabled
    WUMF_MSK: u1 = 0,
    /// [17] Wake Up by Timeout Flag Mask Bit
    /// - 0 Timeout wake up event is disabled
    /// - 1 Timeout wake up event is enabled
    WTOF_MSK: u1 = 0,
    /// [18..31]
    RES18_31: u14 = 0,
};

/// Pretended Networking Control 2 Register
/// - address offset is 0xB04
/// - reset value is 0
const CTRL2_PN_REG = packed struct(u32) {
    /// [0..15] Timeout for No Message Matching the Filtering Criteria
    MATCHTO: u16 = 0,
    /// [16..31]
    RES16_31: u16 = 0,
};

/// Pretended Networking Wake Up Match Register
/// - address offset is 0xB08
/// - reset value is 0
const WU_MTC_REG = packed struct(u32) {
    /// [0..7]
    RES0_7: u8 = 0,
    /// [8..15] Number of Matches while in Pretended Networking
    MCOUNTER: u8 = 0,
    /// [16] Wake Up by Match Flag Bit
    /// - 0 No wake up by match event detected
    /// - 1 Wake up by match event detected
    WUMF: u1 = 0,
    /// [17] Wake Up by Timeout Flag Bit
    /// - 0 No wake up by timeout event detected
    /// - 1 Wake up by timeout event detected
    WTOF: u1 = 0,
    /// [18..31]
    RES18_31: u14 = 0,
};

/// Pretended Networking ID Filter 1 Register
/// - address offset is 0xB0C
/// - reset value is 0
const FLT_ID1_REG = packed struct(u32) {
    /// [0..28] ID Filter 1 for Pretended Networking filtering
    FLT_ID1: u29 = 0,
    /// [29] Remote Transmission Request Filter
    /// - 0 Reject remote frame (accept data frame)
    /// - 1 Accept remote frame
    FLT_RTR: u1 = 0,
    /// [30] ID Extended Filter
    /// - 0 Accept standard frame format
    /// - 1 Accept extended frame format
    FLT_IDE: u1 = 0,
    /// [31]
    RES31: u1 = 0,
};

/// Pretended Networking DLC Filter Register
/// - address offset is 0xB10
/// - reset value is 0x8
const FLT_DLC_REG = packed struct(u32) {
    /// [0..3] Upper Limit for Length of Data Bytes Filter
    FLT_DLC_HI: u4 = 0,
    /// [4..15]
    RES4_15: u12 = 0,
    /// [16..19] Lower Limit for Length of Data Bytes Filter
    FLT_DLC_LO: u4 = 0,
    /// [20..31]
    RES20_31: u12 = 0,
};

/// Pretended Networking Payload Low Filter 1 Register
/// - address offset is 0xB14
/// - reset value is 0
const PL1_LO_REG = packed struct(u32) {
    /// [0..7] Payload Filter 1 low order bits for Pretended Networking payload
    /// filtering corresponding to the data byte 3.
    Data_byte_3: u8 = 0,
    /// [9..15] Payload Filter 1 low order bits for Pretended Networking payload
    /// filtering corresponding to the data byte 2.
    Data_byte_2: u8 = 0,
    /// [16..23] Payload Filter 1 low order bits for Pretended Networking payload
    /// filtering corresponding to the data byte 1.
    Data_byte_1: u8 = 0,
    /// [24..31] Payload Filter 1 low order bits for Pretended Networking payload
    /// filtering corresponding to the data byte 0.
    Data_byte_0: u8 = 0,
};

/// Pretended Networking Payload High Filter 1 Register
/// - address offset is 0xB18
/// - reset value is 0
const PL1_HI_REG = packed struct(u32) {
    /// [0..7] Payload Filter 1 high order bits for Pretended Networking
    /// payload filtering corresponding to the data byte 7.
    Data_byte_7: u8 = 0,
    /// [8..15] Payload Filter 1 high order bits for Pretended Networking
    /// payload filtering corresponding to the data byte 6.
    Data_byte_6: u8 = 0,
    /// [16..23] Payload Filter 1 high order bits for Pretended Networking
    /// payload filtering corresponding to the data byte 5.
    Data_byte_5: u8 = 0,
    /// [24..31] Payload Filter 1 high order bits for Pretended Networking
    /// payload filtering corresponding to the data byte 4.
    Data_byte_4: u8 = 0,
};

/// Pretended Networking ID Filter 2 Register / ID Mask Register
/// - address offset is 0xB1C
/// - reset value is 0
const FLT_ID2_IDMASK_REG = packed struct(u32) {
    /// [0..28] ID Filter 2 for Pretended Networking Filtering / ID Mask Bits
    /// for Pretended Networking ID Filtering
    FLT_ID2_IDMASK: u29 = 0,
    /// [29] Remote Transmission Request Mask Bit
    /// - 0 The corresponding bit in the filter is "don't care"
    /// - 1 The corresponding bit in the filter is checked
    RTR_MSK: u1 = 0,
    /// [30] ID Extended Mask Bit
    /// - 0 The corresponding bit in the filter is "don't care"
    /// - 1 The corresponding bit in the filter is checked
    IDE_MSK: u1 = 0,
    /// [31]
    RES31: u1 = 0,
};

/// Pretended Networking Payload Low Filter 2 Register / Payload Low Mask Register
/// - address offset is 0xB20
/// - reset value is 0
const PL2_PLMASK_LO_REG = packed struct(u32) {
    /// [0..7]  Payload Filter 2 low order bits / Payload Mask low order bits
    /// for Pretended Networking payload filtering corresponding to the data byte 3.
    Data_byte_3: u8 = 0,
    /// [8..15] Payload Filter 2 low order bits / Payload Mask low order bits
    /// for Pretended Networking payload filtering corresponding to the
    /// data byte 2.
    Data_byte_2: u8 = 0,
    /// [16..23] Payload Filter 2 low order bits / Payload Mask low order bits
    /// for Pretended Networking payload filtering corresponding to the data byte 1.
    Data_byte_1: u8 = 0,
    /// [24..31] Payload Filter 2 low order bits / Payload Mask low order bits
    /// for Pretended Networking payload filtering corresponding to the data byte 0.
    Data_byte_0: u8 = 0,
};

/// Pretended Networking Payload High Filter 2 low order bits / Payload High Mask Register
/// - address offset is 0xB24
/// - reset value is 0
const PL2_PLMASK_HI_REG = packed struct(u32) {
    /// [0..7] Payload Filter 2 high order bits / Payload Mask high order bits
    /// for Pretended Networking payload filtering corresponding to the
    /// data byte 7.
    Data_byte_7: u8 = 0,
    /// [8..15] Payload Filter 2 high order bits / Payload Mask high order bits
    /// for Pretended Networking payload filtering corresponding to the data byte 6.
    Data_byte_6: u8 = 0,
    /// [16..23] Payload Filter 2 high order bits / Payload Mask high order bits
    /// for Pretended Networking payload filtering corresponding to the
    /// data byte 5.
    Data_byte_5: u8 = 0,
    /// [24..31] Payload Filter 2 high order bits / Payload Mask high order bits
    /// for Pretended Networking payload filtering corresponding to the
    /// data byte 4.
    Data_byte_4: u8 = 0,
};

/// Wake Up Message Buffer Register for C/S
/// - address offset is 0xB40
/// - reset value is 0
const WMB0_CS_REG = packed struct(u32) {
    /// [0..15]
    RES0_15: u16 = 0,
    /// [16..19] Length of Data in Bytes
    DLC: u4 = 0,
    /// [20] Remote Transmission Request Bit
    /// - 0 Frame is data one (not remote)
    /// - 1 Frame is a remote one
    RTR: u1 = 0,
    /// [21] ID Extended Bit
    /// - 0 Frame format is standard
    /// - 1 Frame format is extended
    IDE: u1 = 0,
    /// [22] Substitute Remote Request
    SRR: u1 = 0,
    /// [23..31]
    RES23_31: u9 = 0,
};

/// Wake Up Message Buffer Register for ID
/// - address offset is 0xB44
/// - reset value is 0
const WMB0_ID_REG = packed struct(u32) {
    /// [0..28] Received ID under Pretended Networking mode
    ID: u29 = 0,
    /// [29..31]
    RES30_31: u3 = 0,
};

/// Wake Up Message Buffer Register for Data 0-3
/// - address offset is 0xB48
/// - reset value is 0
const WMB0_D03_REG = packed struct(u32) {
    /// [0..7] Received payload corresponding to the data byte 3 under
    /// Pretended Networking mode
    Data_byte_3: u8 = 0,
    /// [8..15] Received payload corresponding to the data byte 2 under
    /// Pretended Networking mode
    Data_byte_2: u8 = 0,
    /// [16..23] Received payload corresponding to the data byte 1 under
    /// Pretended Networking mode
    Data_byte_1: u8 = 0,
    /// [24..31] Received payload corresponding to the data byte 0 under
    /// Pretended Networking mode
    Data_byte_0: u8 = 0,
};

/// Wake Up Message Buffer Register Data 4-7
/// - address offset is 0xB4C
/// - reset value is 0
const WMB0_D47_REG = packed struct(u32) {
    /// [0..7] Received payload corresponding to the data byte 7 under
    /// Pretended Networking mode
    Data_byte_7: u8 = 0,
    /// [8..15] Received payload corresponding to the data byte 6 under
    /// Pretended Networking mode
    Data_byte_6: u8 = 0,
    /// [16..23] Received payload corresponding to the data byte 5 under
    /// Pretended Networking mode
    Data_byte_5: u8 = 0,
    /// [24..31] Received payload corresponding to the data byte 4 under
    /// Pretended Networking mode
    Data_byte_4: u8 = 0,
};

/// Wake Up Message Buffer Register for C/S
/// - address offset is 0xB50
/// - reset value is 0
const WMB1_CS_REG = packed struct(u32) {
    /// [0..15]
    RES0_15: u16 = 0,
    /// [16..19] Length of Data in Bytes
    DLC: u4 = 0,
    /// [20] Remote Transmission Request Bit
    /// - 0 Frame is data one (not remote)
    /// - 1 Frame is a remote one
    RTR: u1 = 0,
    /// [21] ID Extended Bit
    /// - 0 Frame format is standard
    /// - 1 Frame format is extended
    IDE: u1 = 0,
    /// [22] Substitute Remote Request
    SRR: u1 = 0,
    /// [23..31]
    RES23_31: u9 = 0,
};

/// Wake Up Message Buffer Register for ID
/// - address offset is 0xB54
/// - reset value is 0
const WMB1_ID_REG = packed struct(u32) {
    /// [0..28] Received ID under Pretended Networking mode
    ID: u29 = 0,
    /// [29..31]
    RES30_31: u3 = 0,
};

/// Wake Up Message Buffer Register for Data 0-3
/// - address offset is 0xB58
/// - reset value is 0
const WMB1_D03_REG = packed struct(u32) {
    /// [0..7] Received payload corresponding to the data byte 3 under
    /// Pretended Networking mode
    Data_byte_3: u8 = 0,
    /// [8..15] Received payload corresponding to the data byte 2 under
    /// Pretended Networking mode
    Data_byte_2: u8 = 0,
    /// [16..23] Received payload corresponding to the data byte 1 under
    /// Pretended Networking mode
    Data_byte_1: u8 = 0,
    /// [24..31] Received payload corresponding to the data byte 0 under
    /// Pretended Networking mode
    Data_byte_0: u8 = 0,
};

/// Wake Up Message Buffer Register Data 4-7
/// - address offset is 0xB5C
/// - reset value is 0
const WMB1_D47_REG = packed struct(u32) {
    /// [0..7] Received payload corresponding to the data byte 7 under
    /// Pretended Networking mode
    Data_byte_7: u8 = 0,
    /// [8..15] Received payload corresponding to the data byte 6 under
    /// Pretended Networking mode
    Data_byte_6: u8 = 0,
    /// [16..23] Received payload corresponding to the data byte 5 under
    /// Pretended Networking mode
    Data_byte_5: u8 = 0,
    /// [24..31] Received payload corresponding to the data byte 4 under
    /// Pretended Networking mode
    Data_byte_4: u8 = 0,
};

/// Wake Up Message Buffer Register for C/S
/// - address offset is 0xB60
/// - reset value is 0
const WMB2_CS_REG = packed struct(u32) {
    /// [0..15]
    RES0_15: u16 = 0,
    /// [16..19] Length of Data in Bytes
    DLC: u4 = 0,
    /// [20] Remote Transmission Request Bit
    /// - 0 Frame is data one (not remote)
    /// - 1 Frame is a remote one
    RTR: u1 = 0,
    /// [21] ID Extended Bit
    /// - 0 Frame format is standard
    /// - 1 Frame format is extended
    IDE: u1 = 0,
    /// [22] Substitute Remote Request
    SRR: u1 = 0,
    /// [23..31]
    RES23_31: u9 = 0,
};

/// Wake Up Message Buffer Register for ID
/// - address offset is 0xB64
/// - reset value is 0
const WMB2_ID_REG = packed struct(u32) {
    /// [0..28] Received ID under Pretended Networking mode
    ID: u29 = 0,
    /// [29..31]
    RES30_31: u3 = 0,
};

/// Wake Up Message Buffer Register for Data 0-3
/// - address offset is 0xB68
/// - reset value is 0
const WMB2_D03_REG = packed struct(u32) {
    /// [0..7] Received payload corresponding to the data byte 3 under
    /// Pretended Networking mode
    Data_byte_3: u8 = 0,
    /// [8..15] Received payload corresponding to the data byte 2 under
    /// Pretended Networking mode
    Data_byte_2: u8 = 0,
    /// [16..23] Received payload corresponding to the data byte 1 under
    /// Pretended Networking mode
    Data_byte_1: u8 = 0,
    /// [24..31] Received payload corresponding to the data byte 0 under
    /// Pretended Networking mode
    Data_byte_0: u8 = 0,
};

/// Wake Up Message Buffer Register Data 4-7
/// - address offset is 0xB6C
/// - reset value is 0
const WMB2_D47_REG = packed struct(u32) {
    /// [0..7] Received payload corresponding to the data byte 7 under
    /// Pretended Networking mode
    Data_byte_7: u8 = 0,
    /// [8..15] Received payload corresponding to the data byte 6 under
    /// Pretended Networking mode
    Data_byte_6: u8 = 0,
    /// [16..23] Received payload corresponding to the data byte 5 under
    /// Pretended Networking mode
    Data_byte_5: u8 = 0,
    /// [24..31] Received payload corresponding to the data byte 4 under
    /// Pretended Networking mode
    Data_byte_4: u8 = 0,
};

/// Wake Up Message Buffer Register for C/S
/// - address offset is 0xB70
/// - reset value is 0
const WMB3_CS_REG = packed struct(u32) {
    /// [0..15]
    RES0_15: u16 = 0,
    /// [16..19] Length of Data in Bytes
    DLC: u4 = 0,
    /// [20] Remote Transmission Request Bit
    /// - 0 Frame is data one (not remote)
    /// - 1 Frame is a remote one
    RTR: u1 = 0,
    /// [21] ID Extended Bit
    /// - 0 Frame format is standard
    /// - 1 Frame format is extended
    IDE: u1 = 0,
    /// [22] Substitute Remote Request
    SRR: u1 = 0,
    /// [23..31]
    RES23_31: u9 = 0,
};

/// Wake Up Message Buffer Register for ID
/// - address offset is 0xB74
/// - reset value is 0
const WMB3_ID_REG = packed struct(u32) {
    /// [0..28] Received ID under Pretended Networking mode
    ID: u29 = 0,
    /// [29..31]
    RES30_31: u3 = 0,
};

/// Wake Up Message Buffer Register for Data 0-3
/// - address offset is 0xB78
/// - reset value is 0
const WMB3_D03_REG = packed struct(u32) {
    /// [0..7] Received payload corresponding to the data byte 3 under
    /// Pretended Networking mode
    Data_byte_3: u8 = 0,
    /// [8..15] Received payload corresponding to the data byte 2 under
    /// Pretended Networking mode
    Data_byte_2: u8 = 0,
    /// [16..23] Received payload corresponding to the data byte 1 under
    /// Pretended Networking mode
    Data_byte_1: u8 = 0,
    /// [24..31] Received payload corresponding to the data byte 0 under
    /// Pretended Networking mode
    Data_byte_0: u8 = 0,
};

/// Wake Up Message Buffer Register Data 4-7
/// - address offset is 0xB7C
/// - reset value is 0
const WMB3_D47_REG = packed struct(u32) {
    /// [0..7] Received payload corresponding to the data byte 7 under
    /// Pretended Networking mode
    Data_byte_7: u8 = 0,
    /// [8..15] Received payload corresponding to the data byte 6 under
    /// Pretended Networking mode
    Data_byte_6: u8 = 0,
    /// [16..23] Received payload corresponding to the data byte 5 under
    /// Pretended Networking mode
    Data_byte_5: u8 = 0,
    /// [24..31] Received payload corresponding to the data byte 4 under
    /// Pretended Networking mode
    Data_byte_4: u8 = 0,
};

/// CAN FD Control Register
/// - address offset is 0xC00
/// - reset value is 0x8000_0100
const FDCTRL_REG = packed struct(u32) {
    /// [0..5] Transceiver Delay Compensation Value
    TDCVAL: u6 = 0,
    /// [6..7]
    RES6_7: u2 = 0,
    /// [8..12] Transceiver Delay Compensation Offset
    TDCOFF: u5 = 0,
    /// [13]
    RES13: u1 = 0,
    /// [14] Transceiver Delay Compensation Fail
    TDCFAIL: u1 = 0,
    /// [15] Transceiver Delay Compensation Enable
    /// - 0 TDC is disabled
    /// - 1 TDC is enabled
    TDCEN: u1 = 0,
    /// [16..17] Message Buffer Data Size for Region 0
    /// - 00 Selects 8 bytes per Message Buffer.
    /// - 01 Selects 16 bytes per Message Buffer.
    /// - 10 Selects 32 bytes per Message Buffer.
    /// - 11 Selects 64 bytes per Message Buffer.
    MBDSR0: u2 = 0,
    /// [18..30]
    RES18_30: u13 = 0,
    /// [31] Bit Rate Switch Enable
    /// - 0 Transmit a frame in nominal rate. The BRS bit in the Tx MB has no effect.
    /// - 1 Transmit a frame with bit rate switching if the BRS bit in
    /// the Tx MB is recessive.
    FDRATE: u1 = 0,
};

/// CAN FD Bit Timing Register
/// - address offset is 0xC04
/// - reset value is 0
const FDCBT_REG = packed struct(u32) {
    /// [0..2] Fast Phase Segment 2
    FPSEG2: u3 = 0,
    /// [3..4]
    RES3_4: u2 = 0,
    /// [5..7] Fast Phase Segment 1
    FPSEG1: u3 = 0,
    /// [8..9]
    RES8_9: u2 = 0,
    /// [10..14] Fast Propagation Segment
    FPROPSEG: u5 = 0,
    /// [15]
    RES15: u1 = 0,
    /// [16..18] Fast Resync Jump Width
    FRJW: u3 = 0,
    /// [19]
    RES19: u1 = 0,
    /// [20..29] Fast Prescaler Division Factor
    FPRESDIV: u10 = 0,
    /// [30..31]
    RES30_31: u2 = 0,
};

/// CAN FD CRC Register
/// - address offset is 0xC08
/// - reset value is 0
const FDCRC_REG = packed struct(u32) {
    /// [0..20] Extended Transmitted CRC value
    FD_TXCRC: u21 = 0,
    /// [21..23]
    RES21_23: u3 = 0,
    /// [24..30] CRC Mailbox Number for FD_TXCRC
    FD_MBCRC: u7 = 0,
    /// [31]
    RES31: u1 = 0,
};

pub const CanMsgDLC_TYPE = enum(u4) {
    NONE = 0,
    LEN_1 = 1,
    LEN_2 = 2,
    LEN_3 = 3,
    LEN_4 = 4,
    LEN_5 = 5,
    LEN_6 = 6,
    LEN_7 = 7,
    LEN_8 = 8,
    LEN_12 = 9,
    LEN_16 = 10,
    LEN_20 = 11,
    LEN_24 = 12,
    LEN_32 = 13,
    LEN_48 = 14,
    LEN_64 = 15,
};

/// Message Buffer Code
/// - This 4-bit field can be accessed (read or write) by the CPU and by the FlexCAN module
/// itself, as part of the message buffer matching and arbitration process. The encoding is
/// shown in Table 55-27 and Table 55-28. See Functional description for additional
/// information.
/// - **For rx buffer**
/// - 0b0000 :0 INACTIVE — MB is not active
/// - 0b0100 :4 EMPTY — MB is active and empty.
/// - 0b0010 :2 FULL
/// - 0b0110 :6 OVERRUN MB is being overwritten into a full buffer.
/// - 0b1010 :10 RANSWER4 — A frame was configured to recognize a Remote Request frame and transmit
/// a Response frame in return
/// - 0b0001 :1 BUSY — FlexCAN is updating the contents of the MB.
/// The CPU must not access the MB.
/// - **For TX Buffer**
/// - 1000 : 8 INACTIVE
/// - 1001 : 9 ABORT - MB is aborted
/// - 1100 : 12 DATA - MB is a Tx data frame (MB RTR must be 0)
/// - 1100 : 12 REMOTE - MB is a Tx Remote Request frame (MB RTR must be 1)
/// - 1110 : 14 TANSWER — MB is a Tx Response frame from an incoming Remote Request frame
/// can or can fd msg buf at 0h
pub const MB_CODE_TYPE = enum(u4) {
    /// dec 0
    RX_INACTIVE = 0b0000,
    /// dec 4
    RX_EMPTY = 0b0100,
    /// dec 2
    RX_FULL = 0b0010,
    /// dec 6
    RX_OVERRUN = 0b0110,
    /// dec 10
    RX_RANSWER = 0b1010,
    /// dec 1
    RX_BUSY = 0b0001,
    /// dec 8
    TX_INACTIVE = 0b1000,
    /// dec 9
    TX_ABORT = 0b1001,
    /// dec 12
    TX_DATA_REMOTE = 0b1100,
    /// dec 14
    /// - MB is a Tx Response frame from an incoming Remote Request frame
    /// can or can fd msg buf at 0h
    TX_RANSWER = 0b1110,
};

pub const CanMsgBufStructHeader_0h = packed struct(u32) {
    /// [0..15]
    TIME_STAMP: u16 = 0,
    /// [16..19]
    DLC: CanMsgDLC_TYPE = CanMsgDLC_TYPE.NONE,
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
    RTR: u1 = 0,
    /// [21] ID Extended Bit
    /// This field identifies whether the frame format is standard or extended.
    /// - 1 = Frame format is extended
    /// - 0 = Frame format is standard
    IDE: u1 = 0,
    /// [22]  Substitute Remote Request
    /// Fixed recessive bit, used only in extended format. **It must be set to one by the user for
    /// transmission (Tx Buffers) and will be stored with the value received on the CAN bus for
    /// Rx receiving buffers**. It can be received as either recessive or dominant. If FlexCAN
    /// receives this bit as dominant, then it is interpreted as an arbitration loss.
    /// - 1 = Recessive value is compulsory for transmission in extended format frames
    /// - 0 = Dominant is not a valid value for transmission in extended format frames
    SRR: u1 = 0,
    /// [23]
    RES23: u1 = 0,
    /// [24..27] Message Buffer Code
    /// - This 4-bit field can be accessed (read or write) by the CPU and by the FlexCAN module
    /// itself, as part of the message buffer matching and arbitration process. The encoding is
    /// shown in Table 55-27 and Table 55-28. See Functional description for additional
    /// information.
    /// - **For rx buffer**
    /// - 0b0000 :0 INACTIVE — MB is not active
    /// - 0b0100 :4 EMPTY — MB is active and empty.
    /// - 0b0010 :2 FULL
    /// - 0b0110 :6 OVERRUN MB is being overwritten into a full buffer.
    /// - 0b1010 :10 RANSWER4 — A frame was configured to recognize a Remote Request frame and transmit
    /// a Response frame in return
    /// - 0b0001 :1 BUSY — FlexCAN is updating the contents of the MB.
    /// The CPU must not access the MB.
    /// - **For TX Buffer**
    /// - 1000 : 8 INACTIVE
    /// - 1001 : 9 ABORT - MB is aborted
    /// - 1100 : 12 DATA - MB is a Tx data frame (MB RTR must be 0)
    /// - 1100 : 12 REMOTE - MB is a Tx Remote Request frame (MB RTR must be 1)
    /// - 1110 : 14 TANSWER — MB is a Tx Response frame from an incoming Remote Request frame
    CODE: u4 = 0,
    /// [28]
    RES28: u1 = 0,
    /// [29] Error State Indicator
    /// - This bit indicates if the transmitting node is error active or error passive.
    ESI: u1 = 0,
    /// [30] Bit Rate Switch
    /// - This bit defines whether the bit rate is switched inside a CAN FD format frame.
    /// - 0 close speed up
    /// - 1 start speed up
    BRS: u1 = 0,
    /// [31] Extended Data Length
    /// - **distinguishes between CAN format and CAN FD format**
    /// - This bit distinguishes between CAN format and CAN FD format frames. The EDL bit
    /// must not be set for message buffers configured to RANSWER with code field 1010b
    EDL: u1 = 0,
};

pub const CanMsgBufStructHeader_4h = packed struct(u32) {
    /// [0..17]
    ID_EXTEND: u18 = 0,
    /// [18..28]
    ID_STD: u11 = 0,
    /// [29..31] Local priority
    /// - This 3-bit field is used only when MCR[LPRIO_EN] is set, and it only makes sense for
    /// Tx mailboxes. These bits are not transmitted. They are appended to the regular ID to
    /// define the transmission priority. See Arbitration process.
    PRIO: u3 = 0,
};

pub const CanMsgBufStructData = packed struct(u32) {
    DATA_BYTE3: u8 = 0,
    DATA_BYTE2: u8 = 0,
    DATA_BYTE1: u8 = 0,
    DATA_BYTE0: u8 = 0,
};

// All can0 module registers
const can0_base_address: u32 = 0x4002_4000;
const can1_base_address: u32 = 0x4002_5000;
const can2_base_address: u32 = 0x4002_B000;

// new can registers start --------------------------
pub const MCM_Regs: [3]*volatile MCM_REG = .{
    @ptrFromInt(can0_base_address + 0x00),
    @ptrFromInt(can1_base_address + 0x00),
    @ptrFromInt(can2_base_address + 0x00),
};

pub const CTRL1_Regs: [3]*volatile CTRL1_REG = .{
    @ptrFromInt(can0_base_address + 0x04),
    @ptrFromInt(can1_base_address + 0x04),
    @ptrFromInt(can2_base_address + 0x04),
};

pub const TIMER_Regs: [3]*volatile TIMER_REG = .{
    @ptrFromInt(can0_base_address + 0x08),
    @ptrFromInt(can1_base_address + 0x08),
    @ptrFromInt(can2_base_address + 0x08),
};

pub const RXMGMASK_Regs: [3]*volatile RXMGMASK_REG = .{
    @ptrFromInt(can0_base_address + 0x10),
    @ptrFromInt(can1_base_address + 0x10),
    @ptrFromInt(can2_base_address + 0x10),
};

pub const RX14MASK_Regs: [3]*volatile RX14MASK_REG = .{
    @ptrFromInt(can0_base_address + 0x14),
    @ptrFromInt(can1_base_address + 0x14),
    @ptrFromInt(can2_base_address + 0x14),
};

pub const RX15MASK_Regs: [3]*volatile RX15MASK_REG = .{
    @ptrFromInt(can0_base_address + 0x18),
    @ptrFromInt(can1_base_address + 0x18),
    @ptrFromInt(can2_base_address + 0x18),
};

pub const ECR_Regs: [3]*volatile ECR_REG = .{
    @ptrFromInt(can0_base_address + 0x1C),
    @ptrFromInt(can1_base_address + 0x1C),
    @ptrFromInt(can2_base_address + 0x1C),
};

pub const ESR1_Regs: [3]*volatile ESR1_REG = .{
    @ptrFromInt(can0_base_address + 0x20),
    @ptrFromInt(can1_base_address + 0x20),
    @ptrFromInt(can2_base_address + 0x20),
};

pub const IMASK1_Regs: [3]*volatile IMASK1_REG = .{
    @ptrFromInt(can0_base_address + 0x28),
    @ptrFromInt(can1_base_address + 0x28),
    @ptrFromInt(can2_base_address + 0x28),
};

pub const IFLAG1_Regs: [3]*volatile IFLAG1_REG = .{
    @ptrFromInt(can0_base_address + 0x30),
    @ptrFromInt(can1_base_address + 0x30),
    @ptrFromInt(can2_base_address + 0x30),
};

pub const CTRL2_Regs: [3]*volatile CTRL2_REG = .{
    @ptrFromInt(can0_base_address + 0x34),
    @ptrFromInt(can1_base_address + 0x34),
    @ptrFromInt(can2_base_address + 0x34),
};

pub const ESR2_Regs: [3]*volatile ESR2_REG = .{
    @ptrFromInt(can0_base_address + 0x38),
    @ptrFromInt(can1_base_address + 0x38),
    @ptrFromInt(can2_base_address + 0x38),
};

pub const CRCR_Regs: [3]*volatile CRCR_REG = .{
    @ptrFromInt(can0_base_address + 0x44),
    @ptrFromInt(can1_base_address + 0x44),
    @ptrFromInt(can2_base_address + 0x44),
};

pub const RXFGMASK_Regs: [3]*volatile RXFGMASK_REG = .{
    @ptrFromInt(can0_base_address + 0x48),
    @ptrFromInt(can1_base_address + 0x48),
    @ptrFromInt(can2_base_address + 0x48),
};

pub const RXFIR_Regs: [3]*volatile RXFIR_REG = .{
    @ptrFromInt(can0_base_address + 0x4C),
    @ptrFromInt(can1_base_address + 0x4C),
    @ptrFromInt(can2_base_address + 0x4C),
};

pub const CBT_Regs: [3]*volatile CBT_REG = .{
    @ptrFromInt(can0_base_address + 0x50),
    @ptrFromInt(can1_base_address + 0x50),
    @ptrFromInt(can2_base_address + 0x50),
};

pub const CanHeader1 = packed struct(u32) {
    /// [0..15]
    TIME_STAMP: u16,
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
    DLC: u4,
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
    RTR: u1,
    /// [21] ID Extended Bit
    /// This field identifies whether the frame format is standard or extended.
    /// - 1 = Frame format is extended
    /// - 0 = Frame format is standard
    IDE: u1,
    /// [22]  Substitute Remote Request
    /// Fixed recessive bit, used only in extended format. **It must be set to one by the user for
    /// transmission (Tx Buffers) and will be stored with the value received on the CAN bus for
    /// Rx receiving buffers**. It can be received as either recessive or dominant. If FlexCAN
    /// receives this bit as dominant, then it is interpreted as an arbitration loss.
    /// - 1 = Recessive value is compulsory for transmission in extended format frames
    /// - 0 = Dominant is not a valid value for transmission in extended format frames
    SRR: u1,
    RES23: u1,
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
    CODE: u4,
    RES28: u1,
    /// [29] Error State Indicator
    /// - This bit indicates if the transmitting node is error active or error passive.
    ESI: u1,
    /// [30] Bit Rate Switch
    /// - This bit defines whether the bit rate is switched inside a CAN FD format frame.
    /// - 0 close speed up
    /// - 1 start speed up
    BRS: u1,
    /// [31] Extended Data Length
    /// - **distinguishes between CAN format and CAN FD format**
    /// - This bit distinguishes between CAN format and CAN FD format frames. The EDL bit
    /// must not be set for message buffers configured to RANSWER with code field 1010b
    /// - 0 CAN
    /// - 1 CAN FD
    EDL: u1,
};

pub const CanHeader2 = packed struct(u32) {
    /// [0..17]
    ID_EXTEND: u18,
    /// [18..28]
    ID_STD: u11,
    /// [29..31] Local priority
    /// - This 3-bit field is used only when MCR[LPRIO_EN] is set, and it only makes sense for
    /// Tx mailboxes. These bits are not transmitted. They are appended to the regular ID to
    /// define the transmission priority. See Arbitration process.
    PRIO: u3,
};

pub const CanStdBytes = packed struct(u32) {
    /// [0..7] Data byte 4N + 3 of Rx/Tx frame.
    DATA_BYTE_N4Add3: u8,
    /// [8..15] Data byte N4 + 2 of Rx/Tx frame.
    DATA_BYTE_N4Add2: u8,
    /// [16..23] Data byte N4 + 1 of Rx/Tx frame.
    DATA_BYTE_N4Add1: u8,
    /// [24..31] Data byte N4 + 0 of Rx/Tx frame.
    DATA_BYTE_N4Add0: u8,
};

pub const CanMailBox = packed struct(u128) {
    header1: CanHeader1,
    header2: CanHeader2,
    byte1: CanStdBytes,
    byte2: CanStdBytes,
};

pub const CanFDMailBox = packed struct {
    header1: CanHeader1,
    header2: CanHeader2,
    bytes1: CanStdBytes,
    bytes2: CanStdBytes,
    bytes3: CanStdBytes,
    bytes4: CanStdBytes,
    bytes5: CanStdBytes,
    bytes6: CanStdBytes,
    bytes7: CanStdBytes,
    bytes8: CanStdBytes,
    bytes9: CanStdBytes,
    bytes10: CanStdBytes,
    bytes11: CanStdBytes,
    bytes12: CanStdBytes,
    bytes13: CanStdBytes,
    bytes14: CanStdBytes,
    bytes15: CanStdBytes,
    bytes16: CanStdBytes,
};

pub const CAN0_RAMn_Regs: *volatile [128]RAMn_REGS = @ptrFromInt(can0_base_address + 0x80);
pub const CAN1_RAMn_Regs: *volatile [64]RAMn_REGS = @ptrFromInt(can1_base_address + 0x80);
pub const CAN2_RAMn_Regs: *volatile [64]RAMn_REGS = @ptrFromInt(can2_base_address + 0x80);
// can mail box
pub const CAN0_Mailbox: *volatile [32]CanMailBox = @ptrFromInt(can0_base_address + 0x80);
pub const CAN1_Mailbox: *volatile [16]CanMailBox = @ptrFromInt(can1_base_address + 0x80);
pub const CAN2_Mailbox: *volatile [16]CanMailBox = @ptrFromInt(can2_base_address + 0x80);
// can rximr
pub const CAN0_RXIMR_Regs: *volatile [32]RXIMR_REGS = @ptrFromInt(can0_base_address + 0x880);
pub const CAN1_RXIMR_Regs: *volatile [16]RXIMR_REGS = @ptrFromInt(can1_base_address + 0x880);
pub const CAN2_RXIMR_Regs: *volatile [16]RXIMR_REGS = @ptrFromInt(can2_base_address + 0x880);

pub const CTRL1_PN_Regs: [3]*volatile CTRL1_PN_REG = .{
    @ptrFromInt(can0_base_address + 0xB00),
    @ptrFromInt(can1_base_address + 0xB00),
    @ptrFromInt(can2_base_address + 0xB00),
};

pub const CTRL2_PN_Regs: [3]*volatile CTRL2_PN_REG = .{
    @ptrFromInt(can0_base_address + 0xB04),
    @ptrFromInt(can1_base_address + 0xB04),
    @ptrFromInt(can2_base_address + 0xB04),
};

pub const WU_MTC_Regs: [3]*volatile WU_MTC_REG = .{
    @ptrFromInt(can0_base_address + 0xB08),
    @ptrFromInt(can1_base_address + 0xB08),
    @ptrFromInt(can2_base_address + 0xB08),
};

pub const FLT_ID1_Regs: [3]*volatile FLT_ID1_REG = .{
    @ptrFromInt(can0_base_address + 0xB0C),
    @ptrFromInt(can1_base_address + 0xB0C),
    @ptrFromInt(can2_base_address + 0xB0C),
};

pub const FLT_DLC_Regs: [3]*volatile FLT_DLC_REG = .{
    @ptrFromInt(can0_base_address + 0xB10),
    @ptrFromInt(can1_base_address + 0xB10),
    @ptrFromInt(can2_base_address + 0xB10),
};

pub const PL1_LO_Regs: [3]*volatile PL1_LO_REG = .{
    @ptrFromInt(can0_base_address + 0xB14),
    @ptrFromInt(can1_base_address + 0xB14),
    @ptrFromInt(can2_base_address + 0xB14),
};

pub const PL1_HI_Regs: [3]*volatile PL1_HI_REG = .{
    @ptrFromInt(can0_base_address + 0xB18),
    @ptrFromInt(can1_base_address + 0xB18),
    @ptrFromInt(can2_base_address + 0xB18),
};

pub const FLT_ID2_IDMASK_Regs: [3]*volatile FLT_ID2_IDMASK_REG = .{
    @ptrFromInt(can0_base_address + 0xB1C),
    @ptrFromInt(can1_base_address + 0xB1C),
    @ptrFromInt(can2_base_address + 0xB1C),
};

pub const PL2_PLMASK_LO_Regs: [3]*volatile PL2_PLMASK_LO_REG = .{
    @ptrFromInt(can0_base_address + 0xB20),
    @ptrFromInt(can1_base_address + 0xB20),
    @ptrFromInt(can2_base_address + 0xB20),
};

pub const PL2_PLMASK_HI_Regs: [3]*volatile PL2_PLMASK_HI_REG = .{
    @ptrFromInt(can0_base_address + 0xB24),
    @ptrFromInt(can1_base_address + 0xB24),
    @ptrFromInt(can2_base_address + 0xB24),
};

pub const WMB0_CS_Regs: [3]*volatile WMB0_CS_REG = .{
    @ptrFromInt(can0_base_address + 0xB40),
    @ptrFromInt(can1_base_address + 0xB40),
    @ptrFromInt(can2_base_address + 0xB40),
};

pub const WMB0_ID_Regs: [3]*volatile WMB0_ID_REG = .{
    @ptrFromInt(can0_base_address + 0xB44),
    @ptrFromInt(can1_base_address + 0xB44),
    @ptrFromInt(can2_base_address + 0xB44),
};

pub const WMB0_D03_Regs: [3]*volatile WMB0_D03_REG = .{
    @ptrFromInt(can0_base_address + 0xB48),
    @ptrFromInt(can1_base_address + 0xB48),
    @ptrFromInt(can2_base_address + 0xB48),
};

pub const WMB0_D47_Regs: [3]*volatile WMB0_D47_REG = .{
    @ptrFromInt(can0_base_address + 0xB4C),
    @ptrFromInt(can1_base_address + 0xB4C),
    @ptrFromInt(can2_base_address + 0xB4C),
};

pub const WMB1_CS_Regs: [3]*volatile WMB1_CS_REG = .{
    @ptrFromInt(can0_base_address + 0xB50),
    @ptrFromInt(can1_base_address + 0xB50),
    @ptrFromInt(can2_base_address + 0xB50),
};

pub const WMB1_ID_Regs: [3]*volatile WMB1_ID_REG = .{
    @ptrFromInt(can0_base_address + 0xB54),
    @ptrFromInt(can1_base_address + 0xB54),
    @ptrFromInt(can2_base_address + 0xB54),
};

pub const WMB1_D03_Regs: [3]*volatile WMB1_D03_REG = .{
    @ptrFromInt(can0_base_address + 0xB58),
    @ptrFromInt(can1_base_address + 0xB58),
    @ptrFromInt(can2_base_address + 0xB58),
};

pub const WMB1_D47_Regs: [3]*volatile WMB1_D47_REG = .{
    @ptrFromInt(can0_base_address + 0xB5C),
    @ptrFromInt(can1_base_address + 0xB5C),
    @ptrFromInt(can2_base_address + 0xB5C),
};

pub const WMB2_CS_Regs: [3]*volatile WMB2_CS_REG = .{
    @ptrFromInt(can0_base_address + 0xB60),
    @ptrFromInt(can1_base_address + 0xB60),
    @ptrFromInt(can2_base_address + 0xB60),
};

pub const WMB2_ID_Regs: [3]*volatile WMB2_ID_REG = .{
    @ptrFromInt(can0_base_address + 0xB64),
    @ptrFromInt(can1_base_address + 0xB64),
    @ptrFromInt(can2_base_address + 0xB64),
};

pub const WMB2_D03_Regs: [3]*volatile WMB2_D03_REG = .{
    @ptrFromInt(can0_base_address + 0xB68),
    @ptrFromInt(can1_base_address + 0xB68),
    @ptrFromInt(can2_base_address + 0xB68),
};

pub const WMB2_D47_Regs: [3]*volatile WMB2_D47_REG = .{
    @ptrFromInt(can0_base_address + 0xB6C),
    @ptrFromInt(can1_base_address + 0xB6C),
    @ptrFromInt(can2_base_address + 0xB6C),
};

pub const WMB3_CS_Regs: [3]*volatile WMB3_CS_REG = .{
    @ptrFromInt(can0_base_address + 0xB70),
    @ptrFromInt(can1_base_address + 0xB70),
    @ptrFromInt(can2_base_address + 0xB70),
};

pub const WMB3_ID_Regs: [3]*volatile WMB3_ID_REG = .{
    @ptrFromInt(can0_base_address + 0xB74),
    @ptrFromInt(can1_base_address + 0xB74),
    @ptrFromInt(can2_base_address + 0xB74),
};

pub const WMB3_D03_Regs: [3]*volatile WMB3_D03_REG = .{
    @ptrFromInt(can0_base_address + 0xB78),
    @ptrFromInt(can1_base_address + 0xB78),
    @ptrFromInt(can2_base_address + 0xB78),
};

pub const WMB3_D47_Regs: [3]*volatile WMB3_D47_REG = .{
    @ptrFromInt(can0_base_address + 0xB7C),
    @ptrFromInt(can1_base_address + 0xB7C),
    @ptrFromInt(can2_base_address + 0xB7C),
};

pub const FDCTRL_Regs: [3]*volatile FDCTRL_REG = .{
    @ptrFromInt(can0_base_address + 0xC00),
    @ptrFromInt(can1_base_address + 0xC00),
    @ptrFromInt(can2_base_address + 0xC00),
};

pub const FDCBT_Regs: [3]*volatile FDCBT_REG = .{
    @ptrFromInt(can0_base_address + 0xC04),
    @ptrFromInt(can1_base_address + 0xC04),
    @ptrFromInt(can2_base_address + 0xC04),
};

pub const FDCRC_Regs: [3]*volatile FDCRC_REG = .{
    @ptrFromInt(can0_base_address + 0xC08),
    @ptrFromInt(can1_base_address + 0xC08),
    @ptrFromInt(can2_base_address + 0xC08),
};

// new can registers ending -------------------------
