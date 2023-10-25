const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day21.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day21:\npart1: {d} {d}ns\npart2: {d} {d}ns", .{ p1, p1_time, p2, p2_time });
}

fn flipHorizontal9(bits: u9) u9 {
    var res: u9 = bits & 0b010_010_010;
    res |= (bits & 0b100_100_100) >> 2;
    res |= (bits & 0b001_001_001) << 2;
    return res;
}
fn flipVertical9(bits: u9) u9 {
    var res: u9 = bits & 0b000_111_000;
    res |= (bits & 0b000_000_111) << 6;
    res |= (bits & 0b111_000_000) >> 6;
    return res;
}
fn flipDiagnal9(bits: u9) u9 {
    var res: u9 = bits & 0b001_010_100;
    res |= (bits & 0b100_000_000) >> 8;
    res |= (bits & 0b000_000_001) << 8;
    res |= (bits & 0b010_000_000) >> 4;
    res |= (bits & 0b000_001_000) << 4;
    res |= (bits & 0b000_100_000) >> 4;
    res |= (bits & 0b000_000_010) << 4;
    return res;
}

fn flipHorizontal4(bits: u4) u4 {
    var res: u4 = 0;
    res |= (bits & 0b1010) >> 1;
    res |= (bits & 0b0101) << 1;
    return res;
}
fn flipVertical4(bits: u4) u4 {
    return (bits << 2) | (bits >> 2);
}
fn flipDiagnal4(bits: u4) u4 {
    var res: u4 = bits & 0b1001;
    res |= (bits & 0b0010) << 1;
    res |= (bits & 0b0100) >> 1;
    return res;
}
fn solve(comptime loops: u16, alloc: Allocator, input: []const u8) !usize {
    var lines = tokenizeAny(u8, input, "\n\r");
    var map2 = std.AutoHashMap(u4, [3]u3).init(alloc);
    defer map2.deinit();
    var map3 = std.AutoHashMap(u9, [4]u4).init(alloc);
    defer map3.deinit();

    for (0..6) |_| {
        if (lines.next()) |line| {
            var left = line[0..5];
            var right = line[9..];
            var key: u4 = 0;
            for (left) |c| {
                if (c == '/') continue;
                key <<= 1;
                if (c == '#') key |= 1;
            }
            var value: [3]u3 = undefined;
            var row: u3 = 0;
            var i: u2 = 0;
            for (right) |c| {
                if (c == '/') {
                    value[i] = row;
                    row = 0;
                    i += 1;
                }
                row <<= 1;
                if (c == '#') row |= 1;
            }
            value[2] = row;
            try map2.put(key, value);
            key = flipHorizontal4(key);
            try map2.put(key, value);
            key = flipVertical4(key);
            try map2.put(key, value);
            key = flipHorizontal4(key);
            try map2.put(key, value);
            key = flipDiagnal4(key);
            try map2.put(key, value);
            key = flipHorizontal4(key);
            try map2.put(key, value);
            key = flipVertical4(key);
            try map2.put(key, value);
            key = flipHorizontal4(key);
            try map2.put(key, value);
        } else {
            unreachable;
        }
    }
    while (lines.next()) |line| {
        var left = line[0..11];
        var right = line[15..];

        var key: u9 = 0;
        for (left) |c| {
            if (c == '/') continue;
            key <<= 1;
            if (c == '#') key |= 1;
        }
        var value: [4]u4 = undefined;
        var row: u4 = 0;
        var i: u3 = 0;
        for (right) |c| {
            if (c == '/') {
                value[i] = row;
                row = 0;
                i += 1;
            }
            row <<= 1;
            if (c == '#') row |= 1;
        }
        value[3] = row;
        try map3.put(key, value);
        key = flipHorizontal9(key);
        try map3.put(key, value);
        key = flipVertical9(key);
        try map3.put(key, value);
        key = flipHorizontal9(key);
        try map3.put(key, value);
        key = flipDiagnal9(key);
        try map3.put(key, value);
        key = flipHorizontal9(key);
        try map3.put(key, value);
        key = flipVertical9(key);
        try map3.put(key, value);
        key = flipHorizontal9(key);
        try map3.put(key, value);
    }

    const Int = @Type(std.builtin.Type{ .Int = .{
        .bits = comptime blk: {
            var x: u15 = 3;
            for (0..loops) |_| x += x / (2 + (x & 1));
            break :blk x;
        },
        .signedness = .unsigned,
    } });

    var pattern = std.ArrayList(Int).init(alloc);
    defer pattern.deinit();
    try pattern.append(0b010);
    try pattern.append(0b001);
    try pattern.append(0b111);

    for (0..loops) |_| {
        var new_pattern = std.ArrayList(Int).init(alloc);
        errdefer new_pattern.deinit();
        const len = pattern.items.len;
        if (len & 1 == 0) {
            for (0..len + len / 2) |_| {
                try new_pattern.append(0);
            }
            for (0..len / 2) |i| {
                for (0..len / 2) |j| {
                    var key: u4 = 0;
                    key |= @as(u4, @truncate(pattern.items[i * 2] >> @truncate(j * 2))) << 2;
                    key |= @as(u4, @truncate(pattern.items[i * 2 + 1] >> @truncate(j * 2))) & 0b11;
                    for (map2.get(key).?, 0..) |val, k| {
                        new_pattern.items[i * 3 + k] |= @as(Int, val) << @truncate(3 * j);
                    }
                }
            }
        } else {
            for (0..len + len / 3) |_| {
                try new_pattern.append(0);
            }
            for (0..len / 3) |i| {
                for (0..len / 3) |j| {
                    var key: u9 = 0;
                    if (loops > 2) {
                        key |= @as(u9, @truncate(pattern.items[i * 3] >> @truncate(j * 3))) << 6;
                        key |= (@as(u9, @truncate(pattern.items[i * 3 + 1] >> @truncate(j * 3))) & 0b111) << 3;
                        key |= @as(u9, @truncate(pattern.items[i * 3 + 2] >> @truncate(j * 3))) & 0b111;
                    } else {
                        key |= @as(u9, (pattern.items[i * 3] >> @truncate(j * 3))) << 6;
                        key |= (@as(u9, (pattern.items[i * 3 + 1] >> @truncate(j * 3))) & 0b111) << 3;
                        key |= @as(u9, (pattern.items[i * 3 + 2] >> @truncate(j * 3))) & 0b111;
                    }
                    for (map3.get(key).?, 0..) |val, k| {
                        new_pattern.items[i * 4 + k] |= @as(Int, val) << @truncate(4 * j);
                    }
                }
            }
        }
        pattern.deinit();
        pattern = new_pattern;
    }
    var count: usize = 0;
    for (pattern.items) |item| count += @popCount(item);
    return count;
}

fn part1(alloc: Allocator, input: []const u8) !usize {
    return try solve(5, alloc, input);
}

fn part2(alloc: Allocator, input: []const u8) !usize {
    return try solve(18, alloc, input);
}

test "solve" {
    try std.testing.expect(12 == try solve(2, std.testing.allocator,
        \\../.# => ##./#../...
        \\../.# => ##./#../...
        \\../.# => ##./#../...
        \\../.# => ##./#../...
        \\../.# => ##./#../...
        \\../.# => ##./#../...
        \\.#./..#/### => #..#/..../..../#..#
    ));
}
