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
module mod_m_counter_tb;

  parameter COUNT = 50_000;

  reg clk_i = 0;
  reg rst_n = 1;

  wire count_tick;

 // DUT instantiation 
 mod_m_counter #(.COUNT(COUNT)) CNTR_U1 (
   .clk_i (clk_i          ),
   .rst_n (rst_n          ),
   .count_tick (count_tick)
 );

 //clock gen
 always #10 clk_i = ~clk_i;

 // rst gen
 task neg_rst_gen ();	 
   begin
     @(negedge clk_i);
     rst_n = 0;
     @(negedge clk_i);
     rst_n = 1;
   end
  endtask   

  initial begin
    $dumpfile ("dump.vcd");
    $dumpvars(0,mod_m_counter_tb);
    neg_rst_gen;
    wait (count_tick);
    $display ("first wait tick recieved");
    #100;
    wait (count_tick);
    $display ("second wait tick recieved");
    #100;
    $finish;
  end	  



endmodule
