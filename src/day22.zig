const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day22.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer, 25);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer, 25);
    const p2_time = timer.read();
    try stdout.print("Day22:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn BitMap(comptime size: usize) type {
    return struct {
        map: [][size / 64]u64,

        const Self = @This();

        fn init(alloc: Allocator) !Self {
            var map = try alloc.alloc([size / 64]u64, size);
            for (map) |*row| @memset(row, 0);
            return .{
                .map = map,
            };
        }

        fn deinit(self: *Self, alloc: Allocator) void {
            alloc.free(self.map);
        }

        fn getBit(self: Self, x: usize, y: usize) bool {
            const xx = x / 64;
            const mx: u6 = @truncate(x % 64);
            return (self.map[y][xx] << mx) & @as(usize, 1 << 63) != 0;
        }

        fn toggleBit(self: *Self, x: usize, y: usize) void {
            const xx = x / 64;
            const mx: u6 = @truncate(x % 64);
            self.map[y][xx] ^= @as(usize, 1 << 63) >> mx;
        }
    };
}

fn part1(alloc: Allocator, input: []const u8, width: usize) !usize {
    var map = try BitMap(1_000).init(alloc);
    defer map.deinit(alloc);
    {
        const offset: usize = (1_000 / 2) - (width / 2);
        var lines = tokenizeAny(u8, input, "\r\n");
        var y: usize = offset;
        while (lines.next()) |line| : (y += 1) {
            for (line, offset..) |c, x| {
                if (c == '#') {
                    map.toggleBit(x, y);
                }
            }
        }
    }
    var x: usize = 1_000 / 2;
    var y = x;
    var dir: u2 = 3;
    var count: usize = 0;

    for (0..10_000) |_| {
        if (map.getBit(x, y)) {
            dir +%= 1;
        } else {
            count += 1;
            dir -%= 1;
        }
        map.toggleBit(x, y);
        switch (dir) {
            0 => x += 1,
            1 => y += 1,
            2 => x -= 1,
            3 => y -= 1,
        }
    }
    return count;
}

fn part2(alloc: Allocator, input: []const u8, width: usize) !usize {
    var map = try alloc.alloc([10_000]u2, 10_000);
    defer alloc.free(map);
    for (map) |*row| @memset(row, 0);

    {
        const offset: usize = (10_000 / 2) - (width / 2);
        var lines = tokenizeAny(u8, input, "\r\n");
        var y: usize = offset;
        while (lines.next()) |line| : (y += 1) {
            for (line, offset..) |c, x| {
                if (c == '#') {
                    map[y][x] = 2;
                }
            }
        }
    }
    var x: usize = 10_000 / 2;
    var y = x;
    var dir: u2 = 3;
    var count: usize = 0;

    for (0..10_000_000) |_| {
        switch (map[y][x]) {
            0 => dir -%= 1,
            1 => count += 1,
            2 => dir +%= 1,
            3 => dir +%= 2,
        }
        map[y][x] +%= 1;
        switch (dir) {
            0 => x += 1,
            1 => y += 1,
            2 => x -= 1,
            3 => y -= 1,
        }
    }
    return count;
}

test "part1" {
    try std.testing.expect(try part1(std.testing.allocator,
        \\..#
        \\#..
        \\...
    , 3) == 5587);
}

test "part2" {
    try std.testing.expect(try part2(std.testing.allocator,
        \\..#
        \\#..
        \\...
    , 3) == 2511944);
}
