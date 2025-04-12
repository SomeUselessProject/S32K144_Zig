//! The General Define for can and lin
//! - version: 0.1.0
//! - date: 2025/03/31
//! - author: weng

pub const SigOrderT = enum(u2) {
    INTEL,
    MOTOROLA_LSB,
    MOTOROLA_MSB,
};

/// The basic signal define for all binary signals
pub const BinarySignalDef = struct {
    bit_start: u8,
    bits_len: u8,
    unit: []const u8 = "NA",
    sig_order: SigOrderT = SigOrderT.INTEL,
    value_T: type,
};

pub const BinarySigSet = struct {
    sig_define: *const BinarySignalDef,
    sig_raw_value: u32,
};

// ------------------------------------------------------------
//#region LIN PART
pub const LinFrameModeT = enum(u2) {
    MASTER_PUBLISH,
    MASTER_SUBSCRIBE,
    SLAVE_PUBLISH,
    SLAVE_SUBSCRIBE,
};

pub const LinChecksumT = enum(u1) {
    CLASSIC = 0,
    ENHANCED = 1,
};

pub const LinFrameGenericDefine = struct {
    id: u6,
    pid: u8,
    bytes_len: u4,
    work_mode: LinFrameModeT,
    check_type: LinChecksumT,
    time_delay_ms: u8,
};

/// The Real Lin Frame instance
pub const LinStdFrameIns = struct {
    const Self = @This();
    const MASK_ONE: u64 = 0xFFFF_FFFF_FFFF_FFFF;

    frame_define: *const LinFrameGenericDefine,
    frame_bytes_arr: *[8]u8,
    signal_defines: []const *const BinarySignalDef,

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
            self.raw_datas[i] = @truncate((bits_value >> @as(u6, i * 8)) & mask);
        }
    }

    pub fn SetRawValueWith(self: *const Self, comptime bit_start: u6, comptime len: u8, new_value: u64) void {
        comptime {
            if (len == 0 or len > 64) @compileError("The len must > 0 or <=64");
            if (len + bit_start > 64) @compileError("The value range is not correct; must less than 64");
        }
        var bits_raw_value: u64 = self.GetRawBitsDataFromArray();
        const right_shift: u6 = @truncate(64 - len);
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

    /// Check if this lin frame contain the signal
    pub fn IsContainSignal(self: *const Self, comptime check_def_ptr: *const BinarySignalDef) bool {
        inline for (self.signal_defines) |sig_def_ptr| {
            if (sig_def_ptr == check_def_ptr) return true;
        }
        return false;
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
};
//#endregion
// ------------------------------------------------------------
