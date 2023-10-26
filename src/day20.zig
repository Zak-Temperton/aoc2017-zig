const std = @import("std");
const Allocator = std.mem.Allocator;
const tokenizeAny = std.mem.tokenizeAny;

pub fn run(alloc: Allocator, stdout: anytype) !void {
    const file = try std.fs.cwd().openFile("src/data/day20.txt", .{ .mode = .read_only });
    const buffer = try file.readToEndAlloc(alloc, std.math.maxInt(u32));
    defer alloc.free(buffer);

    var timer = try std.time.Timer.start();
    const p1 = try part1(buffer);
    const p1_time = timer.lap();
    const p2 = try part2(alloc, buffer);
    const p2_time = timer.read();
    try stdout.print("Day20:\n  part1: {d} {d}ns\n  part2: {d} {d}ns\n", .{ p1, p1_time, p2, p2_time });
}

fn part1(input: []const u8) !usize {
    var lines = tokenizeAny(u8, input, "\n\r");
    var min: usize = 0;
    var min_acc: i32 = std.math.maxInt(i32);
    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        var vals = tokenizeAny(u8, line, " ,vpa=<>");
        for (0..6) |_| _ = vals.next();
        var x = try std.fmt.parseInt(i32, vals.next().?, 10);
        var y = try std.fmt.parseInt(i32, vals.next().?, 10);
        var z = try std.fmt.parseInt(i32, vals.next().?, 10);
        if (x < 0) x = -x;
        if (y < 0) y = -y;
        if (z < 0) z = -z;
        var acc = x + y + z;
        if (acc < min_acc) {
            min_acc = acc;
            min = i;
        }
    }
    return min;
}

const Particle = struct {
    p: [3]i32,
    v: [3]i32,
    a: [3]i32,

    fn tick(self: *@This()) void {
        for (0..3) |i| {
            self.v[i] += self.a[i];
            self.p[i] += self.v[i];
        }
    }
};

const ParticlePair = struct {
    p1_id: usize,
    p2_id: usize,
    prev_dist: i32,
};

fn part2(alloc: Allocator, input: []const u8) !usize {
    var particles = std.ArrayList(Particle).init(alloc);
    defer particles.deinit();
    var dead_particles = std.AutoHashMap(usize, void).init(alloc);
    defer dead_particles.deinit();
    var pairs = std.ArrayList(ParticlePair).init(alloc);
    defer pairs.deinit();

    var lines = tokenizeAny(u8, input, "\n\r");
    while (lines.next()) |line| {
        var vals = tokenizeAny(u8, line, " ,vpa=<>");
        var px = try std.fmt.parseInt(i32, vals.next().?, 10);
        var py = try std.fmt.parseInt(i32, vals.next().?, 10);
        var pz = try std.fmt.parseInt(i32, vals.next().?, 10);
        var vx = try std.fmt.parseInt(i32, vals.next().?, 10);
        var vy = try std.fmt.parseInt(i32, vals.next().?, 10);
        var vz = try std.fmt.parseInt(i32, vals.next().?, 10);
        var ax = try std.fmt.parseInt(i32, vals.next().?, 10);
        var ay = try std.fmt.parseInt(i32, vals.next().?, 10);
        var az = try std.fmt.parseInt(i32, vals.next().?, 10);
        for (particles.items, 0..) |particle, i| {
            var dx = px - particle.p[0];
            var dy = py - particle.p[1];
            var dz = pz - particle.p[2];
            if (dx < 0) dx = -dx;
            if (dy < 0) dy = -dy;
            if (dz < 0) dz = -dz;
            try pairs.append(.{
                .p1_id = particles.items.len,
                .p2_id = i,
                .prev_dist = dx + dy + dz,
            });
        }
        try particles.append(.{ .p = .{ px, py, pz }, .v = .{ vx, vy, vz }, .a = .{ ax, ay, az } });
    }

    var loop = true;
    while (loop) {
        loop = false;
        for (particles.items, 0..) |*particle, i| {
            if (!dead_particles.contains(i))
                particle.tick();
        }
        for (particles.items, 0..) |p1, i| {
            for (particles.items[i + 1 ..], i + 1..) |p2, j| {
                if (std.mem.eql(i32, &p1.p, &p2.p)) {
                    try dead_particles.put(i, {});
                    try dead_particles.put(j, {});
                }
            }
        }

        for (pairs.items) |*pair| {
            if (!dead_particles.contains(pair.p1_id) and !dead_particles.contains(pair.p1_id)) {
                var p1 = particles.items[pair.p1_id];
                var p2 = particles.items[pair.p2_id];
                var dx = p1.p[0] - p2.p[0];
                var dy = p1.p[1] - p2.p[1];
                var dz = p1.p[2] - p2.p[2];
                if (dx < 0) dx = -dx;
                if (dy < 0) dy = -dy;
                if (dz < 0) dz = -dz;
                var dist = dx + dy + dz;
                if (dist < pair.prev_dist) loop = true;
                pair.prev_dist = dist;
            }
        }
    }
    return particles.items.len - dead_particles.count();
}

test "part1" {
    const p1 = try part1(
        \\p=< 3,0,0>, v=< 2,0,0>, a=<-1,0,0>
        \\p=< 4,0,0>, v=< 0,0,0>, a=<-2,0,0>
    );
    try std.testing.expect(p1 == 0);
}

test "part2" {
    const p2 = try part2(std.testing.allocator,
        \\p=<-6,0,0>, v=< 3,0,0>, a=< 0,0,0>
        \\p=<-4,0,0>, v=< 2,0,0>, a=< 0,0,0>
        \\p=<-2,0,0>, v=< 1,0,0>, a=< 0,0,0>
        \\p=< 3,0,0>, v=<-1,0,0>, a=< 0,0,0>
    );
    try std.testing.expect(p2 == 1);
}
