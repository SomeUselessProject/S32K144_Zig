//! The general system resource used by peripheral

pub const GenericSts = @import("./SystemStatus.zig").GeneralSts;
pub const NVIC_Mgr = @import(".//nvic_mgr/NvicMgr.zig");
pub const LPIT_Mgr = @import("./lpit_mgr/LpitMgr.zig");

pub const ClockMgr = @import("./clock_mgr/ClockMgr.zig");
pub const LPTMR_Mgr = @import("./lptmr_mgr/LptmrMgr.zig");
