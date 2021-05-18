/* 
generate_row will create a new psuedo-random row of obstacles for the top of the board.
transitions between generate new empty rows or new rows of obstacles.
only updates when game_Over is high

INPUTS:
game_Over: ouputs the game over condition of game. 0 = game On, 1 = game Over
update_obstacle: updates the new row_data only when this is high and on posedge clk

OUTPUTS:
row_data: new row that will be generated at the top.
*/

module generate_row #(parameter board_width = 9) ( clk, reset, game_Over, update_obstacle, row_data );

	input logic clk, reset, game_Over, update_obstacle;
	output logic [board_width-1:0] row_data;
	
	logic [board_width-1:0] this_row_data;
	
	logic [2:0] obstacle_row [0:3] =
		'{  3'b101,
			3'b010,
			3'b111,	
			3'b010 };
	
	logic [4:0] row_counting;
	logic [2:0] row_shifted;
	enum { obstacle, empty } row_state;
	
	LFSR lfsr ( clk, reset, row_counting == 3, row_state != empty, row_shifted );	// generates the random row shift
	
	always_comb
		if ( update_obstacle && ~game_Over )	// shifts for the new row
			case ( row_state )
				obstacle:
					this_row_data = obstacle_row[row_counting] << row_shifted ;
				empty:
					this_row_data = 0;
			endcase
		else
			this_row_data = row_data;
	
	always_ff @(posedge clk)
		if ( reset ) begin
			row_data <= 0;
			row_counting <= 0;
			row_state <= obstacle;
		end
		else begin								// controls the logic for whether need a set of random rows or empty rows
			row_data <= this_row_data;
			if ( update_obstacle ) 
				if ( row_counting >= 3 ) begin
					row_counting <= 0;
					if ( row_state == obstacle )
						row_state <= empty;
					else
						row_state <= obstacle;
				end
				else 
					row_counting <= row_counting + 1;
		end
	
endmodule

// tests the functionality of generate_row
module generate_row_testbench();

	parameter board_width = 9;

	logic clk, reset, game_Over, update_obstacle;
	logic [board_width-1:0] row_data;

	generate_row #(board_width) dut ( clk, reset, game_Over, update_obstacle, row_data );
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1; @(posedge clk);
		reset <= 0; game_Over <= 0; update_obstacle <= 1; @(posedge clk);	// When not Game Over
		repeat (20) @(posedge clk);
		update_obstacle <= 0;	// when no Update
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		game_Over <= 1; 		// When Game Over and no update
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		update_obstacle <= 1;	// When Game Over
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		$stop;
	end
	
endmodule