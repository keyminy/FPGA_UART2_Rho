`timescale 1ns / 1ps

module top_send_ascii(
    input clk,
    input reset,
    input btn,
    output tx
    );
    wire w_start,w_btn;
    wire [7:0] w_tx_data;

    top_uart u_uart(
    .clk(clk),
    .reset(reset),
    .start(w_start),
    .tx_data(w_tx_data),
    .o_txd(tx),
    .o_tx_done() //none connect
    );

    debounce u_btn(
    .clk(clk),
    .reset(reset),
    .i_btn(btn),
    .o_btn(w_btn)
    );

    ascii_send u_ascii_send(
    .clk(clk),
    .reset(reset),
    .btn(w_btn),
    // output
    .start(w_start),
    .tx_data(w_tx_data)
    );

endmodule

