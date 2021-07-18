`timescale 1 ns / 1 ps
//*****************************************************************************************
//  Module Name		: loop back generator for testing
//  Author		: Inc
//  DoR			: JUl 2021
//  Remarks		: 
//  Rev. History	: v1 
//  ASCII TABLE         : DEC  : 48 | 49 | ........|57 | 
//                        CHAR : 0  | 1  |         |9  |
//                        DEc :45 (-)
//
//
//
//
//
//
//*******************************************************************************************
module loop_back_gen (
  input wire       clk_i         ,
  input wire       rst_n         ,

  input wire       msec_pulse    ,

  output reg [7:0]  data_out     ,
  output reg        data_out_pulse
);


  reg [7:0] data_nxt  ;
  reg       nxt_period_tx;
  reg       period_tx    ;


  parameter [1:0] IDLE   = 2'd0;
  parameter [1:0] NUM_TX = 2'd1;
  parameter [1:0] PER_TX = 2'd2;

  reg [1:0] tx_state, nxt_tx_state;
  wire      clr_num;
  reg  [7:0] num_reg,nxt_num_reg;
  reg  [7:0] per_reg;
  reg        nxt_data_out_pulse;
  reg  [7:0] nxt_data_out;


  always @(posedge clk_i, negedge rst_n) begin
    if (!rst_n) begin
      tx_state       <= IDLE;
      num_reg        <= 8'd48;
      per_reg        <= 8'd45;
      data_out       <= 8'd0;
      data_out_pulse <= 1'd0;
    end
    else begin
      tx_state       <= nxt_tx_state;
      num_reg        <= nxt_num_reg;
      per_reg        <= per_reg    ;
      data_out       <= nxt_data_out;
      data_out_pulse <= nxt_data_out_pulse;
    end	    
  end	  

  
  assign clr_num = (num_reg == 8'd57) ? 1'b1: 1'b0;

  always @(*) begin
    nxt_tx_state       = tx_state;
    nxt_data_out       = data_out;
    nxt_data_out_pulse = 1'b0;
    nxt_num_reg        = num_reg;   
    case(tx_state)
      IDLE: begin
        if (msec_pulse) begin
          nxt_tx_state      = PER_TX;
	  nxt_data_out      = num_reg;
	  nxt_data_out_pulse= 1'b1;
        end		
      end
      NUM_TX: begin
        if (msec_pulse) begin
	  if (clr_num) begin
	    nxt_data_out      = num_reg;
	    nxt_data_out_pulse= 1'b1;
	    nxt_tx_state      = PER_TX;
	    nxt_num_reg       = 8'd47;
	  end
          else begin
	    nxt_data_out      =  num_reg;
	    nxt_data_out_pulse= 1'b1;
	    nxt_tx_state      = PER_TX;
	  end	  
        end		
      end
      PER_TX: begin
        if (msec_pulse) begin
          nxt_data_out       = per_reg;
	  nxt_data_out_pulse = 1'b1;
	  nxt_tx_state       = NUM_TX;
	  nxt_num_reg        = num_reg + 1'b1;
        end	
      end	      
    endcase	    
  end	  

 
endmodule
