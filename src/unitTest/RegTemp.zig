const std = @import("std");

pub const CNT_FIELDS = packed struct(u32) {
    /// [0..7]
    /// - slow
    CNTLOW: u8 = 0,
    /// [8..15]
    CNTHIGH: u8 = 0,
    /// [16..31]
    _RES16_31: u16 = 0,
};

pub const STS_FIELDS = packed struct(u32) {
    /// [0..7]
    /// - status field
    STSLOW: u8 = 0,
    /// [8..15]
    STSHIGH: u8 = 0,
    /// [16..31]
    _RES16_31: u16 = 0,
};

pub const U32FieldDefine = struct {
    bit_start: u32,
    len: u32,
    field_value_t: type,
};

pub fn GenFieldDefine(comptime FT: type) type {
    return struct {
        bit_start: u32,
        len: u32,
        comptime field_t: type = FT,
    };
}

pub const CNT_DEF = struct {
    reg_ins: GeneralRegT2,

    const CNTLOW_ValueT = enum(u8) {
        v11 = 0,
        v22 = 3,
    };
    pub const CNTLOW = U32FieldDefine{
        .bit_start = 0,
        .len = 8,
        .field_value_t = CNTLOW_ValueT,
    };

    const CNTHIGH_ValueT = u8;
    pub const CNTHIGH = U32FieldDefine{
        .bit_start = 8,
        .len = 8,
        .field_value_t = CNTHIGH_ValueT,
    };
};

const baseAddress: u32 = 0x4005_2000;

pub const GeneralRegT2 = struct {
    const Self_T = @This();
    field_t: type,
    raw_ptr: *volatile usize,

    pub fn NewIns(comptime field_t: type, reg_addr: usize) Self_T {
        return Self_T{
            .raw_ptr = @ptrFromInt(reg_addr),
            .field_t = field_t,
        };
    }
};

pub fn GeneralRegT(comptime Field_T: type) type {
    return struct {
        const Self_T = @This();
        const mask_value: Field_T = @bitCast(@as(u32, 0xFFFF_FFFF));
        raw_ptr: *volatile usize,
        fields_ptr: *volatile Field_T,

        pub fn NewIns(reg_addr: usize) Self_T {
            return Self_T{
                .raw_ptr = @ptrFromInt(reg_addr),
                .fields_ptr = @ptrFromInt(reg_addr),
            };
        }

        pub fn GetValueCopy(self: Self_T) Field_T {
            return self.fields_ptr.*;
        }

        pub fn UpdateAll(self: Self_T, new_value: Field_T) void {
            self.fields_ptr.* = new_value;
        }
    };
}

var test_1: u32 = 0b0000_1111_1111_1111;

test "reg test" {
    const test1_ptr = &test_1;
    const test1_addr: usize = @intFromPtr(test1_ptr);
    std.debug.print("test1_addr valus is 0x{x}\n", .{test1_addr});
    std.debug.print("test1 raw value is 0b-{b}\n", .{test1_ptr.*});

    // --------------------------------
    var test1 = GeneralRegT(CNT_FIELDS).NewIns(test1_addr);
    test1.fields_ptr.CNTLOW = 3;
    std.debug.print("test1 raw value is 0b-{b}\n", .{test1.raw_ptr.*});
    //test1.
    var cp = test1.GetValueCopy();
    cp.CNTHIGH = 1;
    test1.UpdateAll(cp);
    std.debug.print("test1 raw value is 0b-{b}\n", .{test1.raw_ptr.*});
}
