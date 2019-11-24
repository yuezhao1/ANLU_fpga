module time_(
	input [17:0]shijian,
	input clk,
	input rst_n,
	input shijian_en,     //语音输入一个高电平
	output reg [3:0]shi_1,
	output reg [3:0]shi_2,
	output reg [3:0]fen_1,
	output reg [3:0]fen_2,
	output reg sj_en
    );

/*	always@(*)                                               //拿出时分各位
	begin
		if((shijian%10000+4'd8)>5'd24)                      //UTC时间加8为北京时间
			begin
			shi_1<=(shijian%10000+4'd8-5'd24)%10;
			shi_2<=(shijian%10000+4'd8-5'd24)-shi_1*10;
			end
		else begin
			shi_1<=(shijian%10000+4'd8)%10;
			 shi_2<=(shijian%10000+4'd8)-shi_1*10;
			 end
		fen_1<=(shijian%1000-(shijian%10000)*10);
		fen_2<=(shijian%100-(shijian%1000)*10);			
	end*/

	reg [1:0]tmp_rx;                       //shijian_en信号上升沿检测所用寄存器
	wire podge;
	always@(posedge clk or negedge rst_n)  //移位寄存器 检测上升沿
	  begin
	  if(!rst_n)  tmp_rx<=2'b00;
	  else
	    begin
	    tmp_rx[0]<=shijian_en;
	    tmp_rx[1]<=tmp_rx[0];
	    end
	  end
	assign podge=tmp_rx[0]&~tmp_rx[1];	
		reg [17:0]sj;
	always@(posedge clk or negedge rst_n)                                //拿出时分各位
		begin
			if(!rst_n)
				begin     shi_1<=4'd0; shi_2<=4'd0;sj<=1'b0;
						  fen_1<=4'd0; fen_2<=4'd0; sj_en<=1'b0;end
			else if(podge)begin sj<=shijian; shi_1<=4'd0; shi_2<=4'd0;fen_1<=4'd0; fen_2<=4'd0;end
			else if(sj>=17'd100000)begin
					sj<=sj-17'd100000;
					shi_1<=shi_1+1'b1;  end
			else if(sj>=14'd10000)begin
					sj<=sj-14'd10000;
					shi_2<=shi_2+1'b1;  end
			else if((shi_1*4'd10+shi_2+4'd8)>5'd24)                                 //UTC时间加8为北京时间
					begin					//eg 小时是28 28-24=4 再把0和4拿出来
						/*sj_yichu<=shi_1*4'd10+shi_2+4'd8-5'd24;
						if(sj_yichu<4'd10)       //时间最多235959 23+8=31 31-24=7 所以最多就是7
								begin shi_2<=sj_yichu;
									  shi_1<=1'b0; end*/
						shi_2<=shi_1*4'd10+shi_2+4'd8-5'd24;
						shi_1<=1'b0;
					end 
			else if(sj>=10'd1000) begin
					sj<=sj-10'd1000;
					fen_1<=fen_1+1'b1; end
			else if(sj>=7'd100) begin
					sj<=sj-7'd100;
					fen_2<=fen_2+1'b1;end
			else if(sj>1'b1&sj<7'd100)sj_en<=1'b1;
			else  sj_en<=1'b0;
		end
endmodule
