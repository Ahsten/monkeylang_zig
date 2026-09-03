const Parser = struct {
    lexer: *Lexer,
    curToken: Token,
    peekToken: Token,

    pub fn init(lexer: *Lexer) Parser {
        var parser = Parser{
            .lexer = lexer,
            .curToken = undefined,
            .peekToken = undefined,
        };

        parser.nextToken();
        parser.nextToken();

        return parser;
    }

    fn nextToken(self: *Parser) void {
        self.curToken = self.peekToken;
        self.peekToken = self.lexer.nextToken();
    }

    pub fn parseProgram(self: *Parser, alloc: Allocator) !ast.Program {
        var list = std.ArrayListUnmanaged(ast.Statement).empty;

        while (self.curToken.kind != .eof) {
            if (self.parseStatement()) |stmt| {
                try list.append(alloc, stmt);
            }

            self.nextToken();
        }

        return ast.Program{ .statements = try list.toOwnedSlice(alloc) };
    }

    fn parseStatement(self: *Parser) ?ast.Statement {
        return switch (self.curToken.kind) {
            .keyword_let => self.parseLetStatement(),
            else => null,
        };
    }

    fn parseLetStatement(self: *Parser) ?ast.Statement {
        const let_token = self.curToken;

        if (self.expectPeek(.ident)) {
            return null;
        }

        const name = ast.Identifier{
            .token = self.curToken,
            .value = self.curToken.literal,
        };

        if (self.expectPeek(.assign)) {
            return null;
        }

        // TODO: parse expressions

        while (!self.curTokenIs(.semicolon)) {
            self.nextToken();
        }

        return ast.LetStatement{
            .token = let_token,
            .name = name,
            .value = "test",
        };
    }

    fn curTokenIs(self: *Parser, token_type: tokenType) bool {
        return self.curToken.kind == token_type;
    }

    fn peekTokenIs(self: *Parser, token_type: tokenType) bool {
        return self.peekToken.kind == token_type;
    }

    fn expectPeek(self: *Parser, token_type: tokenType) bool {
        if (self.peekTokenIs(token_type)) {
            self.nextToken();
            return true;
        } else {
            return false;
        }
    }
};

// Tests
test "let statements" {
    const input =
        \\let x = 5;
        \\let y = 10;
        \\let foobar = 838383
    ;

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    var lexer = Lexer.init(input);
    var parser = Parser.init(&lexer);

    const program = try parser.parseProgram(arena.allocator());

    const expected_idents = [_][]const u8{ "x", "y", "foobar" };

    for (expected_idents, 0..) |ident, i| {
        const stmt = program.statements[i];

        try std.testing.expectEqualStrings("let", stmt.tokenLiteral());

        const letStmt = stmt.letStatement;
        try std.testing.expectEqual(ident, letStmt.name.value);

        try std.testing.expectEqualStrings(ident, letStmt.name.tokenLiteral());
    }
}

const std = @import("std");
const Allocator = std.mem.Allocator;
const Lexer = @import("lexer.zig").Lexer;
const ast = @import("ast.zig");
const Token = @import("token.zig").Token;
const tokenType = Token.TokenType;
