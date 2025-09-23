const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;
const TokenType = @import("token.zig").Token.TokenType;

pub fn start(reader: *std.io.Reader, writer: *std.io.Writer) !void {
    while (true) {
        try writer.writeAll(">> ");
        try writer.flush();

        const line = try reader.takeDelimiterExclusive('\n');

        var lexer = Lexer.init(line);

        var token = lexer.nextToken();
        while (token.kind != TokenType.eof) {
            try writer.print("Type: {any}, Literal: {s}\n", .{ token.kind, token.literal });
            try writer.flush();

            token = lexer.nextToken();
        }
    }
}
