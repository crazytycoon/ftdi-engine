`timescale 1 ns / 1 ps
//*****************************************************************************************
//  Module Name		: loop back top module
//  Author		: Inc
//  DoR			: JUl 2021
//  Remarks		: fifo rd data shoudl read after data_rd_req 
//  Rev. History  	: v2
//
//
//
//
//
//
//
//
//*******************************************************************************************
module loop_back_top (
  input wire       clk_i         ,
  input wire       rst_n         ,

  output wire [7:0] data_out      ,
  output wire       data_out_pulse
 );

  wire  msec_pulse;


// milli sec pulse generator
mod_m_counter #(.COUNT(50_000)) MODM_U1(
  .clk_i       (clk_i            ),
  .rst_n       (rst_n            ),
  .count_tick  (msec_pulse       )
);

loop_back_gen LPBC_U2 (
  .clk_i         (clk_i                     ),
  .rst_n         (rst_n                     ),
  .msec_pulse    (msec_pulse                ),
  .data_out_pulse (data_out_pulse           ),
  .data_out       (data_out                 )
);


 
endmodule
