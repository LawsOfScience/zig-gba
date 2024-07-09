const DMA_START_ADDR: *usize = @ptrFromInt(0x0400_00B0);

/// Struct representing a DMA controller
pub const DmaController = extern struct {
    src: *volatile anyopaque,
    dst: *volatile anyopaque,
    cnt: DmaControl,

    /// Creates a new DmaController.
    /// Returns a reference to *all* DMA controller channels.
    /// Index into the returned pointer to access the channel
    /// you want (e.g. dma[3] for channel 3).
    pub fn new() [*]volatile DmaController {
        return @ptrCast(DMA_START_ADDR);
    }
};

/// Struct representing the DMA control register
pub const DmaControl = packed struct {
    count: u16,  // Left blank to require input
    big_blank: u5 = 0,
    dst_ctl: DestAdjustment = .Increment,
    src_ctl: SourceAdjustment = .Increment,
    repeat: bool = false,
    chunk_size: ChunkSize = .Halfword,
    small_blank: u1 = 0,
    timing_mode: TimingMode = .Now,
    irq: bool = false,
    enable: bool = false,
};

pub const DestAdjustment = enum(u2) {
    Increment = 0,
    Decrement = 1,
    Fixed = 2,
    Reload = 3,
};

pub const SourceAdjustment = enum(u2) {
    Increment = 0,
    Decrement = 1,
    Fixed = 2,
};

pub const ChunkSize = enum(u1) {
    Halfword = 0,
    Word = 1,
};

pub const TimingMode = enum(u2) {
    Now = 0,
    AtVBlank = 1,
    AtHBlank = 2,
    // AtRefresh isn't used according to TONC?
};
