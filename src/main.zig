const std = @import("std");
const time = std.time;
const math = @import("./math.zig");
const format = @import("./format.zig");
const vec3 = math.vec3;

const Ray = struct {
    normalized_direction: vec3,
    position: vec3,
};
const Sphere = struct {
    position: vec3,
    radius: f32,
};
const Plane = struct {
    normalized_direction: vec3,
    distance: f32,
};

const SphereIntersection = struct {
    distance1: f32 = -std.math.inf(f32),
    distance2: f32 = -std.math.inf(f32),
};
fn intersect(ray: Ray, sphere: Sphere) SphereIntersection {
    var ray_sphere_vector = math.sub_vec3(sphere.position, ray.position);
    var ray_sphere_distance = math.dot_vec3(ray_sphere_vector, ray.normalized_direction);
    if (ray_sphere_distance < 0) return .{};

    var leg_squared = math.sq_vec3(ray_sphere_vector) - ray_sphere_distance * ray_sphere_distance;
    var sphere_radius_squared = sphere.radius * sphere.radius;
    if (leg_squared > sphere_radius_squared) return .{};

    var chord_half = math.f_sqrt(sphere_radius_squared - leg_squared);
    return .{
        .distance1 = ray_sphere_distance - chord_half,
        .distance2 = ray_sphere_distance + chord_half,
    };
}

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const cwd = std.fs.cwd();
    const out_file = try cwd.createFile("out.ppm", .{});
    defer out_file.close();
    const out = out_file.writer();

    var sphere = Sphere{ .position = .{ 50, 0, 0 }, .radius = 20 };

    const width = 160;
    const height = 90;
    var times: [height * width]f64 = undefined;
    const max_int: f32 = 255.0;
    try out.print("P3\n{d:.0} {d:.0}\n{d:.0}\n", .{ width, height, max_int });
    const x_fov = 90 * math.deg_to_rad;
    const y_fov = 60 * math.deg_to_rad;
    var y: usize = 0;
    while (y < height) : (y += 1) {
        var x: usize = 0;
        while (x < width) : (x += 1) {
            var a = (@intToFloat(f32, x) / @intToFloat(f32, width - 1) - 0.5) * x_fov;
            var b = (@intToFloat(f32, y) / @intToFloat(f32, height - 1) - 0.5) * y_fov;
            var ray = Ray{ .position = .{ 0, 0, 0 }, .normalized_direction = .{ math.cos(a) * math.cos(b), math.sin(a), math.cos(a) * math.sin(b) } }; // @TODO: implement camera transform

            var intersection = intersect(ray, sphere);
            var ray_sphere1 = math.add_vec3(ray.position, math.mul_vec3(ray.normalized_direction, intersection.distance1));
            var sphere_sphere1_vector = math.sub_vec3(ray_sphere1, sphere.position);
            var cos = if (intersection.distance1 > 0) -math.cos_vec3(ray_sphere1, sphere_sphere1_vector) else 0;
            var RGB: [3]u8 = .{
                @floatToInt(u8, std.math.min(cos * max_int, max_int)),
                @floatToInt(u8, std.math.min(cos * max_int, max_int)),
                @floatToInt(u8, std.math.min(cos * max_int, max_int)),
            };
            try out.print("{d:.0} {d:.0} {d:.0}\n", .{ RGB[0], RGB[1], RGB[2] });
            times[y * height + x] = @intToFloat(f64, timer.lap()) / @intToFloat(f64, std.time.ns_per_s);
        }
    }

    format.log(&times);
}
