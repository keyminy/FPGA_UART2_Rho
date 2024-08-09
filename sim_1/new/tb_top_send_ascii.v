`timescale 1ns / 1ps


module tb_top_send_ascii();
    reg clk;
    reg reset;
    reg btn;
    wire tx;

    top_send_ascii dut_top_send_ascii(
    .clk(clk),
    .reset(reset),
    .btn(btn),
    .tx(tx)
    );

    // gen clk
    always #5 clk = ~clk; // clk period = 10ns

    initial begin
        #00 clk = 0; reset = 1; 
        startSignal = 0; tx_data=0;
        #10 reset = 0;
        #10 tx_data=8'b10100011; btn = 1;
        #10 btn = 0;


        #10 $finish;
    end

endmodule
