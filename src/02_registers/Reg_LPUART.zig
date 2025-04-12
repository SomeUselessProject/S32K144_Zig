//! LPUART Registers
//! - version: 0.1.0
//! - author: weng
//! - lastDate: 2025/02/27

const RegType = @import("./RegType.zig");

const lpuart0_base_addr: u32 = 0x4006_A000;
const lpuart1_base_addr: u32 = 0x4006_B000;
const lpuart2_base_addr: u32 = 0x4006_C000;

/// Version ID Register
/// - addr offset is 0
/// - reset value is 0x4010003
pub const LPUART_VERID = struct {
    pub const reg_ins_arr: [3]RegType.RegIns = [3]RegType.RegIns{
        RegType.RegIns.init(lpuart0_base_addr + 0x00),
        RegType.RegIns.init(lpuart1_base_addr + 0x00),
        RegType.RegIns.init(lpuart2_base_addr + 0x00),
    };

    /// Feature Identification Number
    /// - 1 Standard feature set.
    /// - 3 Standard feature set with MODEM/IrDA support.
    pub const FEATURE = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 16,
    };

    /// Minor Version Number
    pub const MINOR = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 8,
    };
    /// Major Version Number
    pub const MAJOR = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 8,
    };
};

/// Parameter Register
/// - addr offset 0x4
/// - reset value is 0x202
pub const LPUART_PARAM = struct {
    pub const reg_ins_arr: [3]RegType.RegIns = [3]RegType.RegIns{
        RegType.RegIns.init(lpuart0_base_addr + 0x4),
        RegType.RegIns.init(lpuart1_base_addr + 0x4),
        RegType.RegIns.init(lpuart2_base_addr + 0x4),
    };

    /// Transmit FIFO Size
    pub const TXFIFO = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 8,
    };

    /// Receive FIFO Size
    pub const RXFIFO = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 8,
    };
};

/// LPUART Global Register
/// - addr ofsset is 0x8
/// - reset value is 0
pub const LPUART_GLOBAL = struct {
    pub const reg_ins_arr: [3]RegType.RegIns = [3]RegType.RegIns{
        RegType.RegIns.init(lpuart0_base_addr + 0x8),
        RegType.RegIns.init(lpuart1_base_addr + 0x8),
        RegType.RegIns.init(lpuart2_base_addr + 0x8),
    };

    /// Software Reset
    /// - 0 Module is not reset.
    /// - 1 Module is reset.
    pub const RST = RegType.FieldDef{
        .bit_start = 1,
        .bit_len = 1,
    };
};

/// LPUART Pin Configuration Register
/// - addr offset 0xC
/// - reset value is 0
pub const LPUART_PINCFG = struct {
    pub const reg_ins_arr: [3]RegType.RegIns = [3]RegType.RegIns{
        RegType.RegIns.init(lpuart0_base_addr + 0xC),
        RegType.RegIns.init(lpuart1_base_addr + 0xC),
        RegType.RegIns.init(lpuart2_base_addr + 0xC),
    };

    /// Trigger Select
    /// - 00 Input trigger is disabled.
    /// - 01 Input trigger is used instead of RXD pin input.
    /// - 10 Input trigger is used instead of CTS_B pin input.
    /// - 11 Input trigger is used to modulate the TXD pin output. The
    /// TXD pin output (after TXINV configuration) is ANDed with the input trigger.
    pub const TRGSEL = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 2,
    };
};

/// LPUART Baud Rate Register
/// - addr ofsset is 0x10
/// - reset value is 0xF000004
pub const LPUART_BAUD = struct {
    pub const reg_ins_arr: [3]RegType.RegIns = [3]RegType.RegIns{
        RegType.RegIns.init(lpuart0_base_addr + 0x10),
        RegType.RegIns.init(lpuart1_base_addr + 0x10),
        RegType.RegIns.init(lpuart2_base_addr + 0x10),
    };

    /// Baud Rate Modulo Divisor.
    pub const SBR = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 13,
    };

    /// Stop Bit Number Select
    /// - 0 One stop bit.
    /// - 1 Two stop bits.
    pub const SBNS = RegType.FieldDef{
        .bit_start = 13,
        .bit_len = 1,
    };

    /// RX Input Active Edge Interrupt Enable
    /// - 0 'Hardware interrupts from LPUART_STAT[RXEDGIF] disabled.'
    /// - 1 Hardware interrupt requested when LPUART_STAT[RXEDGIF] flag is 1.
    pub const RXEDGIE = RegType.FieldDef{
        .bit_start = 14,
        .bit_len = 1,
    };

    /// LIN Break Detect Interrupt Enable
    /// - 0 Hardware interrupts from LPUART_STAT[LBKDIF] disabled (use polling).
    /// - 1 Hardware interrupt requested when LPUART_STAT[LBKDIF] flag is 1.
    pub const LBKDIE = RegType.FieldDef{
        .bit_start = 15,
        .bit_len = 1,
    };

    /// Resynchronization Disable
    /// - 0 Resynchronization during received data word is supported
    /// - 1 Resynchronization during received data word is disabled
    pub const RESYNCDIS = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 1,
    };

    /// Both Edge Sampling
    /// - 0 Receiver samples input data using the rising edge of the baud rate clock.
    /// - 1 Receiver samples input data using the rising and falling
    /// edge of the baud rate clock.
    pub const BOTHEDGE = RegType.FieldDef{
        .bit_start = 17,
        .bit_len = 1,
    };

    /// Match Configuration
    /// - 00 Address Match Wakeup
    /// - 01 Idle Match Wakeup
    /// - 10 Match On and Match Off
    pub const MATCFG = RegType.FieldDef{
        .bit_start = 18,
        .bit_len = 2,
    };

    /// Receiver Idle DMA Enable
    /// - 0 DMA request disabled.
    /// - 1 DMA request enabled.
    pub const RIDMAE = RegType.FieldDef{
        .bit_start = 20,
        .bit_len = 1,
    };

    /// Receiver Full DMA Enable
    /// - 0 DMA request disabled.
    /// - 1 DMA request enabled.
    pub const RDMAE = RegType.FieldDef{
        .bit_start = 21,
        .bit_len = 1,
    };

    /// Transmitter DMA Enable
    /// - 0 DMA request disabled.
    /// - 1 DMA request enabled.
    pub const TDMAE = RegType.FieldDef{
        .bit_start = 23,
        .bit_len = 1,
    };

    /// Oversampling Ratio
    /// - 00000 Writing 0 to this field will result in an oversampling ratio of 16
    /// - 00011 Oversampling ratio of 4, requires BOTHEDGE to be set.
    /// - 00100 Oversampling ratio of 5, requires BOTHEDGE to be set
    /// - 00101 Oversampling ratio of 6, requires BOTHEDGE to be set
    /// - 00110 Oversampling ratio of 7, requires BOTHEDGE to be set.
    /// - 00111 Oversampling ratio of 8.
    /// - 01000 Oversampling ratio of 9.
    /// - 01001 Oversampling ratio of 10.
    /// - 01010 Oversampling ratio of 11.
    /// - 01011 Oversampling ratio of 12.
    /// - 01100 Oversampling ratio of 13.
    /// - 01101 ~ 11111 Oversampling ratio of 14 - 32
    pub const OSR = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 5,
    };

    /// 10-bit Mode select
    /// - 0 Receiver and transmitter use 7-bit to 9-bit data characters.
    /// - 1 Receiver and transmitter use 10-bit data characters.
    pub const M10 = RegType.FieldDef{
        .bit_start = 29,
        .bit_len = 1,
    };

    /// Match Address Mode Enable 2
    /// - 0 Normal operation.
    /// - 1 Enables automatic address matching or data matching mode
    /// for MATCH[MA2].
    pub const MAEN2 = RegType.FieldDef{
        .bit_start = 30,
        .bit_len = 1,
    };

    /// Match Address Mode Enable 1
    /// - 0 Normal operation.
    /// - 1 Enables automatic address matching or data matching mode
    /// for MATCH[MA1].
    pub const MAEN1 = RegType.FieldDef{
        .bit_start = 31,
        .bit_len = 1,
    };
};

/// LPUART Status Register
/// - addressOffset: '0x14'
/// - resetValue: '0xC00000'
pub const LPUART_STAT = struct {
    pub const reg_ins_arr: [3]RegType.RegIns = [3]RegType.RegIns{
        RegType.RegIns.init(lpuart0_base_addr + 0x14),
        RegType.RegIns.init(lpuart1_base_addr + 0x14),
        RegType.RegIns.init(lpuart2_base_addr + 0x14),
    };

    /// Match 2 Flag
    /// - 0 Received data is not equal to MA2
    /// - 1 Received data is equal to MA2
    pub const MA2F = RegType.FieldDef{
        .bit_start = 14,
        .bit_len = 1,
    };

    /// Match 1 Flag
    /// - 0 Received data is not equal to MA1
    /// - 1 Received data is equal to MA1
    pub const MA1F = RegType.FieldDef{
        .bit_start = 15,
        .bit_len = 1,
    };

    /// Parity Error Flag
    /// - 0 No parity error.
    /// - 1 Parity error.
    pub const PF = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 1,
    };

    /// Framing Error Flag
    /// - 0 No framing error detected. This does not guarantee the
    /// framing is correct.
    /// - 1 Framing error.
    pub const FE = RegType.FieldDef{
        .bit_start = 17,
        .bit_len = 1,
    };

    /// Noise Flag
    /// - 0 No noise detected.
    /// - 1 Noise detected in the received character in LPUART_DATA.
    pub const NF = RegType.FieldDef{
        .bit_start = 18,
        .bit_len = 1,
    };

    /// Receiver Overrun Flag
    /// - 0 No overrun.
    /// - 1 Receive overrun (new LPUART data lost).
    pub const OR = RegType.FieldDef{
        .bit_start = 19,
        .bit_len = 1,
    };

    /// Idle Line Flag
    /// - 0 No idle line detected.
    /// - 1 Idle line was detected.
    pub const IDLE = RegType.FieldDef{
        .bit_start = 20,
        .bit_len = 1,
    };

    /// Receive Data Register Full Flag
    /// - 0 Receive data buffer empty.
    /// - 1 Receive data buffer full
    pub const RDRF = RegType.FieldDef{
        .bit_start = 21,
        .bit_len = 1,
    };

    /// Transmission Complete Flag
    /// - 0 Transmitter active (sending data, a preamble, or a break)
    /// - 1 Transmitter idle (transmission activity complete).
    pub const TC = RegType.FieldDef{
        .bit_start = 22,
        .bit_len = 1,
    };

    /// Transmit Data Register Empty Flag
    /// - 0 Transmit data buffer full.
    /// - 1 Transmit data buffer empty.
    pub const TDRE = RegType.FieldDef{
        .bit_start = 23,
        .bit_len = 1,
    };

    /// Receiver Active Flag
    /// - 0 LPUART receiver idle waiting for a start bit.
    /// - 1 LPUART receiver active (RXD input not idle).
    pub const RAF = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 1,
    };

    /// LIN Break Detection Enable
    /// - 0 LIN break detect is disabled, normal break character can
    /// be detected.
    /// - 1 LIN break detect is enabled. LIN break character is
    /// detected at length of 11 bit times (if M = 0) or 12 (if M = 1) or 13 (M10 = 1).
    pub const LBKDE = RegType.FieldDef{
        .bit_start = 25,
        .bit_len = 1,
    };

    /// Break Character Generation Length
    /// - 0 Break character is transmitted with length of 9 to 13 bit times.
    /// - 1 Break character is transmitted with length of 12 to 15 bit times.
    pub const BRK13 = RegType.FieldDef{
        .bit_start = 26,
        .bit_len = 1,
    };

    /// Receive Wake Up Idle Detect
    /// - 0 During receive standby state (RWU = 1), the IDLE bit does
    /// not get set upon detection of an idle character. During
    /// address match wakeup, the IDLE bit does not set when an address does not match.
    /// - 1 During receive standby state (RWU = 1), the IDLE bit gets
    /// set upon detection of an idle character. During address
    /// match wakeup, the IDLE bit does set when an address does not match.
    pub const RWUID = RegType.FieldDef{
        .bit_start = 27,
        .bit_len = 1,
    };

    /// Receive Data Inversion
    /// - 0 Receive data not inverted.
    /// - 1 Receive data inverted.
    pub const RXINV = RegType.FieldDef{
        .bit_start = 28,
        .bit_len = 1,
    };

    /// MSB First
    /// - 0 LSB (bit0) is the first bit that is transmitted following
    /// the start bit. Further, the first bit received after the
    /// start bit is identified as bit0.
    /// - 1  MSB (bit9, bit8, bit7 or bit6) is the first bit that is
    /// transmitted following the start bit depending on the
    /// setting of CTRL[M], CTRL[PE] and BAUD[M10]. Further, the
    /// first bit received after the start bit is identified as
    /// bit9, bit8, bit7 or bit6 depending on the setting of CTRL[M] and CTRL[PE].
    pub const MSBF = RegType.FieldDef{
        .bit_start = 29,
        .bit_len = 1,
    };

    /// RXD Pin Active Edge Interrupt Flag
    /// - 0 No active edge on the receive pin has occurred.
    /// - 1 An active edge on the receive pin has occurred.
    pub const RXEDGIF = RegType.FieldDef{
        .bit_start = 30,
        .bit_len = 1,
    };

    /// LIN Break Detect Interrupt Flag
    /// - 0 No LIN break character has been detected.
    /// - 1 LIN break character has been detected.
    pub const LBKDIF = RegType.FieldDef{
        .bit_start = 31,
        .bit_len = 1,
    };
};

/// LPUART Control Register
/// - addressOffset: '0x18'
/// - resetValue: '0'
pub const LPUART_CTRL = struct {
    pub const reg_ins_arr: [3]RegType.RegIns = [3]RegType.RegIns{
        RegType.RegIns.init(lpuart0_base_addr + 0x18),
        RegType.RegIns.init(lpuart1_base_addr + 0x18),
        RegType.RegIns.init(lpuart2_base_addr + 0x18),
    };

    /// Parity Type
    /// - 0 Even parity.
    /// - 1 Odd parity.
    pub const PT = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 1,
    };

    /// Parity Enable
    /// - 0 No hardware parity generation or checking.
    /// - 1 Parity enabled.
    pub const PE = RegType.FieldDef{
        .bit_start = 1,
        .bit_len = 1,
    };

    /// Idle Line Type Select
    /// - 0 Idle character bit count starts after start bit.
    /// - 1 Idle character bit count starts after stop bit.
    pub const ILT = RegType.FieldDef{
        .bit_start = 2,
        .bit_len = 1,
    };

    /// Receiver Wakeup Method Select
    /// - 0 Configures RWU for idle-line wakeup.
    /// - 1 Configures RWU with address-mark wakeup.
    pub const WAKE = RegType.FieldDef{
        .bit_start = 3,
        .bit_len = 1,
    };
    /// 9-Bit or 8-Bit Mode Select
    /// - 0 Receiver and transmitter use 8-bit data characters.
    /// - 1 Receiver and transmitter use 9-bit data characters.
    pub const M = RegType.FieldDef{
        .bit_start = 4,
        .bit_len = 1,
    };

    /// Receiver Source Select
    /// - 0  Provided LOOPS is set, RSRC is cleared, selects internal
    /// loop back mode and the LPUART does not use the RXD pin.
    /// - 1 Single-wire LPUART mode where the TXD pin is connected to
    /// the transmitter output and receiver input.
    pub const RSRC = RegType.FieldDef{
        .bit_start = 5,
        .bit_len = 1,
    };

    /// Doze Enable
    /// - 0 LPUART is enabled in Doze mode.
    /// - 1 LPUART is disabled in Doze mode.
    pub const DOZEEN = RegType.FieldDef{
        .bit_start = 6,
        .bit_len = 1,
    };

    /// Loop Mode Select
    /// - 0 Normal operation - RXD and TXD use separate pins
    /// - 1 Loop mode or single-wire mode where transmitter outputs
    /// are internally connected to receiver input (see RSRC bit).
    pub const LOOPS = RegType.FieldDef{
        .bit_start = 7,
        .bit_len = 1,
    };

    /// Idle Configuration
    /// - 000 1 idle character
    /// - 001 2 idle characters
    /// - 010 4 idle characters
    /// - 011 8 idle characters
    /// - 100 16 idle characters
    /// - 101 32 idle characters
    /// - 110 64 idle characters
    /// - 111 128 idle characters
    pub const IDLECFG = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 3,
    };

    /// 7-Bit Mode Select
    /// - 0 Receiver and transmitter use 8-bit to 10-bit data characters.
    /// - 1 Receiver and transmitter use 7-bit data characters.
    pub const M7 = RegType.FieldDef{
        .bit_start = 11,
        .bit_len = 1,
    };

    /// Match 2 Interrupt Enable
    /// - 0 MA2F interrupt disabled
    /// - 1 MA2F interrupt enabled
    pub const MA2IE = RegType.FieldDef{
        .bit_start = 14,
        .bit_len = 1,
    };

    /// Match 1 Interrupt Enable
    /// - 0 MA1F interrupt disabled
    /// - 1 MA1F interrupt enabled
    pub const MA1IE = RegType.FieldDef{
        .bit_start = 15,
        .bit_len = 1,
    };

    /// Send Break
    /// - 0 Normal transmitter operation.
    /// - 1 Queue break character(s) to be sent.
    pub const SBK = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 1,
    };

    /// Receiver Wakeup Control
    /// - 0 Normal receiver operation.
    /// - 1 LPUART receiver in standby waiting for wakeup condition
    pub const RWU = RegType.FieldDef{
        .bit_start = 17,
        .bit_len = 1,
    };

    /// Receiver Enable
    /// - 0 Receiver disabled.
    /// - 1 Receiver enabled.
    pub const RE = RegType.FieldDef{
        .bit_start = 18,
        .bit_len = 1,
    };
    /// Transmitter Enable
    /// - 0 Transmitter disabled.
    /// - 1 Transmitter enabled.
    pub const TE = RegType.FieldDef{
        .bit_start = 19,
        .bit_len = 1,
    };

    /// Idle Line Interrupt Enable
    /// - 0 Hardware interrupts from IDLE disabled; use polling.
    /// - 1 Hardware interrupt requested when IDLE flag is 1.
    pub const ILIE = RegType.FieldDef{
        .bit_start = 20,
        .bit_len = 1,
    };

    /// Receiver Interrupt Enable
    /// - 0 Hardware interrupts from RDRF disabled; use polling.
    /// - 1 Hardware interrupt requested when RDRF flag is 1.
    pub const RIE = RegType.FieldDef{
        .bit_start = 21,
        .bit_len = 1,
    };

    /// Transmission Complete Interrupt Enable for
    /// - 0 Hardware interrupts from TC disabled; use polling.
    /// - 1 Hardware interrupt requested when TC flag is 1.
    pub const TCIE = RegType.FieldDef{
        .bit_start = 22,
        .bit_len = 1,
    };

    /// Transmit Interrupt Enable
    /// - 0 Hardware interrupts from TDRE disabled; use polling.
    /// - 1 Hardware interrupt requested when TDRE flag is 1.
    pub const TIE = RegType.FieldDef{
        .bit_start = 23,
        .bit_len = 1,
    };

    /// Parity Error Interrupt Enable
    /// - 0 PF interrupts disabled; use polling).
    /// - 1 Hardware interrupt requested when PF is set.
    pub const PEIE = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 1,
    };

    /// Framing Error Interrupt Enable
    /// - 0 FE interrupts disabled; use polling.
    /// - 1 Hardware interrupt requested when FE is set.
    pub const FEIE = RegType.FieldDef{
        .bit_start = 25,
        .bit_len = 1,
    };

    /// Noise Error Interrupt Enable
    /// - 0 NF interrupts disabled; use polling.
    /// - 1 NF interrupts disabled; use polling.
    pub const NEIE = RegType.FieldDef{
        .bit_start = 26,
        .bit_len = 1,
    };

    /// OR interrupts disabled; use polling.
    /// - 0 OR interrupts disabled; use polling.
    /// - 1 Hardware interrupt requested when OR is set.
    pub const ORIE = RegType.FieldDef{
        .bit_start = 27,
        .bit_len = 1,
    };

    /// Transmit Data Inversion
    /// - 0 Transmit data not inverted.
    /// - 1 Transmit data inverted.
    pub const TXINV = RegType.FieldDef{
        .bit_start = 28,
        .bit_len = 1,
    };

    /// TXD Pin Direction in Single-Wire Mode
    /// - 0 TXD pin is an input in single-wire mode.
    /// - 1 TXD pin is an output in single-wire mode.
    pub const TXDIR = RegType.FieldDef{
        .bit_start = 29,
        .bit_len = 1,
    };

    /// Receive Bit 9 / Transmit Bit 8
    pub const R9T8 = RegType.FieldDef{
        .bit_start = 30,
        .bit_len = 1,
    };

    /// Receive Bit 8 / Transmit Bit 9
    pub const R8T9 = RegType.FieldDef{
        .bit_start = 31,
        .bit_len = 1,
    };
};

/// LPUART Data Register
/// - addressOffset: '0x1C'
/// - resetValue: '0x1000'
pub const LPUART_DATA = struct {
    pub const reg_ins_arr: [3]RegType.RegIns = [3]RegType.RegIns{
        RegType.RegIns.init(lpuart0_base_addr + 0x1C),
        RegType.RegIns.init(lpuart1_base_addr + 0x1C),
        RegType.RegIns.init(lpuart2_base_addr + 0x1C),
    };

    pub const R0T0 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 1,
    };

    pub const R1T1 = RegType.FieldDef{
        .bit_start = 1,
        .bit_len = 1,
    };

    pub const R2T2 = RegType.FieldDef{
        .bit_start = 2,
        .bit_len = 1,
    };

    pub const R3T3 = RegType.FieldDef{
        .bit_start = 3,
        .bit_len = 1,
    };

    pub const R4T4 = RegType.FieldDef{
        .bit_start = 4,
        .bit_len = 1,
    };

    pub const R5T5 = RegType.FieldDef{
        .bit_start = 5,
        .bit_len = 1,
    };
    pub const R6T6 = RegType.FieldDef{
        .bit_start = 6,
        .bit_len = 1,
    };
    pub const R7T7 = RegType.FieldDef{
        .bit_start = 7,
        .bit_len = 1,
    };
    pub const R8T8 = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 1,
    };
    pub const R9T9 = RegType.FieldDef{
        .bit_start = 9,
        .bit_len = 1,
    };
    /// Idle Line
    /// - 0 Receiver was not idle before receiving this character
    /// - 1 Receiver was idle before receiving this character.
    pub const IDLINE = RegType.FieldDef{
        .bit_start = 11,
        .bit_len = 1,
    };

    /// Receive Buffer Empty
    /// - 0 Receive buffer contains valid data.
    /// - 1 Receive buffer is empty, data returned on read is not valid.
    pub const RXEMPT = RegType.FieldDef{
        .bit_start = 12,
        .bit_len = 1,
    };

    /// Frame Error / Transmit Special Character
    /// - 0 The dataword was received without a frame error on read,
    /// or transmit a normal character on write.
    /// - 1  The dataword was received with a frame error, or transmit
    /// an idle or break character on transmit.
    pub const FRETSC = RegType.FieldDef{
        .bit_start = 13,
        .bit_len = 1,
    };

    /// PARITYE
    /// - 0 The dataword was received without a parity error.
    /// - 1 The dataword was received with a parity error.
    pub const PARITYE = RegType.FieldDef{
        .bit_start = 14,
        .bit_len = 1,
    };

    /// NOISY
    /// - 0 The dataword was received without noise.
    /// - 1 The data was received with noise.
    pub const NOISY = RegType.FieldDef{
        .bit_start = 15,
        .bit_len = 1,
    };
};

/// LPUART Match Address Register
/// - addressOffset: '0x20'
/// - resetValue: '0'
pub const LPUART_MATCH = struct {
    pub const reg_ins_arr: [3]RegType.RegIns = [3]RegType.RegIns{
        RegType.RegIns.init(lpuart0_base_addr + 0x20),
        RegType.RegIns.init(lpuart1_base_addr + 0x20),
        RegType.RegIns.init(lpuart2_base_addr + 0x20),
    };

    /// Match Address 1
    pub const MA1 = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 10,
    };

    /// Match Address 2
    pub const MA2 = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 10,
    };
};

/// LPUART Modem IrDA Register
/// - addressOffset: '0x24'
/// - resetValue: '0'
pub const LPUART_MODIR = struct {
    pub const reg_ins_arr: [3]RegType.RegIns = [3]RegType.RegIns{
        RegType.RegIns.init(lpuart0_base_addr + 0x24),
        RegType.RegIns.init(lpuart1_base_addr + 0x24),
        RegType.RegIns.init(lpuart2_base_addr + 0x24),
    };

    /// Transmitter clear-to-send enable
    /// - 0 CTS has no effect on the transmitter.
    /// - 1 Enables clear-to-send operation. The transmitter checks
    /// the state of CTS each time it is ready to send a
    /// character. If CTS is asserted, the character is sent. If
    /// CTS is deasserted, the signal TXD remains in the mark
    /// state and transmission is delayed until CTS is asserted.
    /// Changes in CTS as a character is being sent do not affect its transmission.
    pub const TXCTSE = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 1,
    };

    /// Transmitter request-to-send enable
    /// - 0 The transmitter has no effect on RTS.
    /// - 1 When a character is placed into an empty transmitter data
    /// buffer , RTS asserts one bit time before the start bit is
    /// transmitted. RTS deasserts one bit time after all
    /// characters in the transmitter data buffer and shift
    /// register are completely sent, including the last stop bit.
    pub const TXRTSE = RegType.FieldDef{
        .bit_start = 1,
        .bit_len = 1,
    };

    /// Transmitter request-to-send polarity
    /// - 0 Transmitter RTS is active low.
    /// - 1 Transmitter RTS is active high.
    pub const TXRTSPOL = RegType.FieldDef{
        .bit_start = 2,
        .bit_len = 1,
    };

    /// Receiver request-to-send enable
    /// - 0 The receiver has no effect on RTS.
    pub const RXRTSE = RegType.FieldDef{
        .bit_start = 3,
        .bit_len = 1,
    };

    /// Transmit CTS Configuration
    /// - 0 CTS input is sampled at the start of each character.
    /// - 1 CTS input is sampled when the transmitter is idle.
    pub const TXCTSC = RegType.FieldDef{
        .bit_start = 4,
        .bit_len = 1,
    };

    /// Transmit CTS Source
    /// - 0 CTS input is the CTS_B pin.
    /// - 1 CTS input is the inverted Receiver Match result.
    pub const TXCTSSRC = RegType.FieldDef{
        .bit_start = 5,
        .bit_len = 1,
    };

    /// Receive RTS Configuration
    pub const RTSWATER = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 2,
    };

    /// Transmitter narrow pulse
    /// - 00 1/OSR.
    /// - 01 2/OSR.
    /// - 10 3/OSR.
    /// - 11 4/OSR.
    pub const TNP = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 2,
    };

    /// Infrared enable
    /// - 0 IR disabled.
    /// - 1 IR enabled.
    pub const IREN = RegType.FieldDef{
        .bit_start = 18,
        .bit_len = 1,
    };
};

/// LPUART FIFO Register
/// - addressOffset: '0x28'
/// - resetValue: '0xC00011'
pub const LPUART_FIFO = struct {
    pub const reg_ins_arr: [3]RegType.RegIns = [3]RegType.RegIns{
        RegType.RegIns.init(lpuart0_base_addr + 0x28),
        RegType.RegIns.init(lpuart1_base_addr + 0x28),
        RegType.RegIns.init(lpuart2_base_addr + 0x28),
    };

    /// Receive FIFO. Buffer Depth
    /// - 000 Receive FIFO/Buffer depth = 1 dataword.
    /// - 001 Receive FIFO/Buffer depth = 4 datawords.
    /// - 010 Receive FIFO/Buffer depth = 8 datawords.
    /// - 011 Receive FIFO/Buffer depth = 16 datawords.
    /// - 100 Receive FIFO/Buffer depth = 32 datawords.
    /// - 101 Receive FIFO/Buffer depth = 64 datawords.
    /// - 110 Receive FIFO/Buffer depth = 128 datawords.
    /// - 111 Receive FIFO/Buffer depth = 256 datawords.
    pub const RXFIFOSIZE = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 3,
    };

    /// Receive FIFO Enable
    /// - 0 Receive FIFO is not enabled. Buffer is depth 1. (Legacy support)
    /// - 1 Receive FIFO is enabled. Buffer is depth indicted by RXFIFOSIZE.
    pub const RXFE = RegType.FieldDef{
        .bit_start = 3,
        .bit_len = 1,
    };

    /// Transmit FIFO. Buffer Depth
    /// - 000 Transmit FIFO/Buffer depth = 1 dataword.
    /// - 001 Transmit FIFO/Buffer depth = 4 datawords.
    /// - 010 Transmit FIFO/Buffer depth = 8 datawords.
    /// - 011 Transmit FIFO/Buffer depth = 16 datawords.
    /// - 100 Transmit FIFO/Buffer depth = 32 datawords.
    /// - 101 Transmit FIFO/Buffer depth = 64 datawords.
    /// - 110 Transmit FIFO/Buffer depth = 128 datawords.
    /// - 111 Transmit FIFO/Buffer depth = 256 datawords
    pub const TXFIFOSIZE = RegType.FieldDef{
        .bit_start = 4,
        .bit_len = 3,
    };

    /// Transmit FIFO Enable
    /// - 0 FIFO is not enabled. Buffer is depth 1. (Legacy support).
    /// - 1 Transmit FIFO is enabled. Buffer is depth indicated by TXFIFOSIZE.
    pub const TXFE = RegType.FieldDef{
        .bit_start = 7,
        .bit_len = 1,
    };

    /// Receive FIFO Underflow Interrupt Enable
    /// - 0 RXUF flag does not generate an interrupt to the host.
    /// - 1 RXUF flag generates an interrupt to the host.
    pub const RXUFE = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 1,
    };

    /// Transmit FIFO Overflow Interrupt Enable
    /// - 0 TXOF flag does not generate an interrupt to the host.
    /// - 1 TXOF flag generates an interrupt to the host.
    pub const TXOFE = RegType.FieldDef{
        .bit_start = 9,
        .bit_len = 1,
    };

    /// Receiver Idle Empty Enable
    /// - 000 Disable RDRF assertion due to partially filled FIFO when receiver is idle.
    /// - 001 Enable RDRF assertion due to partially filled FIFO when
    /// receiver is idle for 1 character.
    /// - 010 Enable RDRF assertion due to partially filled FIFO when
    /// receiver is idle for 2 characters.
    /// - 011 Enable RDRF assertion due to partially filled FIFO when
    /// receiver is idle for 4 characters.
    /// - 100 Enable RDRF assertion due to partially filled FIFO when
    /// receiver is idle for 8 characters.
    /// - 101 Enable RDRF assertion due to partially filled FIFO when
    /// receiver is idle for 16 characters.
    /// - 110 Enable RDRF assertion due to partially filled FIFO when
    /// receiver is idle for 32 characters.
    /// - 111  Enable RDRF assertion due to partially filled FIFO when
    /// receiver is idle for 64 characters.
    pub const RXIDEN = RegType.FieldDef{
        .bit_start = 10,
        .bit_len = 3,
    };

    /// Receive FIFO/Buffer Flush
    /// - 0 No flush operation occurs.
    /// - 1 All data in the receive FIFO/buffer is cleared out
    pub const RXFLUSH = RegType.FieldDef{
        .bit_start = 14,
        .bit_len = 1,
    };

    /// Transmit FIFO/Buffer Flush
    /// - 0 No flush operation occurs.
    /// - 1 All data in the transmit FIFO/Buffer is cleared out.
    pub const TXFLUSH = RegType.FieldDef{
        .bit_start = 15,
        .bit_len = 1,
    };

    /// Receiver Buffer Underflow Flag
    /// - 0 No receive buffer underflow has occurred since the last
    /// time the flag was cleared.
    /// - 1 At least one receive buffer underflow has occurred since
    /// the last time the flag was cleared.
    pub const RXUF = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 1,
    };

    /// Transmitter Buffer Overflow Flag
    /// - 0 No transmit buffer overflow has occurred since the last
    /// time the flag was cleared.
    /// - 1 At least one transmit buffer overflow has occurred since
    /// the last time the flag was cleared
    pub const TXOF = RegType.FieldDef{
        .bit_start = 17,
        .bit_len = 1,
    };

    /// Receive Buffer/FIFO Empty
    /// - 0 Receive buffer is not empty.
    /// - 1 Receive buffer is empty.
    pub const RXEMPT = RegType.FieldDef{
        .bit_start = 22,
        .bit_len = 1,
    };

    /// Transmit Buffer/FIFO Empty
    /// - 0 Transmit buffer is not empty.
    /// - 1 Transmit buffer is empty.
    pub const TXEMPT = RegType.FieldDef{
        .bit_start = 23,
        .bit_len = 1,
    };
};

/// LPUART Watermark Register
/// - addressOffset: '0x2C'
/// - resetValue: '0'
pub const LPUART_WATER = struct {
    pub const reg_ins_arr: [3]RegType.RegIns = [3]RegType.RegIns{
        RegType.RegIns.init(lpuart0_base_addr + 0x2C),
        RegType.RegIns.init(lpuart1_base_addr + 0x2C),
        RegType.RegIns.init(lpuart2_base_addr + 0x2C),
    };

    /// Transmit Watermark
    pub const TXWATER = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 2,
    };

    /// Transmit Counter
    pub const TXCOUNT = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 3,
    };

    /// Receive Watermark
    pub const RXWATER = RegType.FieldDef{
        .bit_start = 16,
        .bit_len = 2,
    };

    /// Receive Counter
    pub const RXCOUNT = RegType.FieldDef{
        .bit_start = 24,
        .bit_len = 3,
    };
};
