const std = @import("std");

pub fn build(b: *std.Build) void {
    var target = std.zig.CrossTarget{
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.arm7tdmi },
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
    };
    target.cpu_features_add.addFeature(@intFromEnum(std.Target.arm.Feature.thumb_mode));

    const exe = b.addExecutable(.{
        .name = "zig-gba",
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(target),
        .optimize = .ReleaseSafe,
    });
    //exe.setLinkerScript(b.path("gba.ld"));
    exe.setLinkerScript(b.path("c_boot.ld"));
    b.installArtifact(exe);

    b.default_step.dependOn(&exe.step);

    const objcopy_step = exe.addObjCopy(.{ .format = .bin });
    objcopy_step.step.dependOn(&exe.step);

    const install_bin_step = b.addInstallBinFile(objcopy_step.getOutput(), "zig-gba.gba");
    install_bin_step.step.dependOn(&objcopy_step.step);

    const mgba = b.addSystemCommand(&.{"/Applications/mGBA.app/Contents/MacOS/mGBA"});
    mgba.addFileArg(objcopy_step.getOutput());

    const run_step = b.step("run", "Runs the program in mGBA");
    run_step.dependOn(&install_bin_step.step);
    run_step.dependOn(&mgba.step);
}
