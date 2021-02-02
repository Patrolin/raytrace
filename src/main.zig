const std = @import("std");
const time = std.time;
const math = @import("./math.zig");
const vec3 = math.vec3;

const Ray = struct {
    pos: vec3,
    dir: vec3, // must be normalized!
};
const Sphere = struct {
    pos: vec3,
    r: f32,
};

const SphereIntersection = struct {
    t1: f32 = 0, // 0 = didn't intersect
    t2: f32 = undefined,
};
var stdout: std.fs.File.Writer = undefined;
fn intersect(r: Ray, s: Sphere) SphereIntersection {
    var rs = math.sub_vec3(s.pos, r.pos);
    var t_p = math.dot_vec3(rs, r.dir);
    if (t_p < 0) return .{};

    var d_sq = math.sq_vec3(rs) - t_p * t_p;
    var r_sq = s.r * s.r;
    if (d_sq > r_sq) return .{};

    var dt = math.f_sqrt(r_sq - d_sq);
    return .{
        .t1 = t_p - dt,
        .t2 = t_p + dt,
    };
}

pub fn main() !void {
    var start = time.nanoTimestamp();
    stdout = std.io.getStdOut().writer();
    const cwd = std.fs.cwd();
    const out_file = cwd.createFile("out.ppm", .{}) catch unreachable;
    defer out_file.close();
    const out = out_file.writer();

    var s = Sphere{ .pos = .{ 50, 0, 0 }, .r = 20 };

    const width = 160;
    const height = 90;
    const max_int: f32 = 255.0;
    out.print("P3\n{d:.0} {d:.0}\n{d:.0}", .{ width, height, max_int }) catch unreachable;
    const x_fov = 90 * math.deg_to_rad;
    const y_fov = 60 * math.deg_to_rad;
    var y: usize = 0;
    while (y < height) : (y += 1) {
        var x: usize = 0;
        while (x < width) : (x += 1) {
            var a = (@intToFloat(f32, x) / @intToFloat(f32, width - 1) - 0.5) * x_fov;
            var b = (@intToFloat(f32, y) / @intToFloat(f32, height - 1) - 0.5) * y_fov;
            var r = Ray{ .pos = .{ 0, 0, 0 }, .dir = .{ math.cos(a) * math.cos(b), math.sin(a), math.cos(a) * math.sin(b) } };

            var i = intersect(r, s);
            //stdout.print("\n{d:.2} {d:.2}\n", .{ i.t1, i.t2 }) catch unreachable;
            var s1 = math.add_vec3(r.pos, math.mul_vec3(r.dir, i.t1));
            var sn = math.sub_vec3(s1, s.pos);
            var cos = -math.cos_vec3(s1, sn);
            //if (@mod(y, height) == 0) {
            //    stdout.print("\n", .{}) catch unreachable;
            //}
            //stdout.print("{d: >5.2} ", .{cos}) catch unreachable;
            //stdout.print("{d:.2} {d:.2} {d:.2}\n", .{ s1[0], s1[1], s1[2] }) catch unreachable;
            var RGB: [3]u8 = .{
                @floatToInt(u8, std.math.min(cos * max_int, max_int)),
                @floatToInt(u8, std.math.min(cos * max_int, max_int)),
                @floatToInt(u8, std.math.min(cos * max_int, max_int)),
            };
            out.print("\n{d:.0} {d:.0} {d:.0}", .{ RGB[0], RGB[1], RGB[2] }) catch unreachable;
        }
    }

    var end = time.nanoTimestamp();
    stdout.print("\n{d:.2}s", .{@intToFloat(f64, end - start) / 1e9}) catch unreachable;
}
