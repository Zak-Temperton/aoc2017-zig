const std = @import("std");
const Allocator = std.mem.Allocator;
const HashMap = std.AutoHashMap;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const input = 277678;
    var timer = try std.time.Timer.start();
    const p1 = part1(input);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, input);
    const p2_time = timer.read();
    try stdout.print("Day01:\npart1: {d} {d}ns\npart2: {d} {d}ns", .{ p1, p1_time, p2, p2_time });
}

fn part1(input: usize) usize {
    var square_side: usize = 1;
    var i: usize = 0;
    while (square_side * square_side < input) : (square_side += 2) {
        i += 1;
    }
    const square = (square_side - 2) * (square_side - 2);
    const half = square_side / 2;
    var loop = input - square;

    var pos = half;
    while (true) : (pos += square_side - 1) {
        if (loop <= pos) return pos - loop + i;
        if (loop <= pos + half) return loop - pos + i;
    }
}

fn getSum(map: HashMap([2]i8, usize), x: i8, y: i8) usize {
    var sum: usize = 0;
    for (0..3) |i| {
        for (0..3) |j| {
            if (map.get(.{ x + @as(i8, @intCast(i)) - 1, y + @as(i8, @intCast(j)) - 1 })) |n| {
                sum += n;
            }
        }
    }
    return sum;
}

fn part2(alloc: Allocator, input: usize) !usize {
    var map = HashMap([2]i8, usize).init(alloc);
    defer map.deinit();
    try map.put(.{ 0, 0 }, 1);
    var x: i8 = 0;
    var y: i8 = 0;
    var side: usize = 2;
    while (true) : (side += 2) {
        x += 1;
        {
            const sum = getSum(map, x, y);
            if (sum > input) return sum;
            try map.put(.{ x, y }, sum);
        }
        for (0..side - 1) |_| {
            y += 1;
            const sum = getSum(map, x, y);
            if (sum > input) return sum;
            try map.put(.{ x, y }, sum);
        }
        for (0..side) |_| {
            x -= 1;
            const sum = getSum(map, x, y);
            if (sum > input) return sum;
            try map.put(.{ x, y }, sum);
        }
        for (0..side) |_| {
            y -= 1;
            const sum = getSum(map, x, y);
            if (sum > input) return sum;
            try map.put(.{ x, y }, sum);
        }
        for (0..side) |_| {
            x += 1;
            const sum = getSum(map, x, y);
            if (sum > input) return sum;
            try map.put(.{ x, y }, sum);
        }
    }
}

test "part1" {
    try std.testing.expect(part1(12) == 3);
    try std.testing.expect(part1(23) == 2);
    try std.testing.expect(part1(1024) == 31);
}

test "part2" {
    try std.testing.expect(try part2(std.testing.allocator, 1) == 2);
    try std.testing.expect(try part2(std.testing.allocator, 2) == 4);
    try std.testing.expect(try part2(std.testing.allocator, 748) == 806);
}
