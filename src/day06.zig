const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day06.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day06:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn hash(state: []u8) u128 {
    var result: u128 = 0;
    for (state) |val| {
        result <<= 4;
        result |= val;
    }
    return result;
}

fn part1(alloc: Allocator, input: []const u8) !usize {
    var count: usize = 0;
    var list = std.ArrayList(u8).init(alloc);
    defer list.deinit();
    var seen = std.ArrayList(u128).init(alloc);
    defer seen.deinit();
    var words = tokenizeAny(u8, input, " \t\r\n");
    while (words.next()) |word| {
        try list.append(try std.fmt.parseInt(u4, word, 10));
    }
    var val = hash(list.items);
    while (!std.mem.containsAtLeast(u128, seen.items, 1, &.{val})) : (count += 1) {
        try seen.append(hash(list.items));
        const i = std.mem.indexOfMax(u8, list.items);
        var num = list.items[i];
        list.items[i] = 0;
        for (1..num + 1) |j| {
            list.items[(i + j) % list.items.len] += 1;
        }

        val = hash(list.items);
    }

    return count;
}

fn part2(alloc: Allocator, input: []const u8) !usize {
    var list = std.ArrayList(u8).init(alloc);
    defer list.deinit();
    var seen = std.ArrayList(u128).init(alloc);
    defer seen.deinit();
    var words = tokenizeAny(u8, input, " \t\r\n");
    while (words.next()) |word| {
        try list.append(try std.fmt.parseInt(u4, word, 10));
    }
    var val = hash(list.items);
    while (!std.mem.containsAtLeast(u128, seen.items, 1, &.{val})) {
        try seen.append(hash(list.items));
        const i = std.mem.indexOfMax(u8, list.items);
        var num = list.items[i];
        list.items[i] = 0;
        for (1..num + 1) |j| {
            list.items[(i + j) % list.items.len] += 1;
        }

        val = hash(list.items);
    }
    seen.clearAndFree();
    try seen.append(val);
    var count: usize = 1;
    {
        const i = std.mem.indexOfMax(u8, list.items);
        var num = list.items[i];
        list.items[i] = 0;
        for (1..num + 1) |j| {
            list.items[(i + j) % list.items.len] += 1;
        }
        val = hash(list.items);
    }
    while (!std.mem.containsAtLeast(u128, seen.items, 1, &.{val})) : (count += 1) {
        try seen.append(hash(list.items));
        const i = std.mem.indexOfMax(u8, list.items);
        var num = list.items[i];
        list.items[i] = 0;
        for (1..num + 1) |j| {
            list.items[(i + j) % list.items.len] += 1;
        }

        val = hash(list.items);
    }
    return count;
}

test "part1" {
    try std.testing.expect(try part1(std.testing.allocator, "0   2   7   0") == 5);
}

test "part2" {
    try std.testing.expect(try part2(std.testing.allocator, "0   2   7   0") == 4);
}
