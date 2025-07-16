//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;


const FileBuffered = struct {
    file: std.fs.File,
    buffered: std.io.BufferedReader(4096, std.fs.File.Reader)
};

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

    fn fileLazyOpener(self: localFile) !FileBuffered {
        var file = try std.fs.cwd().openFile(
            self.filePath,
            .{ .mode = .read_only }
        );

        const fileBuf = std.io.bufferedReader(file.reader());
        
        return FileBuffered {
            .buffered = fileBuf,
            .file = file
        }
    }

    pub fn readFile(
        self: LocalFile,
        allocator: std.mem.Allocator
    ) !std.ArrayList([]u8) {
        var openLazy = try self.fileLazyOpener();
        defer openLazy.file.close();
        var lazyReader = openLazy.buffered.reader();

        var fileContents = std.ArrayList(u8).init(allocator);
        var buf: [1024]u8 = undefined;

        while (true) {
            const line = reader.readUntilDelimiter(
                &buf, '\n') catch |err| switch (err) {
                error.EndOfStream => break,
                else => return err,
            };

            const heapCopy = try allocator.dupe(u8, line);
            fileContents.append(heapCopy)
        };

        return fileContents;
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
