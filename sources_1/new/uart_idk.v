`timescale 1ns / 1ps

module uart_idk(
    // global signal
    input clk,
    input reset,
    // transmitter signal
    input start,
    input [7:0] tx_data,
    output o_tx_done,
    output o_txd,
    // receiver signal
    input rx,
    output [7:0] o_rx_data,
    output o_rx_done
    );

    wire w_br_tick;
    // wire internal_rx;

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
        .tx_done(o_tx_done)
    );

    receiver u_receiver(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .br_tick(w_br_tick),
        .rx_data(o_rx_data),
        .rx_done(o_rx_done)
    );

    // assign internal_rx= o_txd;

    // receiver u_receiver(
    //     .clk(clk),
    //     .reset(reset),
    //     .rx(o_txd),
    //     .br_tick(w_br_tick),
    //     .rx_data(o_rx_data),
    //     .rx_done(o_rx_done)
    // );
endmodule

module baudrate_generator(
    input clk,
    input reset,
    output br_tick
);
    reg [$clog2(100_000_000/9600/16)-1:0] r_counter;
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
             if(r_counter == 100_000_000/9600/16 - 1) begin
            //if(r_counter == 10 - 1) begin
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
    reg tx_reg, tx_next;
    reg tx_done_reg,tx_done_next;
    reg [7:0] temp_data_reg,temp_data_next;
    reg [3:0] tick_cnt_reg,tick_cnt_next; // 16번 sampling용도로 셈
    reg [2:0] bit_cnt_reg,bit_cnt_next;//8개,3빗
    
    parameter IDLE_S = 4'd0;
    parameter START_S = 4'd1;
    parameter D0_S = 4'd2, D1_S = 4'd3, D2_S = 4'd4, D3_S = 4'd5, D4_S = 4'd6, D5_S = 4'd7, D6_S = 4'd8, D7_S = 4'd9;
    parameter DATA_S = 4'd11;
    parameter STOP_S = 4'd10;
    //3.output combinational logic
    assign tx = tx_reg;
    assign tx_done = tx_done_reg;

    //1.state, var register
    always @(posedge clk,posedge reset) begin
        if(reset) begin
            state <= IDLE_S;
            tx_reg <= 1'b1;
            tx_done_reg <= 1'b0;
            temp_data_reg <= 0;
            tick_cnt_reg <= 0;
            bit_cnt_reg <= 0;
        end else begin
            state <= next_state;
            tx_reg <= tx_next;
            tx_done_reg <= tx_done_next;
            temp_data_reg <= temp_data_next;
            tick_cnt_reg <= tick_cnt_next;
            bit_cnt_reg <= bit_cnt_next;
        end
    end

    // 2.next state combinational logic
    always @(*) begin
        next_state = state; // latch를 막기위함
        tx_next = tx_reg;
        tx_done_next = tx_done_reg;
        temp_data_next = temp_data_reg;
        tick_cnt_next = tick_cnt_reg;
        bit_cnt_next = bit_cnt_reg;// latch를 막기위함
        case(state)
            IDLE_S: begin
                // tx=1,done=0
                tx_next = 1'b1;
                tx_done_next = 1'b0;
                if(start == 1'b1) begin
                    // data의 next state에 값 저장 "latching"한다고 한다.
                    temp_data_next = tx_data;
                    next_state = START_S;
                    tick_cnt_next = 0; // start신호 들어오면 초기화
                    bit_cnt_next = 0;
                end
            end
            START_S: begin
                tx_next = 1'b0;
                if(br_tick) begin
                    if(tick_cnt_reg == 15) begin
                        next_state = DATA_S; 
                        tick_cnt_next = 0;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA_S: begin
                tx_next = temp_data_reg[0];
                if(br_tick) begin
                    if(tick_cnt_reg == 15) begin
                        tick_cnt_next = 0;
                        if(bit_cnt_reg == 7) begin
                            next_state = STOP_S;
                            bit_cnt_next = 0;
                        end else begin
                            temp_data_next = {1'b0,temp_data_reg[7:1]};
                            bit_cnt_next = bit_cnt_reg + 1;
                        end
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            // D0_S: begin
            //     tx_next = temp_data_next[0];
            //     if(br_tick) begin
            //         if(tick_cnt_reg == 15) begin
            //             next_state = D1_S;  //br_tick이 들어오지 않으면, next_state = state;로 자기자신(start) 유지!!!
            //             tick_cnt_next = 0;
            //         end else begin
            //             tick_cnt_next = tick_cnt_reg + 1;
            //         end
            //     end
            // end
            // D1_S: begin
            //     tx_next = temp_data_next[1];
            //     if(br_tick) begin
            //         if(tick_cnt_reg == 15) begin
            //             next_state = D2_S;  //br_tick이 들어오지 않으면, next_state = state;로 자기자신(start) 유지!!!
            //             tick_cnt_next = 0;
            //         end else begin
            //             tick_cnt_next = tick_cnt_reg + 1;
            //         end
            //     end
            // end
            // D2_S: begin
            //     tx_next = temp_data_next[2];
            //     if(br_tick) begin
            //         if(tick_cnt_reg == 15) begin
            //             next_state = D3_S;  //br_tick이 들어오지 않으면, next_state = state;로 자기자신(start) 유지!!!
            //             tick_cnt_next = 0;
            //         end else begin
            //             tick_cnt_next = tick_cnt_reg + 1;
            //         end
            //     end
            // end
            // D3_S: begin
            //     tx_next = temp_data_next[3];
            //     if(br_tick) begin
            //         if(tick_cnt_reg == 15) begin
            //             next_state = D4_S;  //br_tick이 들어오지 않으면, next_state = state;로 자기자신(start) 유지!!!
            //             tick_cnt_next = 0;
            //         end else begin
            //             tick_cnt_next = tick_cnt_reg + 1;
            //         end
            //     end
            // end
            // D4_S: begin
            //     tx_next = temp_data_next[4];
            //     if(br_tick) begin
            //         if(tick_cnt_reg == 15) begin
            //             next_state = D5_S;  //br_tick이 들어오지 않으면, next_state = state;로 자기자신(start) 유지!!!
            //             tick_cnt_next = 0;
            //         end else begin
            //             tick_cnt_next = tick_cnt_reg + 1;
            //         end
            //     end
            // end
            // D5_S: begin
            //     tx_next = temp_data_next[5];
            //     if(br_tick) begin
            //         if(tick_cnt_reg == 15) begin
            //             next_state = D6_S; 
            //             tick_cnt_next = 0;
            //         end else begin
            //             tick_cnt_next = tick_cnt_reg + 1;
            //         end
            //     end
            // end
            // D6_S: begin
            //     tx_next = temp_data_next[6];
            //     if(br_tick) begin
            //         if(tick_cnt_reg == 15) begin
            //             next_state = D7_S;
            //             tick_cnt_next = 0;
            //         end else begin
            //             tick_cnt_next = tick_cnt_reg + 1;
            //         end
            //     end
            // end
            // D7_S: begin
            //     tx_next = temp_data_next[7];
            //     if(br_tick) begin
            //         if(tick_cnt_reg == 15) begin
            //             next_state = STOP_S; 
            //             tick_cnt_next = 0;
            //         end else begin
            //             tick_cnt_next = tick_cnt_reg + 1;
            //         end
            //     end
            // end
            STOP_S: begin
                tx_next = 1'b1;
                if(br_tick) begin
                    if(tick_cnt_reg == 15) begin
                        tx_done_next = 1'b1;
                        next_state = IDLE_S;
                        tick_cnt_next = 0;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end
    
endmodule



module receiver(
    input          clk,
    input          reset,
    input          br_tick,
    input          rx,
    output  [7:0]  rx_data,
    output         rx_done
);
    parameter IDLE = 2'd0,START = 2'd1,DATA = 2'd2, STOP = 2'd3;
    reg [1:0] state,next_state;
    reg [7:0] rx_data_reg,rx_data_next;
    reg [15:0] sample_bit_reg,sample_bit_next;
    reg [2:0] bit_cnt_reg,bit_cnt_next; // 8번 count
    reg [3:0] sample_cnt_reg, sample_cnt_next;
    reg rx_done_reg,rx_done_next;

    // 3.output combinational logic
    assign rx_data = rx_data_reg;
    assign rx_done = rx_done_reg;

    // 1.regsister state logic
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= IDLE;
            rx_data_reg <= 0;
            sample_cnt_reg <= 0;
            rx_done_reg <= 1'b0;
            sample_cnt_reg <= 0;
            sample_bit_reg <= 0;
            rx_data_reg <= 0;
            bit_cnt_reg <= 0;
        end else begin
            rx_data_reg <= rx_data_next;
            state <= next_state;
            sample_cnt_reg <= sample_cnt_next;
            rx_done_reg <= rx_done_next;
            sample_cnt_reg <= sample_cnt_next;
            sample_bit_reg <= sample_bit_next;
            rx_data_reg <= rx_data_next;
            bit_cnt_reg <= bit_cnt_next;
        end
    end

    // 2. next_state combinational logic
    always @(*) begin
        next_state      = state; // to prevent latch
        rx_done_next    = rx_done_reg;
        sample_cnt_next = sample_cnt_reg;
        sample_bit_next = sample_bit_reg;
        rx_data_next = rx_data_reg;
        bit_cnt_next = bit_cnt_reg;
        case (state)
            IDLE: begin
                rx_done_next = 1'b0;
                if(rx == 1'b0) begin
                    // start신호가 들어오면
                    sample_cnt_next = 0; // baud rate sample cnt
                    next_state = START;
                end else begin
                    next_state = IDLE; // state를 자기자신으로
                end
            end
            START: begin
                // rx_data = 받을데이터 초기화 해두는 것.
                rx_data_next = 0;
                if(br_tick) begin
                    if(sample_cnt_reg == 15) begin
                        sample_cnt_next = 0;
                        next_state = DATA;
                    end else begin
                        sample_cnt_next = sample_cnt_reg + 1;
                        next_state = START; //자기자신 유지
                    end
                end
            end 
            DATA : begin
                if(br_tick) begin
                    sample_bit_next = {rx,sample_bit_reg[15:1]}; // 15가 안되서?? 위로 올림
                    if(sample_cnt_reg == 15) begin
                        sample_cnt_next = 0;
                        // rx_data_next[7] = sample_bit_reg[7];
                        rx_data_next = {sample_bit_reg[7],rx_data_reg[7:1]};
                        if(bit_cnt_reg == 7) begin
                            // 8비트 다 채우면
                            bit_cnt_next = 0;
                            next_state = STOP;
                        end else begin
                            bit_cnt_next = bit_cnt_reg + 1;
                        end
                    end 
                    else begin
                        sample_cnt_next = sample_cnt_reg + 1;
                    end
                end
            end
            STOP : begin
                if(br_tick) begin
                    if(sample_cnt_reg == 15) begin
                        sample_cnt_next = 0;
                        rx_done_next = 1'b1;
                        next_state = IDLE;
                    end else begin
                        sample_cnt_next = sample_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule