//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

const BufferedFileReader = struct {
    buffered: std.io.BufferedReader(4096, std.fs.File.Reader),
    file: std.fs.File,
};

const localFile = struct {
    filePath: []const u8,

    fn init(fileLocation: []u8) localFile {
        return localFile{
            .filePath = fileLocation,
        };
    }

    pub fn detectFileType(self: localFile) ![]const u8 {
        var readerStruct = try self.readFile();
        var reader = readerStruct.reader();
        
        // Declare a fixbuffer
        var buf: [1024]u8 = undefined;
        const line = try reader.readUntilDelimiter(
            &buf, '\n'
        );
        if (std.mem.startsWith(u8, line, "%PDF")) {
            return "PDF";
        } else {
            return "unknownType";
        }
    }

    fn readFile(self: localFile) !std.io.BufferedReader(
        4096, std.fs.File.Reader) {
        var file = try std.fs.cwd().openFile(
            self.filePath,
            .{ .mode = .read_only }
        );
        defer file.close();

        const fileBuf = std.io.bufferedReader(file.reader());
        
        return fileBuf;
    }
};

// === Tests ===
test "detect file type" {
    var fileLocal = localFile{
        .filePath = "/home/adjignon/Downloads/learn-to-program-ruby.pdf"
    };
    const fileType = try fileLocal.detectFileType();
    try std.testing.expect(std.mem.eql(u8, fileType, "PDF"));
}
