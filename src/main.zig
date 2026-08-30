const std = @import("std");
const monkeylang = @import("monkeylang");
const repl = @import("repl.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    var stdin_buffer: [1024]u8 = undefined;
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(io, &stdout_buffer);
    var stdin_reader = std.Io.File.stdin().reader(io, &stdin_buffer);
    const stdin = &stdin_reader.interface;
    const stdout = &stdout_writer.interface;

    try stdout.writeAll("Hello! This is the Monkey programming language\n");
    try stdout.flush();
    try stdout.writeAll("Feel free to type in commands\n");
    try stdout.flush();

    try repl.start(stdin, stdout);
}
