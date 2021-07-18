`timescale 1 ns/1 ps
//************************************************************************************************
//  Module name		: Sakura control core <sync>
//  Author		: Inc
//  DoR			: Jul 2021
//  Rev. History	: v2
//  Remarks		: 
//
//
//
//
//
//
//
//
//
//
//***************************************************************************************************
module sakura_cntrl_core_test (
  input wire         sys_clk	,
  input wire         sys_rst_n  ,

  // ftdi CHIP bus
  input  wire         rxf_n   ,
  output wire         rd_n    ,
  input  wire         txe_n   ,
  output wire         wr_n    ,
  inout  wire   [7:0] data    

);


  wire clk_ftdi   ;

  wire       data_oe       ;

  wire [7:0] data_out          ;

  wire [7:0] data_in;
 
  reg       ftdi_wr_fifo_empty;
  reg [7:0] ftdi_wr_data      ;
  reg       nxt_ftdi_wr_fifo_empty;
  reg [7:0] nxt_ftdi_wr_data;

  wire       ftdi_wr_fifo_en   ; 



  wire [7:0] data_out_gen     ;

  assign data     = (data_oe) ? data_out : 'bz;
  assign data_in  = data; 


  // ftdi interface
  ftdi_engine FTDI_ENG_INST (
  .async_rst_n       (sys_rst_n       ),
  .clk_i             (sys_clk         ),

   // ftdi CHIP bus
   .rxf_n            (rxf_n            ),
   .rd_n             (rd_n             ),
   .txe_n            (txe_n            ),
   .wr_n             (wr_n             ),
   .data_in          (data_in          ),
   .data_out         (data_out         ),
   .data_oe          (data_oe          ), 

   .ftdi_rd_fifo_full (                 ),
   .ftdi_rd_fifo_data (                 ),
   .ftdi_rd_fifo_en   (                 ),

   .ftdi_wr_fifo_empty(ftdi_wr_fifo_empty),
   .ftdi_wr_data      (ftdi_wr_data      ),
   .ftdi_wr_fifo_en   (ftdi_wr_fifo_en   ) );


  // sync core control module
  loop_back_top LOOP_BACK_INST (
    .clk_i             (sys_clk             ),
    .rst_n             (sys_rst_n           ),

    .data_out          (data_out_gen         ),
    .data_out_pulse    (data_out_pulse       ) );


  // control logic
  always @(posedge sys_clk, negedge sys_rst_n) begin
    if (!sys_rst_n) begin
      ftdi_wr_data       <= 8'd0;
      ftdi_wr_fifo_empty <= 1'b1;
    end
    else begin
      ftdi_wr_data        <= nxt_ftdi_wr_data;
      ftdi_wr_fifo_empty  <= nxt_ftdi_wr_fifo_empty;    
    end	    
  end	  

  always @(*) begin
    nxt_ftdi_wr_fifo_empty = ftdi_wr_fifo_empty;
    nxt_ftdi_wr_data       = ftdi_wr_data;    
    if (data_out_pulse) begin
       nxt_ftdi_wr_data        = data_out_gen; 
       nxt_ftdi_wr_fifo_empty  = 1'b0        ;
    end
    else if (ftdi_wr_fifo_en) begin
       nxt_ftdi_wr_fifo_empty  = 1'b1    ;
    end	    
  end	  

  
endmodule
