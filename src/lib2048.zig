const std = @import("std");

const sort = std.sort.sort;
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

pub fn init() void {
    score = 0;
    std.mem.set(u16, &board, 0);
    std.mem.set(u16, &old_board, 0);

    prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        std.os.getrandom(std.mem.asBytes(&seed)) catch unreachable;
        break :blk seed;
    });
    const rand = prng.random();

    const idx1 = rand.uintLessThan(u8, 16);
    var idx2 = rand.uintLessThan(u8, 16);
    if (idx2 == idx1) {
        idx2 = if (idx1 / 4 <= 1) (idx2 * 2) + 1 else rand.uintLessThan(u8, 7);
    }
    board[idx1] = 2;
    board[idx2] = if (rand.boolean()) 2 else 4;
}

pub fn printBoard() !void {
    const border = "------" ** 4;
    const empty = "      " ** 4;
    const reset = "\x1B[0m";

    try stdout.print("{s}{s}", .{ "\x1B[2J", "\x1B[H" });
    try stdout.print("+{s}+\n|{s}| {d}\n|", .{ border, empty, score });

    var j: usize = 0;
    for (board) |cell, i| {
        if (cell == 0)
            try stdout.print("      ", .{})
        else
            try stdout.print(" {s}{d:^4}{s} ", .{ getColor(cell), cell, reset });

        if (i == 4 * j + 3) {
            try stdout.print("|\n", .{});
            const c = if (i != board.len - 1) "|" else "";
            try stdout.print("|{s}|\n{s}", .{ empty, c });
            j += 1;
        }
    }

    try stdout.print("+{s}+\n", .{border});
}

pub fn reduceUp() bool {
    transpose();
    const op = reduceLeft();
    transpose();
    return op;
}

pub fn reduceDown() bool {
    transpose();
    const op = reduceRight();
    transpose();
    return op;
}

pub fn reduceLeft() bool {
    std.mem.copy(u16, old_board[0..], board[0..]);

    var i: usize = 0;
    while (i < 16) : (i += 4) {
        reduce(Direction.left, board[i .. i + 4]);
    }

    return !std.mem.eql(u16, old_board[0..], board[0..]);
}

pub fn reduceRight() bool {
    std.mem.copy(u16, old_board[0..], board[0..]);

    var i: usize = 0;
    while (i < 16) : (i += 4) {
        reduce(Direction.right, board[i .. i + 4]);
    }

    return !std.mem.eql(u16, old_board[0..], board[0..]);
}

pub fn addNext() void {
    while (true) {
        const rand = prng.random();
        const idx = rand.uintLessThan(u8, 16);
        if (board[idx] == 0) {
            board[idx] = if (rand.boolean()) 2 else 4;
            break;
        }
    }
}

pub fn isGameOver() bool {
    if (!std.mem.containsAtLeast(u16, board[0..], 1, &[_]u16{0})) {
        if (!hasAdjacentEql()) {
            transpose();
            if (!hasAdjacentEql()) {
                return true;
            }
            transpose();
        }
        return false;
    }
    else if(std.mem.containsAtLeast(u16, board[0..], 1, &[_]u16{2048})) {
        return true;
    }
    else {
        return false;
    }
}

var score: u16 = undefined;
var board: [16]u16 = undefined;
var old_board: [16]u16 = undefined;
var prng: std.rand.Xoshiro256 = undefined;

const Direction = enum {
    left,
    right,
};

const Colors = enum(u8) {
    white = 1,
    bold_white,
    cyan,
    bold_cyan,
    magenta,
    bold_magenta,
    blue,
    bold_blue,
    yellow,
    bold_yellow,
    bold_red,

    fn getCode(self: Colors) []const u8 {
        return switch (self) {
            .blue => "\x1B[0;34m",
            .cyan => "\x1B[0;36m",
            .white => "\x1B[0;37m",
            .yellow => "\x1B[0;33m",
            .magenta => "\x1B[0;35m",
            .bold_red => "\x1B[1;31m",
            .bold_blue => "\x1B[1;34m",
            .bold_cyan => "\x1B[1;36m",
            .bold_white => "\x1B[1;37m",
            .bold_yellow => "\x1B[1;33m",
            .bold_magenta => "\x1B[1;35m",
        };
    }
};

fn getColor(n: u16) []const u8 {
    return @intToEnum(Colors, std.math.log2(n)).getCode();
}

fn blanksToEnd(context: Direction, lhs: u16, rhs: u16) bool {
    if (lhs != 0 and rhs != 0) {
        return false;
    } else {
        return switch (context) {
            .left => if (rhs == 0) true else false,
            .right => if (rhs == 0) false else true,
        };
    }
}

fn transpose() void {
    var i: usize = 0;
    while (i < 3) : (i += 1) {
        var j = i + 1;
        while (j < 4) : (j += 1) {
            std.mem.swap(u16, &board[4 * i + j], &board[i + 4 * j]);
        }
    }
}

fn hasAdjacentEql() bool {
    var i: usize = 0;
    while (i < 3) : (i += 1) {
        var j: usize = 0;
        while (j < 3) : (j += 1) {
            if (board[4 * i + j] == board[4 * i + j + 1])
                return true;
        }
    }
    return false;
}

fn reduce(comptime context: Direction, list: []u16) void {
    sort(u16, list, context, blanksToEnd);
    switch (context) {
        .left => {
            var i: u8 = 0;
            while (i < 3) {
                if (list[i] == 0 or list[i] != list[i + 1]) {
                    i += 1;
                } else {
                    list[i] += list[i + 1];
                    list[i + 1] = 0;
                    score += list[i];
                    i += 2;
                }
            }
        },
        .right => {
            var i: u8 = 3;
            while (i > 0) {
                if (list[i] == 0 or list[i] != list[i - 1]) {
                    i -= 1;
                } else {
                    list[i] += list[i - 1];
                    list[i - 1] = 0;
                    score += list[i];
                    if (i < 2) break;
                    i -= 2;
                }
            }
        },
    }
    sort(u16, list, context, blanksToEnd);
}
