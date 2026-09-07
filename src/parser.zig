const Parser = struct {
    lexer: *Lexer,
    cur_token: Token,
    peek_token: Token,
    errors: std.ArrayList([]const u8),
    alloctor: Allocator,

    pub fn init(lexer: *Lexer, allocator: Allocator) Parser {
        var parser = Parser{
            .lexer = lexer,
            .cur_token = undefined,
            .peek_token = undefined,
            .errors = .empty,
            .allocator = allocator,
        };

        parser.nextToken();
        parser.nextToken();

        return parser;
    }

    fn nextToken(self: *Parser) void {
        self.cur_token = self.peek_token;
        self.peek_token = self.lexer.nextToken();
    }

    pub fn parseProgram(self: *Parser, alloc: Allocator) !ast.Program {
        var statements = std.ArrayListUnmanaged(ast.Statement).empty;

        while (!self.curTokenIs(.eof)) {
            if (self.parseStatement()) |stmt| try statements.append(alloc, stmt);
            self.nextToken();
        }

        return ast.Program{ .statements = try statements.toOwnedSlice(alloc) };
    }

    fn parseStatement(self: *Parser) !ast.Statement {
        return switch (self.cur_token.kind) {
            .keyword_let => self.parseLetStatement(),
            .keyword_return => self.parseReturnStatement(),
            else => unreachable,
        };
    }

    fn parseLetStatement(self: *Parser) ast.Statement {
        const let_token = self.cur_token;

        if (try self.expectPeek(.ident)) {
            return error.UnexpectedToken;
        }

        const name = ast.Identifier{
            .token = self.cur_token,
            .value = self.cur_token.literal,
        };

        if (try self.expectPeek(.assign)) {
            try self.peekError(.assign);
        }

        // TODO: parse expressions

        while (!self.curTokenIs(.semicolon)) {
            return error.UnexpectedToken;
        }

        return ast.LetStatement{
            .token = let_token,
            .name = name,
            .value = undefined,
        };
    }

    fn parseReturnStatement(self: *Parser) !ast.Statement {
        const return_token = self.cur_token;

        self.nextToken();

        // TODO: parse expression
        while(!self.curTokenIs(.semicolon)) {
            self.nextToken();
        }
         
        return ast.ReturnStatement{
            .token = return_token,
            .value = undefined,
        };
    }

    fn curTokenIs(self: *Parser, token_type: tokenType) bool {
        return self.cur_token.kind == token_type;
    }

    fn peekTokenIs(self: *Parser, token_type: tokenType) bool {
        return self.peek_token.kind == token_type;
    }

    fn expectPeek(self: *Parser, token_type: tokenType) !bool {
        if (self.peekTokenIs(token_type)) {
            self.nextToken();
            return true;
        } else {
            try self.peekError(token_type);
            return false;
        }
    }

    fn peekError(self: *Parser, token_type: tokenType) !void {
        var buf: [100]u8 = undefined;
        const message = std.fmt.bufPrint(&buf, 
            "expected next token to be {}, got {} instead", 
            .{ token_type, self.peek_token.kind },
        );

        try self.errors.append(self.alloctor, message);
    }
};

// Tests
test "let statements" {
    const input =
        \\let x = 5;
        \\let y = 10;
        \\let foobar = 838383;
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
const Expression = ast.Expression;
const Token = @import("token.zig").Token;
const tokenType = Token.TokenType;
