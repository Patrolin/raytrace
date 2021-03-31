const std = @import("std");
const time = std.time;
const math = @import("./math.zig");
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
fn intersect_sphere(ray: Ray, sphere: Sphere) SphereIntersection {
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
const PlaneIntersection = struct {
    distance: f32 = -std.math.inf(f32),
};
fn intersect_plane(ray: Ray, plane: Plane) PlaneInterSection {
    var denom = math.mul_vec3(ray.normalized_direction, plane.normalized_direction);
    if (denom == 0) return .{};

    return .{(plane.distance - math.mul_vec3(ray.position, plane.normalized_direction)) / denom};
}

pub const RGBA = struct {
    R: u8,
    G: u8,
    B: u8,
    A: u8 = 255,
};
pub fn raytrace(buffer: *[]RGBA, width: u32) !void {
    const height = @divExact(buffer.len, width);

    var sphere = Sphere{ .position = .{ 50, 0, 0 }, .radius = 20 };
    const max_int: f32 = 255.0;
    const x_fov = 90 * math.deg_to_rad;
    const y_fov = x_fov * @intToFloat(f32, height) / @intToFloat(f32, width);
    var y: usize = 0;
    while (y < height) : (y += 1) {
        var x: usize = 0;
        while (x < width) : (x += 1) {
            var a = (@intToFloat(f32, x) / @intToFloat(f32, width - 1) - 0.5) * x_fov;
            var b = (@intToFloat(f32, y) / @intToFloat(f32, height - 1) - 0.5) * y_fov;
            var ray = Ray{
                .position = .{ 0, 0, 0 },
                .normalized_direction = .{
                    math.cos(a) * math.cos(b),
                    math.sin(a),
                    math.cos(a) * math.sin(b),
                },
            }; // @TODO: implement camera transform

            var intersection = intersect_sphere(ray, sphere);
            var ray_sphere1 = math.mul_vec3(ray.normalized_direction, intersection.distance1);
            var sphere_sphere1_vector = math.sub_vec3(ray_sphere1, sphere.position);
            var cos = if (intersection.distance1 > 0) -math.cos_vec3(ray_sphere1, sphere_sphere1_vector) else 0;
            buffer.*[y * width + x] = .{
                .R = @floatToInt(u8, std.math.min(cos * max_int, max_int)),
                .G = @floatToInt(u8, std.math.min(cos * max_int, max_int)),
                .B = @floatToInt(u8, std.math.min(cos * max_int, max_int)),
            };
        }
    }
}
