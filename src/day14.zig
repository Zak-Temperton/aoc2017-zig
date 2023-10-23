const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day14.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    const input = std.mem.trimRight(u8, buffer, "\r\n");
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, input);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, input);
    const p2_time = timer.read();
    try stdout.print("Day14:\npart1: {d} {d}ns\npart2: {d} {d}ns", .{ p1, p1_time, p2, p2_time });
}

fn part1(alloc: Allocator, input: []const u8) !usize {
    var count: usize = 0;
    var buf = std.ArrayList(u8).init(alloc);
    defer buf.deinit();
    for (0..128) |i| {
        var writer = buf.writer();
        try std.fmt.format(writer, "{s}-{d}", .{ input, i });
        count += @popCount(knotHash(buf.items));
        buf.clearRetainingCapacity();
    }

    return count;
}

fn part2(alloc: Allocator, input: []const u8) !usize {
    var buf = std.ArrayList(u8).init(alloc);
    defer buf.deinit();
    var disk: [128]u128 = undefined;
    for (0..128) |i| {
        var writer = buf.writer();
        try std.fmt.format(writer, "{s}-{d}", .{ input, i });
        disk[i] = knotHash(buf.items);
        buf.clearRetainingCapacity();
    }
    var count: usize = 0;
    for (0..128) |y| {
        for (0..128) |x| {
            if (flood(@truncate(x), @truncate(y), &disk)) count += 1;
        }
    }
    return count;
}

fn flood(x: u7, y: u7, disk: []u128) bool {
    var mask: u128 = @as(u128, 1) << x;
    if (disk[y] & mask == 0) return false;
    disk[y] ^= mask;
    std.debug.assert(disk[y] & mask == 0);
    _ = flood(x, y +| 1, disk);
    _ = flood(x, y -| 1, disk);
    _ = flood(x +| 1, y, disk);
    _ = flood(x -| 1, y, disk);

    return true;
}

fn pass(buffer: []u8, index: *u8, skip: *u8, length: u8) void {
    var i: u8 = 0;
    while (i < (length / 2)) : (i += 1) {
        std.mem.swap(u8, &buffer[index.* +% i], &buffer[index.* +% length -% i -% 1]);
    }
    index.* +%= length +% skip.*;
    skip.* +%= 1;
}

fn knotHash(input: []const u8) u128 {
    var buffer: [256]u8 = undefined;
    for (0..256) |i| buffer[i] = @truncate(i);
    var skip: u8 = 0;
    var index: u8 = 0;
    for (0..64) |_| {
        for (input) |c| {
            if (c == '\r' or c == '\n') break;
            pass(&buffer, &index, &skip, c);
        }
        for ([_]u8{ 17, 31, 73, 47, 23 }) |c| {
            pass(&buffer, &index, &skip, c);
        }
    }
    var dense: u128 = undefined;
    for (0..16) |i| {
        dense <<= 8;
        for (buffer[i * 16 .. i * 16 + 16]) |c| {
            dense ^= c;
        }
    }
    return dense;
}

test "part1" {
    try std.testing.expect(try part1(std.testing.allocator, "flqrgnkx") == 8108);
}

test "part2" {
    try std.testing.expect(try part2(std.testing.allocator, "flqrgnkx") == 1242);
}
