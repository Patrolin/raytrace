const std = @import("std");

const imports = struct {
    extern fn printInt(int: u32) void;
    extern fn printFloat(int: f32) void;
    extern fn printString(ptr: [*]const u8, len: usize) void;
    extern fn printBytes(ptr: [*]const u8, len: usize) void;
};
fn print(x: anytype) void {
    switch (@typeInfo(@TypeOf(x))) {
        .Int, .ComptimeInt => imports.printInt(x),
        .Float, .ComptimeFloat => imports.printFloat(x),
        .Array => imports.printString(x.ptr, x.len),
        .Pointer => imports.printString(x, x.len),
        else => @compileLog(@typeInfo(@TypeOf(x))),
    }
}
fn printBytes(x: anytype) void {
    var bytes = std.mem.asBytes(x);
    imports.printBytes(bytes, bytes.len);
}

const raytrace = @import("./raytrace.zig");
const RGBA = raytrace.RGBA;

var buffer: ?[]RGBA = null;
export fn render(width: u32, height: u32) usize {
    if (buffer) |buf| std.heap.page_allocator.free(buf);
    if (std.heap.page_allocator.alloc(RGBA, width * height)) |buf| {
        buffer = buf;
    } else |err| {
        return 0;
    }
    for (buffer.?) |*pixel, i| {
        var x = i % height;
        var y = i / height;
        pixel.* = .{ .R = @intCast(u8, x ^ y), .G = 0, .B = 0 };
    }
    raytrace.raytrace(&buffer.?, width) catch |err| {
        print(@typeName(@TypeOf(err)));
    };
    print("render");
    return @ptrToInt(buffer.?.ptr);
}
