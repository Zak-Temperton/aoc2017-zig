const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day05.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day05:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn part1(alloc: Allocator, input: []const u8) !usize {
    var count: usize = 0;
    var list = std.ArrayList(isize).init(alloc);
    defer list.deinit();
    var lines = tokenizeAny(u8, input, "\r\n");
    while (lines.next()) |line| {
        try list.append(try std.fmt.parseInt(isize, line, 10));
    }
    var index: isize = 0;
    const slice = list.items;
    while (index < slice.len) : (count += 1) {
        const i = slice[@intCast(index)];
        slice[@intCast(index)] += 1;
        index += i;
    }
    return count;
}

fn part2(alloc: Allocator, input: []const u8) !usize {
    var count: usize = 0;
    var list = std.ArrayList(isize).init(alloc);
    defer list.deinit();
    var lines = tokenizeAny(u8, input, "\r\n");
    while (lines.next()) |line| {
        try list.append(try std.fmt.parseInt(isize, line, 10));
    }
    var index: isize = 0;
    const slice = list.items;
    while (index < slice.len) : (count += 1) {
        const i = slice[@intCast(index)];
        if (i >= 3) {
            slice[@intCast(index)] -= 1;
        } else {
            slice[@intCast(index)] += 1;
        }
        index += i;
    }
    return count;
}

test "part1" {
    try std.testing.expect(try part1(std.testing.allocator,
        \\0
        \\3
        \\0
        \\1
        \\-3
    ) == 5);
}

test "part2" {
    try std.testing.expect(try part2(std.testing.allocator,
        \\0
        \\3
        \\0
        \\1
        \\-3
    ) == 10);
}
