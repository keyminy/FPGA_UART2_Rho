module receiver (
    input clk,
    input reset,
    input rx,
    input start,
    input br_tick,
    output rx_done,
    output reg [7:0] rx_data
);
    parameter IDLE_S = 4'd0, START_S=4'd1, D0_S=4'd2 , D1_S=4'd3 , D2_S=4'd4 , D3_S=4'd5 ,
 D4_S=4'd6 , D5_S=4'd7 , D6_S=4'd8 , D7_S=4'd9, STOP_S=4'd10, DATA_S = 4'b11;

    reg [3:0] state, next_state;
//    reg temp_rx, temp_rx_next;
    reg rx_done_reg, rx_done_next;
    reg [7:0] rx_data_reg, rx_data_next;
    reg [3:0] tick_cnt_reg, tick_cnt_next;
    reg [2:0] bit_cnt_next, bit_cnt_reg;
//    reg [7:0] temp_data_reg, temp_data_next;

    //output combination logic
    //assign rx_data = rx_data_reg;
    assign rx_done = rx_done_reg;

    // state logic
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE_S;
            rx_data_reg <= 8'b0;
            rx_done_reg <= 0;
        //    temp_rx <= 0;
            tick_cnt_reg <= 0;
            bit_cnt_reg <= 0;
         //   temp_data_reg<=0;
        end else begin
            state <= next_state;
            rx_data_reg <= rx_data_next;
            rx_done_reg <= rx_done_next;
        //    temp_rx <= temp_rx_next;
            tick_cnt_reg <= tick_cnt_next;
            bit_cnt_reg <= bit_cnt_next;
        //    temp_data_reg<=temp_data_next;
        end
    end

    // next state combinational logic
    always @(*) begin
        next_state=state;
        rx_data_next = rx_data_reg;
        rx_done_next = rx_done_reg;
      //  temp_rx_next = temp_rx;
        tick_cnt_next = tick_cnt_reg;
        bit_cnt_next = bit_cnt_reg;
       // temp_data_next = temp_data_reg;
        case (state)
            IDLE_S: begin
                //rx_data_next = 8'b11111111;
                rx_done_next = 1'b0;
                if(start == 1'b1) begin
                    //temp_rx_next = rx;
                    next_state = START_S;
                    tick_cnt_next = 4'b0;
                    bit_cnt_next = 3'b0;
                end
            end 
            START_S : begin
               // rx_data_next = 8'b00000000;
                if (br_tick == 1) begin
                    if(tick_cnt_reg == 15) begin
                        next_state = D0_S;
                        tick_cnt_next = 0;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            // DATA_S: begin
            // if (br_tick == 1) begin
            //     if (tick_cnt_reg == 15) begin
            //         tick_cnt_next = 0;
            //         if (bit_cnt_reg == 7) begin
            //             next_state   = STOP_S;
            //             bit_cnt_next = 0;
            //         end
            //     end
            //     else if(tick_cnt_reg==7) begin
            //         rx_data_next = {rx, temp_data_reg[7:1]};
            //         bit_cnt_next   = bit_cnt_reg + 1;
            //         end
            // end else begin
            //     tick_cnt_next = tick_cnt_reg + 1;
        
            // end
            // end
            D0_S: begin
                
                if (br_tick == 1) begin
                    if (tick_cnt_reg==8) begin
                        rx_data_next[0] = rx;
                    end
                     if(tick_cnt_reg==15) begin
                        next_state = D1_S;
                        tick_cnt_next=0;
                    end
                    else begin
                        tick_cnt_next=tick_cnt_reg+1;
                    end
                end
            end             
            D1_S: begin
                
                if (br_tick == 1) begin
                    if(tick_cnt_reg==8) begin
                        rx_data_next[1] = rx;
                    end
                    if(tick_cnt_reg==15) begin
                        next_state = D2_S;
                        tick_cnt_next=0;
                    end
                    else begin
                        tick_cnt_next=tick_cnt_reg+1;
                    end
                end
            end
            D2_S: begin
                
                if (br_tick == 1) begin
                    if(tick_cnt_reg==8) begin
                        rx_data_next[2] = rx;
                    end
                    if(tick_cnt_reg==15) begin
                        next_state = D3_S;
                        tick_cnt_next=0;
                    end
                    else begin
                        tick_cnt_next=tick_cnt_reg+1;
                    end
                end
            end
            D3_S: begin
            
                if (br_tick == 1) begin
                    if(tick_cnt_reg==8) begin
                        rx_data_next[3] = rx;
                    end
                    if(tick_cnt_reg==15) begin
                        next_state = D4_S;
                        tick_cnt_next=0;
                    end
                    else begin
                        tick_cnt_next=tick_cnt_reg+1;
                    end
                end
            end
            D4_S: begin
               
                if (br_tick == 1) begin
                    if(tick_cnt_reg==8) begin
                        rx_data_next[4] = rx;
                    end
                    if(tick_cnt_reg==15) begin
                        next_state = D5_S;
                        tick_cnt_next=0;
                    end
                    else begin
                        tick_cnt_next=tick_cnt_reg+1;
                    end
                end
            end
            D5_S: begin
            
                if (br_tick == 1) begin
                    if(tick_cnt_reg==8) begin
                        rx_data_next[5] = rx;
                    end
                    if(tick_cnt_reg==15) begin
                        next_state = D6_S;
                        tick_cnt_next=0;
                    end
                    else begin
                        tick_cnt_next=tick_cnt_reg+1;
                    end
                end
            end
            D6_S: begin
              
                if (br_tick == 1) begin
                    if(tick_cnt_reg==8) begin
                        rx_data_next[6] = rx;
                    end
                    if(tick_cnt_reg==15) begin
                        next_state = D7_S;
                        tick_cnt_next=0;
                    end
                    else begin
                        tick_cnt_next=tick_cnt_reg+1;
                    end
                end
            end
            D7_S: begin
           
                if (br_tick == 1) begin
                    if(tick_cnt_reg==8) begin
                        rx_data_next[7] = rx;
                    end
                    if(tick_cnt_reg==15) begin
                        next_state = STOP_S;
                        tick_cnt_next=0;
                    end
                    else begin
                        tick_cnt_next=tick_cnt_reg+1;
                    end
                end
            end
            STOP_S: begin
                //rx_data_next = 8'b11111111;
                if (br_tick == 1) begin
                    if (tick_cnt_reg == 15) begin
                        rx_data = rx_data_reg;
                        next_state = IDLE_S;
                        tick_cnt_next = 0;
                        rx_done_next = 1'b1;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end

                end
            end

        endcase
    end
endmodule
