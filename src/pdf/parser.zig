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


pub const PdfContentParser = struct {
    fileContent: std.ArrayList([]u8),

    fn init(fileContent: std.ArrayList([]u8)) PdfContentParser {
        return PdfContentParser {
            .fileContent = fileContent
        };
    }

    pub fn readData(self: PdfContentParser) ![]u8 {
        var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
        defer _ = gpa.deinit();
        
        const allocator = gpa.allocator();

        const fullContent = try joinSlices(allocator, self.fileContent);

        // defer allocator.free(fullContent);

        return fullContent;
    }
};
