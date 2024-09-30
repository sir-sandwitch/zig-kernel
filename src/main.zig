const console = @import("./console.zig");
const idt = @import("./idt.zig");
const kb = @import("./kb.zig");

const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const MAGIC = 0x1BADB002;
const FLAGS = ALIGN | MEMINFO;

const MultibootHeader = packed struct {
    magic: i32 = MAGIC,
    flags: i32,
    checksum: i32,
    padding: u32 = 0,
};

export var multiboot align(4) linksection(".multiboot") = MultibootHeader{
    .flags = FLAGS,
    .checksum = -(MAGIC + FLAGS),
};

export var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined;
const stack_bytes_slice = stack_bytes[0..];

export fn _start() callconv(.Naked) noreturn {
    asm volatile (
        \\ movl %[stk], %esp
        \\ movl %esp, %ebp
        \\ call kmain
        :
        : [stk] "{ecx}" (@intFromPtr(&stack_bytes_slice) + @sizeOf(@TypeOf(stack_bytes_slice))),
    );
    while (true) {}
}

export fn kmain() void {
    console.clear_screen();
    console.set_color(console.Color.White, console.Color.Blue);
    console.print("Hello, World!\n");
    console.set_color(console.Color.White, console.Color.Black);
    console.print("This is a simple Kernel written in Zig!\n");
    console.print("It supports scrolling and color changes.\n");

    console.print("Initializing IDT... ");
    idt.idt_init();
    console.set_color(console.Color.Green, console.Color.Black);
    console.print("OK\n");

    console.set_color(console.Color.White, console.Color.Black);
    console.print("Initializing Keyboard... ");
    kb.kb_init();
    console.set_color(console.Color.Green, console.Color.Black);
    console.print("OK\n");

    console.set_color(console.Color.White, console.Color.Black);
    console.print("Try typing something!\n");

    while (true) {
        // do nothing
    }
}
