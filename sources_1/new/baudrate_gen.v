`timescale 1ns / 1ps

module baudrate_gen (
    input  clk,
    input  reset,
    output br_tick
);
    reg [$clog2(10_416-1):0] my_cnt;
    reg my_tick;

    assign br_tick = my_tick;

    // 100_000_000 / 9600 = 10,416
    always@(posedge reset or posedge clk) begin
        if(reset == 1) begin
            my_tick <= 1'b0;
            my_cnt <= 1'b0;
        end else begin
            // if(my_cnt == 10_416 -1) begin
            if(my_cnt == 10 -1) begin
                my_tick <= 1'b1;
                my_cnt <= 1'b0;
            end else begin
                my_cnt <= my_cnt + 1'b1;
                my_tick <= 1'b0;
            end
        end
    end

endmodule
