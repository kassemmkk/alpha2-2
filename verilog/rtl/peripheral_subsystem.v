`default_nettype none

module peripheral_subsystem (
    input  wire        clk,
    input  wire        rst_n,
    
    // Wishbone interface
    input  wire        wb_cyc_i,
    input  wire        wb_stb_i,
    input  wire        wb_we_i,
    input  wire [3:0]  wb_sel_i,
    input  wire [31:0] wb_adr_i,
    input  wire [31:0] wb_dat_i,
    output wire        wb_ack_o,
    output wire [31:0] wb_dat_o,
    
    // Interrupt outputs
    output wire [3:0]  irq,
    
    // SPI Master 0 interface
    input  wire        spi0_miso,
    output wire        spi0_mosi,
    output wire        spi0_csb,
    output wire        spi0_sclk,
    
    // SPI Master 1 interface  
    input  wire        spi1_miso,
    output wire        spi1_mosi,
    output wire        spi1_csb,
    output wire        spi1_sclk,
    
    // I2C interface
    input  wire        i2c_scl_i,
    output wire        i2c_scl_o,
    output wire        i2c_scl_oen_o,
    input  wire        i2c_sda_i,
    output wire        i2c_sda_o,
    output wire        i2c_sda_oen_o,
    
    // GPIO interface (2 pins)
    input  wire [1:0]  gpio_in,
    output wire [1:0]  gpio_out,
    output wire [1:0]  gpio_oe
);

    // Address decoding
    // SPI0: 0x3000_0000 - 0x3000_0FFF
    // SPI1: 0x3000_0800 - 0x3000_0FFF  
    // I2C:  0x3000_1000 - 0x3000_1FFF
    // GPIO: 0x3000_2000 - 0x3000_2FFF
    
    wire spi0_sel = wb_cyc_i && wb_stb_i && (wb_adr_i[31:12] == 20'h30000) && (wb_adr_i[11] == 1'b0);
    wire spi1_sel = wb_cyc_i && wb_stb_i && (wb_adr_i[31:12] == 20'h30000) && (wb_adr_i[11] == 1'b1);
    wire i2c_sel  = wb_cyc_i && wb_stb_i && (wb_adr_i[31:12] == 20'h30001);
    wire gpio_sel = wb_cyc_i && wb_stb_i && (wb_adr_i[31:12] == 20'h30002);
    
    // Wishbone signals for each peripheral
    wire        spi0_ack, spi1_ack, i2c_ack, gpio_ack;
    wire [31:0] spi0_dat_o, spi1_dat_o, i2c_dat_o, gpio_dat_o;
    wire        spi0_irq, spi1_irq, i2c_irq, gpio_irq;
    
    // Output multiplexing
    assign wb_ack_o = spi0_ack | spi1_ack | i2c_ack | gpio_ack;
    assign wb_dat_o = ({32{spi0_sel}} & spi0_dat_o) |
                      ({32{spi1_sel}} & spi1_dat_o) |
                      ({32{i2c_sel}}  & i2c_dat_o)  |
                      ({32{gpio_sel}} & gpio_dat_o);
    
    assign irq = {gpio_irq, i2c_irq, spi1_irq, spi0_irq};
    
    // SPI Master 0
    CF_SPI_WB #(
        .CDW(8),
        .FAW(4)
    ) spi0_inst (
        .clk_i(clk),
        .rst_i(~rst_n),
        .adr_i(wb_adr_i),
        .dat_i(wb_dat_i),
        .dat_o(spi0_dat_o),
        .sel_i(wb_sel_i),
        .cyc_i(spi0_sel),
        .stb_i(spi0_sel),
        .ack_o(spi0_ack),
        .we_i(wb_we_i),
        .IRQ(spi0_irq),
        .miso(spi0_miso),
        .mosi(spi0_mosi),
        .csb(spi0_csb),
        .sclk(spi0_sclk)
    );
    
    // SPI Master 1
    CF_SPI_WB #(
        .CDW(8),
        .FAW(4)
    ) spi1_inst (
        .clk_i(clk),
        .rst_i(~rst_n),
        .adr_i(wb_adr_i),
        .dat_i(wb_dat_i),
        .dat_o(spi1_dat_o),
        .sel_i(wb_sel_i),
        .cyc_i(spi1_sel),
        .stb_i(spi1_sel),
        .ack_o(spi1_ack),
        .we_i(wb_we_i),
        .IRQ(spi1_irq),
        .miso(spi1_miso),
        .mosi(spi1_mosi),
        .csb(spi1_csb),
        .sclk(spi1_sclk)
    );
    
    // I2C Controller
    EF_I2C_WB #(
        .DEFAULT_PRESCALE(1),
        .FIXED_PRESCALE(0),
        .CMD_FIFO(1),
        .CMD_FIFO_DEPTH(16),
        .WRITE_FIFO(1),
        .WRITE_FIFO_DEPTH(16),
        .READ_FIFO(1),
        .READ_FIFO_DEPTH(16)
    ) i2c_inst (
        .clk_i(clk),
        .rst_i(~rst_n),
        .adr_i(wb_adr_i),
        .dat_i(wb_dat_i),
        .dat_o(i2c_dat_o),
        .sel_i(wb_sel_i),
        .cyc_i(i2c_sel),
        .stb_i(i2c_sel),
        .ack_o(i2c_ack),
        .we_i(wb_we_i),
        .IRQ(i2c_irq),
        .scl_i(i2c_scl_i),
        .scl_o(i2c_scl_o),
        .scl_oen_o(i2c_scl_oen_o),
        .sda_i(i2c_sda_i),
        .sda_o(i2c_sda_o),
        .sda_oen_o(i2c_sda_oen_o)
    );
    
    // GPIO Controller (2 pins with edge-detect interrupts)
    // We'll use a subset of the 8-pin GPIO controller
    wire [7:0] gpio_in_extended = {6'b0, gpio_in};
    wire [7:0] gpio_out_extended;
    wire [7:0] gpio_oe_extended;
    
    assign gpio_out = gpio_out_extended[1:0];
    assign gpio_oe = gpio_oe_extended[1:0];
    
    EF_GPIO8_WB gpio_inst (
        .ext_clk(clk),
        .clk_i(clk),
        .rst_i(~rst_n),
        .adr_i(wb_adr_i),
        .dat_i(wb_dat_i),
        .dat_o(gpio_dat_o),
        .sel_i(wb_sel_i),
        .cyc_i(gpio_sel),
        .stb_i(gpio_sel),
        .ack_o(gpio_ack),
        .we_i(wb_we_i),
        .IRQ(gpio_irq),
        .io_in(gpio_in_extended),
        .io_out(gpio_out_extended),
        .io_oe(gpio_oe_extended)
    );
    
    // GPIO interrupt is generated from the GPIO controller's interrupt logic

endmodule

`default_nettype wire