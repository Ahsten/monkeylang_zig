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
        asterisk,
        assign,
        bang,
        comma,
        eof,
        equal_equal,
        not_equal,
        greater_equal,
        less_equal,
        greater_than,
        illegal,
        ident,
        int,
        less_than,
        minus,
        plus,
        semicolon,
        slash,
        l_paren,
        r_paren,
        l_brace,
        r_brace,
        keyword_true,
        keyword_false,
        keyword_if,
        keyword_else,
        keyword_return,
        keyword_function,
        keyword_let,
    };

    pub const keywords = std.StaticStringMap(TokenType).initComptime(.{
        .{"fn", .keyword_function},
        .{"let", .keyword_let},
        .{"true", .keyword_true},
        .{"false", .keyword_false},
        .{"if", .keyword_if},
        .{"else", .keyword_else},
        .{"return", .keyword_return},
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
    try expectEqual(Token.TokenType.keyword_let, keyword);
}
