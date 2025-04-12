const rtt = @import("rtt");
const std = @import("std");

// rtt.RTT takes an rtt.Config
pub const rtt_instance = rtt.RTT(.{
    // A slice of rtt.channel.Config for target -> probe communication
    .up_channels = &.{
        .{ .name = "Terminal", .mode = .NoBlockSkip, .buffer_size = 128 },
        .{ .name = "Up2", .mode = .NoBlockSkip, .buffer_size = 256 },
    },
    // A slice of rtt.channel.Config for probe -> target communication
    .down_channels = &.{
        .{ .name = "Terminal", .mode = .BlockIfFull, .buffer_size = 512 },
        .{ .name = "Down2", .mode = .BlockIfFull, .buffer_size = 1024 },
    },
    // Optional override of lock/unlock functionality for thread safe RTT
    //.exclusive_access = your_lock_struct,
    // Optional placement in specific linker section for a fixed address control block
    //.linker_section = ".rtt_cb",
});

pub var is_inited: bool = false;
const is_rtt_on: bool = true;

pub fn RTT_WriteIn0Channel(str: []const u8) void {
    if (!is_rtt_on) return;
    if (!is_inited) return;
    _ = rtt_instance.write(0, str) catch |err| {
        _ = err;
    };
}

var temp_buf: [4]u8 = undefined;
/// This Function cause a hardware fault @panic
/// - ! Do not use
pub fn RTT_WriteByteIn0Channel(data: u8) void {
    const byte_str = std.fmt.bufPrint(&temp_buf, "-0x{x}", .{data}) catch unreachable;
    RTT_WriteIn0Channel(byte_str);
}
