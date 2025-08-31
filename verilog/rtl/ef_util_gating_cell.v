`default_nettype none

// Simple wrapper to map ef_util_gating_cell to ef_gating_cell
module ef_util_gating_cell (
    `ifdef USE_POWER_PINS
    input   wire    vpwr,
    input   wire    vgnd,
    `endif // USE_POWER_PINS
    input   wire    clk,
    input   wire    rst_n,
    input   wire    clk_en,
    output  wire    clk_o
);

    ef_gating_cell gating_cell_inst (
        `ifdef USE_POWER_PINS
        .vpwr(vpwr),
        .vgnd(vgnd),
        `endif
        .clk(clk),
        .rst_n(rst_n),
        .clk_en(clk_en),
        .clk_o(clk_o)
    );

endmodule

`default_nettype wire