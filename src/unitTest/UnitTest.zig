const std = @import("std");
const LinData = @import("../05_data_center/LinDataDefine.zig");

/// Get tgt bit in a value
inline fn GetBit(value: u8, bit: u3) u8 {
    return (value >> bit) & 0x01;
}

fn NewLin_GetPID(id: u8) u8 {
    if (id > 0x3F) {
        return 0x00;
    }
    // P0: ID[0] ^ ID[1] ^ ID[2] ^ ID[4]
    const p0 = (id & 0x01) ^ ((id >> 1) & 0x01) ^ ((id >> 2) & 0x01) ^ ((id >> 4) & 0x01);
    // P1: !(ID[1] ^ ID[3] ^ ID[4] ^ ID[5])
    const p1 = ~((id >> 1) & 0x01) ^ ((id >> 3) & 0x01) ^ ((id >> 4) & 0x01) ^ ((id >> 5) & 0x01) & 0x01;
    // PID: P1 bit 7,P0 bit 6 (ID range 0..5)
    const pid = (p1 << 7) | (p0 << 6) | id;
    return pid & 0xFF;
}

fn NewLIN_GetID(pid: u8) u8 {
    // Get ID
    const id = pid & 0x3F;
    // Double check the pid
    const p0_received = (pid >> 6) & 0x01;
    const p1_received = (pid >> 7) & 0x01;
    const p0_calculated = (id & 0x01) ^ ((id >> 1) & 0x01) ^ ((id >> 2) & 0x01) ^ ((id >> 4) & 0x01);
    const p1_calculated = ~((id >> 1) & 0x01) ^ ((id >> 3) & 0x01) ^ ((id >> 4) & 0x01) ^ ((id >> 5) & 0x01) & 0x01;
    if (p0_received != p0_calculated or p1_received != p1_calculated) {
        return 0x00;
    }
    return id;
}

test "pid" {
    const ret_value = NewLin_GetPID(0x10);
    std.debug.print("ret is {d} \n\r", .{ret_value});
    // check id
    try std.testing.expectEqual(0x50, NewLin_GetPID(0x10));
    try std.testing.expectEqual(0x64, NewLin_GetPID(0x24));
    // chek pid
    try std.testing.expectEqual(0x24, NewLIN_GetID(0x64));
    try std.testing.expectEqual(0x10, NewLIN_GetID(0x50));
}

test "LinDataTest" {
    LinData.test_lin_frame1.SetSignalValue(
        &LinData.LinFrame1.Sig1Def,
        LinData.LinFrame1.Sig1Def.value_T.VALUE2,
    );
    LinData.test_lin_frame1.SetSignalValue(
        &LinData.LinFrame1.Sig2Def,
        LinData.LinFrame1.Sig2Def.value_T.VALUE3,
    );
    std.debug.print("raw datas value is {}\r\n", .{LinData.test_lin_frame1.raw_datas[0]});
}

fn LIN_MakeClassicChecksum(data_buff: *[8]u8, len: u4) u8 {
    if (len > 8) return 0;
    var checksum: u16 = 0;
    for (0..len) |i| {
        checksum += data_buff[i];
        if (checksum > 0xFF) {
            checksum -= 0xFF;
        }
    }
    return @as(u8, @intCast(~checksum));
}

fn LIN_MakeEnhancedChecksum(pid: u8, data_buff: *[8]u8, len: u4) u8 {
    if (len > 8) return 0;
    var checksum: u16 = 0;
    // For PID is 0x3C (ID 0x3C) or 0x7D (ID 0x3D) or 0xFE (ID 0x3E) or 0xBF (ID 0x3F)
    // apply classic checksum and apply enhanced checksum for other PID
    if ((0x3C != pid) and (0x7D != pid) and (0xFE != pid) and (0xBF != pid)) {
        // For PID other than 0x3C, 0x7D, 0xFE and 0xBF: Add PID in checksum calculation */
        checksum = pid;
    } else {
        // For 0x3C, 0x7D, 0xFE and 0xBF: Do not add PID in checksum calculation
        checksum = 0;
    }

    for (0..len) |i| {
        checksum += data_buff[i];
        if (checksum > 0xFF) {
            checksum -= 0xFF;
        }
    }
    //checksum = ~checksum;
    const ret: u8 = @truncate(~checksum);
    return ret;
}

test "lin checksum test" {
    var data: [8]u8 = [8]u8{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08 };
    const ret = LIN_MakeEnhancedChecksum(
        0x20,
        &data,
        4,
    );
    std.debug.print("The checksum is  {}\r\n", .{ret});
}
