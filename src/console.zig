const fmt = @import("std").fmt;
const Writer = @import("std").io.Writer;

pub const VGA_WIDTH = 80;
pub const VGA_HEIGHT = 25;
const VGA_SIZE = VGA_WIDTH * VGA_HEIGHT;

pub const Color = enum(u8) {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    Yellow = 14,
    White = 15,
};

var row: usize = 0;
var column: usize = 0;
var color: u16 = 0;
var buffer: [*]u16 = @as([*]u16, @ptrFromInt(0xB8000));

pub fn set_color(fg: Color, bg: Color) void {
    const fgi = @intFromEnum(fg);
    const bgi = @intFromEnum(bg);

    color = @as(u16, fgi | bgi << 4);
}

pub export fn scroll() void {
    for (1..VGA_HEIGHT) |i| {
        for (0..VGA_WIDTH) |j| {
            buffer[(i - 1) * VGA_WIDTH + j] = buffer[i * VGA_WIDTH + j];
        }
    }
    for (0..VGA_WIDTH) |i| {
        buffer[(VGA_HEIGHT - 1) * VGA_WIDTH + i] = 0;
    }
    row = VGA_HEIGHT - 1;
    column = 0;
}

pub export fn clear_screen() void {
    for (0..VGA_SIZE) |i| {
        buffer[i] = 0;
    }
    row = 0;
    column = 0;
}

pub export fn put_char(c: u8) void {
    if (c == '\n') {
        if (row == VGA_HEIGHT - 1) {
            scroll();
        }
        row += 1;
        column = 0;
        return;
    }
    if (c == '\t') {
        column += 4;
        return;
    }
    if (c == '\x08') {
        if (column == 0) {
            if (row > 0) {
                row -= 1;
                column = VGA_WIDTH - 1;
            }
        } else {
            column -= 1;
        }
        buffer[row * VGA_WIDTH + column] = 0;
        return;
    }
    buffer[row * VGA_WIDTH + column] = c | (color << 8);
    column += 1;
    if (column == VGA_WIDTH) {
        row += 1;
        column = 0;
    }
    if (row == VGA_HEIGHT) {
        scroll();
    }
}

pub fn print(s: []const u8) void {
    for (s) |c| {
        put_char(c);
    }
}

const std = @import("std");

pub fn printf(fmt_string: []const u8, args: anytype) void {
    var buf: [256]u8 = undefined; // Adjust the size as needed
    const writer = std.fmt.bufPrint(&buf, fmt_string, args) catch return;
    const formatted_string = writer.toSlice();
    print(formatted_string);
}
