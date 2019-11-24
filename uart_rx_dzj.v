module uart_rx_dzj(
	input clk,
	input rst_n,
	input [7:0]data_tx,
	input over_rx,
	input nedge,
	
	output reg [9:0] jiaodu
    );
	
	wire nedge_over_rx;
	reg [1:0]tmp_rx;                       //下降沿检测所用寄存器
	always@(posedge clk or negedge rst_n)  //移位寄存器 检测下降沿
	  begin
	  if(!rst_n)  tmp_rx<=2'b11;
	  else
	    begin
	    tmp_rx[0]<=over_rx;
	    tmp_rx[1]<=tmp_rx[0];
	    end
	  end
	assign nedge_over_rx=~tmp_rx[0]&tmp_rx[1];
	
	parameter s0=4'd0,s1=4'd1,s2=4'd2,s3=4'd3,s4=4'd4,s5=4'd5;//,s6=4'd6,s7=4'd7,s8=4'd8,s9=4'd9,s10=4'd10,s11=4'd12;
	reg[3:0] present_state,next_state;
	always@(posedge clk or negedge rst_n)
	begin
	  if(!rst_n)
		begin
	    present_state<=s0;
		end
	  else if(~over_rx&nedge) present_state<=next_state;
	end
	      //[9:8]百位 [7:4]十位 [3:0]个位
	reg[1:0]baiwei;
	reg[3:0]shiwei;
	reg[3:0]gewei;
	always@(posedge clk or negedge rst_n)
	 begin
	 if(!rst_n)
		begin next_state<=s0; baiwei<=1'b0;shiwei<=1'b0;gewei<=1'b0;end
	 else begin
	 case(present_state)
	    s0: if(data_tx==8'h0D/*8'b01001001*/)  //0D
			  next_state<=s1;
			else next_state<=s0;
		s1: if(data_tx==8'h0A)  //0A
			  next_state<=s2;
			else next_state<=s0;
		s2: if(data_tx[7:4]==4'b0011)
			begin                            //角度百位
			  if(nedge_over_rx)begin next_state<=s3;
			  baiwei<=data_tx[3:0]; end        
			end
			else next_state<=s0;
		s3: if(data_tx[7:4]==4'b0011)
			begin
			  if(nedge_over_rx) begin next_state<=s4;               //角度十位
			  shiwei<=data_tx[3:0]; end
			end
			else next_state<=s0;
		s4: if(data_tx[7:4]==4'b0011)
			begin                           //角度个位
			  if(nedge_over_rx) begin next_state<=s5;
			  gewei<=data_tx[3:0]; end
			end
			else next_state<=s0;
		s5: next_state<=s0;
		
		default: next_state<=s0;
	 endcase
	 end 
	 end 
	 always@(posedge clk or negedge rst_n)
	 begin 
		if(!rst_n)
		jiaodu<=1'b0;
		else if(next_state==s5)
		jiaodu<={baiwei,shiwei,gewei};
		else jiaodu<=jiaodu;
	 end
	endmodule