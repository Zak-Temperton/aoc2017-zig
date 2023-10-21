const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day08.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day08:\npart1: {d} {d}ns\npart2: {d} {d}ns", .{ p1, p1_time, p2, p2_time });
}

fn hash(state: []u8) u128 {
    var result: u128 = 0;
    for (state) |val| {
        result <<= 4;
        result |= val;
    }
    return result;
}

fn part1(alloc: Allocator, input: []const u8) !i32 {
    var registers = std.StringHashMap(i32).init(alloc);
    defer registers.deinit();
    var lines = tokenizeAny(u8, input, "\r\n");
    while (lines.next()) |line| {
        var words = tokenizeAny(u8, line, " ");
        const r1 = words.next().?;
        const inc = words.next().?[0] == 'i';
        const num1 = try std.fmt.parseInt(i32, words.next().?, 10);
        _ = words.next();
        const r2 = words.next().?;
        const reg2 = (try registers.getOrPutValue(r2, 0)).value_ptr;
        const cmp = words.next().?;

        const num2 = try std.fmt.parseInt(i32, words.next().?, 10);
        if (cmp.len == 1) {
            if (switch (cmp[0]) {
                '>' => reg2.* > num2,
                '<' => reg2.* < num2,
                else => unreachable,
            }) {
                const reg1 = (try registers.getOrPutValue(r1, 0)).value_ptr;
                if (inc) {
                    reg1.* += num1;
                } else {
                    reg1.* -= num1;
                }
            }
        } else {
            if (switch (cmp[0]) {
                '>' => reg2.* >= num2,
                '<' => reg2.* <= num2,
                '=' => reg2.* == num2,
                '!' => reg2.* != num2,
                else => unreachable,
            }) {
                const reg1 = (try registers.getOrPutValue(r1, 0)).value_ptr;
                if (inc) {
                    reg1.* += num1;
                } else {
                    reg1.* -= num1;
                }
            }
        }
    }
    var max: i32 = 0;
    var iter = registers.valueIterator();
    while (iter.next()) |reg| {
        if (reg.* > max) max = reg.*;
    }
    return max;
}

fn part2(alloc: Allocator, input: []const u8) !i32 {
    var registers = std.StringHashMap(i32).init(alloc);
    defer registers.deinit();
    var lines = tokenizeAny(u8, input, "\r\n");
    var max: i32 = 0;
    while (lines.next()) |line| {
        var words = tokenizeAny(u8, line, " ");
        const r1 = words.next().?;
        const inc = words.next().?[0] == 'i';
        const num1 = try std.fmt.parseInt(i32, words.next().?, 10);
        _ = words.next();
        const r2 = words.next().?;
        const reg2 = (try registers.getOrPutValue(r2, 0)).value_ptr;
        const cmp = words.next().?;

        const num2 = try std.fmt.parseInt(i32, words.next().?, 10);
        if (cmp.len == 1) {
            if (switch (cmp[0]) {
                '>' => reg2.* > num2,
                '<' => reg2.* < num2,
                else => unreachable,
            }) {
                const reg1 = (try registers.getOrPutValue(r1, 0)).value_ptr;
                if (inc) {
                    reg1.* += num1;
                } else {
                    reg1.* -= num1;
                }
                if (reg1.* > max) max = reg1.*;
            }
        } else {
            if (switch (cmp[0]) {
                '>' => reg2.* >= num2,
                '<' => reg2.* <= num2,
                '=' => reg2.* == num2,
                '!' => reg2.* != num2,
                else => unreachable,
            }) {
                const reg1 = (try registers.getOrPutValue(r1, 0)).value_ptr;
                if (inc) {
                    reg1.* += num1;
                } else {
                    reg1.* -= num1;
                }
                if (reg1.* > max) max = reg1.*;
            }
        }
    }

    return max;
}

test "part1" {
    try std.testing.expect(try part1(std.testing.allocator,
        \\b inc 5 if a > 1
        \\a inc 1 if b < 5
        \\c dec -10 if a >= 1
        \\c inc -20 if c == 10
    ) == 1);
}

test "part2" {
    try std.testing.expect(try part2(std.testing.allocator,
        \\b inc 5 if a > 1
        \\a inc 1 if b < 5
        \\c dec -10 if a >= 1
        \\c inc -20 if c == 10
    ) == 10);
}
