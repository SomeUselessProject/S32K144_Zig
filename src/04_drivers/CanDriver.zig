//! The Can driver of s32k144
//! - date: 2025 03 11
//! - author:weng
//! - version: 0.2.0

const FieldSet = @import("s32k144_regs_mod").RegT.FieldSet;
const CanRegs = @import("s32k144_regs_mod").CAN_Regs;
const PCC_Regs = @import("s32k144_regs_mod").PCC_Regs;

fn TurnCanToFreezeMode(can_index: u2) void {
    if (can_index > 2) return;
    CanRegs.MCM_Regs[can_index].FRZ = 1;
    CanRegs.MCM_Regs[can_index].HALT = 1;
    while (CanRegs.MCM_Regs[can_index].FRZACK == 0) {}
}
fn TurnCanExistFreezeMode(can_index: u2) void {
    if (can_index > 2) return;
    CanRegs.MCM_Regs[can_index].HALT = 0;
    CanRegs.MCM_Regs[can_index].FRZ = 0;
    while (CanRegs.MCM_Regs[can_index].FRZACK == 1) {}
}

pub fn InitClassicCanWith500K(index: u2) void {
    if (index > 2) return;
    switch (index) {
        0 => PCC_Regs.PCC_FlexCAN0_Reg.CGC = 1,
        1 => PCC_Regs.PCC_FlexCAN1_Reg.CGC = 1,
        2 => PCC_Regs.PCC_FlexCAN2_Reg.CGC = 1,
        else => unreachable,
    }
    CanRegs.MCM_Regs[index].MDIS = 1;
    // select the soscdiv2 which is configured as 8Mhz
    CanRegs.CTRL1_Regs[index].CLKSRC = 0;
    CanRegs.MCM_Regs[index].MDIS = 0;
    TurnCanToFreezeMode(index);
    // set the max mailbox to 0,1
    // MAXM is the last number of mailbox
    // one for tx , one for rx
    CanRegs.MCM_Regs[index].MAXM = 1;
    CanRegs.MCM_Regs[index].SRXDIS = 1;
    CanRegs.MCM_Regs[index].IRMQ = 1;
    // Set can baudrate and sample point
    CanRegs.CTRL1_Regs[index].PRESDIV = 0;
    CanRegs.CTRL1_Regs[index].PSEG1 = 3;
    CanRegs.CTRL1_Regs[index].PSEG2 = 3;
    CanRegs.CTRL1_Regs[index].PROPSEG = 6;
    CanRegs.CTRL1_Regs[index].RJW = 3;
    CanRegs.CTRL1_Regs[index].SMP = 1;

    // clear at first
    switch (index) {
        0 => {
            for (0..CanRegs.CAN0_RAMn_Regs.len) |i| CanRegs.CAN0_RAMn_Regs[i] = @bitCast(@as(u32, 0));
            for (0..CanRegs.CAN0_RXIMR_Regs.len) |i| CanRegs.CAN0_RXIMR_Regs[i].MI = 0xFFFF_FFFF;
        },
        1 => {
            for (0..CanRegs.CAN1_RAMn_Regs.len) |i| CanRegs.CAN1_RAMn_Regs[i] = @bitCast(@as(u32, 0));
            for (0..CanRegs.CAN1_RXIMR_Regs.len) |i| CanRegs.CAN1_RXIMR_Regs[i].MI = 0xFFFF_FFFF;
        },
        2 => {
            for (0..CanRegs.CAN2_RAMn_Regs.len) |i| CanRegs.CAN2_RAMn_Regs[i] = @bitCast(@as(u32, 0));
            for (0..CanRegs.CAN2_RXIMR_Regs.len) |i| CanRegs.CAN2_RXIMR_Regs[i].MI = 0xFFFF_FFFF;
        },
        else => unreachable,
    }
    TurnCanExistFreezeMode(index);
    while (CanRegs.MCM_Regs[index].NOTRDY == 1) {}
}

pub fn InstallCanClassicID(can_index: u2, msg_id: u11, rx_mb_idx: u5) void {
    if (can_index > 2) return;
    TurnCanToFreezeMode(can_index);
    // set the invidual receive mask registers
    //CanReg.CAN_RXIMR_REGS.
    CanRegs.CAN0_RXIMR_Regs[0].MI = 0x7FF << 18;
    CanRegs.CAN1_RXIMR_Regs[0].MI = 0x7FF << 18;
    // set the rx mailbox to receive the can msg
    switch (can_index) {
        0 => {},
        1 => {
            // message buffer header1
            CanRegs.CAN1_Mailbox[rx_mb_idx].header1.EDL = 0;
            CanRegs.CAN1_Mailbox[rx_mb_idx].header1.BRS = 0;
            CanRegs.CAN1_Mailbox[rx_mb_idx].header1.ESI = 0;
            CanRegs.CAN1_Mailbox[rx_mb_idx].header1.CODE = 4;
            CanRegs.CAN1_Mailbox[rx_mb_idx].header1.SRR = 0;
            CanRegs.CAN1_Mailbox[rx_mb_idx].header1.IDE = 0;
            CanRegs.CAN1_Mailbox[rx_mb_idx].header1.RTR = 0;
            CanRegs.CAN1_Mailbox[rx_mb_idx].header1.DLC = 8;
            CanRegs.CAN1_Mailbox[rx_mb_idx].header2.ID_STD = msg_id;
        },
        2 => {},
        else => unreachable,
    }
    TurnCanExistFreezeMode(can_index);
    while (CanRegs.MCM_Regs[can_index].NOTRDY == 1) {}
}

pub fn SendClassicCanMsg(can_index: u2, tx_mb_idx: u5, msg_id: u11, msg_datas: [8]u8) void {
    if (can_index > 2) return;
    // 1 fill the data in tx mail box
    switch (can_index) {
        0 => {},
        1 => {
            // 1 fill sending bytes
            // byte 1
            CanRegs.CAN1_Mailbox[tx_mb_idx].byte1.DATA_BYTE_N4Add0 = msg_datas[0];
            CanRegs.CAN1_Mailbox[tx_mb_idx].byte1.DATA_BYTE_N4Add1 = msg_datas[1];
            CanRegs.CAN1_Mailbox[tx_mb_idx].byte1.DATA_BYTE_N4Add2 = msg_datas[2];
            CanRegs.CAN1_Mailbox[tx_mb_idx].byte1.DATA_BYTE_N4Add3 = msg_datas[3];
            // byte2
            CanRegs.CAN1_Mailbox[tx_mb_idx].byte2.DATA_BYTE_N4Add0 = msg_datas[4];
            CanRegs.CAN1_Mailbox[tx_mb_idx].byte2.DATA_BYTE_N4Add1 = msg_datas[5];
            CanRegs.CAN1_Mailbox[tx_mb_idx].byte2.DATA_BYTE_N4Add2 = msg_datas[6];
            CanRegs.CAN1_Mailbox[tx_mb_idx].byte2.DATA_BYTE_N4Add3 = msg_datas[7];

            // 2 fill msg id
            CanRegs.CAN1_Mailbox[tx_mb_idx].header2.ID_STD = msg_id;
            // 3 set msg header1
            CanRegs.CAN1_Mailbox[tx_mb_idx].header1.EDL = 0;
            CanRegs.CAN1_Mailbox[tx_mb_idx].header1.BRS = 0;
            CanRegs.CAN1_Mailbox[tx_mb_idx].header1.ESI = 0;
            CanRegs.CAN1_Mailbox[tx_mb_idx].header1.SRR = 0;
            CanRegs.CAN1_Mailbox[tx_mb_idx].header1.IDE = 0;
            CanRegs.CAN1_Mailbox[tx_mb_idx].header1.RTR = 0;
            CanRegs.CAN1_Mailbox[tx_mb_idx].header1.DLC = 8;
            // 4 set the code to tx
            CanRegs.CAN1_Mailbox[tx_mb_idx].header1.CODE = 0xC;
        },
        2 => {},
        else => unreachable,
    }
    // wait the flag
    // if the msg is transformed ,the iflag will be set
    while (CanRegs.IFLAG1_Regs[can_index].BUF0I == 0) {}
    CanRegs.IFLAG1_Regs[can_index].BUF0I = 1;
}
