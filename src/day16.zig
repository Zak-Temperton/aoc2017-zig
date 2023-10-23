const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day16.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    const input = std.mem.trimRight(u8, buffer, "\r\n");
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(input);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, input);
    const p2_time = timer.read();
    try stdout.print("Day16:\npart1: {s} {d}ns\npart2: {s} {d}ns", .{ p1, p1_time, p2, p2_time });
}
fn CircularBuffer(comptime S: usize) type {
    return struct {
        const Self = @This();

        buffer: [S]u8 = blk: {
            var buf: [S]u8 = undefined;
            for (&buf, 'a'..) |*i, j| i.* = j;
            break :blk buf;
        },
        index: usize = 0,

        fn toSlice(self: Self) [S]u8 {
            var slice: [S]u8 = undefined;
            for (&slice, 0..) |*v, i| {
                v.* = self.buffer[(self.index + i) % S];
            }
            return slice;
        }

        fn hash(self: Self) u128 {
            const slice = self.toSlice();
            return std.mem.readInt(u128, &slice, .Little);
        }

        fn rotateRight(self: *Self, count: usize) void {
            const c = count % S;
            if (c > self.index) {
                self.index += S - c;
                self.index %= S;
            } else {
                self.index -= c;
            }
        }

        fn exchange(self: *Self, pos1: usize, pos2: usize) void {
            std.mem.swap(u8, &self.buffer[(self.index + pos1) % S], &self.buffer[(self.index + pos2) % S]);
        }

        fn swap(self: *Self, letter1: u8, letter2: u8) void {
            for (self.buffer, 0..) |l1, idx1| {
                if (l1 == letter1) {
                    for (self.buffer[idx1 + 1 ..], idx1 + 1..) |l2, idx2| {
                        if (l2 == letter2) {
                            std.mem.swap(u8, &self.buffer[idx1], &self.buffer[idx2]);
                            return;
                        }
                    }
                } else if (l1 == letter2) {
                    for (self.buffer[idx1 + 1 ..], idx1 + 1..) |l2, idx2| {
                        if (l2 == letter1) {
                            std.mem.swap(u8, &self.buffer[idx1], &self.buffer[idx2]);
                            return;
                        }
                    }
                }
            }
        }
    };
}

fn part1(input: []const u8) ![16]u8 {
    var buf = CircularBuffer(16){};
    var words = tokenizeAny(u8, input, ",/\r\n");
    while (words.next()) |word| {
        switch (word[0]) {
            's' => {
                buf.rotateRight(try std.fmt.parseInt(usize, word[1..], 10));
            },
            'x' => {
                buf.exchange(try std.fmt.parseInt(usize, word[1..], 10), try std.fmt.parseInt(usize, words.next().?, 10));
            },
            'p' => {
                buf.swap(word[1], words.next().?[0]);
            },
            else => unreachable,
        }
    }
    return buf.toSlice();
}

fn part2(alloc: Allocator, input: []const u8) ![16]u8 {
    var buf = CircularBuffer(16){};
    var seen = std.AutoHashMap(u128, usize).init(alloc);
    defer seen.deinit();
    var pre: usize = 0;
    var loop: usize = undefined;
    while (true) : (pre += 1) {
        var words = tokenizeAny(u8, input, ",/\r\n");
        while (words.next()) |word| {
            switch (word[0]) {
                's' => {
                    buf.rotateRight(try std.fmt.parseInt(usize, word[1..], 10));
                },
                'x' => {
                    buf.exchange(try std.fmt.parseInt(usize, word[1..], 10), try std.fmt.parseInt(usize, words.next().?, 10));
                },
                'p' => {
                    buf.swap(word[1], words.next().?[0]);
                },
                else => unreachable,
            }
        }
        var hash = buf.hash();
        if (seen.contains(hash)) {
            loop = pre;
            break;
        } else {
            try seen.put(hash, pre);
        }
    }
    var target = ((1_000_000_000) % loop) -| 1;
    var iter = seen.iterator();
    while (iter.next()) |entry| {
        if (entry.value_ptr.* == target) {
            return @as(*[16]u8, @ptrCast(entry.key_ptr)).*;
        }
    }
    unreachable;
}

test "part1" {
    try std.testing.expect(std.mem.eql(u8, &try part1("x13/7,s2,x2/1,pn/a,x11/4"), "onpbjdefgaicklmh"));
}

test "part2" {
    try std.testing.expect(std.mem.eql(u8, &try part2(std.testing.allocator, "x13/7,s2,x2/1,pn/a,x11/4"), "onpbjdefgaicklmh"));
}
