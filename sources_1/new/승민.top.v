`timescale 1ns / 1ps


module top_send_ascii(
    input clk,
    input reset,
    input btn,
    output tx
    );
    wire w_start, w_btn;
    wire [7:0] w_tx_data;
    
top_uart_pf u_top_uart_pf(
    .clk(clk),
    .reset(reset),
    .start(w_start),
    .tx_data(w_tx_data),
    
    .tx_done(),
    .tx(tx)
    );
    
button u_button(
    .clk(clk),
    .reset(reset),
    .i_btn(btn),
    .o_btn(w_btn)
    );        
    
ascii_send(
    .clk(clk),
    .reset(reset),
    .btn(w_btn),
    .start(w_start),
    .tx_data(w_tx_data)
    );
endmodule
