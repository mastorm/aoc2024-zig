const std = @import("std");

pub fn main() !void {}

fn solve(input: []const u8, allocator: std.mem.Allocator) !void {
    var lines = std.mem.split(u8, input, "\n");

    var left = std.ArrayList(i32).init(allocator);
    defer left.deinit();
    var right = std.ArrayList(i32).init(allocator);
    defer right.deinit();

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

    std.debug.print("Solution is: {d}", .{sum});
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
