`timescale 1ns / 1ps

module tb_uart();
    reg clk;
    reg reset;
    reg startSignal;
    reg [7:0] tx_data;
    wire tx_done;
    wire txd;
    reg rx;
    wire [7:0] rx_data;
    wire rx_done;
    wire w_loop;

    top_uart dut_top_uart(
        // globla signal
    .clk(clk),
    .reset(reset),
    .start(startSignal),
    // tx signal
    .tx_data(tx_data),
    .o_txd(w_loop),
    .o_tx_done(tx_done),
    // rx signal
    .rx(w_loop),
    .rx_data(rx_data),
    .o_rx_done(rx_done)
    );

    // gen clk
    always #5 clk = ~clk; // clk period = 10ns

    initial begin
        #00 clk = 0; reset = 1; 
        startSignal = 0; tx_data=0;
        #10 reset = 0;
        #50 tx_data=8'h01; startSignal = 1;
        # 10 startSignal = 0;
        @(rx_done);
        if(tx_data == rx_data)
        $display("PASS! : tx_data : %h,rx_data : %h",tx_data,rx_data);
        else
        $display("FAIL! : tx_data : %h, rx_data : %h",tx_data,rx_data);

        #50 tx_data = 8'haa;   startSignal = 1'b1;
        #10 startSignal = 1'b0;
        @(rx_done);
        if(tx_data == rx_data)
        $display("PASS! : tx_data : %h,rx_data : %h",tx_data,rx_data);
        else
        $display("FAIL! : tx_data : %h, rx_data : %h",tx_data,rx_data);
        @(posedge tx_done);

        #10 $finish;
    end
endmodule