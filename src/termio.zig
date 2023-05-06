const std = @import("std");
const C = @cImport({
    @cInclude("signal.h");
    @cInclude("sys/select.h");
});

var original_tio: std.c.termios = undefined;

pub const signal = C.signal;
pub const sigint = C.SIGINT;

pub fn handleInterrupt(sig: c_int) callconv(.C) void {
    _ = sig;
    restoreInputBuffering();
    _ = std.io.getStdOut().write("Exit\n") catch unreachable;
    std.c.exit(-2);
}

pub fn disableInputBuffering() void {
    _ = std.c.tcgetattr(std.os.STDIN_FILENO, &original_tio);
    var new_tio: std.c.termios = original_tio;
    new_tio.lflag &= (~std.c.ICANON & ~std.c.ECHO);
    _ = std.c.tcsetattr(std.os.STDIN_FILENO, std.c.TCSA.NOW, &new_tio);
}

pub fn restoreInputBuffering() void {
    _ = std.c.tcsetattr(std.os.STDIN_FILENO, std.c.TCSA.NOW, &original_tio);
}

pub fn getKey() u8 {
    while (true) {
        if (kbhit()) {
            return std.io.getStdIn().reader().readByte() catch unreachable;
        }
    }
}

fn kbhit() bool {
    var read_fds: C.fd_set = undefined;
    @memset(&read_fds.fds_bits, 0);
    C.FD_SET(std.os.STDIN_FILENO, &read_fds);

    var timeout: C.timeval = undefined;
    timeout.tv_sec = 0;
    timeout.tv_usec = 0;
    return C.select(1, &read_fds, null, null, &timeout) != 0;
}
