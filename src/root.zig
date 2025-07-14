//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

const localFile = struct {
    filePath: []const u8,

    fn init(fileLocation: []u8) localFile {
        return PdfFile{
            .filePath: fileLocation
        }
    }

    fn detectFileType(self: localFile) ![]const u8 {
        var file = try std.fs.cwd().openFile(self.filePath, .{.mode = .read_only });
        defer file.close;

        var firstLine= std.ArrayList(u8).init(std.heap.page_allocator);
        defer firstLine.deinit();

        var fileBuf = std.io.bufferedReader(file.reader());
        var fileStream = fileBuf.reader();
        
        try reader.streamUntilDelimiter(firstLine.writer(), '\n', null);
        if (std.mem.startsWith(u8, firstLine.items, "%PDF")) {
            return "PDF"
        } else {
            return "unknownType"
        }

    }

    fn readFile(self: localFile) !void {
        var file = try std.fs.cwd().openFile(file_path, .{.mode = .read_only });
        defer file.close();

        var fileBuf = std.io.bufferedReader(file.reader());
        var in_stream = fileBuf.reader();

        const stdout = std.io.getStdOut().writer();

        var buf: [1024]u8 = undefined;
        while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            try stdout.print("{s}\n", .{line});
        }
    }
}
