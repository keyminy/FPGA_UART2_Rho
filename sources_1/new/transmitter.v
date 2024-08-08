`timescale 1ns / 1ps

module transmitter(
    input clk,
    input reset,
    input br_tick,
    input startSignal,
    input [7:0] i_data,
    output tx
);
    localparam IDLE = 0 , START = 1;
    localparam D0=2,D1=3,D2=4,D3=5,D4=6,D5=7,D6=8,D7=9;
    localparam STOP = 10;

    reg [3:0] state, state_next;
    reg [7:0] tx_data;
    reg [7:0] r_data;

    assign tx = tx_data;

    // 1. state control register
    always @(posedge reset or posedge clk) begin
        if(reset) begin
            state <= IDLE;
        end else begin
            state <= state_next;
        end
    end

    // 2. next state combinational
    always @(*) begin
        state_next <= state;
        case (state)
            IDLE: if(br_tick) state_next <= START;
            START: if(br_tick) state_next <= D0;
            D0: if(br_tick) state_next <= D1;
            D1: if(br_tick) state_next <= D2;
            D2: if(br_tick) state_next <= D3;
            D3: if(br_tick) state_next <= D4;
            D4: if(br_tick) state_next <= D5;
            D5: if(br_tick) state_next <= D6;
            D6: if(br_tick) state_next <= D7;
            D7: if(br_tick) state_next <= STOP;
            STOP: if(br_tick) state_next <= IDLE;
        endcase
    end

    // 3. output control combinational
    always @(*) begin
        case(state)
            IDLE: tx_data = 1'b1;
            START: begin
                // set data
                r_data = i_data;
                tx_data = 1'b0;
            end
            D0: tx_data = r_data[0];
            D1: tx_data = r_data[1];
            D2: tx_data = r_data[2];
            D3: tx_data = r_data[3];
            D4: tx_data = r_data[4];
            D5: tx_data = r_data[5];
            D6: tx_data = r_data[6];
            D7: tx_data = r_data[7];
            STOP: tx_data = 1'b1;
        endcase
    end
endmodule
