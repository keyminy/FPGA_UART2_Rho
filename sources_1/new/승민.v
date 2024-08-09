
module baudrate_genarator(
    input clk,
    input reset,
    output br_tick
    );
    reg [$clog2(100_000_000/9600/16) - 1:0] r_counter; // 9600 bps 를 만들기 위한 카운터를 위한reg 값
    reg r_tick; // 
    assign br_tick = r_tick;
    
    always@(posedge clk, posedge reset)begin
    if (reset) begin
        r_counter <= 0;
        r_tick   <= 1'b0;
        end else begin
            if (r_counter == 100_000_000/9600/16 - 1) begin // 상수일때는 상관없다. 컴파일 할 때 코드를 다 만들어낸다.
            //if (r_counter == 2 - 1) begin 
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
    input start,
    input [7:0] tx_data,
    output tx_done,
    output tx
);
    parameter   IDLE_S  = 4'd0,
                START_S = 4'd1,
                D0_S    = 4'd2,
                D1_S    = 4'd3,
                D2_S    = 4'd4,
                D3_S    = 4'd5,
                D4_S    = 4'd6,
                D5_S    = 4'd7,
                D6_S    = 4'd8,
                D7_S    = 4'd9,
                STOP_S  = 4'd10,
                DATA_S  = 4'd11;
                
    reg [3:0] state, next_state, tick_cnt_reg, tick_cnt_next;
    reg tx_reg, tx_next, tx_done_reg, tx_done_next;
    reg [7:0] temp_data,temp_data_reg, temp_data_next, bit_cnt_reg, bit_cnt_next;
    // output combinational logic                     
    assign tx = tx_reg;
    assign tx_done = tx_done_reg;  
    
    // state logic                   
    always@(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE_S;
            tx_reg <= 1'b0;
            tx_done_reg <= 1'b0;
            temp_data_reg <= 0;
            tick_cnt_reg <= 0;
            bit_cnt_reg <= 0;
        end
        else begin
            state <= next_state;
            tx_reg <= tx_next;
            tx_done_reg <= tx_done_next;
            temp_data_reg <= temp_data_next;
            tick_cnt_reg <= tick_cnt_next;
            bit_cnt_reg <= bit_cnt_next;            
        end
    end
    
    // next state combinational logic
    always@(*) begin
        next_state = state;             //원치않는 case 동작 제거용 상태 미리 설정해주는곳
        tx_next = tx_reg;
        tx_done_next = tx_done_reg;
        temp_data_next = temp_data_reg;
        tick_cnt_next = tick_cnt_reg;
        bit_cnt_next = bit_cnt_reg;
        case(state)
            IDLE_S : begin
                tx_next         = 1'b1;
                tx_done_next    = 1'b0;
                if (start == 1'b1) begin
                    temp_data_next = tx_data;
                    next_state = START_S;
                end
            end
            START_S: begin
                tx_next = 1'b0;
                if (br_tick == 1'b1) begin
                    if(tick_cnt_reg== 15)begin
                        next_state = DATA_S;
                        tick_cnt_next = 0;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA_S: begin
                tx_next = temp_data_reg[0];
                if( br_tick== 1'b1 ) begin
                    if(tick_cnt_reg == 15) begin
                        tick_cnt_next = 0;
                        if (bit_cnt_reg == 7) begin
                            next_state = STOP_S;
                            bit_cnt_next = 0;
                        end else begin
                            temp_data_next = {1'b0, temp_data_reg[7:1]};
                            bit_cnt_next = bit_cnt_reg +1;
                        end
//                        next_state = D0_S;
//                        tick_cnt_next = 0;
                    end else begin
                        tick_cnt_next = tick_cnt_reg +1;
                    end
                end
            end
//            D0_S: begin
//                tx_next = temp_data_reg[0];
//                if( br_tick== 1'b1 ) begin
//                    if(tick_cnt_reg == 15) begin
//                        next_state = D1_S;
//                        tick_cnt_next = 0;
//                    end else begin
//                        tick_cnt_next = tick_cnt_reg +1;
//                    end
//                end
//            end
//            D1_S: begin
//                tx_next = temp_data_reg[1];
//                if( br_tick== 1'b1 ) begin
//                    if(tick_cnt_reg == 15) begin
//                        next_state = D2_S;
//                        tick_cnt_next = 0;
//                    end else begin
//                        tick_cnt_next = tick_cnt_reg +1;
//                    end
//                end
//            end
//            D2_S: begin
//                tx_next = temp_data_reg[2];
//                if( br_tick== 1'b1 ) begin
//                    if(tick_cnt_reg == 15) begin
//                        next_state = D3_S;
//                        tick_cnt_next = 0;
//                    end else begin
//                        tick_cnt_next = tick_cnt_reg +1;
//                    end
//                end
//            end
//            D3_S: begin
//                tx_next = temp_data_reg[3];
//                if( br_tick== 1'b1 ) begin
//                    if(tick_cnt_reg == 15) begin
//                        next_state = D4_S;
//                        tick_cnt_next = 0;
//                    end else begin
//                        tick_cnt_next = tick_cnt_reg +1;
//                    end
//                end
//            end
//            D4_S: begin
//                tx_next = temp_data_reg[4];
//                if( br_tick== 1'b1 ) begin
//                    if(tick_cnt_reg == 15) begin
//                        next_state = D5_S;
//                        tick_cnt_next = 0;
//                    end else begin
//                        tick_cnt_next = tick_cnt_reg +1;
//                    end
//                end
//            end
//            D5_S: begin
//                tx_next = temp_data_reg[5];
//                if( br_tick== 1'b1 ) begin
//                    if(tick_cnt_reg == 15) begin
//                        next_state = D6_S;
//                        tick_cnt_next = 0;
//                    end else begin
//                        tick_cnt_next = tick_cnt_reg +1;
//                    end
//                end
//            end
//            D6_S: begin
//                tx_next = temp_data_reg[6];
//                if( br_tick== 1'b1 ) begin
//                    if(tick_cnt_reg == 15) begin
//                        next_state = D7_S;
//                        tick_cnt_next = 0;
//                    end else begin
//                        tick_cnt_next = tick_cnt_reg +1;
//                    end
//                end
//            end
//            D7_S: begin
//                tx_next = temp_data_reg[7];
//                if( br_tick== 1'b1 ) begin
//                   if(tick_cnt_reg == 15) begin
//                        next_state = STOP_S;
//                        tick_cnt_next = 0;
//                    end else begin
//                        tick_cnt_next = tick_cnt_reg +1;
//                    end
//                end
//            end
            STOP_S:begin
                tx_next = 1'b1;
                if( br_tick== 1'b1 ) begin
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
//100_000_000 / 10_000_000 = 10
//100_000_000 / x = 9600