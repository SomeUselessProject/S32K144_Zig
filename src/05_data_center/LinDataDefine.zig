//! The basic define of LIN COMMU
//! - date: 2025/03/30
//! - author: weng
//! - version: 0.1.0

const std = @import("std");
const builtin = std.builtin;

pub const SigOrderT = enum(u2) {
    INTEL,
    MOTOROLA_LSB,
    MOTOROLA_MSB,
};

/// The basic signal define for all binary signals
const BinarySignalDef = struct {
    bit_start: u8,
    bits_len: u8,
    unit: []const u8 = "NA",
    sig_order: SigOrderT = SigOrderT.INTEL,
    value_T: type,
};

pub const Ttt = struct {
    sig_set: BinarySigSet(),
};

pub fn BinarySigSet(comptime T: type) type {
    return struct {
        sig_def_ptr: *const BinarySignalDef,
        sig_value: T,
    };
}

pub fn GetValueT(comptime T: type) type {
    return struct {
        value_T: T,
    };
}

pub fn CanLinSignalIns(comptime T: type) type {
    return struct {
        signal_define: BinarySignalDef,
        value: T,
        pub fn GetRawValue(self: @This()) usize {
            if (T == usize) {
                return @as(T, self.value);
            }
            if (@typeInfo(T) == .@"enum") {
                std.debug.print("it is a enum \r\n", .{});
                return @as(usize, @intFromEnum(self.value));
            }
        }
        pub fn SetValue(self: @This(), comptime new_value: anytype) void {
            if (@TypeOf(new_value) == T) {
                self.value = new_value;
            }
        }
    };
}

pub const LinFrameWorkT = enum(u2) {
    MASTER_PUBLISH,
    MASTER_SUBSCRIBE,
    SLAVE_PUBLISH,
    SLAVE_SUBSCRIBE,
};

pub const LinChecksumT = enum(u1) {
    CLASSIC = 0,
    ENHANCED = 1,
};

pub const LinStdFrameIns = struct {
    const Self = @This();
    const MASK_ONE: u64 = 0xFFFF_FFFF_FFFF_FFFF;
    id: u6 = 0,
    raw_datas: *[8]u8,
    bytes_len: u4 = 8,
    work_mode: LinFrameWorkT = LinFrameWorkT.MASTER_PUBLISH,
    time_delay: u8 = 10,
    check_type: LinChecksumT = LinChecksumT.ENHANCED,
    signal_defines: []const *const BinarySignalDef,

    pub fn IsContainSignal(self: *const Self, comptime signal_define_ptr: *const BinarySignalDef) bool {
        inline for (self.signal_defines) |sig_def_ptr| {
            if (sig_def_ptr == signal_define_ptr) return true;
        }
        return false;
    }

    pub fn UpdateFrameByte(self: *const @This(), byte_value: u8, index: u3) void {
        if (index > (self.bytes_len - 1)) return;
        //self.raw_datas[index] = byte_value;
        //self.raw_datas[index] = byte_value;
        self.raw_datas[index] = byte_value;
    }

    fn GetRawBitsDataFromArray(self: *const Self) u64 {
        var ret: u64 = 0;
        inline for (0..self.raw_datas.len) |i| {
            ret |= @as(u64, self.raw_datas[i]) << @as(u6, i * 8);
        }
        return ret;
    }

    fn SetRawDataArrFromBitsData(self: *const Self, bits_value: u64) void {
        const mask: u64 = 0xFF;
        inline for (0..self.raw_datas.len) |i| {
            self.raw_datas[i] = @intCast((bits_value >> @as(u6, i * 8)) & mask);
        }
    }

    pub fn SetSignalValue(self: *const Self, comptime sig_def: *const BinarySignalDef, comptime new_value: anytype) void {
        comptime {
            if (sig_def.value_T != @TypeOf(new_value)) {
                @compileError("The type of new value should be the same with signal define");
            }
            if (!self.IsContainSignal(sig_def)) {
                @compileError("The Lin frame didn't contain the signal");
            }
            if (@typeInfo(sig_def.value_T) != .@"enum" and
                sig_def.value_T != usize)
            {
                @compileError("The signal value must be usize or enum");
            }
        }

        //const new_value_size: comptime_int = @sizeOf(sig_def.value_T);

        var new_raw_value: u64 = 0;
        // if is a enum value
        if (@typeInfo(sig_def.value_T) == .@"enum") {
            new_raw_value = @intFromEnum(new_value);
        }
        if (sig_def.value_T == usize) {
            new_raw_value = @intCast(new_value);
        }
        self.SetRawValueWith(sig_def.bit_start, sig_def.bits_len, new_raw_value);
    }

    pub fn GetSignalValue(
        self: *const Self,
        comptime sig_def: *const BinarySignalDef,
        comptime sig_value_T: type,
    ) sig_value_T {
        // check at compiling time
        comptime {
            if (sig_def.value_T != sig_value_T) {
                @compileError("The return Type must be the same with signal define");
            }
            if (!self.IsContainSignal(sig_def)) {
                @compileError("The Lin frame didn't contain the signal");
            }
            if (@typeInfo(sig_def.value_T) != .@"enum" and
                sig_def.value_T != usize)
            {
                @compileError("The signal value must be usize or enum");
            }
        }
        const ret_value: u64 = self.GetRawValueWith(sig_def.bit_start, sig_def.bits_len);
        if (@typeInfo(sig_def.value_T) == .@"enum") {
            return @as(sig_value_T, @enumFromInt(ret_value));
        }
        if (sig_def.value_T == usize) {
            return @as(sig_value_T, @intCast(ret_value));
        }
    }

    pub fn SetRawValueWith(self: *const Self, comptime bit_start: u6, comptime len: u8, new_value: u64) void {
        comptime {
            if (len == 0 or len > 64) @compileError("The len must > 0 or <=64");
            if (len + bit_start > 64) @compileError("The value range is not correct; must less than 64");
        }
        var bits_raw_value: u64 = self.GetRawBitsDataFromArray();
        const right_shift: u6 = @intCast(64 - len);
        const mask = ~((MASK_ONE >> right_shift) << bit_start);
        bits_raw_value = ((bits_raw_value & mask) | (new_value << bit_start));
        self.SetRawDataArrFromBitsData(bits_raw_value);
    }

    pub fn GetRawValueWith(self: *const Self, comptime bit_start: u6, comptime len: u8) u64 {
        comptime {
            if (len == 0 or len > 64) @compileError("The len must > 0 or <=64");
            if (len + bit_start > 64) @compileError("The value range is not correct; must less than 64");
        }
        const bits_raw_value: u64 = self.GetRawBitsDataFromArray();
        const left_shift: u6 = @intCast(64 - len - bit_start);
        const right_shift: u6 = @intCast(64 - len);
        return (bits_raw_value << left_shift) >> right_shift;
    }

    pub fn SetidTest(self: @This(), new_id: u6) void {
        self.id = new_id;
    }
};

pub const LinFrame1 = struct {
    pub const Sig1Def = BinarySignalDef{
        .bit_start = 0,
        .bits_len = 4,
        .value_T = enum(u4) {
            VALUE1 = 0,
            VALUE2 = 1,
            VALUE3 = 3,
        },
    };

    pub const Sig2Def = BinarySignalDef{
        .bit_start = 4,
        .bits_len = 4,
        .value_T = enum(u4) {
            VALUE1 = 0,
            VALUE2 = 1,
            VALUE3 = 3,
        },
    };
    var datas: [8]u8 = .{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
};

pub const test_lin_frame1 = LinStdFrameIns{
    .id = 0x10,
    .bytes_len = 4,
    .raw_datas = &LinFrame1.datas,
    .signal_defines = &[_]*const BinarySignalDef{
        &LinFrame1.Sig1Def,
        &LinFrame1.Sig2Def,
    },
};
