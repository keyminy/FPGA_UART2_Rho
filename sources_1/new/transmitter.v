`timescale 1ns / 1ps

module transmitter(
    input clk,
    input reset,
    input br_tick,
    input startSignal,
    input [7:0] data,
    output tx
);

    localparam  IDLE = 0 , START = 1,STOP = 10;
    localparam D0=2,D1=3,D2=4,D3=5,D4=6,D5=7,D6=8,D7=9;

    reg [3:0] state, state_next;
    reg [7:0] r_data;
    reg tx_reg, tx_next;

    assign tx = tx_reg;

    // 1. state register
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= IDLE;
            tx_reg <= 1'b0;
        end else begin
            state <= state_next;
            tx_reg <= tx_next;
        end
    end
    // 2.next state Combi logic
    always @(*) begin
        state_next <= state;
        case (state)
            IDLE:begin
                if(startSignal) begin
                    state_next <= START;
                end
                // else begin
                //     state_next <= IDLE;
                // end
            end 
            START:if(br_tick) state_next <= D0;
            D0:if(br_tick) state_next <= D1;
            D1:if(br_tick) state_next <= D2;
            D2:if(br_tick) state_next <= D3;
            D3:if(br_tick) state_next <= D4;
            D4:if(br_tick) state_next <= D5;
            D5:if(br_tick) state_next <= D6;
            D6:if(br_tick) state_next <= D7;
            D7:if(br_tick) state_next <= STOP;
            STOP:if(br_tick) state_next <= IDLE;
        endcase
    end
    // 3.output Combi logic
    always @(*) begin
        tx_next = tx_reg;
        case (state)
            IDLE:tx_next = 1'b1;
            START:begin
                tx_next = 1'b0;
                r_data  = data;
            end
            D0:tx_next = r_data[0];
            D1:tx_next = r_data[1];
            D2:tx_next = r_data[2];
            D3:tx_next = r_data[3];
            D4:tx_next = r_data[4];
            D5:tx_next = r_data[5];
            D6:tx_next = r_data[6];
            D7:tx_next = r_data[7];
            STOP:tx_next = 1;            
        endcase
    end


endmodule
