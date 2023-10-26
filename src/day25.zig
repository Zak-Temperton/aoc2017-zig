const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day25.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, buffer);
    const p1_time = timer.lap();
    try stdout.print("Day25:\n  part1: {d} {d}ns\n", .{ p1, p1_time });
}

const State = struct {
    zero_path: Path,
    one_path: Path,
};

const Path = struct {
    write_val: bool,
    move_right: bool,
    next_state: u8,
};

fn part1(alloc: Allocator, input: []const u8) !usize {
    var lines = tokenizeAny(u8, input, "\r\n");
    _ = lines.next();
    const steps = blk: {
        var words = tokenizeAny(u8, lines.next().?, " \t");
        for (0..5) |_| _ = words.next();
        break :blk try std.fmt.parseInt(usize, words.next().?, 10);
    };
    var states = std.ArrayList(State).init(alloc);
    defer states.deinit();
    while (lines.next()) |_| {
        _ = lines.next();
        const val0: bool = blk: {
            var words = tokenizeAny(u8, lines.next().?, " -");
            for (0..3) |_| _ = words.next();
            break :blk words.next().?[0] == '1';
        };
        const right0: bool = blk: {
            var words = tokenizeAny(u8, lines.next().?, " -");
            for (0..5) |_| _ = words.next();
            break :blk words.next().?[0] == 'r';
        };
        const next0: u8 = blk: {
            var words = tokenizeAny(u8, lines.next().?, " -");
            for (0..3) |_| _ = words.next();
            break :blk @truncate(words.next().?[0] - 'A');
        };
        _ = lines.next();
        const val1: bool = blk: {
            var words = tokenizeAny(u8, lines.next().?, " -");
            for (0..3) |_| _ = words.next();
            break :blk words.next().?[0] == '1';
        };
        const right1: bool = blk: {
            var words = tokenizeAny(u8, lines.next().?, " -");
            for (0..5) |_| _ = words.next();
            break :blk words.next().?[0] == 'r';
        };
        const next1: u8 = blk: {
            var words = tokenizeAny(u8, lines.next().?, " -");
            for (0..3) |_| _ = words.next();
            break :blk @truncate(words.next().?[0] - 'A');
        };
        try states.append(.{
            .zero_path = .{
                .write_val = val0,
                .move_right = right0,
                .next_state = next0,
            },

            .one_path = .{
                .write_val = val1,
                .move_right = right1,
                .next_state = next1,
            },
        });
    }
    var index: u8 = 0;
    var mask: u64 = 1;
    var offset: u6 = 32;
    var bits = std.TailQueue(u64){};
    errdefer {
        while (bits.pop()) |i| alloc.destroy(i);
    }

    var curr_node = try alloc.create(std.TailQueue(u64).Node);
    curr_node.data = 0;
    bits.append(curr_node);

    for (0..steps) |_| {
        const path = if (curr_node.data & (mask << offset) == 0) states.items[index].zero_path else states.items[index].one_path;
        if (path.write_val) {
            curr_node.data |= mask << offset;
        } else {
            curr_node.data &= ~(mask << offset);
        }
        if (path.move_right) {
            if (offset == 0) {
                offset = 63;
                if (curr_node.next) |next| {
                    curr_node = next;
                } else {
                    var node = try alloc.create(std.TailQueue(u64).Node);
                    node.data = 0;
                    bits.append(node);
                    curr_node = node;
                }
            } else {
                offset -= 1;
            }
        } else {
            if (offset == 63) {
                offset = 0;
                if (curr_node.prev) |prev| {
                    curr_node = prev;
                } else {
                    var node = try alloc.create(std.TailQueue(u64).Node);
                    node.data = 0;
                    bits.prepend(node);
                    curr_node = node;
                }
            } else {
                offset += 1;
            }
        }
        index = path.next_state;
    }

    var count: usize = 0;
    while (bits.pop()) |i| {
        count += @popCount(i.data);
        alloc.destroy(i);
    }
    return count;
}

test "part1" {
    try std.testing.expect(try part1(std.testing.allocator,
        \\Begin in state A.
        \\Perform a diagnostic checksum after 6 steps.
        \\
        \\In state A:
        \\  If the current value is 0:
        \\    - Write the value 1.
        \\    - Move one slot to the right.
        \\    - Continue with state B.
        \\  If the current value is 1:
        \\    - Write the value 0.
        \\    - Move one slot to the left.
        \\    - Continue with state B.
        \\
        \\In state B:
        \\  If the current value is 0:
        \\    - Write the value 1.
        \\    - Move one slot to the left.
        \\    - Continue with state A.
        \\  If the current value is 1:
        \\    - Write the value 1.
        \\    - Move one slot to the right.
        \\    - Continue with state A.
    ) == 3);
}
