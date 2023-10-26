const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day23.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = part2();
    const p2_time = timer.read();
    try stdout.print("Day23:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

const Register = union(enum) {
    reg: u8,
    val: i64,
};

const Token = enum {
    set,
    sub,
    mul,
    jnz,
};

const Instruction = union(Token) {
    const TwoRegisters = struct { a: Register, b: Register };
    set: TwoRegisters,
    sub: TwoRegisters,
    mul: TwoRegisters,
    jnz: TwoRegisters,
};

const strMap = std.ComptimeStringMap(Token, .{
    .{ "set", .set },
    .{ "sub", .sub },
    .{ "mul", .mul },
    .{ "jnz", .jnz },
});

fn parseInstructions(alloc: Allocator, input: []const u8) ![]Instruction {
    var instructions = std.ArrayList(Instruction).init(alloc);
    defer instructions.deinit();
    var words = tokenizeAny(u8, input, " \r\n");
    while (words.next()) |word| {
        switch (strMap.get(word).?) {
            .set => {
                if (words.next()) |r1| {
                    const a: Register = if (r1[0] >= 'a' and r1[0] <= 'z') .{ .reg = r1[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r1, 10) };
                    if (words.next()) |r2| {
                        const b: Register = if (r2[0] >= 'a' and r2[0] <= 'z') .{ .reg = r2[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r2, 10) };
                        try instructions.append(.{ .set = .{ .a = a, .b = b } });
                    }
                }
            },
            .sub => {
                if (words.next()) |r1| {
                    const a: Register = if (r1[0] >= 'a' and r1[0] <= 'z') .{ .reg = r1[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r1, 10) };
                    if (words.next()) |r2| {
                        const b: Register = if (r2[0] >= 'a' and r2[0] <= 'z') .{ .reg = r2[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r2, 10) };
                        try instructions.append(.{ .sub = .{ .a = a, .b = b } });
                    }
                }
            },
            .mul => {
                if (words.next()) |r1| {
                    const a: Register = if (r1[0] >= 'a' and r1[0] <= 'z') .{ .reg = r1[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r1, 10) };
                    if (words.next()) |r2| {
                        const b: Register = if (r2[0] >= 'a' and r2[0] <= 'z') .{ .reg = r2[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r2, 10) };
                        try instructions.append(.{ .mul = .{ .a = a, .b = b } });
                    }
                }
            },
            .jnz => {
                if (words.next()) |r1| {
                    const a: Register = if (r1[0] >= 'a' and r1[0] <= 'z') .{ .reg = r1[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r1, 10) };
                    if (words.next()) |r2| {
                        const b: Register = if (r2[0] >= 'a' and r2[0] <= 'z') .{ .reg = r2[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r2, 10) };
                        try instructions.append(.{ .jnz = .{ .a = a, .b = b } });
                    }
                }
            },
        }
    }
    return instructions.toOwnedSlice();
}

fn part1(alloc: Allocator, input: []const u8) !usize {
    const instructions = try parseInstructions(alloc, input);
    defer alloc.free(instructions);
    var registers: [8]i64 = [1]i64{0} ** 8;
    var i: usize = 0;
    var count: usize = 0;
    while (i < instructions.len) {
        switch (instructions[i]) {
            .set => |r| {
                switch (r.a) {
                    .reg => |a| switch (r.b) {
                        .reg => |b| registers[a] = registers[b],
                        .val => |b| registers[a] = b,
                    },
                    .val => unreachable,
                }
            },
            .sub => |r| {
                switch (r.a) {
                    .reg => |a| switch (r.b) {
                        .reg => |b| registers[a] -= registers[b],
                        .val => |b| registers[a] -= b,
                    },
                    .val => unreachable,
                }
            },
            .mul => |r| {
                count += 1;
                switch (r.a) {
                    .reg => |a| switch (r.b) {
                        .reg => |b| registers[a] *= registers[b],
                        .val => |b| registers[a] *= b,
                    },
                    .val => unreachable,
                }
            },
            .jnz => |r| {
                const a = switch (r.a) {
                    .reg => |v| registers[v],
                    .val => |v| v,
                };
                if (a != 0) {
                    switch (r.b) {
                        .reg => |b| i = @intCast(@as(i64, @intCast(i)) + registers[b]),
                        .val => |b| i = @intCast(@as(i64, @intCast(i)) + b),
                    }
                    continue;
                }
            },
        }
        i += 1;
    }
    return count;
}

fn part2() i64 {
    var b: i64 = 0;
    var d: i64 = 0;
    var h: i64 = 0;

    b = 93 * 100 + 100_000;

    for (0..1_001) |_| {
        d = 2;
        while (d * d <= b) : (d += 1) {
            if (@mod(b, d) == 0) {
                h += 1;
                break;
            }
        }
        b += 17;
    }
    return h;
}
