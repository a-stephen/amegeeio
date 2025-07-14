//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

const LocalFile = struct {
    filePath: []const u8,

    fn init(fileLocation: []u8) LocalFile {
        return PdfFile{
            .filePath: fileLocation
        }
    }

    fn detectFileType() !void {}

    fn fileReader(self: LocalFile) !void {
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
