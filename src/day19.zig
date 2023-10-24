const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day19.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    defer alloc.free(p1);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day19:\npart1: {s} {d}ns\npart2: {d} {d}ns", .{ p1, p1_time, p2, p2_time });
}

fn part1(alloc: Allocator, input: []const u8) ![]u8 {
    var map_list = std.ArrayList([]const u8).init(alloc);
    defer map_list.deinit();

    var lines = tokenizeAny(u8, input, "\n\r");

    var x: usize = std.mem.indexOf(u8, lines.next().?, "|").?;
    var y: usize = 0;
    var dir: u2 = 1;

    while (lines.next()) |line| try map_list.append(line);
    const map = map_list.items;

    var result = std.ArrayList(u8).init(alloc);
    defer result.deinit();

    const height = map.len;
    while (true) {
        switch (dir) {
            0 => {
                switch (map[y][x]) {
                    '+' => {
                        if (y != 0 and x < map[y - 1].len and map[y - 1][x] != ' ') {
                            dir = 3;
                            y -= 1;
                        } else if (y != height - 1 and x < map[y + 1].len and map[y + 1][x] != ' ') {
                            dir = 1;
                            y += 1;
                        } else {
                            break;
                        }
                    },
                    'A'...'Z' => {
                        try result.append(map[y][x]);
                        x += 1;
                    },
                    '-', '|' => {
                        x += 1;
                    },
                    else => {
                        break;
                    },
                }
            },
            1 => {
                switch (map[y][x]) {
                    '+' => {
                        if (x != 0 and map[y][x - 1] != ' ') {
                            dir = 2;
                            x -= 1;
                        } else if (x != map[y].len - 1 and map[y][x + 1] != ' ') {
                            dir = 0;
                            x += 1;
                        } else {
                            break;
                        }
                    },
                    'A'...'Z' => {
                        try result.append(map[y][x]);
                        y += 1;
                    },
                    '-', '|' => {
                        y += 1;
                    },
                    else => {
                        break;
                    },
                }
            },
            2 => {
                switch (map[y][x]) {
                    '+' => {
                        if (y != 0 and x < map[y - 1].len and map[y - 1][x] != ' ') {
                            dir = 3;
                            y -= 1;
                        } else if (y != height - 1 and x < map[y + 1].len and map[y + 1][x] != ' ') {
                            dir = 1;
                            y += 1;
                        } else {
                            break;
                        }
                    },
                    'A'...'Z' => {
                        try result.append(map[y][x]);
                        x -= 1;
                    },
                    '-', '|' => {
                        x -= 1;
                    },
                    else => {
                        break;
                    },
                }
            },
            3 => {
                switch (map[y][x]) {
                    '+' => {
                        if (x != 0 and map[y][x - 1] != ' ') {
                            dir = 2;
                            x -= 1;
                        } else if (x != map[y].len - 1 and map[y][x + 1] != ' ') {
                            dir = 0;
                            x += 1;
                        } else {
                            break;
                        }
                    },
                    'A'...'Z' => {
                        try result.append(map[y][x]);
                        y -= 1;
                    },
                    '-', '|' => {
                        y -= 1;
                    },
                    else => {
                        break;
                    },
                }
            },
        }
    }
    return result.toOwnedSlice();
}

fn part2(alloc: Allocator, input: []const u8) !usize {
    var map_list = std.ArrayList([]const u8).init(alloc);
    defer map_list.deinit();

    var lines = tokenizeAny(u8, input, "\n\r");

    var x: usize = std.mem.indexOf(u8, lines.next().?, "|").?;
    var y: usize = 0;
    var dir: u2 = 1;

    while (lines.next()) |line| try map_list.append(line);
    const map = map_list.items;

    const height = map.len;
    var count: usize = 1;
    while (true) : (count += 1) {
        switch (dir) {
            0 => {
                switch (map[y][x]) {
                    '+' => {
                        if (y != 0 and x < map[y - 1].len and map[y - 1][x] != ' ') {
                            dir = 3;
                            y -= 1;
                        } else if (y != height - 1 and x < map[y + 1].len and map[y + 1][x] != ' ') {
                            dir = 1;
                            y += 1;
                        } else {
                            break;
                        }
                    },
                    'A'...'Z', '-', '|' => {
                        x += 1;
                    },
                    else => {
                        break;
                    },
                }
            },
            1 => {
                switch (map[y][x]) {
                    '+' => {
                        if (x != 0 and map[y][x - 1] != ' ') {
                            dir = 2;
                            x -= 1;
                        } else if (x != map[y].len - 1 and map[y][x + 1] != ' ') {
                            dir = 0;
                            x += 1;
                        } else {
                            break;
                        }
                    },
                    'A'...'Z', '-', '|' => {
                        y += 1;
                    },
                    else => {
                        break;
                    },
                }
            },
            2 => {
                switch (map[y][x]) {
                    '+' => {
                        if (y != 0 and x < map[y - 1].len and map[y - 1][x] != ' ') {
                            dir = 3;
                            y -= 1;
                        } else if (y != height - 1 and x < map[y + 1].len and map[y + 1][x] != ' ') {
                            dir = 1;
                            y += 1;
                        } else {
                            break;
                        }
                    },
                    'A'...'Z', '-', '|' => {
                        x -= 1;
                    },
                    else => {
                        break;
                    },
                }
            },
            3 => {
                switch (map[y][x]) {
                    '+' => {
                        if (x != 0 and map[y][x - 1] != ' ') {
                            dir = 2;
                            x -= 1;
                        } else if (x != map[y].len - 1 and map[y][x + 1] != ' ') {
                            dir = 0;
                            x += 1;
                        } else {
                            break;
                        }
                    },
                    'A'...'Z', '-', '|' => {
                        y -= 1;
                    },
                    else => {
                        break;
                    },
                }
            },
        }
    }
    return count;
}

test "part1" {
    const p1 = try part1(std.testing.allocator,
        \\     |
        \\     |  +--+
        \\     A  |  C
        \\ F---|----E|--+
        \\     |  |  |  D
        \\     +B-+  +--+
        \\
    );
    try std.testing.expect(std.mem.eql(u8, p1, "ABCDEF"));
    std.testing.allocator.free(p1);
}

test "part2" {
    const p2 = try part2(std.testing.allocator,
        \\     |
        \\     |  +--+
        \\     A  |  C
        \\ F---|----E|--+
        \\     |  |  |  D
        \\     +B-+  +--+
        \\
    );
    try std.testing.expect(p2 == 38);
}
