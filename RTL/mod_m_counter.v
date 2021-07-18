`timescale 1 ns/ 1 ps
//**********************************************************************************************************
//  Module Name			: Mod-m counter
//  Designer			: Inc
//  DoR				: Jul 2021
//  Revision History		: v1
//  Remarks			: sys clk - 48MHz
//                                default: 1ms-50000
//
//
//
//
//
//
//************************************************************************************************************
module mod_m_counter #(parameter COUNT = 50_000)(
  input wire clk_i,
  input wire rst_n,

  output wire count_tick
);



  reg [$clog2(COUNT):0] count_reg;
  reg [$clog2(COUNT):0] count_nxt;

  always @(posedge clk_i, negedge rst_n) begin
    if (!rst_n) begin
      count_reg  <= 'd0;
    end
    else begin
      count_reg  <= count_nxt;
    end	    
  end

  always @(*) begin
    if (count_reg == COUNT) begin
      count_nxt = 'd0;	   
    end
    else begin
      count_nxt = count_reg + 1'b1;	   
    end	    
  end	  

  assign count_tick = (count_reg == COUNT);

endmodule
