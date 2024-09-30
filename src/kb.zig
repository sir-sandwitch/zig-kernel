const portio = @import("./portio.zig");
const kb_map = @import("./kb_map.zig");
const console = @import("./console.zig");

pub export fn kb_init() void {
    portio.write_port(0x21, 0xFD);
}

pub export fn kb_handler() void {
    const scancode = portio.read_port(0x60);
    portio.write_port(0x20, 0x20);
    if (scancode == 0x01) {
        // Escape key
        return;
    }
    const char = kb_map.scancode_to_char(scancode);
    console.put_char(char);
}

pub export fn kb_irq_handler() void {
    kb_handler();
    asm volatile ("iret");
}
