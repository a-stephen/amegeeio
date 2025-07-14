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

    pub fn detectFileType(self: localFile) ![]const u8 {
        var reader = self.readFile();
        var firstLine= std.ArrayList(u8).init(std.heap.page_allocator);
        defer firstLine.deinit();
        if (std.mem.startsWith(u8, firstLine.items, "%PDF")) {
            return "PDF"
        } else {
            return "unknownType"
        }
    }

    fn readFile(self: localFile) !std.io.GenericReader {
        var file = try std.fs.cwd().openFile(file_path, .{.mode = .read_only });
        defer file.close();

        var fileBuf = std.io.bufferedReader(file.reader());
        
        return fileBuf.reader();
    }
}
