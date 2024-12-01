const std = @import("std");

pub fn main() !void {}

fn solve(input: []const u8, allocator: std.mem.Allocator) !void {
    var lines = std.mem.split(u8, input, "\n");

    var left = std.ArrayList(i32).init(allocator);
    defer left.deinit();
    var right = std.ArrayList(i32).init(allocator);
    defer right.deinit();

    var similarityLookup = std.AutoHashMap(i32, i32).init(allocator);
    defer similarityLookup.deinit();

    var existenceLookup = std.AutoHashMap(i32, i32).init(allocator);
    defer existenceLookup.deinit();

    while (lines.next()) |x| {
        if (std.mem.eql(u8, x, "")) {
            continue;
        }

        std.debug.print("Processing line: {s}\n", .{x});
        const line = try parseLine(x);
        std.debug.print("\tLeft: {d}\n", .{line.left});
        std.debug.print("\tRight: {d}\n", .{line.right});

        try left.append(line.left);
        try right.append(line.right);

        // ensure entry from the left

        const seen = similarityLookup.get(line.right);
        try similarityLookup.put(line.right, (seen orelse 0) + 1);

        const count = existenceLookup.get(line.left);
        try existenceLookup.put(line.left, (count orelse 0) + 1);
    }

    const leftSlice = try left.toOwnedSlice();
    defer allocator.free(leftSlice);
    const rightSlice = try right.toOwnedSlice();
    defer allocator.free(rightSlice);
    std.mem.sort(i32, leftSlice, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, rightSlice, {}, comptime std.sort.asc(i32));

    var sum: u32 = 0;
    for (leftSlice, rightSlice) |l, r| {
        sum += @abs(r - l);
    }

    var it = similarityLookup.iterator();
    var similarityScore: i32 = 0;
    std.debug.print("Calculating Similarity: \n", .{});
    while (it.next()) |item| {
        const key = item.key_ptr.*;

        const hitCount = existenceLookup.get(key) orelse continue;

        similarityScore += key * item.value_ptr.* * hitCount;
        std.debug.print("\tK: {d}, V: {d}, HC: {d}\n", .{ item.key_ptr.*, item.value_ptr.*, hitCount });
    }

    std.debug.print("Solution is: {d}\n", .{sum});
    std.debug.print("Similarity is: {d}\n", .{similarityScore});
}

const Line = struct {
    left: i32,
    right: i32,
};

const ParseLineError = error{
    NoNumbersFound,
};

fn parseLine(line: []const u8) !Line {
    var numbers = std.mem.split(u8, line, " ");
    var first: ?i32 = null;

    while (numbers.next()) |num| {
        if (std.mem.eql(u8, num, "")) {
            continue;
        }
        const parsed = try std.fmt.parseInt(i32, num, 10);

        if (first == null) {
            first = parsed;
        } else {
            return .{
                .left = first orelse return ParseLineError.NoNumbersFound,
                .right = parsed,
            };
        }
    }

    return ParseLineError.NoNumbersFound;
}

test "find distance" {
    const input = @embedFile("real_input.txt");
    try solve(input, std.testing.allocator);
}
