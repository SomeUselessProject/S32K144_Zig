//! WDOG Registers
//! - date:2025/02/21
//! - author: weng
//! - version: 0.3.0
//! - use regtype to handle all th registers

const RegType = @import("./RegType.zig");

const baseAddress: u32 = 0x4005_2000;
// new coding 0228 --------------------------------------------------------------------

/// Watchdog Control and Status Register
/// - resetValue: '0x2980'
/// - reset value is 0b 0010 1001 1000 0000
pub const WDOG_CS = struct {
    pub const reg_ins = RegType.RegIns.init(baseAddress + 0x0);
    /// [0] STOP ENABLE
    /// - 0 - description: Watchdog disabled in chip stop mode.
    /// - 1 - description: Watchdog enabled in chip stop mode.
    pub const STOP = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 1,
    };
    /// [1] Wait Enable
    /// - 0 - Watchdog disabled in chip wait mode.
    /// - 1 - Watchdog enabled in chip wait mode
    pub const WAIT = RegType.FieldDef{
        .bit_start = 1,
        .bit_len = 1,
    };
    /// [2] Debug Enable
    /// - 0 Watchdog disabled in chip debug mode.
    /// - 1 Watchdog enabled in chip debug mode.
    pub const DBG = RegType.FieldDef{
        .bit_start = 2,
        .bit_len = 1,
    };
    /// [3..4] Watchdog Test
    /// - 00 Watchdog test mode disabled.
    /// - 01 Watchdog user mode enabled. (Watchdog test mode disabled.)
    /// After testing the watchdog, software should use this
    /// setting to indicate that the watchdog is functioning
    /// normally in user mode.
    /// - 10 Watchdog test mode enabled, only the low byte is used.CNT[CNTLOW] is compared with TOVAL[TOVALLOW].
    /// - 11 Watchdog test mode enabled, only the high byte is used.CNT[CNTHIGH] is compared with TOVAL[TOVALHIGH].
    pub const TST = RegType.FieldDef{
        .bit_start = 3,
        .bit_len = 2,
    };
    /// [5] Allow updates
    /// - 0 Updates not allowed. After the initial configuration,
    /// the watchdog cannot be later modified without forcing a reset.
    /// - 1 Updates allowed. Software can modify the watchdog
    /// configuration registers within 8'd128 bus clocks after
    /// performing the unlock write sequence.
    pub const UPDATE = RegType.FieldDef{
        .bit_start = 5,
        .bit_len = 1,
    };
    /// [6] Watchdog Interrupt
    /// - 0 Watchdog interrupts are disabled. Watchdog resets are not delayed.
    /// - 1 Watchdog interrupts are enabled. Watchdog resets are
    /// delayed by 8'd128 bus clocks from the interrupt vector fetch.
    pub const INT = RegType.FieldDef{
        .bit_start = 6,
        .bit_len = 1,
    };
    /// [7] Watchdog Enable
    /// - 0 Watchdog disabled.
    /// - 1 Watchdog enabled.
    pub const EN = RegType.FieldDef{
        .bit_start = 7,
        .bit_len = 1,
    };
    /// [8..9] Watchdog Clock
    /// - 00 Bus clock
    /// - 01 LPO clock
    /// - 10 INTCLK (internal clock)
    /// - 11 ERCLK (external reference clock)
    pub const CLK = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 2,
    };
    /// [10] Reconfiguration Success
    /// - 0 Reconfiguring WDOG
    /// - 1 Reconfiguration is successful.
    pub const RCS = RegType.FieldDef{
        .bit_start = 10,
        .bit_len = 1,
    };
    /// [11] Unlock status
    /// - 0 WDOG is locked.
    /// - 1 WDOG is unlocked
    pub const ULK = RegType.FieldDef{
        .bit_start = 11,
        .bit_len = 1,
    };
    /// [12] Watchdog prescaler
    /// - 0 256 prescaler disabled.
    /// - 1 256 prescaler enabled.
    pub const PRES = RegType.FieldDef{
        .bit_start = 12,
        .bit_len = 1,
    };
    /// [13] Enables or disables WDOG support for 32-bit (otherwise 16-bit or 8-bit) refresh/unlock command write words
    /// - 0 Disables support for 32-bit refresh/unlock command write
    /// words. Only 16-bit or 8-bit is supported.
    /// - 1 Enables support for 32-bit refresh/unlock command write
    /// words. 16-bit or 8-bit is NOT supported.
    pub const CMD32EN = RegType.FieldDef{
        .bit_start = 13,
        .bit_len = 1,
    };
    /// [14] Watchdog Interrupt Flag
    /// - 0 No interrupt occurred.
    /// - 1 An interrupt occurred.
    pub const FLG = RegType.FieldDef{
        .bit_start = 14,
        .bit_len = 1,
    };
    /// [15] Watchdog Window
    /// - 0 Window mode disabled.
    /// - 1 Window mode enabled
    pub const WIN = RegType.FieldDef{
        .bit_start = 15,
        .bit_len = 1,
    };
};
/// Watchdog Counter Register
/// - reset value is 0
pub const WDOG_CNT = struct {
    pub const reg_ins = RegType.RegIns.init(baseAddress + 0x4);
    /// [0..7] Low byte of the Watchdog Counter
    pub const CNTLOW = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 8,
    };
    /// [8..15] High byte of the Watchdog Counter
    pub const CNTHIGH = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 8,
    };
};

/// Watchdog Timeout Value Register
/// - RESET VALUE IS 0x400
/// - 0100 0000 0000
pub const WDOG_TOVAL = struct {
    pub const reg_ins = RegType.RegIns.init(baseAddress + 0x8);
    /// [0..7] Low byte of the timeout value
    pub const TOVALLOW = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 8,
    };
    /// [8..15] High byte of the timeout value
    pub const TOVALHIGH = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 8,
    };
};
/// Watchdog Window Register
/// - RESET VALUE IS 0
pub const WDOG_WIN = struct {
    pub const reg_ins = RegType.RegIns.init(baseAddress + 0xC);
    /// [0..7] Low byte of Watchdog Window
    pub const WINLOW = RegType.FieldDef{
        .bit_start = 0,
        .bit_len = 8,
    };
    /// [8..15] High byte of Watchdog Window
    pub const WINHIGH = RegType.FieldDef{
        .bit_start = 8,
        .bit_len = 8,
    };
};
