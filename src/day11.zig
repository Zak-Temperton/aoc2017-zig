const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day11.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = part1(buffer);
    const p1_time = timer.lap();
    const p2 = part2(buffer);
    const p2_time = timer.read();
    try stdout.print("Day11:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

const State = struct {
    nw: usize = 0,
    n: usize = 0,
    ne: usize = 0,
    se: usize = 0,
    s: usize = 0,
    sw: usize = 0,

    fn add(state: *@This(), word: []const u8) void {
        if (word[0] == 'n') {
            if (word.len == 2) {
                if (word[1] == 'e') {
                    state.ne += 1;
                } else {
                    state.nw += 1;
                }
            } else {
                state.n += 1;
            }
        } else {
            if (word.len == 2) {
                if (word[1] == 'e') {
                    state.se += 1;
                } else {
                    state.sw += 1;
                }
            } else {
                state.s += 1;
            }
        }
    }

    fn simplify(self: *@This()) usize {
        //ne + sw == 0
        if (self.ne > self.sw) {
            self.ne -= self.sw;
            self.sw = 0;
        } else {
            self.sw -= self.ne;
            self.ne = 0;
        }
        //nw + self.se == 0
        if (self.nw > self.se) {
            self.nw -= self.se;
            self.se = 0;
        } else {
            self.se -= self.nw;
            self.nw = 0;
        }
        //nw + self.s = self.sw
        if (self.nw > self.s) {
            self.sw += self.s;
            self.nw -= self.s;
            self.s = 0;
        } else {
            self.sw += self.nw;
            self.s -= self.nw;
            self.nw = 0;
        }
        //ne + self.s = se
        if (self.ne > self.s) {
            self.se += self.s;
            self.ne -= self.s;
            self.s = 0;
        } else {
            self.se += self.ne;
            self.s -= self.ne;
            self.ne = 0;
        }
        //self.sw + self.n = nw
        if (self.se > self.n) {
            self.ne += self.n;
            self.se -= self.n;
            self.n = 0;
        } else {
            self.ne += self.se;
            self.n -= self.se;
            self.se = 0;
        }
        //ne + self.n = ne
        if (self.sw > self.n) {
            self.nw += self.n;
            self.sw -= self.n;
            self.n = 0;
        } else {
            self.nw += self.sw;
            self.n -= self.sw;
            self.sw = 0;
        }
        //nw + ne == n
        if (self.nw > self.ne) {
            self.n += self.ne;
            self.nw -= self.ne;
            self.ne = 0;
        } else {
            self.n += self.nw;
            self.ne -= self.nw;
            self.nw = 0;
        }
        //self.sw + self.se == s
        if (self.sw > self.se) {
            self.s += self.se;
            self.sw -= self.se;
            self.se = 0;
        } else {
            self.s += self.sw;
            self.se -= self.sw;
            self.sw = 0;
        }
        //self.n + self.s == 0
        if (self.n > self.s) {
            self.n -= self.s;
            self.s = 0;
        } else {
            self.s -= self.n;
            self.n = 0;
        }
        return self.ne + self.n + self.nw + self.sw + self.s + self.se;
    }
};

fn part1(input: []const u8) usize {
    var state = State{};
    var words = tokenizeAny(u8, input, ",\r\n");
    while (words.next()) |word| {
        state.add(word);
    }
    return state.simplify();
}

fn part2(input: []const u8) usize {
    var max: usize = 0;
    var state = State{};
    var words = tokenizeAny(u8, input, ",\r\n");
    while (words.next()) |word| {
        state.add(word);
        const tmp = state.simplify();
        if (tmp > max) max = tmp;
    }
    return max;
}

test "part1" {
    try std.testing.expect(part1("ne,ne,ne") == 3);
    try std.testing.expect(part1("ne,ne,sw,sw") == 0);
    try std.testing.expect(part1("ne,ne,s,s") == 2);
    try std.testing.expect(part1("se,sw,se,sw,sw") == 3);
}

test "part2" {
    try std.testing.expect(part2("ne,ne,ne") == 3);
    try std.testing.expect(part2("ne,ne,sw,sw") == 2);
    try std.testing.expect(part2("ne,ne,s,s") == 2);
    try std.testing.expect(part2("se,sw,se,sw,sw,ne") == 3);
}
