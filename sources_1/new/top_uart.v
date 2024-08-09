`timescale 1ns / 1ps

module top_uart(
    input clk,
    input reset,
    input start,
    input [7:0] tx_data,
    output o_txd,
    output o_done
    );

    wire w_br_tick;

    baudrate_generator u_baud_gen(
        .clk(clk),
        .reset(reset),
        .br_tick(w_br_tick)
    );

    transmitter u_tarnsmitter(
        .clk(clk),
        .reset(reset),
        .br_tick(w_br_tick),
        .start(start),
        .tx_data(tx_data),
        // output
        .tx(o_txd),
        .tx_done(o_done)
    );
endmodule

module baudrate_generator(
    input clk,
    input reset,
    output br_tick
);
    reg [$clog2(100_000_000)-1:0] r_counter;
    reg r_tick;
    assign br_tick = r_tick;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_counter <= 0;
            r_tick <= 1'b0;
        end else begin
            // 1bps : 100_000_000 - 1
            // 10bps : 10_000_000 - 1 (0을 1개 제거), 1초에 10클럭 발생
            // 100bps : 1_000_000 - 1 (0을 2개 제거), 1초에 100클럭 발생
            // 100bps의 의미 : 100_000_000/100 해준 값임.
            // if(r_counter == 100_000_000/9600 - 1) begin
            if(r_counter == 10 - 1) begin
                r_counter <= 0;
                r_tick <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                r_tick <= 1'b0;       
            end
        end
    end
endmodule

module transmitter (
    input clk,
    input reset,
    input br_tick,
    input [7:0] tx_data,
    input start,
    output tx_done,
    output tx
);
    reg [3:0] state,next_state;
    reg tx_reg, tx_next,tx_done_reg,tx_done_next;
    reg [7:0] temp_data_reg,temp_data_next;
    
    parameter IDLE_S = 4'd0;
    parameter START_S = 4'd1;
    parameter D0_S = 4'd2, D1_S = 4'd3, D2_S = 4'd4, D3_S = 4'd5, D4_S = 4'd6, D5_S = 4'd7, D6_S = 4'd8, D7_S = 4'd9;
    parameter STOP_S = 4'd10;
    //3.output combinational logic
    assign tx = tx_reg;
    assign tx_done = tx_done_reg;

    //1.state var register
    always @(posedge clk,posedge reset) begin
        if(reset) begin
            state <= IDLE_S;
            tx_reg <= 1'b0;
            tx_done_reg <= 1'b0;
            temp_data_reg <= 0;
        end else begin
            state <= next_state;
            tx_reg <= tx_next;
            tx_done_reg <= tx_done_next;
            temp_data_reg <= temp_data_next;
        end
    end

    // 2.next state combinational logic
    always @(*) begin
        next_state = state; // latch를 막기위함
        tx_next = tx_reg;
        tx_done_next = tx_done_reg;
        temp_data_next = temp_data_reg;
        case(state)
            IDLE_S: begin
                // tx=1,done=0
                tx_next = 1'b1;
                tx_done_next = 1'b0;
                if(start == 1'b1) begin
                    // data의 next state에 값 저장 "latching"한다고 한다.
                    temp_data_next = tx_data;
                    next_state = START_S;
                end
            end
            START_S: begin
                tx_next = 1'b0;
                if(br_tick) next_state = D0_S;  //br_tick이 들어오지 않으면, next_state = state;로 자기자신(start) 유지!!!
            end
            D0_S: begin
                tx_next = temp_data_next[0];
                if(br_tick) next_state = D1_S;
            end
            D1_S: begin
                tx_next = temp_data_next[1];
                if(br_tick) next_state = D2_S;
            end
            D2_S: begin
                tx_next = temp_data_next[2];
                if(br_tick) next_state = D3_S;
            end
            D3_S: begin
                tx_next = temp_data_next[3];
                if(br_tick) next_state = D4_S;
            end
            D4_S: begin
                tx_next = temp_data_next[4];
                if(br_tick) next_state = D5_S;
            end
            D5_S: begin
                tx_next = temp_data_next[5];
                if(br_tick) next_state = D6_S;
            end
            D6_S: begin
                tx_next = temp_data_next[6];
                if(br_tick) next_state = D7_S;
            end
            D7_S: begin
                tx_next = temp_data_next[7];
                if(br_tick) next_state = STOP_S;
            end
            STOP_S: begin
                tx_next = 1'b1;
                if(br_tick) begin
                    next_state = IDLE_S;
                    tx_done_next = 1'b1;
                end
            end
        endcase
    end
    
endmodule