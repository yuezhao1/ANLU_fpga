module bin_bcd(
     input               clk,
     input               rst_n,
     input               tran_en,
     input       [15:0]  data_in,
     output   reg        tran_done,
     output      [15:0]  bcd
 
 );
 parameter       DATA_WIDTH  =   16;
 parameter       SHIFT_WIDTH =   5;
 parameter       SHIFT_DEPTH =   16;

 //-------------------------------------------------------
 localparam  IDLE    =   3'b001;
 localparam   SHIFT   =   3'b010;
 localparam   DONE    =   3'b100;
 
 //-------------------------------------------------------
 reg     [2:0]   pre_state;
 reg     [2:0]   next_state;
 //
 reg     [SHIFT_DEPTH-1:0]   shift_cnt;
 //
 reg     [DATA_WIDTH:0]  data_reg;
 reg     [3:0]   thou_reg;
 reg        [3:0]    hund_reg;
 reg        [3:0]    tens_reg;
 reg        [3:0]    unit_reg; 
 reg     [3:0]   thou_out;
 reg        [3:0]    hund_out;
 reg        [3:0]    tens_out;
 reg        [3:0]    unit_out; 
 wire    [3:0]   thou_tmp;
 wire    [3:0]    hund_tmp;
 wire    [3:0]    tens_tmp;
 wire    [3:0]    unit_tmp;
 
 //-------------------------------------------------------
 //FSM step1
 always  @(posedge clk or negedge rst_n)begin
     if(rst_n == 1'b0)begin
         pre_state <= IDLE;
     end
     else begin
         pre_state <= next_state;
     end
 end
 
 //FSM step2
 always  @(*)begin
     case(pre_state)
     IDLE:begin
         if(tran_en == 1'b1)
             next_state = SHIFT;
         else 
             next_state = IDLE;
     end
     SHIFT:begin
         if(shift_cnt == SHIFT_DEPTH + 1)
             next_state = DONE;
         else 
             next_state = SHIFT;
     end
     DONE:begin
         next_state = IDLE;
     end
     default:next_state = IDLE;
     endcase
 end
 
 //FSM step3
 always  @(posedge clk or negedge rst_n)begin
     if(rst_n == 1'b0)begin
         thou_reg <= 4'b0; 
         hund_reg <= 4'b0; 
         tens_reg <= 4'b0; 
         unit_reg <= 4'b0; 
         tran_done <= 1'b0;
         shift_cnt <= 'd0; 
         data_reg <= 'd0;
     end
     else begin
         case(next_state)
         IDLE:begin
             thou_reg <= 4'b0; 
             hund_reg <= 4'b0; 
             tens_reg <= 4'b0; 
             unit_reg <= 4'b0; 
             tran_done <= 1'b0;
             shift_cnt <= 'd0; 
             data_reg <= data_in;
         end
         SHIFT:begin
             if(shift_cnt == SHIFT_DEPTH + 1)
                 shift_cnt <= 'd0;
             else begin
                 shift_cnt <= shift_cnt + 1'b1;
                 data_reg <= data_reg << 1;
                 unit_reg <= {unit_tmp[2:0], data_reg[16]};
                 tens_reg <= {tens_tmp[2:0], unit_tmp[3]};
                 hund_reg <= {hund_tmp[2:0], tens_tmp[3]};
                 thou_reg <= {thou_tmp[2:0], hund_tmp[3]};
             end
         end
         DONE:begin
             tran_done <= 1'b1;
         end
         default:begin
             thou_reg <= thou_reg; 
             hund_reg <= hund_reg; 
             tens_reg <= tens_reg; 
             unit_reg <= unit_reg; 
             tran_done <= tran_done;
             shift_cnt <= shift_cnt; 
         end
         endcase
     end
 end
 //-------------------------------------------------------
 always  @(posedge clk or negedge rst_n)begin
     if(rst_n == 1'b0)begin
         thou_out <= 'd0;
         hund_out <= 'd0;
         tens_out <= 'd0;
         unit_out <= 'd0; 
     end
     else if(tran_done == 1'b1)begin
         thou_out <= thou_reg;
         hund_out <= hund_reg;
         tens_out <= tens_reg;
         unit_out <= unit_reg;
     end
     else begin
         thou_out <= thou_out;
         hund_out <= hund_out;
         tens_out <= tens_out;
         unit_out <= unit_out;
     end
 end
 
 
 //-------------------------------------------------------
 assign  thou_tmp = (thou_reg > 4'd4)?  (thou_reg + 2'd3) : thou_reg;
 assign  hund_tmp = (hund_reg > 4'd4)?  (hund_reg + 2'd3) : hund_reg;
 assign  tens_tmp = (tens_reg > 4'd4)?  (tens_reg + 2'd3) : tens_reg; 
 assign  unit_tmp = (unit_reg > 4'd4)?  (unit_reg + 2'd3) : unit_reg; 
 
 assign bcd = {thou_out,hund_out,tens_out,unit_out};

 
 endmodule