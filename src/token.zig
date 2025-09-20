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
        keyword_function,
        keyword_let,
        minus,
        bang,
        asterisk,
        slash,
        less_than,
        greater_than,
        keyword_true,
        keyword_false,
        keyword_if,
        keyword_else,
        keyword_return,
        
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
