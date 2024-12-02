const std = @import("std");

pub fn main() !void {}

const Order = enum { asc, desc };

const ReactorReading = struct {
    levels: *std.ArrayList(isize),

    pub fn isValid(self: ReactorReading) bool {
        var order: ?Order = null;
        for (self.levels.items, 0..) |reading, i| {
            const nextIndex = if (i == self.levels.items.len - 1) i else i + 1;
            const next = self.levels.items[nextIndex];
            const isAscending = next >= reading;

            order = order orelse if (isAscending) Order.asc else Order.desc;

            if (order == Order.asc and !isAscending) {
                return false;
            }

            if (order == Order.desc and isAscending) {
                return false;
            }

            const prevIndex = if (i > 0) i - 1 else 0;
            const prevEl = self.levels.items[prevIndex];

            const prevDistance = @abs(prevEl - reading);
            std.debug.print("{d} - {d}\n", .{ next, reading });
            const nextDistance = @abs(next - reading);
            const isSafeDistance = nextDistance > 1 and nextDistance <= 3 and prevDistance > 1 and nextDistance <= 3;

            if (!isSafeDistance) {
                return false;
            }
        }

        return true;
    }
};

const ReactorReadingIterator = struct {
    it: std.mem.SplitIterator(u8, .sequence),

    alloc: std.mem.Allocator,
    fn next(self: *ReactorReadingIterator) !?*const ReactorReading {
        const line = self.it.next() orelse return null;
        var cols = std.mem.split(u8, line, " ");

        var acc = std.ArrayList(isize).init(self.alloc);
        defer acc.deinit();
        while (cols.next()) |col| {
            if (std.mem.eql(u8, col, "")) {
                continue;
            }
            const parsedReading = try std.fmt.parseInt(isize, col, 10);

            try acc.append(parsedReading);
        }

        return &ReactorReading{ .levels = &acc };
    }
};

fn reader(input: []const u8, allocator: std.mem.Allocator) ReactorReadingIterator {
    return ReactorReadingIterator{ .it = std.mem.split(u8, input, "\n"), .alloc = allocator };
}

fn getInvalidReadingCount(input: []const u8, allocator: std.mem.Allocator) !isize {
    var it = reader(input, allocator);

    var sum: isize = 0;
    while (try it.next()) |reading| {
        if (reading.isValid()) {
            sum += 1;
        }
    }

    return sum;
}

test "sample input file works" {
    const sampleInput = @embedFile("./sample_input.txt");
    const validReadings = try getInvalidReadingCount(sampleInput, std.testing.allocator);
    std.debug.print("There is {d} valid readings\n", .{validReadings});
}
