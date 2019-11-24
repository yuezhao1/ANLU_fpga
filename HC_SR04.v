module HC_SR04(
	input clk,
	input rst_n,
	input en,
	input echo	,
	output reg trig,
	output [8:0] dis
    );
reg [23:0]cnt;
reg [31:0] cnt_t;
parameter T=24'd15000000;//300ms
parameter C=10'd600;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		cnt<=0;
	else if(cnt==T-1)
		cnt<=0;
	else 
		cnt<=cnt+1;
		
end
	
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		trig<=0;
	else if(cnt>=1&&cnt<=C)
		trig<=1;
	else
		trig<=0;
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		cnt_t<=0;	
	else if(echo==1)
		cnt_t<=cnt_t+1;
	else if(cnt==T-1)
		cnt_t<=0;
	else 
		cnt_t<=cnt_t;
end
reg [31:0]distance ;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		distance<=0;
	else if(cnt==T-2'd2)
		distance<=(cnt_t*11)>>15;
end

assign dis=distance;	
 
endmodule
