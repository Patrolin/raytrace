const builtin = @import("builtin");
const std = @import("std");

pub const deg_to_rad = std.math.pi / 180.0;
pub const rad_to_deg = 180.0 / std.math.pi;
pub fn cos(x: f32) f32 {
    return std.math.cos(x);
}
pub fn sin(x: f32) f32 {
    return std.math.sin(x);
}

const x1 = 1.0 / std.math.ln(2.0) - 1.0;
const log2p1_bias: f32 = -(0.0 + (std.math.log2(1.0 + x1) - x1)) / 2.0;
// fast log2(1 + x) for x in [0; 1]
pub fn a_log2p1(x: f32) f32 {
    return x - log2p1_bias;
}

// @bitCast(i32, x) = ~ (log2(x) + 127) * 2^23
const sqrt_bias: i32 = (127 * 1 << 22) - (127 * 1 << 23);
pub fn a_sqrt(x: f32) f32 {
    // 1/2 * log2(x) = log2(sqrt(x))
    var i = @bitCast(i32, x); // i = (log2(x) + 127) * 2^23
    i = i >> 1; // 1/2 i = (log2(sqrt(x)) * 2^23) + (1/2 * 127 * 2^23)
    i = i - sqrt_bias; // sqrt_bias = (1/2 * 127 * 2^23) - (127 * 2^23)
    var y = @bitCast(f32, i); // i = (log2(sqrt(x)) + 127) * 2^23
    return y; // y = sqrt(x)
}
//test "a_sqrt()" {
//    @sqrt(.1)
//}
// TODO: investigate assembly: https://www.codeproject.com/Articles/69941/Best-Square-Root-Method-Algorithm-Function-Precisi

pub const isqrt_bias: i32 = (-127 * 1 << 22) - (127 * 1 << 23);
pub fn a_isqrt(x: f32) f32 {
    //var half_x = x * 0.5;

    // -1/2 * log2(x) = log2(1/sqrt(x))
    var i = @bitCast(i32, x); // i = (log2(x) + 127) * 2^23
    i = -(i >> 1); // -1/2 i = (log2(1/sqrt(x)) * 2^23) + (-1/2 * 127 * 2^23)
    i = i - isqrt_bias; // isqrt_bias = (-1/2 * 127 * 2^23) - (127 * 2^23)
    var y = @bitCast(f32, i); // i = (log2(1/sqrt(x)) + 127) * 2^23

    // Newtons method x = x + f(x)/f'(x)
    //y = y * (1.5 - (half_x * y * y)); // 1st iteration
    //y = y * (1.5 - (half_x * y * y)); // 2nd iteration
    return y; // y = 1/sqrt(x)
}

pub inline fn f_sqrt(x: f32) f32 {
    // .ReleaseFast = 50-100x .Debug
    return switch (builtin.mode) {
        else => @sqrt(x),
        .ReleaseSafe, .ReleaseFast, .ReleaseSmall => a_sqrt(x),
    };
}
pub inline fn f_isqrt(x: f32) f32 {
    // .ReleaseFast = 10-75x .Debug
    return switch (builtin.mode) {
        else => 1 / @sqrt(x),
        .ReleaseFast, .ReleaseSmall => a_isqrt(x),
    };
}

pub const vec3 = [3]f32;
//pub const vec3 = std.meta.Vector(3, f32);

pub fn add_vec3(A: vec3, B: vec3) vec3 {
    return .{ A[0] + B[0], A[1] + B[1], A[2] + B[2] };
}
pub fn sub_vec3(A: vec3, B: vec3) vec3 {
    return .{ A[0] - B[0], A[1] - B[1], A[2] - B[2] };
}
pub fn mul_vec3(A: vec3, x: f32) vec3 {
    return .{ A[0] * x, A[1] * x, A[2] * x };
}
pub fn normalize_vec3(A: vec3) vec3 {
    return mul_vec3(A, 1 / @sqrt(sq_vec3(A)));
}
pub fn dot_vec3(A: vec3, B: vec3) f32 {
    return (A[0] * B[0]) + (A[1] * B[1]) + (A[2] * B[2]);
}
pub fn cross_vec3(A: vec3, B: vec3) vec3 {
    return (vec3){
        (A[1] * B[2]) - (B[1] * A[2]),
        (A[2] * B[0]) - (B[2] * A[0]),
        (A[0] * B[1]) - (B[0] * A[1]),
    };
}
pub fn sq_vec3(A: vec3) f32 {
    return (A[0] * A[0]) + (A[1] * A[1]) + (A[2] * A[2]);
}
pub fn cos_vec3(A: vec3, B: vec3) f32 {
    return dot_vec3(A, B) * f_isqrt(sq_vec3(A) * sq_vec3(B));
}
