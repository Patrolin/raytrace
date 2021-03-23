const std = @import("std");
fn log1p(x: f64) u64 {
    return @floatToInt(u64, std.math.log1p(x));
}
pub fn log(times: []const f64) void {
    std.log.info("({:.2} {:.2})", .{ std.mem.min(f64, times), std.mem.max(f64, times) });
    std.log.info("({:.2} {:.2})", .{ log1p(std.mem.min(f64, times)), log1p(std.mem.max(f64, times)) });
}
