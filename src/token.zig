const std = @import("std");

pub const Token = struct {
    kind: TokenType,
    literal: []const u8,

    pub fn init(literal: []const u8, kind: TokenType) Token {
        return Token{
            .literal = literal,
            .kind = kind,
        };
    }

    pub const TokenType = enum {
        illegal,
        eof,
        ident,
        int,
        assign,
        plus,
        comma,
        semicolon,
        l_paren,
        r_paren,
        l_brace,
        r_brace,
        function,
        let,
    };

    pub const keywords = std.StaticStringMap(TokenType).initComptime(.{
        .{"fn", .function},
        .{"let", .let},
    });

    pub fn getKeyword(string: []const u8) ?TokenType {
        return keywords.get(string);
    }

    pub fn lookupIdent(string: []const u8) TokenType {
        const tokenType = keywords.get(string);
        if(tokenType) |tt|{
            return tt;
        }
        return TokenType.ident;
    }
};


const expectEqual = std.testing.expectEqual;

test "get keyword" {
    const keyword = Token.keywords.get("let");
    try expectEqual(Token.TokenType.let, keyword);
}
