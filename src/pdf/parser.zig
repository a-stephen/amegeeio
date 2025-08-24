// Pdf file parser

// I have a sequence of bytes

const std = @import("std");


fn joinSlices(allocator: std.mem.Allocator, contents: std.ArrayList([]u8)) ![]u8 {
    var content_len: usize = 0;
    for (contents.items) |item| {
        content_len += item.len;
    }

    var joined = try allocator.alloc(u8, content_len);
    
    var offset: usize = 0;
    for (contents.items) |item| {
        @memcpy(joined[offset..offset + item.len], item);
        offset += item.len;
    }

    return joined;
}


const TokenType = enum {
    Keyword,
    Delimiter,
    Name,
    StringLiteral,
    HexString,
    Number,
    Comment,
    EOF,
    Unknown,
};


const Token = struct {
    typ: TokenType,
    value: []const u8
};


pub fn tokenize(allocator: std.mem.Allocator, input: []u8) ![]Token {
    var tokens: std.ArrayList(Token) = std.ArrayList(Token).init(allocator);

    var i: usize = 0;
    while (i < input.len) {
        const c = input[i];

        if (std.ascii.isWhitespace(c)) {
            try std.io.getStdOut().writer().print("{c}\n", .{c});
            i += 1;
            continue;
        }

        if (c == '%') {
            i += 1;
            while (i < input.len and input[i] != '\n') : (i += 1) {}
            continue;
        }

        if (std.ascii.isDigit(c) or c == '-' or c == '+') {
            const start = i;
            i += 1;
            while (i < input.len and (std.ascii.isDigit(input[i]) or input[i] == '.')) : (i += 1) {}
            try tokens.append(Token{ .typ = .Number, .value = input[start..i] });
            continue;
        }

        if (c == '(' or c == ')' or c == '[' or c == ']' or c == '<' or c == '>' or c == '/' or c == '{' or c == '}') {
            try tokens.append(Token{ .typ = .Delimiter, .value = input[i..i+1] });
            i += 1;
            continue;
        }

        if (c == '/') {
            const start = i;
            i += 1;
            while (i < input.len and !std.ascii.isWhitespace(input[i]) and !isDelimiter(input[i])) : (i += 1) {}
            try tokens.append(Token{ .typ = .Name, .value = input[start..i] });
            continue;
        }

        // Tokenize keywords and identifiers
        if (std.ascii.isAlphabetic(c)) {
            const start = i;
            i += 1;
            while (i < input.len and (std.ascii.isAlphabetic(input[i]) or std.ascii.isDigit(input[i]))) : (i += 1) {}
            const val = input[start..i];
            try tokens.append(Token{ .typ = .Keyword, .value = val });
            continue;
        }

        // If none matched, append unknown token
        try tokens.append(Token{ .typ = .Unknown, .value = input[i..i+1] });
        i += 1;
    }

    try tokens.append(Token{ .typ = .EOF, .value = "" });
    return tokens.toOwnedSlice();
}


fn isDelimiter(c: u8) bool {
    return switch (c) {
        '(', ')', '[', ']', '<', '>', '/', '{', '}' => true,
        else => false,
    };
}


pub const PdfContentParser = struct {
    fileContent: std.ArrayList([]u8),

    fn init(fileContent: std.ArrayList([]u8)) PdfContentParser {
        return PdfContentParser {
            .fileContent = fileContent
        };
    }

    pub fn readData(self: PdfContentParser, allocator: std.mem.Allocator) ![]u8 {
        return try joinSlices(allocator, self.fileContent);
    }
};
