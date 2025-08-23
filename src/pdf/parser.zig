// Pdf file parser

// I have a sequence of bytes

const std = @import("std");


pub const PdfContentParser = struct {
    fileContent = std.ArrayList([]u8);


    pub fn readData(self) []u8 {
        return self.fileContent.items[0];
    }
}

