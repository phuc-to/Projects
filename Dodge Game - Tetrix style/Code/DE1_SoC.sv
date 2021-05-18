// divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, [24] = 1.5Hz,[25] = 0.75Hz, ...
module clock_divider (clock, reset, divided_clocks);
   input logic reset, clock;
   output logic[31:0] divided_clocks =0;
   always_ff@(posedge clock) begin
		divided_clocks <= divided_clocks +1;
	end
endmodule 

module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW,
					 CLOCK_50, CLOCK2_50, PS2_DAT, PS2_CLK, VGA_R, VGA_G, VGA_B, 
					 VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS, 
					 FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACLRCK, AUD_ADCLRCK, 
					 AUD_BCLK, AUD_ADCDAT, AUD_DACDAT);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;

	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	
	input CLOCK_50, CLOCK2_50;
	input    PS2_DAT;
	input    PS2_CLK;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK; 
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;

	//Game variables
	logic on, start, restart, reset, done, resetV, game_Over;		
	logic [4:0] player_pos;
	logic [7:0] score;
	logic [8:0] row_data;
	logic [8:0] obstacle_data [0:15];
	logic [8:0] board_data [0:15];		
	logic [23:0] color [17:0] [0:15];
	
	//VGA variables
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;
		
	// Keyboard variables
	logic [7:0] key;
	logic makeBreak, left, right;
	logic [13:0] out;
	
	
	// reset assignment
	assign reset = ~KEY[0];
	
	
// CLOCK
	// Generate clk off of CLOCK_50, whichClock picks rate. 
	logic [31:0] clk;
	logic clk2;		
	parameter whichClock = 22; 
	clock_divider cdiv (.clock(CLOCK_50), .reset(reset), .divided_clocks(clk));	
	
	assign clk2 = clk[whichClock];
	//assign clk2 = CLOCK_50;	
	
// Game controller
	enum {s1, s2, s3} ps, ns;
	
	always_comb
		case (ps)
			s1:begin
					resetV = 1;
					done = 0;
					if (start) begin
						ns = s2;
						on = 1;
					end
					else begin
						on = 0;
						ns = s1;
					end
				end
			s2:begin
					resetV = 0;
					done = 0;
					if (~game_Over) begin
						ns = s2;
						on = 1;
					end
					else begin
						ns = s3;
						on = 0;
						done = 1;
					end
				end
			s3:begin 
					resetV = 0;
					on = 0;
					done = 1;
					if (restart)
						ns = s1;
					else ns = s3;
				end
		endcase
	
	always_ff @(posedge clk2) begin
		if (reset) ps <= s1;
		else ps <= ns;
	end
	
	// Game logic
	update_screen su(.clk(clk2), .reset(resetV), .board_data, .on, .done, .score, .result(color));
	
	counter scoring(.clk(clk2), .reset(resetV), .on, .score);
	
	board_logic board(.clk(clk2), .reset(resetV), .game_Over, 
						.update_board(on), .player_pos, .obstacle_data, .board_data); 	
	
	obstacle_logic obs(.clk(clk2), .reset(resetV), .game_Over, 
						.update_obstacle(on), .row_data, .obstacle_data);
	
	generate_row row(.clk(clk2), .reset(resetV), .game_Over, 
						.update_obstacle(on), .row_data);
	
	player pl(.clk(clk2), .reset(resetV), .game_Over, .update_player(on), 
				 .left(right), .right(left), .player_pos);
				 
	collision_detection(.clk(clk2), .reset(resetV), .update_collision(on), .player_pos, .obstacle_data, 
				 .game_Over);
	
// VGA Controller	
	
	video_driver #(.WIDTH(18), .HEIGHT(16))
		v1 (.CLOCK_50, .reset, .x, .y, .r, .g, .b,
			 .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
			 .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
	
	always_ff @(posedge CLOCK_50) begin
		r <= color[x][y][23:16];
		g <= color[x][y][15:8];
		b <= color[x][y][7:0];
	end
	

	
// Codec Controller
	
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	// Local wires.
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right;
	wire resetA = ~KEY[0];
	
	assign writedata_left = on? readdata_left:0;
	assign writedata_right = on? readdata_right:0;
	assign read = read_ready;
	assign write = write_ready;

	
/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		resetA,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		resetA,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		resetA,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);

	

// Keyboard Controller	
	
	keyboard_press_driver keyboard(.CLOCK_50(CLOCK_50), .valid(1'b1), .makeBreak(makeBreak),
								 .outCode(key), .PS2_DAT(PS2_DAT), .PS2_CLK(PS2_CLK), .reset(reset));
								 
	assign left  =   makeBreak & (key == 8'b01101011);
	assign right =   makeBreak & (key == 8'b01110100);
	assign start =   makeBreak & (key == 8'b01011010);
	assign restart = makeBreak & (key == 8'b00101001);
	
endmodule
