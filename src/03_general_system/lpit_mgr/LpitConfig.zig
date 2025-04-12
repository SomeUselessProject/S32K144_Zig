//! General config of S32K144
//! - author: weng
//! - date : 2025 /03/19

const LpitUsrConfig = @import("./LpitMgr.zig").LpitUsrConfig;

pub const lpit0_usr_cfg = LpitUsrConfig{
    .EnableRunInDebug = false,
    .EnableRunInDoze = false,
};
