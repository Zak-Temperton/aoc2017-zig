const std = @import("std");
const Allocator = std.mem.Allocator;
pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day01.txt", .{ .mode = .read_only });
    const buffer = try file.reader().readUntilDelimiterAlloc(alloc, '\r', std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = part1(buffer);
    const p1_time = timer.lap();
    const p2 = part2(buffer);
    const p2_time = timer.read();
    try stdout.print("Day01:\npart1: {d} {d}ns\npart2: {d} {d}ns", .{ p1, p1_time, p2, p2_time });
}

fn part1(input: []const u8) usize {
    var sum: usize = 0;

    for (0..input.len - 1) |i| {
        if (input[i] == input[i + 1]) sum += input[i] - '0';
    }
    if (input[input.len - 1] == input[0]) {
        sum += input[0] - '0';
    }

    return sum;
}

fn part2(input: []const u8) usize {
    var sum: usize = 0;
    const skip = input.len / 2;

    for (input, 0..) |c, i| {
        if (c == input[(i + skip) % input.len]) sum += c - '0';
    }

    return sum;
}

test "part1" {
    try std.testing.expect(3 == part1("1122"));
    try std.testing.expect(4 == part1("1111"));
    try std.testing.expect(0 == part1("1234"));
    try std.testing.expect(9 == part1("91212129"));
    try std.testing.expect(10 == part1("911212129"));
}

test "part2" {
    try std.testing.expect(6 == part2("1212"));
    try std.testing.expect(0 == part2("1221"));
    try std.testing.expect(4 == part2("123425"));
    try std.testing.expect(12 == part2("123123"));
    try std.testing.expect(4 == part2("12131415"));
}
