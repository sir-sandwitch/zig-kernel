pub export fn write_port(port: u16, value: u8) void {
    asm volatile ("outb %0, %1"
        :
        : [value] "dx" (value),
          [port] "al" (port),
    );
}

pub export fn read_port(port: u16) u8 {
    return asm volatile ("inb %1, %0"
        : [ret] "={al}" (-> u8),
        : [port] "{dx}" (port),
    );
}
