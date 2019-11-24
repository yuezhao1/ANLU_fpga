module bizhang(clk,rst,hq,hz,jiaodu,dianji2,led7,led6,led5,led4,/*led3,led2,*/jiaodu1,flag1
    );
	input clk;
	input rst;
	input [9:0]hq;
	input [9:0]hz;
	input [9:0]jiaodu;
	output [9:0]jiaodu1;
	output reg[1:0]dianji2;
	output reg led7;
	output reg led6;
	output reg led5;
	output reg led4;
	output flag1;
	/*output reg led3;
	output reg led2;*/
	reg [3:0]state;
	reg [9:0]jiaodu1;
	parameter safe= 60;
	wire  [9:0]JD;
	assign JD=jiaodu[9:8]*100+jiaodu[7:4]*10+jiaodu[3:0];
	
	/*reg data_in_d1;
reg data_in_d2;

always @ (posedge clk,negedge rst)
begin
    if(!rst)
    begin data_in_d1 <= 1'b0; data_in_d2 <= 1'b0; end 
    else
    begin data_in_d1 <= flag; data_in_d2 <= data_in_d1;end 
end 
assign raising_flag = data_in_d1  & (~data_in_d2);//上升沿*/
	/*reg [30:0]cnt;
always@(posedge clk or negedge rst)
if(!rst)
  cnt  <= 31'd0;
 else if(cnt == 30'd250_000_000)
   cnt  <= 31'd0;
   else 
    cnt <= cnt;
	reg [30:0]cnt2;
	always@(posedge clk or negedge rst)
if(!rst)
  cnt2  <= 31'd0;
 else if(cnt == 30'd250_000_000&&(JD==jiaodu1 + 90))
   cnt2  <= cnt2 + 1'b1;
   else 
    cnt2 <= cnt2;*/
	
	reg [30:0]cnt1;
	reg [30:0]cnt3;
	always@(posedge clk or negedge rst)
if(!rst)
begin
  cnt1  <= 31'd0;
  cnt3  <= 31'd0;
  end
 else if(cnt3 == 30'd50_000_000)
 begin
   cnt1  <= cnt1 + 1'b1;
   cnt3  <= 31'd0;
   end
   else 
   begin
    cnt1 <= cnt1;
	cnt3 <= cnt3 + 1'b1;
	end
	

always@(posedge clk or negedge rst)
if(!rst)
  jiaodu1 <= 10'd0;
  else if(cnt1 == 1)
  jiaodu1 <= JD;
  else 
   jiaodu1 <= jiaodu1;
  always@(posedge clk or negedge rst)
  if(!rst)
  begin
  led7 <= 1'b0;
  led6 <= 1'b0;
  led5 <= 1'b0;
  led4 <= 1'b0;
 // led3 <= 1'b0;
 // led2 <= 1'b0;
  end
  else if(state == 4'd0)
  led7 <= 1;
  else if(state == 4'd1)
  led6 <= 1;
   else if(state == 4'd2)
  led5 <= 1;
   else if(state == 4'd3)
  led4 <= 1;
  // else if(state == 4'd4)
 // led3 <= 1;
   //else if(state == 4'd5)
  //led2 <= 1;
  else
  begin
  led7 <= led7;
  led6 <= led6;
  led5 <= led5;
  led4 <= led4;
  //led3 <= led3;
 // led2 <= led2;
  end
  
	
	/*reg [30:0]cnt5;
	/*always@(posedge clk or negedge rst)
if(!rst)
begin
  cnt4  <= 31'd0;
  cnt5  <= 31'd0;
  end
 else if((cnt5 == 30'd50_000_000) && (state == 4'd2))
 begin
   cnt4  <= cnt4 + 1'b1;
   cnt5  <= 31'd0;
   end
   else 
   begin
    cnt4 <= cnt4;
	cnt5 <= cnt5 + 1'b1;
	end*/
  
    reg flag1;
	always@(posedge clk or negedge rst)
	if(!rst)
	begin
	dianji2 <= 2'b00;
	state <= 4'd0;
	flag1  <= 0;
	end
	else
	  if(hq != 0)
	  begin
	case(state)
	0:  if(hq > 50)
	    begin
		  dianji2 <= 2'b11;
		  state  <= 4'd0;
		 end
		else
		 begin
		 dianji2 <= 2'b10;
		 state  <= 4'd1;
		 flag1 <= 1;
		 end
	1:  if(JD==jiaodu1 + 70)
	     begin
	      dianji2 <= 2'b11;
		  state  <= 4'd2;
		  end
		else
		begin
		   if(JD < jiaodu1 + 70)
		    begin
		   dianji2 <= 2'b10;
		    state <= 4'd1;
		   end
		   else if(JD > jiaodu1 + 70)
		   begin
		    dianji2 <= 2'b01;
		    state <= 4'd1;
		   end
		 end  
    2:  if(hz > 80)
	      begin
		    dianji2  <= 2'b01;
			state  <= 4'd3;
			flag1 <= 0;
		  end
		else
		   begin
		   dianji2  <= 2'b11;
		   state   <= 4'd2;
		   end
	3:	if(JD==jiaodu1)
        begin
		   dianji2 <= 2'b11;
		   state  <= 4'd4;
        end	
		else
		begin
		   if(JD < jiaodu1 )
		    begin
		   dianji2 <= 2'b10;
		    state <= 4'd3;
		   end
		   else if(JD > jiaodu1 )
		   begin
		    dianji2 <= 2'b01;
		    state <= 4'd3;
		   end
		 end  	
    4:  if(hz > 80)
         begin
		   dianji2 <= 2'b01;
		   state <= 4'd5;
         end	
        else 
          begin
		    dianji2 <= 2'b11;
			state  <= 4'd4;
           end		  
	5:   if(JD == jiaodu1 - 70 )
	      begin
		     dianji2 <= 2'b11;
			 state <= 4'd6;
			 end
	     else 
		   begin
		  if(JD < jiaodu1 )
		    begin
		   dianji2 <= 2'b10;
		    state <= 4'd5;
		   end
		   else if(JD > jiaodu1 )
		   begin
		    dianji2 <= 2'b01;
		    state <= 4'd5;
		   end
		   end
    6:   begin
	       state  <= state;
		   dianji2 <= 2'b00;
	     end
		 
	endcase
	end
	else 
	   dianji2 <= 2'b00;



endmodule
