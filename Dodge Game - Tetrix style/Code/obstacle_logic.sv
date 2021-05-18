/*
obstacle_logic shifts the whole obstacle board down by one and also puts the new row at the top
furthuremore, this module only updates when update_obstacle is set high

INPUTS:
Obstacle_logic takes in clk, reset, game_Over, and update_obstacle for the operation
game_Over: game over condition of game. 0 = game on, 1 = game Over
update_obstacle: updates the obstacle array only when this is high and on posedge clk
row_data: new row that should be generated at the top.

OUTPUTS:
obstacle_data: the output array of the locations of the obstacle blocks
*/

module obstacle_logic #(parameter board_width = 9, board_height = 16) ( clk, reset, game_Over, update_obstacle, row_data, obstacle_data );

	input logic clk, reset, game_Over, update_obstacle;
	input logic [board_width-1:0] row_data;
	output logic [board_width-1:0] obstacle_data [0:board_height-1];
	
	logic [board_width-1:0] this_obstacle_data [0:board_height-1];
	
	integer i,j;
	
	always_comb 												// shifts obstacles down
		if ( update_obstacle && ~game_Over ) begin
			for ( j = board_height-1; j > board_height-1-4; j-- )
				this_obstacle_data[j] = obstacle_data[j-1];
			for ( j = board_height-1-4; j > 0; j-- )
				this_obstacle_data[j] = obstacle_data[j-1];
			this_obstacle_data[0] = row_data;
		end
		else 
			for ( j = 0; j < board_height; j++ )		// keeps the obstacles in the saem place
				this_obstacle_data[j] = obstacle_data[j];
	
	always_ff @(posedge clk) 
		if ( reset )
			for ( i = 0; i < 2 ** 4; i++ )				// zeros all the obstacles
				obstacle_data[i] <= 0;
		else
			obstacle_data <= this_obstacle_data;

endmodule

// tests the functionality of obstacle_logic
module obstacle_logic_testbench();
	
	parameter board_width = 9, board_height = 16;
	
	logic clk, reset, game_Over, update_obstacle;
	logic [board_width-1:0] row_data;
	logic [board_width-1:0] obstacle_data [0:board_height-1];
	
	obstacle_logic #(board_width, board_height) dut ( clk, reset, game_Over, update_obstacle, row_data, obstacle_data );
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1; @(posedge clk);
		reset <= 0; game_Over <= 0; row_data <= 42; update_obstacle <= 0; @(posedge clk);	// no Update and not game Over
		@(posedge clk);
		
		update_obstacle <= 1; @(posedge clk);	// Updating and not game Over
		@(posedge clk);
		
		row_data <= 83; @(posedge clk);			
		row_data <= 0; @(posedge clk);
		@(posedge clk);
		
		row_data <= 32; @(posedge clk);
		game_Over <= 1; @(posedge clk);			// GameOver and Updating
		@(posedge clk);
		@(posedge clk);
		$stop;
	end
	
endmodule