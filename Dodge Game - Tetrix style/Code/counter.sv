/* Calculate the score the player gets. Maximum point is 99
	input:
		clk	:	clock signal
		reset	:	reset signal
		on		:	1 if the game is going on, 0 otherwise
		
	output:
		score	: 8-bit number of the player's score
*/
module counter(clk, reset, on, score);
	input logic clk, reset, on;
	output logic [7:0] score;
	
	integer i;
	
	always_ff @(posedge clk) begin
		if (reset) begin
			score <= 0;
			i <= 0;
		end
		else begin
			if (!on) begin
				i <= 0;
				score <= 0;
			end
			else begin
				if (i == 7) begin
					if (score == 99) score <= 99;
					else	score <= score + 1;
					i <= 0;
				end
				else begin
					i <= i + 1;
					score <= score;
				end
			end
		end
	end
endmodule

module counter_testbench();
	logic clk, reset, on;
	logic [7:0] score;

	counter dut (clk, reset, on, score);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	integer j;
	
	initial begin
		reset <= 1; on <= 0;	@(posedge clk);
		reset <= 0; 			@(posedge clk);
									@(posedge clk);
						on <= 1;	@(posedge clk);
		for (j = 0; j < 20; j++)
									@(posedge clk);
		$stop;
	end
endmodule 