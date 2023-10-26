const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day04.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day04:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn part1(alloc: Allocator, input: []const u8) !usize {
    var sum: usize = 0;
    var lines = tokenizeAny(u8, input, "\r\n");

    blk: while (lines.next()) |line| {
        var words = tokenizeAny(u8, line, " ");
        var passphrase = std.StringHashMap(void).init(alloc);
        defer passphrase.deinit();
        while (words.next()) |word| {
            if (passphrase.contains(word)) {
                continue :blk;
            } else {
                try passphrase.put(word, {});
            }
        }
        sum += 1;
    }
    return sum;
}

fn part2(alloc: Allocator, input: []const u8) !usize {
    var sum: usize = 0;
    var lines = tokenizeAny(u8, input, "\r\n");

    blk: while (lines.next()) |line| {
        var words = tokenizeAny(u8, line, " ");
        var passphrase = std.StringHashMap(void).init(alloc);
        defer {
            var iter = passphrase.keyIterator();
            while (iter.next()) |item| alloc.free(item.*[0..]);
            passphrase.deinit();
        }
        while (words.next()) |word| {
            var sorted: []u8 = try alloc.dupe(u8, word);
            std.mem.sortUnstable(u8, sorted, {}, std.sort.asc(u8));
            if (passphrase.contains(sorted)) {
                alloc.free(sorted);
                continue :blk;
            } else {
                try passphrase.put(sorted, {});
            }
        }
        sum += 1;
    }
    return sum;
}

test "part1" {
    try std.testing.expect(try part1(std.testing.allocator,
        \\aa bb cc dd ee
        \\aa bb cc dd aa
        \\aa bb cc dd aaa
    ) == 2);
}

test "part2" {
    try std.testing.expect(try part2(std.testing.allocator,
        \\abcde fghij
        \\abcde xyz ecdab
        \\a ab abc abd abf abj
        \\iiii oiii ooii oooi oooo
        \\oiii ioii iioi iiio
    ) == 3);
}
