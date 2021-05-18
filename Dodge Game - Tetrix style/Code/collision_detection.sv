/*
collision_detection outputs if the game is over based on player location and obstacle locations

INPUTS:
update_collision: will only check collision when high and on clock edge of 
player_pos: [4:0] vector that will hold the position of the player. Currently will be 0 representing the right column
	1 is 1 to the left, 2 is the next left, and following. Its numerical, not graphical
obstacle_data: the array of the locations of the obstacle blocks

OUTPUTS:
game_Over: ouputs the game over condition of game. 0 = game On, 1 = game Over
*/

module collision_detection #(parameter board_width = 9, board_height = 16) ( clk, reset, update_collision, player_pos, obstacle_data, game_Over );

	input logic clk, reset, update_collision;
	input logic [4:0] player_pos;
	input logic [board_width-1:0] obstacle_data [0:board_height-1];
	output logic game_Over;
	
	logic [2:0] player_row [0:3] =
		'{ 3'b101,
			3'b010,
			3'b111,	
			3'b010 };
	
	logic this_game_Over;
	logic state;
	
	logic temp;
	always_comb begin
	
		case ( player_pos )			// checks which player position it is. This is kinda long but needs to be for synthesis
			5'b00000: temp = ( obstacle_data[15][2:0] & ( player_row[board_height-1-15]  ) ) |
								  ( obstacle_data[14][2:0] & ( player_row[board_height-1-14]  ) ) |
								  ( obstacle_data[13][2:0] & ( player_row[board_height-1-13]  ) ) |
								  ( obstacle_data[12][2:0] & ( player_row[board_height-1-12]  ) ) > 0;
			5'b00001: temp = ( obstacle_data[15][5:3] & ( player_row[board_height-1-15]  ) ) |
								  ( obstacle_data[14][5:3] & ( player_row[board_height-1-14]  ) ) |
								  ( obstacle_data[13][5:3] & ( player_row[board_height-1-13]  ) ) |
								  ( obstacle_data[12][5:3] & ( player_row[board_height-1-12]  ) ) > 0;
			5'b00010: temp = ( obstacle_data[15][8:6] & ( player_row[board_height-1-15]  ) ) |
								  ( obstacle_data[14][8:6] & ( player_row[board_height-1-14]  ) ) |
								  ( obstacle_data[13][8:6] & ( player_row[board_height-1-13]  ) ) |
								  ( obstacle_data[12][8:6] & ( player_row[board_height-1-12]  ) ) > 0;
			default: temp = 0;
		endcase
		
		if (update_collision && ~game_Over) begin			// only assigns game_Over if we can want to update the collision case
			state = 0;
			this_game_Over = temp;
		end
		else begin
			this_game_Over = game_Over;
			state = 1;
		end
		
	end
	
	always_ff @(posedge clk)
		if ( reset )
			game_Over <= 0;
		else
			game_Over <= this_game_Over;
		

endmodule

// tests the functionality of collision_detection
module collision_detection_testbench();

	parameter board_width = 9, board_height = 16;

	logic clk, reset, update_collision;
	logic [4:0] player_pos;
	logic [board_width-1:0] obstacle_data [0:board_height-1];
	logic game_Over;
	
	collision_detection dut ( clk, reset, update_collision, player_pos, obstacle_data, game_Over );
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1; @(posedge clk);
		reset <= 0; update_collision <= 1; player_pos <= 0; obstacle_data[15] <= 42; obstacle_data[14] <= 42; obstacle_data[13] <= 42; obstacle_data[12] <= 42; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		reset <= 1; player_pos <= 2; @(posedge clk);
		reset <= 0; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		player_pos <= 1; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		$stop;
	end
	
endmodule