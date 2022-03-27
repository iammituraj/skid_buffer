/*===============================================================================================================================
   Module       : Skid Buffer

   Description  : Skid Buffer is used as an elastic buffer to store the data when receiver applies backpressure to sender. 
                  - Latency-0 buffer implemented with just one register.    
                  - Simple valid-ready handshaking.
                  - Configurable data width.              

   Developer    : Mitu Raj, chip@chipmunklogic.com at Chipmunk Logic ™, https://chipmunklogic.com
   Notes        : -
   License      : Open-source.
   Date         : Mar-26-2022
===============================================================================================================================*/

/*-------------------------------------------------------------------------------------------------------------------------------
                                                      S K I D   B U F F E R
-------------------------------------------------------------------------------------------------------------------------------*/

module skid_buffer #(
   
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
   Internal Registers/Signals
-------------------------------------------------------------------------------------------------------------------------------*/
logic                ready_rg   ;        // Ready 
logic [DWIDTH-1 : 0] data_rg    ;        // Data buffer
logic                bypass_rg  ;        // Bypass signal to data and data valid muxes


/*-------------------------------------------------------------------------------------------------------------------------------
   Synchronous logic
-------------------------------------------------------------------------------------------------------------------------------*/
always @(posedge clk) begin
   
   // Reset  
   if (!rstn) begin
      
      // Internal Registers
      ready_rg  <= 1'b0 ;
      data_rg   <= '0   ;     
      bypass_rg <= 1'b1 ;

   end
   
   // Out of reset
   else begin
      
      // Bypass state      
      if (bypass_rg) begin
         
         ready_rg <= 1'b1 ;

         if (!i_ready && i_valid && ready_rg) begin
            ready_rg  <= 1'b0   ;            
            data_rg   <= i_data ;        // Data skid happened, store to buffer
            bypass_rg <= 1'b0   ;        // To skid mode  
         end 

      end
      
      // Skid state
      else begin
         
         if (i_ready) begin
            ready_rg  <= 1'b1   ;            
            bypass_rg <= 1'b1   ;        // Back to bypass mode           
         end

      end      

   end

end


/*-------------------------------------------------------------------------------------------------------------------------------
   Continuous Assignments
-------------------------------------------------------------------------------------------------------------------------------*/
assign o_ready = ready_rg                                   ;        
assign o_data  = bypass_rg ? i_data  : data_rg              ;        // Data mux
assign o_valid = bypass_rg ? (i_valid & ready_rg) : 1'b1    ;        // Data valid mux


endmodule

/*-------------------------------------------------------------------------------------------------------------------------------
                                                      S K I D   B U F F E R
-------------------------------------------------------------------------------------------------------------------------------*/
