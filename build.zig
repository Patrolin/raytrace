const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();
    //@setFloatMode(.Optimized); // do nothing

    // Time
    const time = b.addExecutable("time", "src/time.zig");
    time.setTarget(target);
    time.setBuildMode(mode);
    time.install();

    const time_cmd = time.run();
    time_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        time_cmd.addArgs(args);
    }

    const time_step = b.step("time", "Time the functions");
    time_step.dependOn(&time_cmd.step);

    // Run
    const exe = b.addExecutable("raytrace", "src/raytrace.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // WASM
    const wasm = b.addStaticLibrary("main", "src/main.zig");
    wasm.setTarget(std.zig.CrossTarget.parse(.{ .arch_os_abi = "wasm32-freestanding" }) catch unreachable);
    wasm.setBuildMode(mode);
    wasm.setOutputDir("zig-cache/bin");
    //wasm.strip = true; // do nothing
    wasm.install();

    const wasm_step = b.step("wasm", "Build for WASM");
    wasm_step.dependOn(&wasm.step);
}
