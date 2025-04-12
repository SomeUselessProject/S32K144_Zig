//! The basic config of lin1 channel
//! - version: 0.1.0
//! - author: weng
//! - date: 20250401:1437

const CanLinDataDefine = @import("data_center").CanLinDataDefine;
const BinarySignalDef = CanLinDataDefine.BinarySignalDef;
const LinFrameGenericDefine = CanLinDataDefine.LinFrameGenericDefine;

pub const LinFrame_Test1 = struct {
    var bytes_arr: [8]u8 = .{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
    const define = LinFrameGenericDefine{
        .id = 0x22,
        .pid = 0xE2,
        .bytes_len = 4,
        .check_type = CanLinDataDefine.LinChecksumT.ENHANCED,
        .time_delay_ms = 10,
        .work_mode = CanLinDataDefine.LinFrameModeT.MASTER_PUBLISH,
    };
    pub const test1_frame_ins = CanLinDataDefine.LinStdFrameIns{
        .frame_bytes_arr = &bytes_arr,
        .frame_define = &define,
        .signal_defines = &[_]*const BinarySignalDef{
            &sig1_define,
            &sig2_define,
        },
    };

    pub const sig1_define = BinarySignalDef{
        .bit_start = 0,
        .bits_len = 6,
        .sig_order = CanLinDataDefine.SigOrderT.INTEL,
        .value_T = enum(u6) {
            VALUE1 = 0,
            VALUE2 = 5,
        },
    };
    pub const sig2_define = BinarySignalDef{
        .bit_start = 9,
        .bits_len = 3,
        .sig_order = CanLinDataDefine.SigOrderT.INTEL,
        .value_T = enum(u3) {
            VALUE1 = 0,
            VALUE2 = 2,
        },
    };
};

pub const LinFrame_Test2 = struct {
    var bytes_arr: [8]u8 = .{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
    const define = LinFrameGenericDefine{
        .id = 0x12,
        .pid = 0x92,
        .bytes_len = 8,
        .check_type = CanLinDataDefine.LinChecksumT.ENHANCED,
        .time_delay_ms = 10,
        .work_mode = CanLinDataDefine.LinFrameModeT.MASTER_SUBSCRIBE,
    };
    pub const test1_frame_ins = CanLinDataDefine.LinStdFrameIns{
        .frame_bytes_arr = &bytes_arr,
        .frame_define = &define,
        .signal_defines = &[_]*const BinarySignalDef{
            &sig1_feedback1,
        },
    };

    pub const sig1_feedback1 = BinarySignalDef{
        .bit_start = 8,
        .bits_len = 6,
        .sig_order = CanLinDataDefine.SigOrderT.INTEL,
        .value_T = enum(u6) {
            VALUE1 = 0,
            VALUE2 = 1,
            VALUE4 = 4,
        },
    };
};
