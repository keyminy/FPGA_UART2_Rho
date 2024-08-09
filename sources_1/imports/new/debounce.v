`timescale 1ns / 1ps

module debounce(
    input clk,
    input reset,
    input i_btn,
    output o_btn
    );

    // 1kHz pulse
    // 100_000번 세기
    reg pls_1k;
    reg [$clog2(100_000)-1:0] r_counter;
    reg [3:0] shiftReg;
    reg [1:0] edgeReg;
    wire w_shift;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_counter <= 0;
            pls_1k <= 1'b0;
        end else begin
//            if(r_counter == 100_000 -1) begin // board
             if(r_counter == 2 -1) begin // for simulation
                r_counter <= 0;
                pls_1k <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                pls_1k <= 1'b0;
            end
        end
    end
    //pls_1k
    always @(posedge pls_1k or posedge reset) begin
        if(reset) begin
            shiftReg <= 0;
        end else begin
            shiftReg <= {i_btn,shiftReg[3:1]};
        end
    end

    assign w_shift = &shiftReg;

    always@(posedge clk or posedge reset) begin
        if(reset) begin
            edgeReg <= 0;
        end else begin
            edgeReg[0] <= w_shift;
            edgeReg[1] <= edgeReg[0];
        end
    end

    assign o_btn = edgeReg[0] & ~edgeReg[1];

endmodule
