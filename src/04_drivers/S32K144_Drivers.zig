//! The driver mod of s32k144
//! - date : 2025/03/10
//! - version : 0.1.0
//! - author : weng

pub const WDOG = @import("./WdogDriver.zig");
//pub const SysTick = @import("./SysTickDriver.zig");
//pub const Clock = @import("./ClockDriver.zig");
pub const PIN = @import("./PinDriver.zig");
pub const CAN = @import("./CanDriver.zig");
//pub const LPUART = @import("./LpuartDriver.zig");
pub const LIN = @import("./lin_driver/LinBasicDriver.zig");
