/*===============================================================================================================================
   Module       : Pipeline Skid Buffer

   Description  : Pipeline Skid Buffer is used as buffer in pipeline between two modules.  
                  - Smallest pipeline buffer; implemented with just two registers.   
                  - Simple valid-ready handshaking.
                  - Latency = 1 cycle. 
                  - Configurable data width.              

   Developer    : Mitu Raj, chip@chipmunklogic.com at Chipmunk Logic ™, https://chipmunklogic.com
   Notes        : -
   License      : Open-source.
   Date         : Mar-26-2022
===============================================================================================================================*/

/*-------------------------------------------------------------------------------------------------------------------------------
                                                P I P E   S K I D   B U F F E R
-------------------------------------------------------------------------------------------------------------------------------*/

module pipe_skid_buffer #(
   
   // Global Parameters   
   parameter DWIDTH    =  8                                // Data width
                                                          
) 

(
   input  logic                clk             ,           // Clock
   input  logic                rstn            ,           // Active-low synchronous reset
   
   // Input Interface   
   input  logic [DWIDTH-1 : 0] i_data          ,           // Data in
   input  logic                i_valid         ,           // Data in valid
   output logic                o_ready         ,           // Ready out
   
   // Output Interface
   output logic [DWIDTH-1 : 0] o_data          ,            // Data out
   output logic                o_valid         ,            // Data out valid
   input  logic                i_ready                      // Ready in
) ;


/*-------------------------------------------------------------------------------------------------------------------------------
   Local Parameters
-------------------------------------------------------------------------------------------------------------------------------*/

// State encoding
localparam PIPE  = 1'b0 ;
localparam SKID  = 1'b1 ;


/*-------------------------------------------------------------------------------------------------------------------------------
   Internal Registers/Signals
-------------------------------------------------------------------------------------------------------------------------------*/
logic                state_rg                                  ;        // State register
logic [DWIDTH-1 : 0] data_rg, sparebuff_rg                     ;        // Data buffer, Spare buffer
logic                valid_rg, sparebuff_valid_rg, ready_rg    ;        // Valid and Ready signals 
logic                ready                                     ;        // Pipeline ready signal


/*-------------------------------------------------------------------------------------------------------------------------------
   Synchronous logic 
-------------------------------------------------------------------------------------------------------------------------------*/
always @(posedge clk) begin
   
   // Reset  
   if (!rstn) begin
      
      // Internal Registers
      state_rg           <= PIPE ;
      data_rg            <= '0   ;     
      sparebuff_rg       <= '0   ;
      valid_rg           <= 1'b0 ;
      sparebuff_valid_rg <= 1'b0 ;
      ready_rg           <= 1'b0 ;

   end
   
   // Out of reset
   else begin
      
      case (state_rg)   
         
         /* Stage where data is piped out or stored to spare buffer */  
         PIPE : begin
            
            // Pipe data out             
            if (ready) begin
               data_rg            <= i_data  ;  
               valid_rg           <= i_valid ;
               ready_rg           <= 1'b1    ;               
            end

            // Pipeline stall, store input data to spare buffer (skid happened)
            else begin
               sparebuff_rg       <= i_data  ;
               sparebuff_valid_rg <= i_valid ;
               ready_rg           <= 1'b0    ;
               state_rg           <= SKID    ;
            end

         end
         
         /* Stage to wait after data skid happened */
         SKID : begin
            
            // Copy data from spare buffer to data buffer, resume pipeline           
            if (ready) begin
               data_rg  <= sparebuff_rg       ;
               valid_rg <= sparebuff_valid_rg ;               
               ready_rg <= 1'b1               ;
               state_rg <= PIPE               ;               
            end

         end

      endcase

   end

end


/*-------------------------------------------------------------------------------------------------------------------------------
   Continuous Assignments
-------------------------------------------------------------------------------------------------------------------------------*/
assign ready   = i_ready || ~valid_rg ;
assign o_ready = ready_rg             ;
assign o_data  = data_rg              ;
assign o_valid = valid_rg             ;


endmodule

/*-------------------------------------------------------------------------------------------------------------------------------
                                                P I P E   S K I D   B U F F E R
-------------------------------------------------------------------------------------------------------------------------------*/