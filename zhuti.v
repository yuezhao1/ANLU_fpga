module zhuti(
	input clk,
	input rst,
	input du_en,
	input a,
	input b,
	input [9:0]jiaodu,         //GY_26传过来的角度，正北是0°，0-360度
	
	output reg [1:0]dianji,
	output [60:0]jishu,
	output wire[8:0]JD,
	output reg [8:0]baidu_JD,
	input [7:0]licheng
    );
	wire podge;
	reg [1:0]tmp_rx;                       //上升沿检测所用寄存器
	always@(posedge clk or negedge rst)  //移位寄存器 检测下降沿
	  begin
	  if(!rst)  tmp_rx<=2'b00;
	  else
	    begin
	    tmp_rx[0]<=du_en;
	    tmp_rx[1]<=tmp_rx[0];
	    end
	  end
	assign podge=tmp_rx[0]&~tmp_rx[1];
	
	
	
reg 			wea;
reg		[6:0]	addra;
wire 	[92:0]	douta;


daohang_ram u_daohang_ram(
	.clka(clka),
	.rsta(!rsta),
	.ocea(1),
	.addra(addra),		//[2:0] 
	.doa(douta)			//[92:0]
	);


reg [92:0]addra1;
always@(posedge clk or negedge rst)   //地址打一拍
begin
	if(!rst) begin addra1<=1'b0; end
	else 
		begin
			addra1<=addra;
		end
end

 reg flag;                            //检测输出的地址有没有变化，没有变化是1 有变化是0   flag
always@(*)
begin
	if(addra1==addra)
		flag<=1'b1;
	else flag<=1'b0;
end

	/*wire nedge;
	reg [1:0]tmp_rx1;                       //flag下降沿检测所用寄存器
	always@(posedge clk or negedge rst)  //移位寄存器 检测下降沿
	  begin
	  if(!rst)  tmp_rx1<=2'b11;
	  else
	    begin
	    tmp_rx1[0]<=flag;
	    tmp_rx1[1]<=tmp_rx1[0];
	    end
	  end
	assign nedge=~tmp_rx1[0]&tmp_rx1[1];*/


assign JD=jiaodu[9:8]*100+jiaodu[7:4]*10+jiaodu[3:0];

//对百度传回来的角度进行翻译  枚举值，返回值在0-11之间的一个值，共12个枚举值，以30度递进，即每个值代表角度范围为30度；其中返回"0"代表345度到15度，以此类推，返回"11"代表315度到345度"；分别代表的含义是：0-[345°-15°]；1-[15°-45°]；2-[45°-75°]；3-[75°-105°]；4-[105°-135°]；5-[135°-165°]；6-[165°-195°]；7-[195°-225°]；8-[225°-255°]；9-[255°-285°]；10-[285°-315°]；11-[315°-345°] 
//reg [8:0]baidu_JD;
always@(posedge clk)     
begin
	if(douta[84])
		case(douta[83:80])
		4'd0:  baidu_JD<=1'b0;
		4'd1:  baidu_JD<=9'd30;
		4'd2:  baidu_JD<=9'd60;
		4'd3:  baidu_JD<=9'd90;
		4'd4:  baidu_JD<=9'd120;
		4'd5:  baidu_JD<=9'd150;
		4'd6:  baidu_JD<=9'd180;
		4'd7:  baidu_JD<=9'd195;
		4'd8:  baidu_JD<=9'd240;
		4'd9:  baidu_JD<=9'd270;
		4'd10: baidu_JD<=9'd300;
		4'd11: baidu_JD<=9'd330;
		endcase
end
reg  data_a1;
 reg  data_a2;
always @(posedge clk or negedge rst)
begin
    if(!rst)
    begin 
	data_a1 <= 1'b0; 
	data_a2 <= 1'b0;
	end 
    else
    begin 
	data_a1 <= a; 
	data_a2 <= data_a1;
	end 
end 
assign double_a  = data_a1 ^ data_a2;//双边沿 编码器1A相



reg data_b1;
 reg data_b2;
always @(posedge clk or negedge rst)
begin
    if(!rst)
    begin 
	data_b1 <= 1'b0; 
	data_b2 <= 1'b0;
	end 
    else
    begin 
	data_b1 <= b; 
	data_b2 <= data_b1;
	end 
end 
assign double_b  = data_b1 ^ data_b2;//双边沿 编码器1B相



	 
reg clk1;
reg data_clk1;
reg data_clk2;
always @ (posedge clk,negedge rst)
begin
    if(!rst)
    begin data_clk1 <= 1'b0; data_clk2 <= 1'b0; end 
    else
    begin data_clk1 <= clk1; data_clk2 <= data_clk1;end 
end 
assign raising_clk1 = data_clk1  & (~data_clk2);//上升沿


reg [27:0]cnt1;
reg [60:0]cnt2;
always@(posedge clk or negedge rst)
begin
   if(!rst)
   begin
     cnt1 <= 28'd0;
	 cnt2 <= 61'd0;
	 end
	else if(flag==1'b0)
	 cnt2<=1'b0;
   else if(double_a==1|double_b==1)
     cnt1  <= cnt1 + 1'b1;
   else if(raising_clk1 == 1 /*&& flag *//*&& JD==baidu_JD */)
   begin
     cnt1 <= 0;
     cnt2 <= cnt2 + 1'b1;
	 end
	else 
	begin
	  cnt1 <= cnt1;
	  cnt2 <= cnt2;
	end
end
always@(posedge clk or negedge rst)//2,632,500‬
if(!rst)
begin
clk1 <= 0;
end
else if(cnt1 == 38'd195)
begin
  clk1 <= 1;
end
 else
     clk1 <= 0;
assign  jishu = ((((cnt2*13*5)*13)*24*41)>>12)/8;

always@(posedge clk or negedge rst)
begin
	if(!rst)
		dianji<=2'b00;
	else begin
	if(podge)
		begin wea<=1'b0; addra<=1'b0;end
	if(douta[84]&&du_en)//需要转弯      1001右转   0110左转   1010直走
		begin
			if(JD==baidu_JD) begin       //小车的角度等于需要转的角度
				dianji<=2'b11;
				if(licheng==douta[92:85]&flag)
				addra<=addra+1'b1;
				else addra<=addra;
				end
			else if (JD<baidu_JD)    //小车现在的角度小于需要转到的角度 右转
				dianji<=2'b10;
			else if(JD>baidu_JD)	//小车现在的角度大于需要转到的角度 左转
				dianji<=2'b01;
			 
		end
	else 
	   dianji <= 2'b00;
	end
end 



endmodule
