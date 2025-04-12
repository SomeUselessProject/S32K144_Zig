//! This file defines the entry of mcu

/// Enable Interrupts for this MCU
/// asm cpsie i
pub inline fn EnableGlobalInterrupts() void {
    asm volatile ("cpsie i" ::: "memory");
}

/// Disbale Interrupts for this MCU
/// asm cpsid i
pub inline fn DisableGlobalInterrupts() void {
    asm volatile ("cpsid i" ::: "memory");
}

/// To avoid circular dependencies between main.zig and startup.zig
extern fn main() noreturn;

const startup_locations = struct {
    extern var _sbss: u8;
    extern var _ebss: u8;
    extern var _sdata: u8;
    extern var _edata: u8;
    extern const _sidata: u8;
};

fn InitDataBss() void {

    // fill .bss with zeroes
    const bss_start: [*]u8 = @ptrCast(&startup_locations._sbss);
    const bss_end: [*]u8 = @ptrCast(&startup_locations._ebss);
    const bss_len = @intFromPtr(bss_end) - @intFromPtr(bss_start);
    @memset(bss_start[0..bss_len], 0);

    // load .data from flash  to sram
    const data_start: [*]u8 = @ptrCast(&startup_locations._sdata);
    const data_end: [*]u8 = @ptrCast(&startup_locations._edata);
    const data_len = @intFromPtr(data_end) - @intFromPtr(data_start);
    const data_src: [*]const u8 = @ptrCast(&startup_locations._sidata);
    @memcpy(data_start[0..data_len], data_src[0..data_len]);
}

pub fn resetHandler() callconv(.C) noreturn {
    DisableGlobalInterrupts();
    InitDataBss();
    EnableGlobalInterrupts();
    main();
    unreachable;
}
