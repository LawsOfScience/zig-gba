pub const SCREEN_HEIGHT: comptime_int = 160;
pub const SCREEN_WIDTH: comptime_int = 240;
pub const VIDEO_BUFFER: [*]volatile u16 = @ptrFromInt(0x0600_0000);

const DISPLAY_CONTROL: *u16 = @ptrFromInt(0x0400_0000);
const SCANLINE_CNT: *volatile u16 = @ptrFromInt(0x0400_0006);

pub const Color = enum(u16) {
    RED = 31,
    GREEN = 31 << 5,
    BLUE = 31 << 10,
    BLACK = 0,
};


pub const Display = extern struct {
    control: DisplayControl,

    pub fn new() *Display {
        return @ptrCast(DISPLAY_CONTROL);
    }
};

pub const DisplayControl = packed struct {
    mode: DisplayMode = .Mode0,
    is_cartrige: bool = false,
    page_select: u1 = 0,
    oam_hblank_access: bool = false,
    object_mapping_mode: u1 = 0,
    force_blank: bool = false,
    background: Background = .Bg0,
    window_control: WindowControl = .None,
};

pub const DisplayMode = enum(u3) {
    Mode0 = 0,
    Mode1 = 1,
    Mode2 = 2,
    Mode3 = 3,
    Mode4 = 4,
    Mode5 = 5,
};

pub const Background = enum(u5) {
    Bg0 = 1 << 0,
    Bg1 = 1 << 1,
    Bg2 = 1 << 2,
    Bg3 = 1 << 3,
    Obj = 1 << 4,
};

pub const WindowControl = enum(u3) {
    None = 0b000,
    Window0 = 1 << 0,
    Window1 = 1 << 1,
    ObjectWindow = 1 << 2,
};

pub fn waitForVBlank() void {
    while (SCANLINE_CNT.* > 160) {}
    while (SCANLINE_CNT.* < 160) {}
}
