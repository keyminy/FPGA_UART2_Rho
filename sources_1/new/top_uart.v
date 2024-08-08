`timescale 1ns / 1ps


module top_uart(
    input clk,
    input reset,
    input startSignal,
    input [7:0] tx_data,
    output txd
    );

    wire w_br_tick;

    baudrate_gen u_buadrate_gen(
    .clk(clk),
    .reset(reset),
    .br_tick(w_br_tick)
    );

    transmitter u_transmitter(
    .clk(clk),
    .reset(reset),
    .br_tick(w_br_tick),
    .startSignal(startSignal),
    .data(tx_data),
    // output
    .tx(txd)
);
endmodule
