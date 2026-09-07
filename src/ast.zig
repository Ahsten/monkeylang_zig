pub const Program = struct {
    statements: []const Statement,

    fn tokenLiteral(self: *const Program) []const u8 {
        if(self.statements.len > 0) {
            return self.statements[0].tokenLiteral();
        }

        return "";
    }

    pub fn string(self: *const Program, writer: *std.Io.Writer) ![]const u8 {
        for(self.statements) |stmt| {
            try stmt.string(writer);
        }
    }
};

pub const Expression = union(enum) {
    identifier: Identifier,

    fn tokenLiteral(self: Expression) []const u8 {
        return self.tokenLiteral();
    }
};


pub const Statement = union(enum) {
    let_statement: LetStatement,
    return_statement: ReturnStatement,

    pub fn tokenLiteral(self: Statement) []const u8 {
        return self.tokenLiteral();
    }

    pub fn string(self: Statement, writer: *std.Io.Writer) ![]const u8 {
        for(self.statements) |stmt| {
            try stmt.string(writer);
        }
    }
};

pub const LetStatement = struct {
    token: Token,
    name: Identifier,
    value: Expression,

    pub fn tokenLiteral(self: *const LetStatement) []const u8 {
        return self.token.literal;
    }
    
    pub fn string(self: *const LetStatement, writer: *std.Io.Writer) !void {
        try writer.writeAll(self.tokenLiteral());
        try writer.writeByte(' ');
        try self.name.string(writer);
        try writer.writeAll(" = ");
        try self.value.string(writer);
        try writer.writeByte(';');
    }
};

pub const ReturnStatement = struct {
    token: Token,
    return_value: Expression,

    pub fn tokenLiteral(self: *const Expression) []const u8 {
        return self.token.literal;
    }

    pub fn string(self: *const ReturnStatement, writer: *std.Io.Writer) !void {
        try writer.writeAll(self.tokenLiteral());
        try writer.writeByte(' ');
        try self.return_value.string(writer);
        try writer.writeByte(';');
    }
};

pub const ExpressionStatement = struct {
    token: Token,
    expression: Expression,

    pub fn tokenLiteral(self: *const Expression) []const u8 {
        return self.token.literal;
    }

    pub fn string(self: *const ExpressionStatement, writer: *std.Io.Writer) !void {
        try self.expression.string(writer);
    }
};

pub const Identifier = struct {
    token: Token,
    value: []const u8,

    pub fn string(self: *const Identifier, writer: std.Io.Writer) !void {
        try writer.writeAll(self.value);
    }
};

const Token = @import("token.zig").Token;
const std = @import("std");
