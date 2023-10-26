const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day18.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day18:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

const Register = union(enum) {
    reg: u8,
    val: i64,
};

const Token = enum {
    snd,
    set,
    add,
    mul,
    mod,
    rcv,
    jgz,
};

const Instruction = union(Token) {
    const OneRegister = Register;
    const TwoRegisters = struct { a: Register, b: Register };
    snd: OneRegister,
    set: TwoRegisters,
    add: TwoRegisters,
    mul: TwoRegisters,
    mod: TwoRegisters,
    rcv: OneRegister,
    jgz: TwoRegisters,
};

const strMap = std.ComptimeStringMap(Token, .{
    .{ "snd", .snd },
    .{ "set", .set },
    .{ "add", .add },
    .{ "mul", .mul },
    .{ "mod", .mod },
    .{ "rcv", .rcv },
    .{ "jgz", .jgz },
});

fn parseInstructions(alloc: Allocator, input: []const u8) ![]Instruction {
    var instructions = std.ArrayList(Instruction).init(alloc);
    defer instructions.deinit();
    var words = tokenizeAny(u8, input, " \r\n");
    while (words.next()) |word| {
        switch (strMap.get(word).?) {
            .snd => {
                if (words.next()) |r1| {
                    const a: Register = if (r1[0] >= 'a' and r1[0] <= 'z') .{ .reg = r1[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r1, 10) };
                    try instructions.append(.{ .snd = a });
                }
            },
            .set => {
                if (words.next()) |r1| {
                    const a: Register = if (r1[0] >= 'a' and r1[0] <= 'z') .{ .reg = r1[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r1, 10) };
                    if (words.next()) |r2| {
                        const b: Register = if (r2[0] >= 'a' and r2[0] <= 'z') .{ .reg = r2[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r2, 10) };
                        try instructions.append(.{ .set = .{ .a = a, .b = b } });
                    }
                }
            },
            .add => {
                if (words.next()) |r1| {
                    const a: Register = if (r1[0] >= 'a' and r1[0] <= 'z') .{ .reg = r1[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r1, 10) };
                    if (words.next()) |r2| {
                        const b: Register = if (r2[0] >= 'a' and r2[0] <= 'z') .{ .reg = r2[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r2, 10) };
                        try instructions.append(.{ .add = .{ .a = a, .b = b } });
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
            .mod => {
                if (words.next()) |r1| {
                    const a: Register = if (r1[0] >= 'a' and r1[0] <= 'z') .{ .reg = r1[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r1, 10) };
                    if (words.next()) |r2| {
                        const b: Register = if (r2[0] >= 'a' and r2[0] <= 'z') .{ .reg = r2[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r2, 10) };
                        try instructions.append(.{ .mod = .{ .a = a, .b = b } });
                    }
                }
            },
            .rcv => {
                if (words.next()) |r1| {
                    const a: Register = if (r1[0] >= 'a' and r1[0] <= 'z') .{ .reg = r1[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r1, 10) };
                    try instructions.append(.{ .rcv = a });
                }
            },
            .jgz => {
                if (words.next()) |r1| {
                    const a: Register = if (r1[0] >= 'a' and r1[0] <= 'z') .{ .reg = r1[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r1, 10) };
                    if (words.next()) |r2| {
                        const b: Register = if (r2[0] >= 'a' and r2[0] <= 'z') .{ .reg = r2[0] - 'a' } else .{ .val = try std.fmt.parseInt(i64, r2, 10) };
                        try instructions.append(.{ .jgz = .{ .a = a, .b = b } });
                    }
                }
            },
        }
    }
    return instructions.toOwnedSlice();
}

fn part1(alloc: Allocator, input: []const u8) !i64 {
    const instructions = try parseInstructions(alloc, input);
    defer alloc.free(instructions);
    var registers: [26]i64 = [1]i64{0} ** 26;
    var sound: i64 = 0;
    var i: usize = 0;
    while (i < instructions.len) {
        switch (instructions[i]) {
            .snd => |r| {
                const a = switch (r) {
                    .reg => |v| registers[v],
                    .val => |v| v,
                };
                sound = a;
            },
            .rcv => |r| {
                const a = switch (r) {
                    .reg => |v| registers[v],
                    .val => |v| v,
                };
                if (a != 0) return sound;
            },
            .set => |r| {
                switch (r.a) {
                    .reg => |a| switch (r.b) {
                        .reg => |b| registers[a] = registers[b],
                        .val => |b| registers[a] = b,
                    },
                    .val => unreachable,
                }
            },
            .add => |r| {
                switch (r.a) {
                    .reg => |a| switch (r.b) {
                        .reg => |b| registers[a] += registers[b],
                        .val => |b| registers[a] += b,
                    },
                    .val => unreachable,
                }
            },
            .mul => |r| {
                switch (r.a) {
                    .reg => |a| switch (r.b) {
                        .reg => |b| registers[a] *= registers[b],
                        .val => |b| registers[a] *= b,
                    },
                    .val => unreachable,
                }
            },
            .mod => |r| {
                switch (r.a) {
                    .reg => |a| switch (r.b) {
                        .reg => |b| registers[a] = @mod(registers[a], registers[b]),
                        .val => |b| registers[a] = @mod(registers[a], b),
                    },
                    .val => unreachable,
                }
            },
            .jgz => |r| {
                const a = switch (r.a) {
                    .reg => |v| registers[v],
                    .val => |v| v,
                };
                if (a > 0) {
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
    unreachable;
}

const Queue = std.TailQueue(i64);
fn runInstructions(alloc: Allocator, i: *usize, instructions: []Instruction, registers: []i64, sent: *Queue, received: *Queue) !void {
    while (i.* < instructions.len) {
        switch (instructions[i.*]) {
            .snd => |r| {
                const a = switch (r) {
                    .reg => |v| registers[v],
                    .val => |v| v,
                };
                var data = try alloc.create(Queue.Node);
                data.data = a;
                sent.append(data);
            },
            .rcv => |r| {
                const a = switch (r) {
                    .reg => |v| v,
                    .val => unreachable,
                };
                if (received.popFirst()) |first| {
                    registers[a] = first.data;
                    alloc.destroy(first);
                } else {
                    return;
                }
            },
            .set => |r| {
                switch (r.a) {
                    .reg => |a| switch (r.b) {
                        .reg => |b| registers[a] = registers[b],
                        .val => |b| registers[a] = b,
                    },
                    .val => unreachable,
                }
            },
            .add => |r| {
                switch (r.a) {
                    .reg => |a| switch (r.b) {
                        .reg => |b| registers[a] += registers[b],
                        .val => |b| registers[a] += b,
                    },
                    .val => unreachable,
                }
            },
            .mul => |r| {
                switch (r.a) {
                    .reg => |a| switch (r.b) {
                        .reg => |b| registers[a] *= registers[b],
                        .val => |b| registers[a] *= b,
                    },
                    .val => unreachable,
                }
            },
            .mod => |r| {
                switch (r.a) {
                    .reg => |a| switch (r.b) {
                        .reg => |b| registers[a] = @mod(registers[a], registers[b]),
                        .val => |b| registers[a] = @mod(registers[a], b),
                    },
                    .val => unreachable,
                }
            },
            .jgz => |r| {
                const a = switch (r.a) {
                    .reg => |v| registers[v],
                    .val => |v| v,
                };
                if (a > 0) {
                    switch (r.b) {
                        .reg => |b| i.* = @intCast(@as(i64, @intCast(i.*)) + registers[b]),
                        .val => |b| i.* = @intCast(@as(i64, @intCast(i.*)) + b),
                    }
                    continue;
                }
            },
        }
        i.* += 1;
    }
}

fn part2(alloc: Allocator, input: []const u8) !usize {
    const instructions = try parseInstructions(alloc, input);
    defer alloc.free(instructions);
    var registers0: [26]i64 = [1]i64{0} ** 26;
    var registers1: [26]i64 = [1]i64{1} ** 26;
    var p0: usize = 0;
    var p0_sent = Queue{};
    defer while (p0_sent.pop()) |tail| alloc.destroy(tail);

    var p1: usize = 0;
    var p1_sent = Queue{};
    defer while (p1_sent.pop()) |tail| alloc.destroy(tail);

    try runInstructions(alloc, &p0, instructions, &registers0, &p0_sent, &p1_sent);
    if (p0_sent.len != 0) try runInstructions(alloc, &p1, instructions, &registers1, &p1_sent, &p0_sent);
    var count = p1_sent.len;
    while (p1_sent.len != 0) {
        try runInstructions(alloc, &p0, instructions, &registers0, &p0_sent, &p1_sent);
        if (p0_sent.len != 0) try runInstructions(alloc, &p1, instructions, &registers1, &p1_sent, &p0_sent);
        count += p1_sent.len;
    }

    return count;
}

test "part1" {
    try std.testing.expect(try part1(std.testing.allocator,
        \\set a 1
        \\add a 2
        \\mul a a
        \\mod a 5
        \\snd a
        \\set a 0
        \\rcv a
        \\jgz a -1
        \\set a 1
        \\jgz a -2
    ) == 4);
}

test "part2" {
    try std.testing.expect(try part2(std.testing.allocator,
        \\snd 1
        \\snd 2
        \\snd p
        \\rcv a
        \\rcv b
        \\rcv c
        \\rcv d
    ) == 3);
}
