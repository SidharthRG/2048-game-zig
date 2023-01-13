const std = @import("std");
const tio = @import("termio.zig");
const game = @import("lib2048.zig");

const stdout = std.io.getStdOut().writer();

pub fn main() !void {

    // Handle interrupts (Ctrl-C)
    _ = tio.signal(tio.sigint, tio.handleInterrupt);

    // Disable buffering
    tio.disableInputBuffering();

    outer: while (true) {
        // Initialize the game board
        game.init();

        // Run the game
        inner: while (true) {
            try game.printBoard();

            const char = tio.getKey();
            const valid = switch (char) {
                'i', 'w' => game.reduceUp(),
                'j', 'a' => game.reduceLeft(),
                'k', 's' => game.reduceDown(),
                'l', 'd' => game.reduceRight(),
                else => continue :inner,
            };
            
            if (game.isGameOver()) {
                try stdout.print("Game Over!\n", .{});
                break :inner;
            }
            
            if (valid) {
                game.addNext();
            }
        }

        // Check if the user wants to play again
        try stdout.print("Do you want to play again? (y/n) ", .{});
        const choice = tio.getKey();
        switch (choice) {
            'y', 'Y' => continue :outer,
            else => break :outer,
        }
    }

    // Restore buffering
    tio.restoreInputBuffering();
}
