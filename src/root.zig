//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;


const FileBuffered = struct {
    file: std.fs.File,
    buffered: std.io.BufferedReader(4096, std.fs.File.Reader)
};

fn joinBytes(allocator: std.mem.Allocator, bytes: []const u8) ![]u8 {
    var result = std.ArrayList(u8).init(allocator);
    defer result.deinit();
    for (bytes) |byte| try result.append(byte);
    return result.toOwnedSlice();
}

fn readPdfFile(
    reader: anytype,
    allocator: std.mem.Allocator
) !std.ArrayList([]u8) {
    var fileContents = std.ArrayList([]u8).init(allocator);

    while (true) {
        var line_buf = std.ArrayList(u8).init(allocator);
        defer line_buf.deinit();
        reader.streamUntilDelimiter(
            line_buf.writer(), '\n', null
        ) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        const jBytes = try joinBytes(allocator, line_buf.items);
        // defer allocator.free(jBytes);
        // const heapCopy: []u8 = try allocator.dupe(u8, line_buf.items);
        try fileContents.append(jBytes);
    }

    return fileContents;
} 

const localFile = struct {
    filePath: []const u8,

    fn init(fileLocation: []u8) localFile {
        return localFile{
            .filePath = fileLocation,
        };
    }

    pub fn isPdf(self: localFile) !bool {
        var openLazy = try self.fileLazyOpener();
        var reader = openLazy.buffered.reader();
        defer openLazy.file.close();
        // Declare a fixbuffer
        var buf: [1024]u8 = undefined;
        const line = try reader.readUntilDelimiter(
            &buf, '\n'
        );
        // Check if the buf content starts with PDF
        if (std.mem.startsWith(u8, line, "%PDF")) {
            return true;
        } else {
            return false;
        }
    }

    pub fn fileLazyOpener(self: localFile) !FileBuffered {
        var file = try std.fs.cwd().openFile(
            self.filePath,
            .{ .mode = .read_only }
        );

        const fileBuf = std.io.bufferedReader(file.reader());
        
        return FileBuffered {
            .buffered = fileBuf,
            .file = file
        };
    }
};



// === Tests ===
test "isPdf" {
    var fileLocal = localFile{
        .filePath = "../learn-to-program-ruby.pdf"
    };
    const fileType = try fileLocal.isPdf();
    try std.testing.expect(std.meta.eql(fileType, true));
}

test "readPdfFile" {
    var fileLocal = localFile{
        .filePath = "../learn-to-program-ruby.pdf"
    };
   
    var lazyFile = try fileLocal.fileLazyOpener();
    defer lazyFile.file.close();
    const reader = lazyFile.buffered.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();
    var fileContents = try readPdfFile(reader, allocator);

    defer {
        for (fileContents.items) |item| allocator.free(item);
        fileContents.deinit();
    }

    // try std.io.getStdOut().writer().print("{s}\n", .{fileContents.items[0]});

    try std.testing.expect(
        std.mem.eql(u8, fileContents.items[0], "%PDF-1.4")
    );
}
