//**************************************************************************************
//  Author		: Inc
//  Module Name		: FTDI ENGINE 
//  Description		: FTDI RD WR ENGINE
//  DoR			: June 2021
//  Rev. History	: v3
//  Remarks		: ftdi wr data is updated with register
//                        [v3] - added missing wires and registers
//
//***************************************************************************************

`timescale 1 ns / 1 ps

module ftdi_engine ( 
	input wire        clk_i        ,
	input wire        async_rst_n  ,

        // from/to FTDI CHIP
	input wire       rxf_n        ,
	output reg       rd_n         ,
    
        input  wire       txe_n        ,
        output reg        wr_n         ,
 

        input  wire [7:0] data_in      ,
	output wire [7:0] data_out     ,

	output reg        data_oe      ,

        // RD ASYNC FIFO 
	input wire        ftdi_rd_fifo_full ,
	output reg [7:0]  ftdi_rd_fifo_data ,
        output reg        ftdi_rd_fifo_en   ,	
     

        // WR ASYNC FIFO 
	input wire        ftdi_wr_fifo_empty ,
	input wire [7:0]  ftdi_wr_data       ,
        output reg        ftdi_wr_fifo_en   	
);


  localparam  IDLE             = 3'd0;  
  localparam  RD_PRE_WAIT      = 3'd1;
  localparam  RD_POST_WAIT     = 3'd2;
  localparam  WR_PRE_DATA_LOAD = 3'd3;
  localparam  WR_DONE          = 3'd4;
  localparam  FTDI_BACK_OFF    = 3'd5;


  reg [2:0]  ftdi_eng_state    ; 
  reg [2:0]  ftdi_eng_state_nxt;

  reg rxf_n_meta;
  reg rxf_n_synq;

  reg txe_n_meta;
  reg txe_n_synq;

  reg [1:0] counter_nxt; 
  reg [1:0] counter_reg;


  reg        data_oe_nxt  ;

  wire       rxf          ;
  reg [7:0]  data_in_nxt  ;
  reg [7:0]  data_in_reg  ;
  reg        wr_n_nxt     ;
  reg [7:0]  data_out_reg ;
  reg [7:0]  data_out_nxt ;

  wire       txe          ;

  assign data_out = data_out_reg;

  // double flop sync <level>
  always @ (posedge clk_i) begin
    rxf_n_meta  <= rxf_n      ;
    rxf_n_synq  <= rxf_n_meta ;

    txe_n_meta  <= txe_n      ;
    txe_n_synq  <= txe_n_meta ;
  end	  

  assign rxf   = ~ rxf_n_synq;
  assign txe   = ~ txe_n_synq; 


  always @(posedge clk_i, negedge async_rst_n) begin
    if (!async_rst_n) begin
       ftdi_eng_state <= IDLE;
       counter_reg    <= 2'd0;
       wr_n           <= 1'd1;
       data_in_reg    <= 8'd0;
       data_oe        <= 1'b0;
       data_out_reg   <= 8'd0;
    end
    else begin
       ftdi_eng_state <= ftdi_eng_state_nxt;
       counter_reg    <= counter_nxt       ;
       wr_n           <= wr_n_nxt          ;
       data_in_reg    <= data_in_nxt       ;
       data_oe        <= data_oe_nxt       ;
       data_out_reg   <= data_out_nxt      ;

    end
  end

  always @(*) begin
    ftdi_eng_state_nxt = ftdi_eng_state;
    counter_nxt        = counter_reg   ;
    data_oe_nxt        = 1'b0          ;
    wr_n_nxt           = 1'b1          ;
    data_in_nxt        = data_in_reg   ;
    
    ftdi_rd_fifo_en    = 1'b0          ;
    ftdi_wr_fifo_en    = 1'b0          ;
    rd_n               = 1'b1          ;
    data_out_nxt       = data_out_reg  ;
    ftdi_rd_fifo_data  = 8'd0          ;

    case (ftdi_eng_state) 
      IDLE: begin
	counter_nxt          = 2'd0;
        if ((rxf == 1'b1) && (!ftdi_rd_fifo_full)) begin
          ftdi_eng_state_nxt = RD_PRE_WAIT;
	  rd_n               = 1'b0;       
        end
        else if ((txe == 1'b1) && (!ftdi_wr_fifo_empty)) begin
          ftdi_eng_state_nxt = WR_PRE_DATA_LOAD;
	  ftdi_wr_fifo_en    = 1'b1;
	end	
      end
      RD_PRE_WAIT: begin // must wait for 14ns before read data
	rd_n             = 1'b0;       
        counter_nxt = counter_reg + 1'b1 ;	      
        if (counter_reg == 2'd1) begin
           ftdi_eng_state_nxt = RD_POST_WAIT;
	   data_in_nxt        = data_in; 
        end		
      end
      RD_POST_WAIT: begin // rd_n must maintain 30ns
	rd_n               = 1'b1;       
        ftdi_rd_fifo_data  = data_in_reg    ;
        ftdi_rd_fifo_en    = 1'b1           ;	
        ftdi_eng_state_nxt = FTDI_BACK_OFF  ;
      end
      WR_PRE_DATA_LOAD: begin // pre loads data on the bus
         counter_nxt        = counter_reg + 1'b1   ;
	 if (counter_reg == 2'd0) begin
           data_out_nxt       = ftdi_wr_data;		 
         end		 
         else if (counter_reg == 2'd1) begin	 
	   data_oe_nxt        = 1'b1        ;
           ftdi_eng_state_nxt = WR_DONE     ;
	   counter_nxt        = 'd0         ;
         end  
      end      
      WR_DONE: begin  // wr_n should maintain 30 ns
	 counter_nxt   = counter_reg + 1'b1;
	 data_oe_nxt   = 1'b1              ;
	 wr_n_nxt      = 1'b0              ;
         if (counter_reg == 2'd3) begin
	    wr_n_nxt      = 1'b1                    ;
	    data_oe_nxt   = 1'b0                    ;
            ftdi_eng_state_nxt = FTDI_BACK_OFF      ;
	 end	 
      end
      FTDI_BACK_OFF: begin
        ftdi_eng_state_nxt = IDLE      ;
      end	      
    endcase	    
  end 
   
endmodule
