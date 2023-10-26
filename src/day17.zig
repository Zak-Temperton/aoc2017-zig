const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day17.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    const input = try std.fmt.parseInt(usize, std.mem.trimRight(u8, buffer, "\r\n"), 10);
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(alloc, input);
    const p1_time = timer.lap();
    const p2 = part2(input);
    const p2_time = timer.read();
    try stdout.print("Day17:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn part1(alloc: Allocator, input: usize) !usize {
    var list = std.SinglyLinkedList(usize){};
    defer {
        var prev = list.first;
        while (prev) |node| {
            var curr = node.next;
            alloc.destroy(node);
            prev = curr;
        }
    }
    var curr = try alloc.create(std.SinglyLinkedList(usize).Node);
    curr.data = 0;
    list.prepend(curr);
    for (1..2018) |i| {
        for (0..input) |_| {
            if (curr.next) |next| {
                curr = next;
            } else {
                curr = list.first.?;
            }
        }
        const next = try alloc.create(std.SinglyLinkedList(usize).Node);
        next.data = i;
        curr.insertAfter(next);
        curr = curr.next.?;
    }

    if (curr.next) |next| {
        return next.data;
    } else {
        return list.first.?.data;
    }
}
fn part2(input: usize) usize {
    var cur: usize = 0;
    var before_len: usize = 1;
    var after_len: usize = 1;
    var len: usize = 1;
    var after_num: usize = 0;

    for (1..50_000_001) |i| {
        cur = ((cur + input) % len) + 1;
        len += 1;
        if (cur == before_len) {
            after_num = i;
            after_len += 1;
        } else if (cur > before_len) {
            after_len += 1;
        } else {
            before_len += 1;
        }
    }
    return after_num;
}

test "part1" {
    try std.testing.expect(try part1(std.testing.allocator, 3) == 638);
}

test "part2" {
    try std.testing.expect(part2(3) == 1222153);
}
