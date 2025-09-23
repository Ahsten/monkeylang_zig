const std = @import("std");
const monkeylang = @import("monkeylang");
const repl = @import("repl.zig");

var stdin_buffer: [1024]u8 = undefined;
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
var stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
const stdin = &stdin_reader.interface;
const stdout = &stdout_writer.interface;

pub fn main() !void {
    try stdout.writeAll("Hello! This is the Monkey programming language\n");
    try stdout.flush();
    try stdout.writeAll("Feel free to type in commands\n");
    try stdout.flush();

    try repl.start(stdin, stdout);
}
