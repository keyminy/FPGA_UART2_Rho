`timescale 1ns / 1ps

module ascii_send(
    input           clk,
    input           reset,
    input           btn,
    output          start,
    output  [7:0]   tx_data
    );
    parameter IDLE = 1'b0, TX = 1'b1;

    reg state,next_state;
    reg start_reg,start_next;
    reg [7:0] a_data_reg, a_data_next;

    // 3. output 신호
    assign start=start_reg;
    assign tx_data=a_data_reg;

   //1.state var register
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= IDLE;
            a_data_reg <= 8'h30; // '0' ascii code 0x30
            start_reg <= 1'b0;
        end else begin
            state <= next_state;
            a_data_reg <= a_data_next;
            start_reg <= start_next;
        end
    end

     // 2.next state combinational logic
    always @(*) begin
        next_state <= state;
        start_next <= start_reg;
        a_data_next <= a_data_reg;
        case(state)
            IDLE: begin
                start_next = 1'b0;
                if(btn == 1'b1) begin
                    start_next = 1'b1;
                    next_state = TX;
                end
            end
            TX: begin
                start_next = 1'b1; // start신호 전송추가
                a_data_next = a_data_reg + 1;
                next_state = IDLE;
            end
        endcase
    end

endmodule
