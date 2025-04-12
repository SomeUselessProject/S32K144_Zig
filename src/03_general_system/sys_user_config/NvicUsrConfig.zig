//! The Default config of NVIC
//! - include priority settings
//! - date: 2025 03 27
//! - version: 0.1.0
//! - author: weng

const IQRnType = @import("../nvic_mgr/NvicMgr.zig").IQRnType;

pub fn GetPriorityByType(iqrn_type: IQRnType) u4 {
    switch (iqrn_type) {
        IQRnType.IRQn_LPUART0_RxTx => return 0x3,
        IQRnType.IRQn_LPUART1_RxTx => return 0x4,
        IQRnType.IRQn_LPTMR0 => return 0x5,
        else => return 0xF,
    }
    return 0xF;
}
