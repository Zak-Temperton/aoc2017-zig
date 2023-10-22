const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day12.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day12:\npart1: {d} {d}ns\npart2: {d} {d}ns", .{ p1, p1_time, p2, p2_time });
}

fn dfs(key: u16, pipes: [][]u16, seen: *std.AutoHashMap(u16, void)) !void {
    try seen.put(key, {});
    for (pipes[key]) |pipe| {
        if (!seen.contains(pipe)) {
            try dfs(pipe, pipes, seen);
        }
    }
}

fn part1(alloc: Allocator, input: []const u8) !usize {
    var lines = tokenizeAny(u8, input, "\r\n");
    var pipes = std.ArrayList([]u16).init(alloc);
    defer {
        for (pipes.items) |item| alloc.free(item);
        pipes.deinit();
    }
    var seen = std.AutoHashMap(u16, void).init(alloc);
    defer seen.deinit();
    while (lines.next()) |line| {
        var words = tokenizeAny(u8, line, " <->,");
        var connections = std.ArrayList(u16).init(alloc);
        defer connections.deinit();
        _ = words.next();
        while (words.next()) |pipe| {
            try connections.append(try std.fmt.parseInt(u16, pipe, 10));
        }
        try pipes.append(try connections.toOwnedSlice());
    }
    try dfs(0, pipes.items, &seen);
    return seen.count();
}

fn part2(alloc: Allocator, input: []const u8) !usize {
    var lines = tokenizeAny(u8, input, "\r\n");
    var pipes = std.ArrayList([]u16).init(alloc);
    defer {
        for (pipes.items) |item| alloc.free(item);
        pipes.deinit();
    }
    var seen = std.AutoHashMap(u16, void).init(alloc);
    defer seen.deinit();
    while (lines.next()) |line| {
        var words = tokenizeAny(u8, line, " <->,");
        var connections = std.ArrayList(u16).init(alloc);
        defer connections.deinit();
        _ = words.next();
        while (words.next()) |pipe| {
            try connections.append(try std.fmt.parseInt(u16, pipe, 10));
        }
        try pipes.append(try connections.toOwnedSlice());
    }
    var count: usize = 0;
    for (0..pipes.items.len) |i| {
        if (!seen.contains(@truncate(i))) {
            count += 1;
            try dfs(@truncate(i), pipes.items, &seen);
        }
    }
    return count;
}

test "part1" {
    try std.testing.expect(try part1(std.testing.allocator,
        \\0 <-> 2
        \\1 <-> 1
        \\2 <-> 0, 3, 4
        \\3 <-> 2, 4
        \\4 <-> 2, 3, 6
        \\5 <-> 6
        \\6 <-> 4, 5
    ) == 6);
}

test "part2" {
    try std.testing.expect(try part2(std.testing.allocator,
        \\0 <-> 2
        \\1 <-> 1
        \\2 <-> 0, 3, 4
        \\3 <-> 2, 4
        \\4 <-> 2, 3, 6
        \\5 <-> 6
        \\6 <-> 4, 5
    ) == 2);
}
