const portio = @import("./portio.zig");
const array = @import("std").ArrayList;
const kb = @import("./kb.zig");

const IDTEntry = struct {
    offset_low: u16,
    selector: u16,
    zero: u8,
    type_attr: u8,
    offset_high: u16,
};

var IDT: [256]IDTEntry = [_]IDTEntry{IDTEntry{ .offset_high = 0, .offset_low = 0, .selector = 0, .type_attr = 0, .zero = 0 }} ** 256;

pub export fn idt_init() void {
    const keyboard_address: usize = @intFromPtr(&kb.kb_irq_handler);
    const idt_address: usize = @intFromPtr(&IDT[0]);
    var idt_ptr: [2]usize = undefined;

    IDT[0x21] = IDTEntry{
        .offset_low = @intCast(keyboard_address),
        .selector = 0x08,
        .zero = 0,
        .type_attr = 0x8E,
        .offset_high = @intCast(keyboard_address >> 16),
    };

    portio.write_port(0x20, 0x11);
    portio.write_port(0xA0, 0x11);

    portio.write_port(0x21, 0x20);
    portio.write_port(0xA1, 0x28);

    portio.write_port(0x21, 0x00);
    portio.write_port(0xA1, 0x00);

    portio.write_port(0x21, 0x01);
    portio.write_port(0xA1, 0x01);

    portio.write_port(0x21, 0xff);
    portio.write_port(0xA1, 0xff);

    idt_ptr[0] = (@sizeOf(IDTEntry) * 256) + ((idt_address & 0xffff) << 16);

    idt_ptr[1] = idt_address >> 16;

    asm volatile ("lidt %0"
        :
        : [ptr] "{edx}" (idt_ptr),
    );
}
