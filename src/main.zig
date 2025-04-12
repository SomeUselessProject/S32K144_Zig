//! Main Function of the program
//! - date : 2025 03 10
//! - author : weng

// Responsible for exporting relevant _start and vector table symbols
comptime {
    @import("start_mod").ExportStartSymbol();
}

pub const ZigRtt = @import("./00_segger_rtt/ZigRtt.zig");
const EcuIns = @import("./07_ecu_layer/EcuInstance.zig");

export fn main() callconv(.C) noreturn {
    // coding
    ZigRtt.rtt_instance.init();
    ZigRtt.is_inited = true;

    EcuIns.InitTheECU();
    while (true) {
        EcuIns.EcuLoopHandle();
    }
    //unreachable;
}
