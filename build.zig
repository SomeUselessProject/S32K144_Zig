const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {

    // 1 set compile target and the target file
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabihf,
        .cpu_model = std.Target.Query.CpuModel{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        .cpu_features_add = std.Target.arm.featureSet(&[_]std.Target.arm.Feature{std.Target.arm.Feature.thumb2}),
    });

    //const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseSmall });
    const executable_name = "s32k144Test";
    const elf = b.addExecutable(.{
        .name = executable_name ++ ".elf",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = .Debug,
        .linkage = .static,
        .single_threaded = true,
    });
    // used to maintain the debug info
    //elf.root_module.
    elf.root_module.strip = false;

    // 1 add the start mod to this project
    // ----------------------------------------------------------
    const start_mod = b.addModule(
        "startup",
        .{ .root_source_file = b.path("./src/01_startup/startup.zig") },
    );
    elf.root_module.addImport("start_mod", start_mod);
    // 2 add registers mod to this project
    // ----------------------------------------------------------
    const regs_mod = b.addModule(
        "regs_mod",
        .{ .root_source_file = b.path("./src/02_registers/S32K144_Regs.zig") },
    );
    elf.root_module.addImport("s32k144_regs_mod", regs_mod);
    // 3 Add GenericSys Mod to the Project
    // ---------------------------------------------------------
    const generic_sys_mod = b.addModule(
        "generic_sys_mod",
        .{ .root_source_file = b.path("./src/03_general_system/S32K144_GenericSys.zig") },
    );
    generic_sys_mod.addImport("s32k144_regs_mod", regs_mod);
    generic_sys_mod.addImport("start_mod", start_mod);
    elf.root_module.addImport("s32k144_genericSys_mod", generic_sys_mod);
    // 4 add drivers mod to this project
    // -----------------------------------------------------------
    const drivers_mod = b.addModule(
        "drivers_mod",
        .{ .root_source_file = b.path("./src/04_drivers/S32K144_Drivers.zig") },
    );
    drivers_mod.addImport("s32k144_genericSys_mod", generic_sys_mod);
    drivers_mod.addImport("s32k144_regs_mod", regs_mod);
    drivers_mod.addImport("start_mod", start_mod);
    elf.root_module.addImport("s32k144_drivers_mod", drivers_mod);
    // ----------------------------------------------------------------
    // 5 add data center mod to this project
    const data_center_mod = b.addModule(
        "data_center",
        .{ .root_source_file = b.path("./src/05_data_center/DataCenterMod.zig") },
    );
    elf.root_module.addImport("data_center", data_center_mod);
    // ----------------------------------------------------------------

    const rtt = b.dependency("rtt", .{});
    elf.root_module.addImport("rtt", rtt.module("rtt"));

    // set linker
    elf.setLinkerScript(b.path("linker/S32K144.ld"));

    // lto should not be used; it will cause error
    //elf.want_lto = true;
    // if the optimize mode == debug, this option should be turn on to remove unused code
    elf.link_gc_sections = true;
    // 下面这两个选项会进一步压缩空间，但是可能会导致错误,不建议启用
    //elf.link_data_sections = true;
    //elf.link_function_sections = true;

    //elf.entry = .{ .symbol_name = "_start" };

    // Produce .hex file from .elf
    const hex = b.addObjCopy(elf.getEmittedBin(), .{
        .format = .hex,
    });
    hex.step.dependOn(&elf.step);
    const copy_hex = b.addInstallBinFile(hex.getOutput(), executable_name ++ ".hex");
    b.default_step.dependOn(&copy_hex.step);

    b.default_step.dependOn(&elf.step);
    b.installArtifact(elf);

    // testing --------------
    //const test_step = b.addTest(.{ .root_source_file = b.path("./src/UnitTest.zig"), .target = b.standardTargetOptions(.{}), .optimize = .Debug });
    // 添加依赖模块
    //test_step.root_module.addImport("s32k144_regs_mod", regs_mod);
    // 将测试添加到默认步骤
    //const tests = b.step("test", "Run Test");
    //tests.dependOn(&test_step.step);
}
