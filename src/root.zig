//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const pdf = @import("pdf/pdf.zig");


pub fn main() !void {
    const localPdfFile = pdf.localFile{
        .filePath = "../examples/learn-to-program-ruby.pdf"
    };

   const fileType =  try localPdfFile.isPdf();

   std.debug.print("The file at location {s} {}ly a pdf!\n", .{localPdfFile.filePath}, .{fileType});
}
