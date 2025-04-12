//! This file contains all the status in 32k144
//! - version : 0.1.0
//! - refernce: s32k sdk status.h

pub const GeneralSts = enum(u8) {
    STATUS_SUCCESS = 0,
    STATUS_ERROR = 1,
    STATUS_BUSY = 2,
    STATUS_TIMEOUT = 3,
    STATUS_UNSUPPORTED = 4,
    STATUS_ABORTED = 5,
    /// 重复初始化
    STATUS_REINIT = 6,
};
