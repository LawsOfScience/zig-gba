const DMA_START_ADDR: *usize = @ptrFromInt(0x0400_00B0);

/// Struct representing the DMA control register
pub const DmaCtl = packed struct {
    count: u16 = 0,
    big_blank: u5 = 0,
    dst_ctl: u2 = 0,
    src_ctl: u2 = 2,
    repeat: u1 = 0,
    chunk_size: u1 = 0,
    small_blank: u1 = 0,
    timing_mode: u2 = 0,
    irq: u1 = 0,
    enable: u1 = 1,
};

/// Struct representing a DMA controller
pub const DmaController = extern struct {
    src: *volatile anyopaque,
    dst: *volatile anyopaque,
    cnt: DmaCtl,

    /// Creates a new DmaController.
    /// Returns a reference to *all* DMA controller channels.
    /// Index into the returned pointer to access the channel
    /// you want (e.g. dma[3] for channel 3).
    pub fn new() [*]volatile DmaController {
        return @ptrCast(DMA_START_ADDR);
    }
};
