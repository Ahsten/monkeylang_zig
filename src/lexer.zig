const std = @import("std");
const Tokens = @import("token.zig");
const Token = Tokens.Token;
const TokenType = Tokens.Token.TokenType;

pub const Lexer = struct {
    input: []const u8,
    position: usize = 0,
    readPosition: usize = 0,
    ch: u8 = 0,

    pub fn init(input: []const u8) Lexer {
        var lexer = Lexer{
            .input = input,
        };
        lexer.readChar();
        return lexer;
    }

    pub fn readChar(self: *Lexer) void {
        if (self.readPosition >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.readPosition];
        }
        self.position = self.readPosition;
        self.readPosition += 1;
    }

    fn getCurrentString(self: *Lexer) []const u8 {
        if (self.readPosition <= self.input.len) {
            return self.input[self.position..self.readPosition];
        } else {
            return "0";
        }
    }

    fn isLetter(self: *Lexer) bool {
        return (self.ch >= 'a' and self.ch <= 'z') or (self.ch >= 'A' and self.ch <= 'Z') or self.ch == '_';
    }

    fn isDigit(self: *Lexer) bool {
        return std.ascii.isDigit(self.ch);
    }

    fn readIdentifier(self: *Lexer) []const u8 {
        const startPosition = self.position;
        while (self.isLetter()) {
            self.readChar();
        }
        return self.input[startPosition..self.position];
    }

    fn readInteger(self: *Lexer) []const u8 {
        const startPosition = self.position;
        while (self.isDigit()) {
            self.readChar();
        }
        return self.input[startPosition..self.position];
    }

    fn skipWhitespace(self: *Lexer) void {
        while (std.ascii.isWhitespace(self.ch)) {
            self.readChar();
        }
    }

    pub fn nextToken(self: *Lexer) Token {
        self.skipWhitespace();
        const chars = self.getCurrentString(); 
        var token: Token = Token.init(chars, TokenType.illegal);

        switch (self.ch) {
            '=' => token.kind = TokenType.assign,
            '+' => token.kind = TokenType.plus,
            ';' => token.kind = TokenType.semicolon,
            ',' => token.kind = TokenType.comma,
            '{' => token.kind = TokenType.l_brace,
            '}' => token.kind = TokenType.r_brace,
            '(' => token.kind = TokenType.l_paren,
            ')' => token.kind = TokenType.r_paren,
            0 => token.kind = TokenType.eof,
            'a'...'z', 'A'...'Z', '_' => {
                const identifer = self.readIdentifier();
                token.literal = identifer;
                token.kind = Token.lookupIdent(identifer);
                return token;
            },
            '0'...'9' => {
                const int = self.readInteger();
                token.kind = TokenType.int;
                token.literal = int;
                return token;
            },
            else => unreachable,
        }

        self.readChar();
        return token;
    }
};

// Tests

const expectEqual = std.testing.expectEqual;

fn compareTokens(expected: Token, actual: Token) bool {
    return expected.kind == actual.kind and std.mem.eql(u8, expected.literal, actual.literal);
}

test "nextToken" {
    const input = "=+(){},;";
    const expected_tokenTypes = [_]Token.TokenType{ .assign, .plus, .l_paren, .r_paren, .l_brace, .r_brace, .comma, .semicolon };

    var lexer = Lexer.init(input);

    for (expected_tokenTypes) |tt| {
        const token = lexer.nextToken();
        try expectEqual(tt, token.kind);
    }
}

test "keywords and identifiers" {
    const input = 
    \\let five = 5;
    \\let ten = 10;
    \\let add = fn(x, y){
    \\x+y;
    \\};
    \\let result = add(five, ten);
;
    const expected_tokens = [_]Token{
        Token.init("let", TokenType.let),
        Token.init("five", TokenType.ident),
        Token.init("=", TokenType.assign),
        Token.init("5", TokenType.int),
        Token.init(";", TokenType.semicolon),
        Token.init("let", TokenType.let),
        Token.init("ten", TokenType.ident),
        Token.init("=", TokenType.assign),
        Token.init("10", TokenType.int),
        Token.init(";", TokenType.semicolon),
        Token.init("let", TokenType.let),
        Token.init("add", TokenType.ident),
        Token.init("=", TokenType.assign),
        Token.init("fn", TokenType.function),
        Token.init("(", TokenType.l_paren),
        Token.init("x", TokenType.ident),
        Token.init(",", TokenType.comma),
        Token.init("y", TokenType.ident),
        Token.init(")", TokenType.r_paren),
        Token.init("{", TokenType.l_brace),
        Token.init("x", TokenType.ident),
        Token.init("+", TokenType.plus),
        Token.init("y", TokenType.ident),
        Token.init(";", TokenType.semicolon),
        Token.init("}", TokenType.r_brace),
        Token.init(";", TokenType.semicolon),
        Token.init("let", TokenType.let),
        Token.init("result", TokenType.ident),
        Token.init("=", TokenType.assign),
        Token.init("add", TokenType.ident),
        Token.init("(", TokenType.l_paren),
        Token.init("five", TokenType.ident),
        Token.init(",", TokenType.comma),
        Token.init("ten", TokenType.ident),
        Token.init(")", TokenType.r_paren),
        Token.init(";", TokenType.semicolon),
        Token.init("0", TokenType.eof)
    };

    var lexer = Lexer.init(input);

    for (expected_tokens, 0..) |expected, i| {
        const actual = lexer.nextToken();
        errdefer {
            std.debug.print("{d} | Expected {s}, got {s}\n", .{ i, expected.literal, actual.literal });
        }
        try std.testing.expect(compareTokens(expected, actual));
    }
}
