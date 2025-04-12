//! The driver of WDOG Module
//! - date:2025/02/28
//! - author:weng
//! - version:0.1.0

const FieldSet = @import("s32k144_regs_mod").RegT.FieldSet;
const WDOG_Rgstrs = @import("s32k144_regs_mod").WDOG_Regs;
const CNT = WDOG_Rgstrs.WDOG_CNT;
const CS = WDOG_Rgstrs.WDOG_CS;
const TOVAL = WDOG_Rgstrs.WDOG_TOVAL;

pub fn DisableWdog() void {
    // unlock watch dog
    // write the key twice to ensure the unlock operation
    // 0x_D9_28_C5_20
    //WDOG_Rgstrs.WDOG_CNT_Reg.writeRaw(0xD928_C520);
    //WDOG_Rgstrs.WDOG_CNT_Reg.writeRaw(0xD928_C520);
    CNT.reg_ins.setRaw(0xD928_C520);
    CNT.reg_ins.setRaw(0xD928_C520);
    // read the unlock status until ULK field is 0b01
    while (CS.reg_ins.getFieldValue(CS.ULK) == 0) {}
    //while (WDOG_Rgstrs.WDOG_CS_Reg.get().ULK == 0) {}
    // set wdog timout value to max time
    //WDOG_Rgstrs.WDOG_TOVAL_Reg.setFields(.{ .TOVALLOW = 0xFF, .TOVALHIGH = 0xFF });
    TOVAL.reg_ins.updateAllFieldsValue(&[_]FieldSet{
        FieldSet{ .field_def = TOVAL.TOVALLOW, .field_value = 0xFF },
        FieldSet{ .field_def = TOVAL.TOVALHIGH, .field_value = 0xFF },
    });
    // disable wdog
    // 0x0000_2100
    // 0b 0010 0001 0000 0000
    //WDOG_Rgstrs.WDOG_CS_Reg.writeRaw(0x0000_2100);
    CS.reg_ins.setRaw(0x0000_2100);
}
