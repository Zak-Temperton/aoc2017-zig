const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day15.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    const input = std.mem.trimRight(u8, buffer, "\r\n");
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, input);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, input);
    const p2_time = timer.read();
    try stdout.print("Day15:\npart1: {d} {d}ns\npart2: {d} {d}ns", .{ p1, p1_time, p2, p2_time });
}

fn part1(alloc: Allocator, input: []const u8) !usize {
    _ = alloc;
    var count: usize = 0;
    var words = tokenizeAny(u8, input, "\r\n");
    var gen_a = try std.fmt.parseInt(u64, words.next().?[24..], 10);
    var gen_b = try std.fmt.parseInt(u64, words.next().?[24..], 10);

    for (0..40_000_000) |_| {
        gen_a *= 16807;
        gen_a %= 2147483647;
        gen_b *= 48271;
        gen_b %= 2147483647;
        if (0xFFFF & (gen_a ^ gen_b) == 0) count += 1;
    }

    return count;
}

fn part2(alloc: Allocator, input: []const u8) !usize {
    _ = alloc;
    var count: usize = 0;
    var words = tokenizeAny(u8, input, "\r\n");
    var gen_a = try std.fmt.parseInt(u64, words.next().?[24..], 10);
    var gen_b = try std.fmt.parseInt(u64, words.next().?[24..], 10);

    for (0..5_000_000) |_| {
        gen_a *= 16807;
        gen_a %= 2147483647;
        while (gen_a % 4 != 0) {
            gen_a *= 16807;
            gen_a %= 2147483647;
        }
        gen_b *= 48271;
        gen_b %= 2147483647;
        while (gen_b % 8 != 0) {
            gen_b *= 48271;
            gen_b %= 2147483647;
        }
        if (0xFFFF & (gen_a ^ gen_b) == 0) count += 1;
    }

    return count;
}

test "part1" {
    try std.testing.expect(try part1(std.testing.allocator,
        \\Generator A starts with 65
        \\Generator B starts with 8921
    ) == 588);
}

test "part2" {
    try std.testing.expect(try part2(std.testing.allocator,
        \\Generator A starts with 65
        \\Generator B starts with 8921
    ) == 309);
}
