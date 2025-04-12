//! This file is the start up file of s32k144
//! - it could be referenced as other arm chips
//! - date : 2025 03 09 19:52
//! - author : weng

pub const Entry = @import("./entry.zig");
pub const Vector = @import("./vector.zig");

/// This function should be called at compile time
/// - export the _start func
/// - export the vector table
pub fn ExportStartSymbol() void {
    @export(&Entry.resetHandler, .{
        .name = "_start",
        .linkage = .strong,
    });
    @export(&Vector.Vector_Table, .{
        .name = "Vector_Table",
        .section = ".isr_vector",
        .linkage = .strong,
    });
}

/// define flash config
/// - the flash will be locked if the value is changed
export const Flash_Config linksection(".flash_config") = [_]u32{
    0xFFFFFFFF, // 8 bytes backdoor comparison key
    0xFFFFFFFF,
    0xFFFFFFFF, // 4 bytes program flash protection bytes
    0xFFFF7FFE, // FDPROT:FEPROT:FOPT:FSEC(0xFE = unsecured)
};
