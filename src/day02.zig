const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const tokenizeAny = std.mem.tokenizeAny;
const parseInt = std.fmt.parseInt;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day02.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day02:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn part1(input: []const u8) !usize {
    var checksum: usize = 0;
    var lines = tokenizeAny(u8, input, "\r\n");
    while (lines.next()) |line| {
        var words = tokenizeAny(u8, line, " \t");

        var min: usize = try parseInt(usize, words.next().?, 10);
        var max: usize = min;
        while (words.next()) |word| {
            var num = try parseInt(usize, word, 10);
            if (num < min) {
                min = num;
            } else if (num > max) {
                max = num;
            }
        }
        checksum += max - min;
    }
    return checksum;
}

fn part2(alloc: Allocator, input: []const u8) !usize {
    var checksum: usize = 0;
    var lines = tokenizeAny(u8, input, "\r\n");
    while (lines.next()) |line| {
        var words = tokenizeAny(u8, line, " \t");

        var row = ArrayList(usize).init(alloc);
        defer row.deinit();
        blk: while (words.next()) |word| {
            var num = try parseInt(usize, word, 10);
            for (row.items) |item| {
                if (item % num == 0) {
                    checksum += item / num;
                    break :blk;
                } else if (num % item == 0) {
                    checksum += num / item;
                    break :blk;
                }
            }
            try row.append(num);
        }
    }
    return checksum;
}

test "part1" {
    const input =
        \\5 1 9 5
        \\7 5 3
        \\2 4 6 8
    ;
    try std.testing.expect(try part1(input) == 18);
}

test "part2" {
    const input =
        \\5 9 2 8
        \\9 4 7 3
        \\3 8 6 5
    ;
    try std.testing.expect(try part2(std.testing.allocator, input) == 9);
}
