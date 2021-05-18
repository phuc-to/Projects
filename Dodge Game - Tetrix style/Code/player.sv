/*
player will output the player's position based on whether left or right is set high.
only updates the position when update_player is set high

INPUTS:
game_Over: game over condition of game. 0 = game on, 1 = game Over
update_player: updates players only when this is high and on posedge clk
left: will move player 1 large column left per clk cycle
right: will move player 1 large column right per clk cycle

OUTPUTS:
player_pos: outputs [4:0] vector that will hold the position of the player. Currently will be 0 representing the right column
	1 is 1 to the left, 2 is the next left, and following. Its numerical, not graphical
*/

module player #(parameter board_width = 9) ( clk, reset, game_Over, update_player, left, right, player_pos );
	
	input logic clk, reset, game_Over, update_player, left, right;
	output logic [4:0] player_pos;
	
	logic [4:0] next_player_pos;
	
	always_comb begin
		next_player_pos = player_pos;
		if ( update_player && ~game_Over )
			case ( { left, right } )		// shifts the player position if going left or right
				2'b10: if ( player_pos < board_width/3-1 ) next_player_pos = player_pos + 1;
				2'b01: if ( player_pos > 0 ) next_player_pos = player_pos - 1;
				default: next_player_pos = player_pos;
			endcase	
	end
	
	always_ff @(posedge clk)
		if ( reset )			// resets the player position to the center of the board
			player_pos <= board_width / 3 / 2;
		else
			player_pos <= next_player_pos;
			
endmodule

// tests the functionality of player
module player_testbench();

	parameter board_width = 9;

	logic clk, reset, game_Over, update_player, left, right;
	logic [4:0] player_pos;
	
	player dut ( clk, reset, game_Over, update_player, left, right, player_pos );
	
	parameter CLOCK_PERIOD = 100;
	// Setup Clock
	
	initial begin
		clk <= 0;
		forever #( CLOCK_PERIOD / 2 ) clk <= ~clk;
	end
	// clk Periods
	
	initial begin
		reset <= 1; @(posedge clk);
		reset <= 0; update_player <= 1; left <= 1; right <= 0; game_Over <= 0; @(posedge clk);	// When not game Over
		@(posedge clk);
		@(posedge clk);
		right <= 1; @(posedge clk);
		@(posedge clk);
		left <= 0; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		right <= 0; @(posedge clk);
		@(posedge clk);
		left <= 1; @(posedge clk);
		
		game_Over <= 1; left <= 1; @(posedge clk);	// When game Over
		@(posedge clk);
		@(posedge clk);
		right <= 1; @(posedge clk);
		@(posedge clk);
		left <= 0; @(posedge clk);
		@(posedge clk);
		right <= 0; @(posedge clk);
		@(posedge clk);
		$stop;
		
		game_Over <= 0; update_player <= 0; left <= 1; @(posedge clk);	// When not updating player
		@(posedge clk);
		@(posedge clk);
		right <= 1; @(posedge clk);
		@(posedge clk);
		left <= 0; @(posedge clk);
		@(posedge clk);
		right <= 0; @(posedge clk);
		@(posedge clk);
		$stop;
	end
	
endmodule