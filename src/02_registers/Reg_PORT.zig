//! Created by weng
//! - 2025/02/21
//! - contain all the ports registers

/// [16..19] Interrupt Configuration
/// - 0000 - Interrupt Status Flag (ISF) is disabled.
/// - 0001 - ISF flag and DMA request on rising edge.
/// - 0010 - ISF flag and DMA request on falling edge.
/// - 0011 - ISF flag and DMA request on either edge.
/// - 1000 - ISF flag and Interrupt when logic 0.
/// - 1001 - ISF flag and Interrupt on rising-edge.
/// - 1010 - ISF flag and Interrupt on falling-edge.
/// - 1011 - ISF flag and Interrupt on either edge.
/// - 1100 - ISF flag and Interrupt when logic 1.
pub const IRQC_TYPE = enum(u4) {
    ISF_DISABLED = 0b0000,
    ISF_DMA_RISE_EDGE = 0b0001,
    ISF_DMA_FALL_EDGE = 0b0010,
    ISF_DMA_EITHER_EDGE = 0b0011,
    ISF_LOGIC_0 = 0b1000,
    ISF_INTERRUPT_RISE_EDGE = 0b1001,
    ISF_INTERRUPT_FALL_EDGE = 0b1010,
    ISF_INTERRUPT_EITHER_EDGE = 0b1011,
    ISF_LOGIC_1 = 0b1100,
};

const PCR_REG = packed struct(u32) {
    /// [0] Pull Select
    /// - 0-Internal pulldown resistor is enabled on the corresponding pin, if the corresponding PE field is set.
    /// - 1-Internal pullup resistor is enabled on the corresponding pin, if the corresponding PE field is set.
    PS: u1 = 0,
    /// [1] Pull Enable
    /// - 0-Internal pullup or pulldown resistor is not enabled on the corresponding pin.
    /// - 1-Internal pullup or pulldown resistor is enabled on the corresponding pin,
    /// if the pin is configured as a digital input.
    PE: u1 = 0,
    /// [2..3]
    RES2_3: u2 = 0,
    /// [4] Passive Filter Enable
    /// - 0 - Passive input filter is disabled on the corresponding pin.
    /// - 1 - Passive input filter is enabled on the corresponding pin,
    /// if the pin is configured as a digital input.
    /// Refer to the device data sheet for filter characteristics.
    PFE: u1 = 0,
    /// [5]
    RES_5: u1 = 0,
    /// [6] Drive Strength Enable
    /// - 0 - Low drive strength is configured on the corresponding pin,
    /// if pin is configured as a digital output.
    /// - 1 - High drive strength is configured on the corresponding pin,
    /// if pin is configured as a digital output.
    DSE: u1 = 0,
    /// [7]
    RES7: u1 = 0,
    /// [8..10] Pin Mux Control
    /// - 000 - Pin disabled (Alternative 0) (analog).
    /// - 001 - Alternative 1 (GPIO).
    /// - 010 - Alternative 2 (chip-specific).
    /// - 011 - Alternative 3 (chip-specific).
    /// - 100 - Alternative 4 (chip-specific).
    /// - 101 - Alternative 5 (chip-specific).
    /// - 110 - Alternative 6 (chip-specific).
    /// - 111 - Alternative 7 (chip-specific).
    MUX: u3 = 0,
    /// [11..14]
    RES11_15: u4 = 0,
    /// [15] Lock Register
    /// - 0 - Pin Control Register REG [15:0] are not locked.
    /// - 1 - Pin Control Register REG [15:0] are locked and cannot be updated until the next system reset.
    LK: u1 = 0,
    /// [16..19] Interrupt Configuration
    /// - 0000 - Interrupt Status Flag (ISF) is disabled.
    /// - 0001 - ISF flag and DMA request on rising edge.
    /// - 0010 - ISF flag and DMA request on falling edge.
    /// - 0011 - ISF flag and DMA request on either edge.
    /// - 1000 - ISF flag and Interrupt when logic 0.
    /// - 1001 - ISF flag and Interrupt on rising-edge.
    /// - 1010 - ISF flag and Interrupt on falling-edge.
    /// - 1011 - ISF flag and Interrupt on either edge.
    /// - 1100 - ISF flag and Interrupt when logic 1.
    IRQC: u4 = 0,
    /// [20..23]
    RES20_23: u4 = 0,
    /// [24] Interrupt Status Flag
    /// - 0 - Configured interrupt is not detected.
    /// - 1 - Configured interrupt is detected.
    /// If the pin is configured to generate a DMA request,
    /// then the corresponding flag will be cleared automatically
    /// at the completion of the requested DMA transfer.
    ISF: u1 = 0,
    /// [25..31]
    RES25_31: u7 = 0,
};

const GPCLR_REG = packed struct(u32) {
    /// [0..15] Global Pin Write Data
    GPWD: u16 = 0,
    /// [16..31] Global Pin Write Enable
    /// - 0 - Corresponding Pin Control Register is not updated with the value in GPWD.
    /// - 1 - Corresponding Pin Control Register is updated with the value in GPWD.
    GPWE: u16 = 0,
};

const GPCHR_REG = packed struct(u32) {
    /// [0..15] Global Pin Write Data
    GPWD: u16 = 0,
    /// [16..31] Global Pin Write Enable
    /// - 0 - Corresponding Pin Control Register is not updated with the value in GPWD.
    /// - 1 - Corresponding Pin Control Register is updated with the value in GPWD.
    GPWE: u16 = 0,
};

const GICLR_REG = packed struct(u32) {
    /// [0..15]Global Interrupt Write Enable
    /// - 0 - Corresponding Pin Control Register is not updated with the value in GPWD.
    /// - 1 - Corresponding Pin Control Register is updated with the value in GPWD.
    GIWE: u16 = 0,
    /// [16..31] Global Interrupt Write Data
    GIWD: u16 = 0,
};

const GICHR_REG = packed struct(u32) {
    /// [0..15]Global Interrupt Write Enable
    /// - 0 - Corresponding Pin Control Register is not updated with the value in GPWD.
    /// - 1 - Corresponding Pin Control Register is updated with the value in GPWD.
    GIWE: u16 = 0,
    /// [16..31] Global Interrupt Write Data
    GIWD: u16 = 0,
};

const ISFR_REG = packed struct(u32) {
    /// [0..31] Interrupt Status Flag
    /// - 0 -Configured interrupt is not detected.
    /// - 1 - Configured interrupt is detected.
    /// If the pin is configured to generate a DMA request,
    /// then the corresponding flag will be cleared
    /// automatically at the completion of the requested DMA transfer.
    /// Otherwise, the flag remains set until a logic 1 is written to the flag.
    /// If the pin is configured for a level sensitive interrupt and the pin remains asserted,
    /// then the flag is set again immediately after it is cleared.
    ISF: u32 = 0,
};

const DFER_REG = packed struct(u32) {
    /// [0..31] Digital Filter Enable
    /// - 0 - Digital filter is disabled on the corresponding pin and output of the digital filter is reset to zero.
    /// - 1 - Digital filter is enabled on the corresponding pin, if the pin is configured as a digital input.
    DFE: u32 = 0,
};

const DFCR_REG = packed struct(u32) {
    /// [0] Clock Source
    /// - 0 - Digital filters are clocked by the bus clock.
    /// - 1 - Digital filters are clocked by the LPO clock.
    CS: u1 = 0,
    /// [1..31]
    _unused1_31: u31 = 0,
};

const DFWR_REG = packed struct(u32) {
    /// [0..4] Filter Length
    FILT: u5 = 0,
    /// [5..31]
    _unused1_31: u27 = 0,
};

/// PORT A START
const portA_base_addr: u32 = 0x4004_9000;
const portB_base_addr: u32 = 0x4004_A000;
const portC_base_addr: u32 = 0x4004_B000;
const portD_base_addr: u32 = 0x4004_C000;
const portE_base_addr: u32 = 0x4004_D000;

// new registers part -----------------------------------
pub const PCR_Regs: [5]*volatile [32]PCR_REG = .{
    @ptrFromInt(portA_base_addr + 0x0),
    @ptrFromInt(portB_base_addr + 0x0),
    @ptrFromInt(portC_base_addr + 0x0),
    @ptrFromInt(portD_base_addr + 0x0),
    @ptrFromInt(portE_base_addr + 0x0),
};

pub const GPCLR_Regs: [5]*volatile GPCLR_REG = .{
    @ptrFromInt(portA_base_addr + 0x80),
    @ptrFromInt(portB_base_addr + 0x80),
    @ptrFromInt(portC_base_addr + 0x80),
    @ptrFromInt(portD_base_addr + 0x80),
    @ptrFromInt(portE_base_addr + 0x80),
};

pub const GPCHR_Regs: [5]*volatile GPCHR_REG = .{
    @ptrFromInt(portA_base_addr + 0x84),
    @ptrFromInt(portB_base_addr + 0x84),
    @ptrFromInt(portC_base_addr + 0x84),
    @ptrFromInt(portD_base_addr + 0x84),
    @ptrFromInt(portE_base_addr + 0x84),
};

pub const GICLR_Regs: [5]*volatile GICLR_REG = .{
    @ptrFromInt(portA_base_addr + 0x88),
    @ptrFromInt(portB_base_addr + 0x88),
    @ptrFromInt(portC_base_addr + 0x88),
    @ptrFromInt(portD_base_addr + 0x88),
    @ptrFromInt(portE_base_addr + 0x88),
};

pub const GICHR_Regs: [5]*volatile GICHR_REG = .{
    @ptrFromInt(portA_base_addr + 0x8C),
    @ptrFromInt(portB_base_addr + 0x8C),
    @ptrFromInt(portC_base_addr + 0x8C),
    @ptrFromInt(portD_base_addr + 0x8C),
    @ptrFromInt(portE_base_addr + 0x8C),
};

pub const ISFR_Regs: [5]*volatile ISFR_REG = .{
    @ptrFromInt(portA_base_addr + 0xA0),
    @ptrFromInt(portB_base_addr + 0xA0),
    @ptrFromInt(portC_base_addr + 0xA0),
    @ptrFromInt(portD_base_addr + 0xA0),
    @ptrFromInt(portE_base_addr + 0xA0),
};

pub const DFER_Regs: [5]*volatile DFER_REG = .{
    @ptrFromInt(portA_base_addr + 0xC0),
    @ptrFromInt(portB_base_addr + 0xC0),
    @ptrFromInt(portC_base_addr + 0xC0),
    @ptrFromInt(portD_base_addr + 0xC0),
    @ptrFromInt(portE_base_addr + 0xC0),
};

pub const DFCR_Regs: [5]*volatile DFCR_REG = .{
    @ptrFromInt(portA_base_addr + 0xC4),
    @ptrFromInt(portB_base_addr + 0xC4),
    @ptrFromInt(portC_base_addr + 0xC4),
    @ptrFromInt(portD_base_addr + 0xC4),
    @ptrFromInt(portE_base_addr + 0xC4),
};

pub const DFWR_Regs: [5]*volatile DFWR_REG = .{
    @ptrFromInt(portA_base_addr + 0xC8),
    @ptrFromInt(portB_base_addr + 0xC8),
    @ptrFromInt(portC_base_addr + 0xC8),
    @ptrFromInt(portD_base_addr + 0xC8),
    @ptrFromInt(portE_base_addr + 0xC8),
};

// new registers ending ---------------------------------

/// PCR
pub const PORTA_PCR_Regs: *volatile [32]PCR_REG = @ptrFromInt(portA_base_addr + 0x0);
/// GPCLR
pub const PORTA_GPCLR_Reg: *volatile GPCLR_REG = @ptrFromInt(portA_base_addr + 0x80);
/// GPCHR
pub const PORTA_GPCHR_Reg: *volatile GPCHR_REG = @ptrFromInt(portA_base_addr + 0x84);
/// GICLR
pub const PORTA_GICLR_Reg: *volatile GICLR_REG = @ptrFromInt(portA_base_addr + 0x88);
/// GICHR
pub const PORTA_GICHR_Reg: *volatile GICHR_REG = @ptrFromInt(portA_base_addr + 0x8C);
/// ISFR
pub const PORTA_ISFR_Reg: *volatile ISFR_REG = @ptrFromInt(portA_base_addr + 0xA0);
/// DFER
pub const PORTA_DFER_Reg: *volatile DFER_REG = @ptrFromInt(portA_base_addr + 0xC0);
/// DFCR
pub const PORTA_DFCR_Reg: *volatile DFCR_REG = @ptrFromInt(portA_base_addr + 0xC4);
/// DFWR
pub const PORTA_DFWR_Reg: *volatile DFWR_REG = @ptrFromInt(portA_base_addr + 0xC8);

/// PORT B START
pub const PORTB_PCR_Regs: *volatile [32]PCR_REG = @ptrFromInt(portB_base_addr + 0x0);
pub const PORTB_GPCLR_Reg: *volatile GPCLR_REG = @ptrFromInt(portB_base_addr + 0x80);
pub const PORTB_GICLR_Reg: *volatile GICLR_REG = @ptrFromInt(portB_base_addr + 0x88);
pub const PORTB_GICHR_Reg: *volatile GICHR_REG = @ptrFromInt(portB_base_addr + 0x8C);
pub const PORTB_ISFR_Reg: *volatile ISFR_REG = @ptrFromInt(portB_base_addr + 0xA0);
pub const PORTB_DFER_Reg: *volatile DFER_REG = @ptrFromInt(portB_base_addr + 0xC0);
pub const PORTB_DFCR_Reg: *volatile DFCR_REG = @ptrFromInt(portB_base_addr + 0xC4);
pub const PORTB_DFWR_Reg: *volatile DFWR_REG = @ptrFromInt(portB_base_addr + 0xC8);

/// PORT C START
pub const PORTC_PCR_Regs: *volatile [32]PCR_REG = @ptrFromInt(portC_base_addr + 0x0);
pub const PORTC_GPCLR_Reg: *volatile GPCLR_REG = @ptrFromInt(portC_base_addr + 0x80);
pub const PORTC_GICLR_Reg: *volatile GICLR_REG = @ptrFromInt(portC_base_addr + 0x88);
pub const PORTC_GICHR_Reg: *volatile GICHR_REG = @ptrFromInt(portC_base_addr + 0x8C);
pub const PORTC_ISFR_Reg: *volatile ISFR_REG = @ptrFromInt(portC_base_addr + 0xA0);
pub const PORTC_DFER_Reg: *volatile DFER_REG = @ptrFromInt(portC_base_addr + 0xC0);
pub const PORTC_DFCR_Reg: *volatile DFCR_REG = @ptrFromInt(portC_base_addr + 0xC4);
pub const PORTC_DFWR_Reg: *volatile DFWR_REG = @ptrFromInt(portC_base_addr + 0xC8);

/// PORT D START
pub const PORTD_PCR_Regs: *volatile [32]PCR_REG = @ptrFromInt(portD_base_addr + 0x0);
pub const PORTD_GPCLR_Reg: *volatile GPCLR_REG = @ptrFromInt(portD_base_addr + 0x80);
pub const PORTD_GICLR_Reg: *volatile GICLR_REG = @ptrFromInt(portD_base_addr + 0x88);
pub const PORTD_GICHR_Reg: *volatile GICHR_REG = @ptrFromInt(portD_base_addr + 0x8C);
pub const PORTD_ISFR_Reg: *volatile ISFR_REG = @ptrFromInt(portD_base_addr + 0xA0);
pub const PORTD_DFER_Reg: *volatile DFER_REG = @ptrFromInt(portD_base_addr + 0xC0);
pub const PORTD_DFCR_Reg: *volatile DFCR_REG = @ptrFromInt(portD_base_addr + 0xC4);
pub const PORTD_DFWR_Reg: *volatile DFWR_REG = @ptrFromInt(portD_base_addr + 0xC8);

/// PORT E START
pub const PORTE_PCR_Regs: *volatile [32]PCR_REG = @ptrFromInt(portE_base_addr + 0x0);
pub const PORTE_GPCLR_Reg: *volatile GPCLR_REG = @ptrFromInt(portE_base_addr + 0x80);
pub const PORTE_GICLR_Reg: *volatile GICLR_REG = @ptrFromInt(portE_base_addr + 0x88);
pub const PORTE_GICHR_Reg: *volatile GICHR_REG = @ptrFromInt(portE_base_addr + 0x8C);
pub const PORTE_ISFR_Reg: *volatile ISFR_REG = @ptrFromInt(portE_base_addr + 0xA0);
pub const PORTE_DFER_Reg: *volatile DFER_REG = @ptrFromInt(portE_base_addr + 0xC0);
pub const PORTE_DFCR_Reg: *volatile DFCR_REG = @ptrFromInt(portE_base_addr + 0xC4);
pub const PORTE_DFWR_Reg: *volatile DFWR_REG = @ptrFromInt(portE_base_addr + 0xC8);
