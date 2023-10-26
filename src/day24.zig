const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day24.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day24:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

const Bridge = struct {
    id: usize,
    head: usize,
    tail: usize,
};

fn part1(alloc: Allocator, input: []const u8) !usize {
    var bridge_map = std.AutoHashMap(usize, std.ArrayList(Bridge)).init(alloc);
    defer {
        var iter = bridge_map.valueIterator();
        while (iter.next()) |val| val.deinit();
        bridge_map.deinit();
    }
    {
        var lines = tokenizeAny(u8, input, "\r\n");
        var i: usize = 0;
        while (lines.next()) |line| : (i += 1) {
            var words = tokenizeAny(u8, line, "/");
            var v1 = try std.fmt.parseInt(usize, words.next().?, 10);
            var v2 = try std.fmt.parseInt(usize, words.next().?, 10);
            {
                const bridge: Bridge = .{
                    .id = i,
                    .head = v1,
                    .tail = v2,
                };
                if (bridge_map.getPtr(v1)) |entry| {
                    try entry.append(bridge);
                } else {
                    var bridges = std.ArrayList(Bridge).init(alloc);
                    try bridges.append(bridge);
                    try bridge_map.put(v1, bridges);
                }
            }
            {
                const bridge: Bridge = .{
                    .id = i,
                    .head = v2,
                    .tail = v1,
                };
                if (bridge_map.getPtr(v2)) |entry| {
                    try entry.append(bridge);
                } else {
                    var bridges = std.ArrayList(Bridge).init(alloc);
                    try bridges.append(bridge);
                    try bridge_map.put(v2, bridges);
                }
            }
        }
    }

    var used = std.ArrayList(usize).init(alloc);
    defer used.deinit();
    return try strongestBridgePower(0, bridge_map, &used);
}

fn strongestBridgePower(start: usize, bridge_map: std.AutoHashMap(usize, std.ArrayList(Bridge)), used: *std.ArrayList(usize)) !usize {
    var max: usize = 0;
    if (bridge_map.get(start)) |bridges| {
        for (bridges.items) |bridge| {
            if (!std.mem.containsAtLeast(usize, used.items, 1, &.{bridge.id})) {
                try used.append(bridge.id);
                var power = bridge.head + bridge.tail +
                    try strongestBridgePower(bridge.tail, bridge_map, used);
                if (power > max) max = power;
                _ = used.pop();
            }
        }
    }

    return max;
}
fn strongestLongestBridgePower(start: usize, bridge_map: std.AutoHashMap(usize, std.ArrayList(Bridge)), used: *std.ArrayList(usize)) ![2]usize {
    var max: usize = 0;
    var max_len: usize = 0;
    if (bridge_map.get(start)) |bridges| {
        for (bridges.items) |bridge| {
            if (!std.mem.containsAtLeast(usize, used.items, 1, &.{bridge.id})) {
                try used.append(bridge.id);
                const sl = try strongestLongestBridgePower(bridge.tail, bridge_map, used);
                var power = bridge.head + bridge.tail + sl[0];
                if (sl[1] > max_len) {
                    max = power;
                    max_len = sl[1];
                } else if (power > max and sl[1] == max_len) {
                    max = power;
                }
                _ = used.pop();
            }
        }
    }

    return .{ max, max_len + 1 };
}
fn part2(alloc: Allocator, input: []const u8) !usize {
    var bridge_map = std.AutoHashMap(usize, std.ArrayList(Bridge)).init(alloc);
    defer {
        var iter = bridge_map.valueIterator();
        while (iter.next()) |val| val.deinit();
        bridge_map.deinit();
    }
    {
        var lines = tokenizeAny(u8, input, "\r\n");
        var i: usize = 0;
        while (lines.next()) |line| : (i += 1) {
            var words = tokenizeAny(u8, line, "/");
            var v1 = try std.fmt.parseInt(usize, words.next().?, 10);
            var v2 = try std.fmt.parseInt(usize, words.next().?, 10);
            {
                const bridge: Bridge = .{
                    .id = i,
                    .head = v1,
                    .tail = v2,
                };
                if (bridge_map.getPtr(v1)) |entry| {
                    try entry.append(bridge);
                } else {
                    var bridges = std.ArrayList(Bridge).init(alloc);
                    try bridges.append(bridge);
                    try bridge_map.put(v1, bridges);
                }
            }
            {
                const bridge: Bridge = .{
                    .id = i,
                    .head = v2,
                    .tail = v1,
                };
                if (bridge_map.getPtr(v2)) |entry| {
                    try entry.append(bridge);
                } else {
                    var bridges = std.ArrayList(Bridge).init(alloc);
                    try bridges.append(bridge);
                    try bridge_map.put(v2, bridges);
                }
            }
        }
    }

    var used = std.ArrayList(usize).init(alloc);
    defer used.deinit();
    return (try strongestLongestBridgePower(0, bridge_map, &used))[0];
}

test "part1" {
    try std.testing.expect(try part1(std.testing.allocator,
        \\0/2
        \\2/2
        \\2/3
        \\3/4
        \\3/5
        \\0/1
        \\10/1
        \\9/10
    ) == 31);
}

test "part2" {
    try std.testing.expect(try part2(std.testing.allocator,
        \\0/2
        \\2/2
        \\2/3
        \\3/4
        \\3/5
        \\0/1
        \\10/1
        \\9/10
    ) == 19);
}
