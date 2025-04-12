//! The ECU devices define of this board
//! - version: 0.1.0
//! - author: weng

pub const Beeper = @import("./ecu_devices/Beeper.zig");
pub const Can1Channel = @import("./ecu_devices/Can1Channel.zig");
pub const Lin1Channel = @import("./ecu_devices/Lin1Channel.zig");

pub fn InitAllEcuDevices() void {
    Beeper.InitBeeper();
    Can1Channel.InitChannel();
    Lin1Channel.InitChannel();
}
