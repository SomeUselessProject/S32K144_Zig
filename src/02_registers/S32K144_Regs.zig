//! This file contains all the register in s32k144
//! - it was used as "s32k144_regs_mod"

pub const RegT = @import("./RegType.zig");
pub const WDOG_Regs = @import("./Reg_WDOG.zig");
pub const SysTick_Regs = @import("./Reg_SysTick.zig");
pub const SCG_Regs = @import("./Reg_SCG.zig");
pub const PCC_Regs = @import("./Reg_PCC.zig");
pub const PORT_Regs = @import("./Reg_PORT.zig");
pub const GPIO_Regs = @import("./Reg_GPIO.zig");
pub const CAN_Regs = @import("./Reg_CAN.zig");
pub const NVIC_Regs = @import("./Reg_NVIC.zig");
pub const LPUART_Regs = @import("./Reg_LPUART.zig");
pub const ADC_Regs = @import("./Reg_ADC.zig");
pub const FTM_Regs = @import("./Reg_FTM.zig");
pub const LPIT_Regs = @import("./Reg_LPIT.zig");
pub const LPTMR_Regs = @import("./Reg_LPTMR.zig");
