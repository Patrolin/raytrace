const std = @import("std");

pub const io_mode = .evented;

var testRunDetachedData: usize = 0;
pub fn main() !void {
    var loop: std.event.Loop = std.event.Loop.instance.?.*;
    //try loop.initSingleThreaded();
    try loop.initMultiThreaded();
    defer loop.deinit();

    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});
    try loop.runDetached(std.testing.allocator, testRunDetached, .{});

    loop.run();
}

fn testRunDetached() void {
    var foo = 2 * testRunDetachedData + 1;
    testRunDetachedData = foo;
    std.debug.print("ThreadID = {} => \ttestRunDetachedData = {}\n", .{ std.Thread.getCurrentId(), testRunDetachedData });
}
