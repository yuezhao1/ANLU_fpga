module uart_bps(clk,rst_n,cnt_start,bps_sig
    );
    input clk;
    input rst_n;
    input cnt_start;
    output bps_sig;
    
    reg [12:0]cnt_bps;
    wire bps_sig;
    
    parameter bps_t = 13'd433;//5207
    
    always@(posedge clk or negedge rst_n)
    begin
       if(!rst_n)
       begin
          cnt_bps <= 13'd0;
       end
       else if(cnt_bps == bps_t)
       begin
          cnt_bps <= 13'd0;
       end
       else if(cnt_start)
       begin
          cnt_bps <= cnt_bps + 1'b1;
       end
       else 
       begin
          cnt_bps <= 1'b0;
       end
    end
     
    assign bps_sig = (cnt_bps ==  13'd217) ? 1'b1 : 1'b0;  //将采集数据的时刻放在波特率计数器每次循环计数的中间位置
     
endmodule