/*
board_logic mashes the locations of all the obstacle blocks and the player blocks together.
will only mash together when update_board is set high

INPUTS:
game_Over: game over condition of game. 0 = game on, 1 = game Over
update_board: updates the board only when this signal is high and on posedge clk
player_pos: [4:0] vector that will hold the position of the player. Currently will be 0 representing the right column
	1 is 1 to the left, 2 is the next left, and following. Its numerical, not graphical
obstacle_data: array of the locations of the obstacle blocks

OUTPUTS:
board_data: holds all the locations of any block, whether obstacle or player.
*/
module board_logic #(parameter board_width = 9, board_height = 16) ( clk, reset, game_Over, update_board, player_pos, obstacle_data, board_data );

	input logic clk, reset, game_Over, update_board;
	input logic [4:0] player_pos;
	input logic [board_width-1:0] obstacle_data [0:board_height-1];
	output logic [board_width-1:0] board_data [0:board_height-1];
	
	logic [board_width-1:0] this_board_data [0:board_height-1];

	logic [2:0] player_row [0:3] =			// player design
		'{ 3'b101,
			3'b010,
			3'b111,	
			3'b010 };
	
	integer i,j;
	
	always_comb begin
		if ( update_board && ~game_Over ) begin			// updates the board
			for ( i = board_height-1; i > board_height-1-4; i-- )
				this_board_data[i] = obstacle_data[i] | player_row[board_height-1-i] << ( 3*player_pos );
			for ( i = board_height-1-4; i >= 0; i-- )
				this_board_data[i] = obstacle_data[i];
		end
		else															// keeps the board the same
			for ( i = 0; i < board_height; i++ )
				this_board_data[i] = board_data[i];
	end
		
	always_ff @(posedge clk)
		if ( reset )
			for ( j = 0; j < board_height; j++ )			// zeros the entire board
				board_data[j] <= 0;
		else
			board_data <= this_board_data;
		
endmodule

// tests the functionality of board_logic
module board_logic_testbench();

	parameter board_width = 9, board_height = 16;

	logic clk, reset, game_Over, update_board;
	logic [4:0] player_pos;
	logic [board_width-1:0] obstacle_data [0:board_height-1];
	logic [board_width-1:0] board_data [0:board_height-1];
	
	board_logic dut ( clk, reset, game_Over, update_board, player_pos, obstacle_data, board_data );
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	integer i;
	initial begin
		reset <= 1; @(posedge clk);
		reset <= 0; game_Over <= 0; update_board <= 1; player_pos <= 1;	// Player position 1 and obstacle data
		for ( i = 0; i < board_height; i++ )
			obstacle_data[i] <= 8 + 5 * i;
		@(posedge clk);
		player_pos <= 2;									// Player position 2 and new obstacle data
		for ( i = 0; i < board_height; i++ )
			obstacle_data[i] <= 3 + 5 * i;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		$stop;
	end
	
endmodule