const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day10.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(buffer);
    const p1_time = timer.lap();
    const p2 = part2(buffer);
    const p2_time = timer.read();
    try stdout.print("Day10:\npart1: {d} {d}ns\npart2: {s} {d}ns", .{ p1, p1_time, p2, p2_time });
}

fn pass(buffer: []u8, index: *u8, skip: *u8, length: u8) void {
    var i: u8 = 0;
    while (i < (length / 2)) : (i += 1) {
        std.mem.swap(u8, &buffer[index.* +% i], &buffer[index.* +% length -% i -% 1]);
    }
    index.* +%= length +% skip.*;
    skip.* +%= 1;
}

fn part1(input: []const u8) !usize {
    var buffer: [256]u8 = undefined;
    for (0..256) |i| buffer[i] = @truncate(i);
    var skip: u8 = 0;
    var index: u8 = 0;
    var words = tokenizeAny(u8, input, ",\r\n");
    while (words.next()) |word| {
        var length = try std.fmt.parseInt(u8, word, 10);
        pass(&buffer, &index, &skip, length);
    }

    return @as(usize, buffer[0]) * @as(usize, buffer[1]);
}

fn part2(input: []const u8) [32]u8 {
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
    var dense: [16]u8 = undefined;
    for (0..16) |i| {
        dense[i] = buffer[i * 16];
        for (buffer[i * 16 + 1 .. i * 16 + 16]) |c| {
            dense[i] ^= c;
        }
    }
    return std.fmt.bytesToHex(dense, .lower);
}

test "part1" {
    try std.testing.expect(try part1("227,169,3,166,246,201,0,47,1,255,2,254,96,3,97,144") == 13760);
}

test "part2" {
    try std.testing.expect(std.mem.eql(u8, &part2("1,2,3"), "3efbe78a8d82f29979031a4aa0b16a9d"));
}
