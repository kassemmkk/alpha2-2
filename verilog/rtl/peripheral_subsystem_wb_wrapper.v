`default_nettype none

module peripheral_subsystem_wb_wrapper (
`ifdef USE_POWER_PINS
    inout VPWR,
    inout VGND,
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,
    
    // Interrupt outputs
    output [3:0] irq,
    
    // SPI Master 0 interface
    input  wire spi0_miso,
    output wire spi0_mosi,
    output wire spi0_csb,
    output wire spi0_sclk,
    
    // SPI Master 1 interface  
    input  wire spi1_miso,
    output wire spi1_mosi,
    output wire spi1_csb,
    output wire spi1_sclk,
    
    // I2C interface
    input  wire i2c_scl_i,
    output wire i2c_scl_o,
    output wire i2c_scl_oen_o,
    input  wire i2c_sda_i,
    output wire i2c_sda_o,
    output wire i2c_sda_oen_o,
    
    // GPIO interface (2 pins)
    input  wire [1:0] gpio_in,
    output wire [1:0] gpio_out,
    output wire [1:0] gpio_oe
);

    peripheral_subsystem peripheral_subsystem_inst (
        .clk(wb_clk_i),
        .rst_n(~wb_rst_i),
        
        // Wishbone interface
        .wb_cyc_i(wbs_cyc_i),
        .wb_stb_i(wbs_stb_i),
        .wb_we_i(wbs_we_i),
        .wb_sel_i(wbs_sel_i),
        .wb_adr_i(wbs_adr_i),
        .wb_dat_i(wbs_dat_i),
        .wb_ack_o(wbs_ack_o),
        .wb_dat_o(wbs_dat_o),
        
        // Interrupt outputs
        .irq(irq),
        
        // SPI Master 0 interface
        .spi0_miso(spi0_miso),
        .spi0_mosi(spi0_mosi),
        .spi0_csb(spi0_csb),
        .spi0_sclk(spi0_sclk),
        
        // SPI Master 1 interface  
        .spi1_miso(spi1_miso),
        .spi1_mosi(spi1_mosi),
        .spi1_csb(spi1_csb),
        .spi1_sclk(spi1_sclk),
        
        // I2C interface
        .i2c_scl_i(i2c_scl_i),
        .i2c_scl_o(i2c_scl_o),
        .i2c_scl_oen_o(i2c_scl_oen_o),
        .i2c_sda_i(i2c_sda_i),
        .i2c_sda_o(i2c_sda_o),
        .i2c_sda_oen_o(i2c_sda_oen_o),
        
        // GPIO interface (2 pins)
        .gpio_in(gpio_in),
        .gpio_out(gpio_out),
        .gpio_oe(gpio_oe)
    );

endmodule

`default_nettype wire