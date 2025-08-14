const std = @import("std");
const testing = std.testing;
const pdf = @import("pdf_reader");


const pdfFile = pdf.localFile{ 
    .filePath = "./examples/learn-to-program-ruby.pdf"
};

const imageFile = pdf.localFile{
    .filePath = "./examples/feather.png"
};


test "pdf: isPdf" {
    const fileType = try pdfFile.isPdf();
    defer std.debug.print("✓ Passed\n", .{});
    try std.testing.expect(std.meta.eql(fileType, true));
}

test "pdf: notPdf" {
    const fileType = try imageFile.isPdf();
    defer std.debug.print("✓ Passed\n", .{});
    try std.testing.expect(std.meta.eql(fileType, false));
}

test "pdf: readPdfFile" {
    defer std.debug.print("✓ Passed\n", .{});
    var lazyFile = try pdfFile.fileLazyOpener();
    defer lazyFile.file.close();
    const reader = lazyFile.buffered.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();
    var fileContents = try pdf.readPdfFile(reader, allocator);

    defer {
        for (fileContents.items) |item| allocator.free(item);
        fileContents.deinit();
    }

    // try std.io.getStdOut().writer().print("{s}\n", .{fileContents.items[0]});

    try std.testing.expect(
        std.mem.eql(u8, fileContents.items[0], "%PDF-1.4")
    );
}
