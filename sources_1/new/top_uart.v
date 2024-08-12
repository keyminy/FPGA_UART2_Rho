`timescale 1ns / 1ps

module top_uart(
    input clk,
    input reset,
    input rx,
    output tx
    );

    wire w_rx_done;
    wire [7:0] w_rx_data;

    uart_idk u_uart_idk(
        // globla signal
        .clk(clk),
        .reset(reset),
        // tx signal
        .start(w_rx_done),
        .tx_data(w_rx_data),
        .o_txd(tx),
        .o_tx_done(), // no connect
        // rx signal
        .rx(rx),
        .o_rx_data(w_rx_data),
        .o_rx_done(w_rx_done)
    );
endmodule
