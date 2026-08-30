const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;
const TokenType = @import("token.zig").Token.TokenType;

pub fn start(reader: *std.Io.Reader, writer: *std.Io.Writer) !void {
    while (true) {
        try writer.print(">> ", .{});
        try writer.flush();

        while(try reader.takeDelimiter('\n')) |line| {
            var lexer = Lexer.init(line);

            
            var token = lexer.nextToken(); 
            while (token.kind != TokenType.eof) {
                try writer.print("Type: {any}, Literal: {s}\n", .{ token.kind, token.literal });
                try writer.flush();

                token = lexer.nextToken();
            }
            try writer.print(">> ", .{});
            try writer.flush();
        }
    }
}
