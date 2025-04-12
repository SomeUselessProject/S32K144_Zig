//! S32K144 GPIO Registers
//! by weng
//! 2025/02/21

const PDOR_REG = packed struct(u32) {
    /// [0..31]
    /// Port Data Output
    PDO: u32 = 0,
};

const PSOR_REG = packed struct(u32) {
    /// [0..31]
    /// Port Set Output
    PTSO: u32 = 0,
};

const PCOR_REG = packed struct(u32) {
    /// [0..31]
    /// Port Clear Output
    PTCO: u32 = 0,
};

const PTOR_REG = packed struct(u32) {
    /// [0..31]
    /// Port Toggle Output
    PTTO: u32 = 0,
};

const PDIR_REG = packed struct(u32) {
    /// [0..31]
    /// Port Data Input
    PDI: u32 = 0,
};

const PDDR_REG = packed struct(u32) {
    /// [0..31]
    /// Port Data Direction
    PDD: u32 = 0,
};

const PIDR_REG = packed struct(u32) {
    /// [0..31]
    /// Port Input Disable
    PID: u32 = 0,
};

/// PTA ADDRESS START
const pta_base_addr: u32 = 0x400F_F000;
/// PDOR
pub const PTA_PDOR_Reg: *volatile PDOR_REG = @ptrFromInt(pta_base_addr + 0x0);
/// PSOR
pub const PTA_PSOR_Reg: *volatile PSOR_REG = @ptrFromInt(pta_base_addr + 0x4);
/// PCOR
pub const PTA_PCOR_Reg: *volatile PCOR_REG = @ptrFromInt(pta_base_addr + 0x8);
/// PTOR
pub const PTA_PTOR_Reg: *volatile PTOR_REG = @ptrFromInt(pta_base_addr + 0xC);
/// PDIR
pub const PTA_PDIR_Reg: *volatile PDIR_REG = @ptrFromInt(pta_base_addr + 0x10);
/// PDDR
pub const PTA_PDDR_Reg: *volatile PDDR_REG = @ptrFromInt(pta_base_addr + 0x14);
/// PIDR
pub const PTA_PIDR_Reg: *volatile PIDR_REG = @ptrFromInt(pta_base_addr + 0x18);

/// PTB ADDRESS START
const ptb_base_addr: u32 = 0x400F_F040;
/// PDOR
pub const PTB_PDOR_Reg: *volatile PDOR_REG = @ptrFromInt(ptb_base_addr + 0x0);
/// PSOR
pub const PTB_PSOR_Reg: *volatile PSOR_REG = @ptrFromInt(ptb_base_addr + 0x4);
/// PCOR
pub const PTB_PCOR_Reg: *volatile PCOR_REG = @ptrFromInt(ptb_base_addr + 0x8);
/// PTOR
pub const PTB_PTOR_Reg: *volatile PTOR_REG = @ptrFromInt(ptb_base_addr + 0xC);
/// PDIR
pub const PTB_PDIR_Reg: *volatile PDIR_REG = @ptrFromInt(ptb_base_addr + 0x10);
/// PDDR
pub const PTB_PDDR_Reg: *volatile PDDR_REG = @ptrFromInt(ptb_base_addr + 0x14);
/// PIDR
pub const PTB_PIDR_Reg: *volatile PIDR_REG = @ptrFromInt(ptb_base_addr + 0x18);

/// PTC ADDRESS START
const ptc_base_addr: u32 = 0x400F_F080;
/// PDOR
pub const PTC_PDOR_Reg: *volatile PDOR_REG = @ptrFromInt(ptc_base_addr + 0x0);
/// PSOR
pub const PTC_PSOR_Reg: *volatile PSOR_REG = @ptrFromInt(ptc_base_addr + 0x4);
/// PCOR
pub const PTC_PCOR_Reg: *volatile PCOR_REG = @ptrFromInt(ptc_base_addr + 0x8);
/// PTOR
pub const PTC_PTOR_Reg: *volatile PTOR_REG = @ptrFromInt(ptc_base_addr + 0xC);
/// PDIR
pub const PTC_PDIR_Reg: *volatile PDIR_REG = @ptrFromInt(ptc_base_addr + 0x10);
/// PDDR
pub const PTC_PDDR_Reg: *volatile PDDR_REG = @ptrFromInt(ptc_base_addr + 0x14);
/// PIDR
pub const PTC_PIDR_Reg: *volatile PIDR_REG = @ptrFromInt(ptc_base_addr + 0x18);

/// PTD ADDRESS START
const ptd_base_addr: u32 = 0x400F_F0C0;
pub const PTD_PDOR_Reg: *volatile PDOR_REG = @ptrFromInt(ptd_base_addr + 0x0);
pub const PTD_PSOR_Reg: *volatile PSOR_REG = @ptrFromInt(ptd_base_addr + 0x4);
pub const PTD_PCOR_Reg: *volatile PCOR_REG = @ptrFromInt(ptd_base_addr + 0x8);
pub const PTD_PTOR_Reg: *volatile PTOR_REG = @ptrFromInt(ptd_base_addr + 0xC);
pub const PTD_PDIR_Reg: *volatile PDIR_REG = @ptrFromInt(ptd_base_addr + 0x10);
pub const PTD_PDDR_Reg: *volatile PDDR_REG = @ptrFromInt(ptd_base_addr + 0x14);
pub const PTD_PIDR_Reg: *volatile PIDR_REG = @ptrFromInt(ptd_base_addr + 0x18);

/// PTE ADDRESS START
const pte_base_addr: u32 = 0x400F_F100;
pub const PTE_PDOR_Reg: *volatile PDOR_REG = @ptrFromInt(pte_base_addr + 0x0);
pub const PTE_PSOR_Reg: *volatile PSOR_REG = @ptrFromInt(pte_base_addr + 0x4);
pub const PTE_PCOR_Reg: *volatile PCOR_REG = @ptrFromInt(pte_base_addr + 0x8);
pub const PTE_PTOR_Reg: *volatile PTOR_REG = @ptrFromInt(pte_base_addr + 0xC);
pub const PTE_PDIR_Reg: *volatile PDIR_REG = @ptrFromInt(pte_base_addr + 0x10);
pub const PTE_PDDR_Reg: *volatile PDDR_REG = @ptrFromInt(pte_base_addr + 0x14);
pub const PTE_PIDR_Reg: *volatile PIDR_REG = @ptrFromInt(pte_base_addr + 0x18);
