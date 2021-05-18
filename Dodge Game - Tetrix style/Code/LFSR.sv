/*
Outputs a pseudo-random 3 bit number
INPUT:
next: will send out new random number whenever this is high
state: will only work when this is set low

OUTPUT:
out: the output of the pseudo-random 3 bit number
*/

module LFSR ( clk, reset, next, state, out );

	input logic clk, reset, next, state;
	output logic [2:0] out;
	
	always_ff @(posedge clk)
		if ( reset )
			out <= 3'b000;
		else if ( next && state == 0 ) begin	// generates the new numb
			out <= out >> 1;
			out[2] <= ~( out[1] ^ out[0] );
		end
	
endmodule

// This module tests the capabilities of the LFSR
// by testing it with all possible combinations of inputs.
module LFSR_testbench();

	logic clk, reset, next, state;
	logic [2:0] out;
	
	LFSR dut ( clk, reset, next, state, out );
	
	parameter CLOCK_PERIOD=100;
	// Set up the clock.
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	// Set up the inputs to the design. Each line is a clock cycle.
	
	integer i;
	initial begin
		reset <= 1; @(posedge clk);
		reset <= 0; @(posedge clk); next <= 1; state <= 0;
		for ( i = 0; i < 12; i++ )
			@(posedge clk);
		next <= 0;
		for ( i = 0; i < 12; i++ )
			@(posedge clk);
		next <= 1; state <= 1;
		for ( i = 0; i < 12; i++ )
			@(posedge clk);
		$stop;
	end

endmodule