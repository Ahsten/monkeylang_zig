pub const Program = struct {
    statements: []const Statement,

    fn tokenLiteral(self: *const Program) []const u8 {
        if(self.statements.len > 0) {
            return self.statements[0].tokenLiteral();
        }

        return "";
    }
};

pub const Expression = union(enum) {
    identifier: Identifier,

    fn tokenLiteral(self: Expression) []const u8 {
        return self.tokenLiteral();
    }
};


pub const Statement = union(enum) {
    letStatement: LetStatement,

    pub fn tokenLiteral(self: Statement) []const u8 {
        return self.tokenLiteral();
    }
};

pub const LetStatement = struct {
    token: Token,
    name: Identifier,
    value: Expression,

    pub fn tokenLiteral(self: *const LetStatement) []const u8 {
        return self.token.literal;
    }
};

pub const Identifier = struct {
    token: Token,
    value: []const u8,
};

const Token = @import("token.zig").Token;
