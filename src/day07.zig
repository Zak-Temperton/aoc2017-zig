const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day07.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day07:\npart1: {s} {d}ns\npart2: {d} {d}ns", .{ p1, p1_time, p2, p2_time });
}

fn part1(alloc: Allocator, input: []const u8) ![]const u8 {
    var list = std.StringHashMap([]const u8).init(alloc);
    defer list.deinit();

    var lines = tokenizeAny(u8, input, "\r\n");
    while (lines.next()) |line| {
        var words = tokenizeAny(u8, line, " (),");
        const word = words.next().?;
        _ = words.next().?;
        while (words.next()) |key| {
            try list.put(key, word);
        }
    }
    var iter = list.keyIterator();
    var key = iter.next().?.*;
    while (list.get(key)) |k| key = k;
    return key;
}

fn getWeight(key: []const u8, programs: std.StringHashMap([][]const u8), program_weights: *std.StringHashMap(u32), weights: std.StringHashMap(u32)) !u32 {
    if (program_weights.get(key)) |weight| {
        return weight;
    } else if (programs.get(key)) |list| {
        var weight = weights.get(key).?;
        for (list) |k| {
            weight += try getWeight(k, programs, program_weights, weights);
        }
        try program_weights.put(key, weight);
        return weight;
    } else {
        return weights.get(key).?;
    }
}

fn part2(alloc: Allocator, input: []const u8) !u32 {
    var list = std.StringHashMap([]const u8).init(alloc);
    defer list.deinit();
    var programs = std.StringHashMap([][]const u8).init(alloc);
    defer {
        var iter = programs.valueIterator();
        while (iter.next()) |val| alloc.free(val.*);
        programs.deinit();
    }
    var weights = std.StringHashMap(u32).init(alloc);
    defer weights.deinit();

    var lines = tokenizeAny(u8, input, "\r\n");
    while (lines.next()) |line| {
        var words = tokenizeAny(u8, line, " (),->");
        const key = words.next().?;
        const weight = try std.fmt.parseInt(u32, words.next().?, 10);
        try weights.put(key, weight);
        if (words.next()) |word1| {
            try list.put(word1, key);
            var branches = std.ArrayListUnmanaged([]const u8){};
            defer branches.deinit(alloc);
            try branches.append(alloc, word1);
            while (words.next()) |word| {
                try list.put(word, key);
                try branches.append(alloc, word);
            }
            try programs.put(key, try branches.toOwnedSlice(alloc));
        }
    }

    var program_weights = std.StringHashMap(u32).init(alloc);
    defer program_weights.deinit();
    var iter = list.keyIterator();
    var key = iter.next().?.*;
    while (list.get(key)) |k| key = k;
    return try findUnbalanced(key, programs, &program_weights, weights, null);
}

fn findUnbalanced(key: []const u8, programs: std.StringHashMap([][]const u8), program_weights: *std.StringHashMap(u32), weights: std.StringHashMap(u32), target: ?u32) !u32 {
    if (programs.get(key)) |program| {
        const w1 = try getWeight(program[0], programs, program_weights, weights);
        const w2 = try getWeight(program[1], programs, program_weights, weights);
        if (w1 == w2) {
            for (program[2..]) |k| {
                if (w1 != try getWeight(k, programs, program_weights, weights)) {
                    return findUnbalanced(k, programs, program_weights, weights, w1);
                }
            }
            if (target) |t| {
                return weights.get(key).? + t - try getWeight(key, programs, program_weights, weights);
            }
        } else {
            const w3 = try getWeight(program[2], programs, program_weights, weights);
            if (w1 == w3) {
                return findUnbalanced(program[1], programs, program_weights, weights, w1);
            } else {
                return findUnbalanced(program[0], programs, program_weights, weights, w2);
            }
        }
    }
    unreachable;
}

test "part1" {
    try std.testing.expect(std.mem.eql(u8, try part1(std.testing.allocator,
        \\pbga (66)
        \\xhth (57)
        \\ebii (61)
        \\havc (66)
        \\ktlj (57)
        \\fwft (72) -> ktlj, cntj, xhth
        \\qoyq (66)
        \\padx (45) -> pbga, havc, qoyq
        \\tknk (41) -> ugml, padx, fwft
        \\jptl (61)
        \\ugml (68) -> gyxo, ebii, jptl
        \\gyxo (61)
        \\cntj (57)
    ), "tknk"));
}

test "part2" {
    try std.testing.expect(try part2(std.testing.allocator,
        \\pbga (66)
        \\xhth (57)
        \\ebii (61)
        \\havc (66)
        \\ktlj (57)
        \\fwft (72) -> ktlj, cntj, xhth
        \\qoyq (66)
        \\padx (45) -> pbga, havc, qoyq
        \\tknk (41) -> ugml, padx, fwft
        \\jptl (61)
        \\ugml (68) -> gyxo, ebii, jptl
        \\gyxo (61)
        \\cntj (57)
    ) == 60);
}
