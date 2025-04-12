//! The basic type of all registers
//! - this file is referenced by
//! - version:0.2.0
//! - author: weng

/// used to define a field in registers
pub const FieldDef = struct {
    bit_start: u5 = 0,
    bit_len: u6 = 0,
};

/// used to set field
pub const FieldSet = struct {
    field_def: FieldDef,
    field_value: u32,
};

pub const RegIns = struct {
    const Self = @This();
    const mask_base: u32 = 0xFFFF_FFFF;

    raw_ptr: *volatile u32,

    pub fn init(address: usize) Self {
        return Self{ .raw_ptr = @as(*volatile u32, @ptrFromInt(address)) };
    }

    pub fn initRange(address: usize, comptime dim_increment: usize, comptime num_registers: usize) [num_registers]Self {
        var registers: [num_registers]Self = undefined;
        var i: usize = 0;
        while (i < num_registers) : (i += 1) {
            registers[i] = Self.init(address + (i * dim_increment));
        }
        return registers;
    }

    fn initPtr(ptr: *volatile u32) Self {
        return Self{ .raw_ptr = ptr };
    }

    pub fn getRaw(self: Self) u32 {
        return self.raw_ptr.*;
    }

    pub fn setRaw(self: Self, value: u32) void {
        self.raw_ptr.* = value;
    }

    pub fn getFieldValue(self: Self, tgt_field: FieldDef) u32 {
        const raw_value: u32 = self.getRaw();
        const left_shift: u5 = @intCast(32 - tgt_field.bit_len - tgt_field.bit_start);
        const right_shift: u5 = @intCast(32 - tgt_field.bit_len);
        return (raw_value << left_shift) >> right_shift;
    }

    pub fn GetFieldValueByRawData(tgt_field: FieldDef, raw_value: u32) u32 {
        const left_shift: u5 = @truncate(32 - tgt_field.bit_len - tgt_field.bit_start);
        const right_shift: u5 = @truncate(32 - tgt_field.bit_len);
        return (raw_value << left_shift) >> right_shift;
    }

    pub fn updateFieldValue(self: Self, tgt_field: FieldDef, new_value: u32) void {
        var temp_value: u32 = self.getRaw();
        if (tgt_field.bit_len > 31 or tgt_field.bit_len == 0) return;
        const right_shift: u5 = @intCast(32 - tgt_field.bit_len);
        const mask = ~((mask_base >> right_shift) << tgt_field.bit_start);
        temp_value = ((temp_value & mask) | (new_value << tgt_field.bit_start));
        self.setRaw(temp_value);
    }

    pub fn updateAllFieldsValue(self: Self, fields_sets: []const FieldSet) void {
        //const old_value: u32 =
        var temp_value: u32 = self.getRaw();
        for (fields_sets) |fieldSet| {
            if (fieldSet.field_def.bit_len > 31 or fieldSet.field_def.bit_len == 0) return;
            const right_shift: u5 = @intCast(32 - fieldSet.field_def.bit_len);
            const mask = ~((mask_base >> right_shift) << fieldSet.field_def.bit_start);
            temp_value = ((temp_value & mask) | (fieldSet.field_value << fieldSet.field_def.bit_start));
        }
        self.setRaw(temp_value);
    }
};
