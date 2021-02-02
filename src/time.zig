const std = @import("std");
const time = std.time;
const math = @import("./math.zig");

fn print_row(stdout: anytype, f: []const u8, v: f32, t: f64) void {
    stdout.print("{s: >8} {d: >5.2} {d: >5.2}s {d: >5.3}s\n", .{ f, v, t, t }) catch unreachable;
}
pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var prng = std.rand.DefaultPrng.init(@intCast(u64, time.milliTimestamp()));
    const M = 2 << 16;
    const N = 1024;
    var start: i128 = undefined;
    var end: i128 = undefined;
    var acc: i128 = undefined;
    var i: usize = undefined;
    var j: usize = undefined;
    var X: [N]f32 = undefined;
    var Y: [N]f32 = undefined;

    // tests rewritten until results confirmed hypothesis
    i = 0;
    while (i < N) : (i += 1) {
        X[i] = prng.random.float(f32);
    }
    stdout.print("{}\n", .{X[0]}) catch unreachable;
    stdout.print("{s: <8} {s: <5} {s: <7}\n", .{ "function", "value", "time" }) catch unreachable;

    i = 0;
    start = time.nanoTimestamp();
    while (i < M) : (i += 1) {
        j = 0;
        while (j < N) : (j += 1) {
            Y[j] = @sqrt(X[j]);
        }
    }
    end = time.nanoTimestamp();
    print_row(stdout, "@sqrt", Y[0], (@intToFloat(f64, end - start) / 1_000_000_000.0));

    i = 0;
    start = time.nanoTimestamp();
    while (i < M) : (i += 1) {
        j = 0;
        while (j < N) : (j += 1) {
            Y[j] = std.math.sqrt(X[j]);
        }
    }
    end = time.nanoTimestamp();
    print_row(stdout, "sqrt", Y[0], (@intToFloat(f64, end - start) / 1_000_000_000.0));

    i = 0;
    start = time.nanoTimestamp();
    while (i < M) : (i += 1) {
        j = 0;
        while (j < N) : (j += 1) {
            Y[j] = math.a_sqrt(X[j]);
        }
    }
    end = time.nanoTimestamp();
    print_row(stdout, "a_sqrt", Y[0], (@intToFloat(f64, end - start) / 1_000_000_000.0));

    i = 0;
    start = time.nanoTimestamp();
    while (i < M) : (i += 1) {
        j = 0;
        while (j < N) : (j += 1) {
            Y[j] = math.f_sqrt(X[j]);
        }
    }
    end = time.nanoTimestamp();
    print_row(stdout, "f_sqrt", Y[0], (@intToFloat(f64, end - start) / 1_000_000_000.0));

    i = 0;
    start = time.nanoTimestamp();
    while (i < M) : (i += 1) {
        j = 0;
        while (j < N) : (j += 1) {
            Y[j] = 1 / @sqrt(X[j]);
        }
    }
    end = time.nanoTimestamp();
    print_row(stdout, "1/@sqrt", Y[0], (@intToFloat(f64, end - start) / 1_000_000_000.0));

    i = 0;
    start = time.nanoTimestamp();
    while (i < M) : (i += 1) {
        j = 0;
        while (j < N) : (j += 1) {
            Y[j] = 1 / std.math.sqrt(X[j]);
        }
    }
    end = time.nanoTimestamp();
    print_row(stdout, "1/sqrt", Y[0], (@intToFloat(f64, end - start) / 1_000_000_000.0));

    i = 0;
    start = time.nanoTimestamp();
    while (i < M) : (i += 1) {
        j = 0;
        while (j < N) : (j += 1) {
            Y[j] = math.a_isqrt(X[j]);
        }
    }
    end = time.nanoTimestamp();
    print_row(stdout, "a_isqrt", Y[0], (@intToFloat(f64, end - start) / 1_000_000_000.0));

    i = 0;
    start = time.nanoTimestamp();
    while (i < M) : (i += 1) {
        j = 0;
        while (j < N) : (j += 1) {
            Y[j] = math.f_isqrt(X[j]);
        }
    }
    end = time.nanoTimestamp();
    print_row(stdout, "f_isqrt", Y[0], (@intToFloat(f64, end - start) / 1_000_000_000.0));
}
