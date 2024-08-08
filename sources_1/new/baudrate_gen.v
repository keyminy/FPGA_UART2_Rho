`timescale 1ns / 1ps

module baudrate_gen (
    input  clk,
    input  reset,
    output br_tick
);
    // reg [$clog2(10_416-1):0] r_cnt1, r_cnt2;
    // reg tick_reg, tick_next;
    reg [$clog2(10_416-1):0] my_cnt;
    reg my_tick;

    // assign br_tick = tick_reg;
    assign br_tick = my_tick;

    // 100_000_000 / 9600 = 10,416
    always @(posedge reset or posedge clk) begin
        if (reset) begin
            my_cnt   <= 0;
            my_tick <= 1'b0;
        end else begin
            // if (my_cnt == 10_416 - 1) begin
            if (my_cnt == 20 - 1) begin
                my_cnt = 0;
                my_tick = 1'b1;
            end else begin
                my_cnt = my_cnt + 1;
                my_tick = 1'b0;
            end
        end
    end
    // always @(posedge reset or posedge clk) begin
    //     if (reset) begin
    //         r_cnt1   <= 0;
    //         tick_reg <= 1'b0;
    //     end else begin
    //         r_cnt1   <= r_cnt2;
    //         tick_reg <= tick_next;
    //     end
    // end
    
    // always @(*) begin
    //     r_cnt2 = r_cnt1;
    //     if (r_cnt1 == 10_416 - 1) begin
    //         r_cnt2 = 0;
    //         tick_next = 1'b1;
    //     end else begin
    //         r_cnt2 = r_cnt1 + 1;
    //         tick_next = 1'b0;
    //     end
    // end
endmodule
