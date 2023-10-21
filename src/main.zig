const std = @import("std");
const day01 = @import("day01.zig");
const day02 = @import("day02.zig");
const day03 = @import("day03.zig");
const day04 = @import("day04.zig");
const day05 = @import("day05.zig");
const day06 = @import("day06.zig");
const day07 = @import("day07.zig");
const day08 = @import("day08.zig");

const Day = enum {
    day01,
    day02,
    day03,
    day04,
    day05,
    day06,
    day07,
    day08,
    day09,
    day10,
    day11,
    day12,
    day13,
    day14,
    day15,
    day16,
    day17,
    day18,
    day19,
    day20,
    day21,
    day22,
    day23,
    day24,
    day25,
};

const days = std.ComptimeStringMap(Day, .{
    .{ "day01", .day01 },
    .{ "day02", .day02 },
    .{ "day03", .day03 },
    .{ "day04", .day04 },
    .{ "day05", .day05 },
    .{ "day06", .day06 },
    .{ "day07", .day07 },
    .{ "day08", .day08 },
    .{ "day09", .day09 },
    .{ "day10", .day10 },
    .{ "day11", .day11 },
    .{ "day12", .day12 },
    .{ "day13", .day13 },
    .{ "day14", .day14 },
    .{ "day15", .day15 },
    .{ "day16", .day16 },
    .{ "day17", .day17 },
    .{ "day18", .day18 },
    .{ "day19", .day19 },
    .{ "day20", .day20 },
    .{ "day21", .day21 },
    .{ "day22", .day22 },
    .{ "day23", .day23 },
    .{ "day24", .day24 },
    .{ "day25", .day25 },
});

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    // Create Allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();
    _ = args.next();
    if (args.next()) |day| {
        if (days.get(day)) |day_enum| {
            switch (day_enum) {
                .day01 => try day01.run(alloc, stdout),
                .day02 => try day02.run(alloc, stdout),
                .day03 => try day03.run(alloc, stdout),
                .day04 => try day04.run(alloc, stdout),
                .day05 => try day05.run(alloc, stdout),
                .day06 => try day06.run(alloc, stdout),
                .day07 => try day07.run(alloc, stdout),
                .day08 => try day08.run(alloc, stdout),
                .day09 => {},
                .day10 => {},
                .day11 => {},
                .day12 => {},
                .day13 => {},
                .day14 => {},
                .day15 => {},
                .day16 => {},
                .day17 => {},
                .day18 => {},
                .day19 => {},
                .day20 => {},
                .day21 => {},
                .day22 => {},
                .day23 => {},
                .day24 => {},
                .day25 => {},
            }
        } else {
            try stdout.print("invalid day", .{});
        }
    } else {
        try stdout.print("Give the day as an argument e.g. zig build run day01", .{});
    }

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
