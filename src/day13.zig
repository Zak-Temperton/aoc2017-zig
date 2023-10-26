const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day13.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day13:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn part1(alloc: Allocator, input: []const u8) !usize {
    var caught = std.ArrayList([2]usize).init(alloc);
    defer caught.deinit();

    var lines = tokenizeAny(u8, input, "\r\n");
    while (lines.next()) |line| {
        var words = tokenizeAny(u8, line, ": ");
        var layer = try std.fmt.parseInt(usize, words.next().?, 10);
        var depth = try std.fmt.parseInt(usize, words.next().?, 10);
        if (layer % (depth + depth - 2) == 0) try caught.append(.{ layer, depth });
    }

    var result: usize = 0;
    for (caught.items) |layer| {
        var steps = layer[0] % (layer[1] * 2 - 2);
        if (steps < layer[1]) {
            result += layer[0] * layer[1];
        } else {
            result += layer[0] * (layer[1] - (layer[1] - layer[0]));
        }
    }
    return result;
}

fn part2(alloc: Allocator, input: []const u8) !usize {
    var packets = std.ArrayList([2]usize).init(alloc);
    defer packets.deinit();

    var lines = tokenizeAny(u8, input, "\r\n");
    while (lines.next()) |line| {
        var words = tokenizeAny(u8, line, ": ");
        var layer = try std.fmt.parseInt(usize, words.next().?, 10);
        var depth = try std.fmt.parseInt(usize, words.next().?, 10);
        try packets.append(.{ layer, depth });
    }

    var delay: usize = 0;
    blk: while (true) : (delay += 1) {
        for (packets.items) |layer| {
            if ((layer[0] + delay) % (layer[1] + layer[1] - 2) == 0) continue :blk;
        }
        return delay;
    }
}

test "part1" {
    try std.testing.expect(try part1(std.testing.allocator,
        \\0: 3
        \\1: 2
        \\4: 4
        \\6: 4
    ) == 24);
}

test "part2" {
    try std.testing.expect(try part2(std.testing.allocator,
        \\0: 3
        \\1: 2
        \\4: 4
        \\6: 4
    ) == 10);
}
