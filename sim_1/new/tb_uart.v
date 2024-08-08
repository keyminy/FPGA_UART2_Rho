`timescale 1ns / 1ps

module tb_uart();
    reg clk;
    reg reset;
    reg startSignal;
    reg [7:0] tx_data;
    wire txd;

    top_uart dut_top_uart(
    .clk(clk),
    .reset(reset),
    .startSignal(startSignal),
    .tx_data(tx_data),
    .txd(txd)
    );

    // gen clk
    always #5 clk = ~clk; // clk period = 10ns

    initial begin
        #00 clk = 0; reset = 1; startSignal = 0; tx_data=8'b10100011;
        #10 reset = 0;
        #30 startSignal = 1;
        #35 startSignal = 0;
        #350 $finish;
    end
endmodule
