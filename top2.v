module top2(
input          clk     ,
		 input          rst_n   ,
		 input          echo2    ,
		 
		 //output  [6:0]  smg_duan,
		// output  [3:0]  smg_wei ,
		 //output         dp      ,
		 output         trig2,
		 output         led0,
		 output      [9:0]hz
    );   
         
    
	wire [8:0]  dis    ;
	wire        tran_en;
	
    hc_sr042 HC_SR04_inst(
	          .clk    (clk   ),
	          .rst_n  (rst_n ),
	          .en     (1'b1  ),
	          .echo2	  (echo2	 ),
	          .trig2   (trig2  ),
	          .dis    (dis   )
    );
	
	reg  [ 8:0] dis_reg;
	wire [ 8:0] dis_wire;
	wire [15:0] bcd;
	always @(posedge clk or negedge rst_n) begin
	   if (!rst_n)
	      dis_reg <= 0;
	   else 
	      dis_reg <= dis;
	end
	
	assign dis_wire = dis_reg;
	assign tran_en = (dis_reg != dis)? 1'd1:1'd0;
	
	bcd2 bin_bcd_inst(
              .clk         (clk       ),
              .rst_n       (rst_n     ),
              .tran_en     (1'd1   ),
              .data_in     ({7'd0,dis_wire}),
              .tran_done   (          ),
              .bcd         (bcd       )
 
 );
 
    smg2 x7seg_msg_inst(
              .x         (bcd     ),
	          .clk       (clk     ),
	          .rst_n       (rst_n  ),
	          //.smg_duan  (smg_duan),
	          //.smg_wei   (smg_wei ),
	          //.dp        (dp      ),
			  .led0 (led0),
			  .hz(hz)
    );

endmodule
