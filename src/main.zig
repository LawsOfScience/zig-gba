const DMA = @import("dma.zig");
const VID = @import("vid.zig");

export fn main() noreturn {
    const display = VID.Display.new();
    display.*.control = .{ .mode = .Mode3, .background = .Bg2 };

    const dma = DMA.DmaController.new();

    // So now that there's two color variables
    // and they're used in this kind of demo,
    // Zig won't optimize them out on Release
    // optimization? Weird
    var color = VID.Color.RED;
    var black = VID.Color.BLACK;
    // const thing: *volatile u16 = @ptrFromInt(0x0300_7EFC);
    // thing.* = 31;

    const size = 10;

    var row: i16 = 0;
    var col: i16 = 0;
    var oldrow: i16 = row;
    var oldcol: i16 = col;
    var rowchange: i16 = 1;
    var colchange: i16 = 1;

    while (true) {
        oldrow = row;
        oldcol = col;

        row += rowchange;
        col += colchange;

        if (row < 0) {
            row = 0;
            rowchange = -rowchange;
        } else if (row > (VID.SCREEN_HEIGHT - size)) {
            row = VID.SCREEN_HEIGHT - size;
            rowchange = -rowchange;
        }

        if (col < 0) {
            col = 0;
            colchange = -colchange;
        } else if (col > (VID.SCREEN_WIDTH - size)) {
            col = VID.SCREEN_WIDTH - size;
            colchange = -colchange;
        }

        VID.waitForVBlank();

        for (0..size) |i| {
            dma[3].src = &black;
            dma[3].dst = (VID.VIDEO_BUFFER + (240 * (i + @as(usize, @intCast(oldrow)))) + @as(usize, @intCast(oldcol)));
            dma[3].cnt = .{ .count = size, .src_ctl = .Fixed, .enable = true };
        }

        for (0..size) |i| {
            dma[3].src = &color;
            dma[3].dst = (VID.VIDEO_BUFFER + (240 * (i + @as(usize, @intCast(row)))) + @as(usize, @intCast(col)));
            dma[3].cnt = .{ .count = size, .src_ctl = .Fixed, .enable = true };
        }
    }

    // Let these comments serve as a testament to my suffering
    // while trying to make DMA work for mode 3 drawing
    //
    // const iwram_place: *volatile usize = @ptrFromInt(0x03000004);
    // // const dma2: [*]volatile DmaController = @ptrFromInt(0x0400_00B0);
    // // var color2: u16 = 42069;
    // // dma2[3].src = @constCast(&color2);
    // // dma2[3].dst = VID;
    // // dma2[3].cnt = .{ .count = 10 };
    // var one: u32 = 1;
    // var two: u32 = 2;
    // var three = one + two;
    // if (three == 3) {
    //     DISPCNT.* = MODE_3 | BG2;
    // }
    // one = 2;
    // two = 1;
    // iwram_place.* = @intFromPtr(&three);

    // while (true) {}

    // needs to be var and not const
    // so that DMA can read it right
    // (werid)
    // const green = Color.GREEN;
    // const red = Color.RED;
    // const blue = Color.BLUE;

    // for (0..10) |i| {
    //     dma_draw(@intFromPtr(VID + ((i + 30) * 240) + 10), red, 10 | 2 << 23 | 1 << 31);
    //     dma_draw(@intFromPtr(VID + ((i + 10) * 240) + 10), green, 10 | 2 << 23 | 1 << 31);
    //     dma_draw(@intFromPtr(VID + ((i + 10) * 240) + 30), blue, 10 | 2 << 23 | 1 << 31);
    // }

    // while (true) {
    //     DMA3_SRC.* = &RED;
    //     DMA3_DST.* = @ptrFromInt(0x0600_0000);
    //     DMA3_CNT.* = 10 | 2 << 23 | 1 << 31;
    // }
}

// Might use in the future
// inline fn dma_draw(dest: u32, color: Color, ctl: u32) void {
//     asm volatile (
//         \\str %[c],     [%[src]]
//         \\str %[vid],   [%[dst]]
//         \\str %[ctl],   [%[cnt]]
//         :
//         : [c] "r" (&color),
//           [src] "r" (DMA3_SRC),
//           [vid] "r" (dest),
//           [dst] "r" (DMA3_DST),
//           [ctl] "r" (ctl),
//           [cnt] "r" (DMA3_CNT),
//     );
// }

export fn _start() linksection(".gba_crt0") callconv(.Naked) noreturn {
    asm volatile (
    // == Zig Runtime 0 (zrt0)
    // Code inspired from a few places, see
    // the source of c_boot.ld and
    // GBA From Scratch with Ferris
        \\.arm
        \\.cpu arm7tdmi
        //
        // No need to enable thumb mode since
        // the Zig builder seems to pre-enable it
        //
        // -- Header skip
        \\b header_end
        \\.space 0xE0
        \\header_end:
        // -- Multiboot jazz (unused)
        \\b start_vector
        \\.byte 0
        \\.byte 0
        \\.fill 26, 1, 0
        \\.word 0
        \\.align
        // -- Start Vector
        \\start_vector:
        // Go to main
        \\mov r0, #0
        \\mov r1, #0
        \\ldr r2, =main
        \\bx r2
        // Emergency soft reset if main returns
        \\swi #0x00
    );
}
