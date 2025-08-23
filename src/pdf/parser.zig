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


const token = struct {
    typ: TokenType,
    value: []const u8
}


fn tokenize(allocator: std.mem.Allocator, input: []u8) ![]token {}


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
