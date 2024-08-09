`timescale 1ns / 1ps

module receiver(
    input       clk,
    input       reset,
    input       rx,
    input       br_tick,
    output [7:0] rx_data,
    output       rx_done
    );

    reg [3:0] state,next_state;
    // reg rx_reg,rx_reg_next;
    reg rx_done_reg,rx_done_reg_next;
    reg [7:0] temp_data,temp_data_next;
    reg [7:0] rx_data_reg,rx_data_reg_next;
    reg [3:0] tick_cnt_reg,tick_cnt_next; // 16번 sampling용도로 셈
    reg [2:0] bit_cnt_reg,bit_cnt_next;//8개,3빗

    // 3. output combinational logic
    assign rx_done = rx_done_reg;
    // TODO assign rx_data
    assign rx_data = rx_data_reg;

    localparam IDLE_S = 4'd0;
    localparam START_S = 4'd1;
    localparam DATA_S = 4'd2;
    localparam STOP_S = 4'd3;

    // 1. STATE,VAR register
    always @(posedge clk,posedge reset) begin
        if(reset) begin
            state <= IDLE_S;
            tick_cnt_reg <= 0;
            bit_cnt_reg <= 0;
            temp_data <= 0;
            rx_done_reg <= 0;
            // rx_reg<=0;
            rx_data_reg <= 0;
        end else begin
            state <= next_state;
            tick_cnt_reg <= tick_cnt_next;
            bit_cnt_reg <= bit_cnt_next;
            temp_data <= temp_data_next;
            // rx_reg <= rx_reg_next;
            rx_done_reg <= rx_done_reg_next;
            rx_data_reg <= rx_data_reg_next;
        end
    end

    // 2.next state combinational logic
    always @(*) begin
        next_state = state;
        // rx_reg_next = rx_reg;
        rx_done_reg_next = rx_done_reg;
        temp_data_next = temp_data;
        rx_data_reg_next = rx_data_reg;
        tick_cnt_next = tick_cnt_reg;
        bit_cnt_next = bit_cnt_reg;
        case(state)
        IDLE_S : begin
            rx_done_reg_next = 1'b0;
            if(rx == 1'b0) begin
                next_state = START_S;
                tick_cnt_reg = 0;
                bit_cnt_reg = 0;
            end
        end
        START_S: begin
            if(br_tick) begin
                if(tick_cnt_reg == 7) begin
                    next_state = DATA_S;
                    tick_cnt_next = 0;
                end else begin
                    tick_cnt_next = tick_cnt_reg + 1;
                end
            end
        end
        DATA_S : begin
            if(br_tick) begin
                if(tick_cnt_reg == 15) begin
                    tick_cnt_next = 0;
                    if(bit_cnt_reg == 7) begin
                        next_state = STOP_S;
                        bit_cnt_next = 0;
                        rx_data_reg_next = temp_data_next;
                    end else begin
                        temp_data_next = {rx,temp_data_next[7:1]};
                        bit_cnt_next = bit_cnt_reg + 1;
                    end
                end else begin
                    tick_cnt_next = tick_cnt_reg + 1;
                end
            end
        end
        STOP_S : begin
            if(br_tick) begin
                if(tick_cnt_reg == 7) begin
                    rx_done_reg_next = 1'b1;
                    tick_cnt_next = 0;
                    next_state = IDLE_S;
                end else begin
                    tick_cnt_next = tick_cnt_reg + 1;
                end
            end
        end
        endcase
    end


endmodule
