const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day09.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(buffer);
    const p1_time = timer.lap();
    const p2 = try part2(buffer);
    const p2_time = timer.read();
    try stdout.print("Day09:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn garbage(input: []const u8, i: *usize) void {
    while (input[i.*] != '>') {
        if (input[i.*] == '!') {
            i.* += 2;
        } else {
            i.* += 1;
        }
    }
}

fn part1(input: []const u8) !usize {
    var score: usize = 0;
    var depth: usize = 0;
    var i: usize = 0;
    while (i < input.len) : (i += 1) {
        switch (input[i]) {
            '{' => {
                depth += 1;
                score += depth;
            },
            '}' => depth -= 1,
            '<' => garbage(input, &i),
            else => {},
        }
    }

    return score;
}

fn countGarbage(input: []const u8, i: *usize) usize {
    var count: usize = 0;
    while (input[i.*] != '>') {
        if (input[i.*] == '!') {
            i.* += 2;
        } else {
            i.* += 1;
            count += 1;
        }
    }
    return count;
}

fn part2(input: []const u8) !usize {
    var score: usize = 0;
    var i: usize = 0;
    while (i < input.len) : (i += 1) {
        switch (input[i]) {
            '<' => {
                i += 1;
                score += countGarbage(input, &i);
            },
            else => {},
        }
    }

    return score;
}

test "part1" {
    try std.testing.expect(try part1("{}") == 1);
    try std.testing.expect(try part1("{{{}}}") == 6);
    try std.testing.expect(try part1("{{}, {}}") == 5);
    try std.testing.expect(try part1("{{{}, {},{{}}}}") == 16);
    try std.testing.expect(try part1("{<a>,<a>,<a>,<a>}") == 1);
    try std.testing.expect(try part1("{{<ab>},{<ab>},{<ab>},{<ab>}}") == 9);
    try std.testing.expect(try part1("{{<!!>},{<!!>},{<!!>},{<!!>}}") == 9);
    try std.testing.expect(try part1("{{<a!>},{<a!>},{<a!>},{<ab>}}") == 3);
}

test "part2" {
    try std.testing.expect(try part2("<>") == 0);
    try std.testing.expect(try part2("<random characters>") == 17);
    try std.testing.expect(try part2("<<<<>") == 3);
    try std.testing.expect(try part2("<{!>}>") == 2);
    try std.testing.expect(try part2("<!!>") == 0);
    try std.testing.expect(try part2("<!!!>>") == 0);
    try std.testing.expect(try part2("<{o\"i!a,<{i<a>") == 10);
}
