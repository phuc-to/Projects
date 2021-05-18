/* Update the coordinates and color of the pixels

	@param:
		parameter:
			W, H			: width and height of the screen
		input:
			clk			: clock signal
			reset			: reset signal
			board_data	: 9-bit array size 15 containing the data of
							  playfield
			on				: 1 if the game is going on, 0 otherwise
			done			: 1 if the player lost, 0 otherwise
			score			: 8-bit number of the score
			
		output:			
			result	: rgb colors of the pixel
*/
module update_screen (clk, reset, board_data, on, done, score, result);
	parameter W = 18, H = 16;
	input logic clk, reset, on, done;
	input logic [7:0] score;
	input logic [8:0] board_data [0:15];
	output logic [23:0] result [17:0] [0:15];
	
	integer i, j, k;	
	
	// "Press Enter to go" Starting Screen
	logic [W-1:0] temp_data [0:H-1] =
									'{18'b111011101110111111,
									  18'b101010101000100100,
									  18'b111011101110111111,
									  18'b100010101000001001,
									  18'b100010101110111111,
									  18'b0,
									  18'b111011111101110111,
									  18'b100010101001000101,
									  18'b111010101001110111,
									  18'b100010101001000101,
									  18'b111010101001110101,
									  18'b011101110011101110,
									  18'b001001010010001010,
									  18'b001001010011101010,
									  18'b001001010010101010,
									  18'b001001110011101110
									 };
									 
	// "You Lost" Ending Screen							 
	logic [W-1:0] temp_data_lose [0:H-1] =
									'{18'b0, 18'b0,
									  18'b000101011101010000,
									  18'b000101010101010000,
									  18'b000111010101010000,
									  18'b000010010101010000,
									  18'b000010011101110000,
									  18'b0, 18'b0,
									  18'b001000111011101110,
									  18'b001000101010000100,
									  18'b001000101011100100,
									  18'b001000101000100100,
									  18'b001110111011100100,
									  18'b0, 18'b0
									 };	
	
	// Static starting and ending screen
	logic [23:0] temp_color [W-1:0] [0:H-1];
	logic [W-1:0] temp [0:H-1];
									 
	// Upper "SC" part of the score screen								 
	logic [8:0] score_up [0:10] = 
									'{9'b0, 9'b0,
									  9'b011101110,
									  9'b000100010,
									  9'b000101110,
									  9'b000101000,
									  9'b011101110,
									  9'b0, 9'b0, 9'b0, 9'b0
									 };
	
	// Numbers for the score part
	logic [2:0] zero  [0:4] = '{3'b111, 3'b101, 3'b101, 3'b101, 3'b111};
	logic [2:0] one   [0:4] = '{3'b100, 3'b100, 3'b100, 3'b100, 3'b100};
	logic [2:0] two   [0:4] = '{3'b111, 3'b100, 3'b111, 3'b001, 3'b111};
	logic [2:0] three [0:4] = '{3'b111, 3'b100, 3'b111, 3'b100, 3'b111};
	logic [2:0] four  [0:4] = '{3'b101, 3'b101, 3'b111, 3'b100, 3'b100};
	logic [2:0] five  [0:4] = '{3'b111, 3'b001, 3'b111, 3'b100, 3'b111};
	logic [2:0] six   [0:4] = '{3'b111, 3'b001, 3'b111, 3'b101, 3'b111};
	logic [2:0] seven [0:4] = '{3'b111, 3'b100, 3'b100, 3'b100, 3'b100};
	logic [2:0] eight [0:4] = '{3'b111, 3'b101, 3'b111, 3'b101, 3'b111};
	logic [2:0] nine  [0:4] = '{3'b111, 3'b101, 3'b111, 3'b100, 3'b111};
	logic [2:0] a		[0:4] = '{3'b111, 3'b101, 3'b111, 3'b101, 3'b101};
	logic [2:0] b		[0:4] = '{3'b111, 3'b101, 3'b111, 3'b101, 3'b111};
	logic [2:0] c		[0:4] = '{3'b111, 3'b001, 3'b001, 3'b001, 3'b111};
	logic [2:0] d		[0:4] = '{3'b111, 3'b101, 3'b101, 3'b101, 3'b111};
	logic [2:0] e		[0:4] = '{3'b111, 3'b001, 3'b111, 3'b001, 3'b111};
	logic [2:0] f		[0:4] = '{3'b111, 3'b001, 3'b111, 3'b001, 3'b001};
	
	
	logic [2:0] first [0:4];
	logic [2:0] second[0:4];
	
	// Complete in-game data and color array
	logic [17:0] final_data [0:15];
	logic [23:0] final_color [17:0] [0:15];
	
	// Logic part for VGA color array
	always_comb begin
		case (done)
			0: temp = temp_data;
			1: temp = temp_data_lose;
		endcase		
		for (j = 0; j < W; j++)
			for (k = 0; k < H; k++) 
			begin
				if (temp[k][j] == 0)
					temp_color[17-j][k] = '1;
				else temp_color[17-j][k] = 24'b0;
			end
		case (score[3:0])
			4'b0000: second = zero;
			4'b0001: second = one;
			4'b0010: second = two;
			4'b0011: second = three;
			4'b0100: second = four;
			4'b0101: second = five;
			4'b0110: second = six;
			4'b0111: second = seven;
			4'b1000: second = eight;
			4'b1001: second = nine;			
			4'b1010: second = a;
			4'b1011: second = b;
			4'b1100: second = c;
			4'b1101: second = d;
			4'b1110: second = e;
			4'b1111: second = f;
		endcase
		case (score[7:4])
			4'b0000: first = zero;
			4'b0001: first = one;
			4'b0010: first = two;
			4'b0011: first = three;
			4'b0100: first = four;
			4'b0101: first = five;
			4'b0110: first = six;
			4'b0111: first = seven;
			4'b1000: first = eight;
			4'b1001: first = nine;			
			4'b1010: first = a;
			4'b1011: first = b;
			4'b1100: first = c;
			4'b1101: first = d;
			4'b1110: first = e;
			4'b1111: first = f;
		endcase
		
		for (i = 0; i < 11; i++) 
			final_data[i] = {score_up[i],board_data[i]};
		for (i = 11; i < 16; i++) 
			final_data[i] = {1'b0,second[i-11],1'b0,first[i-11], 1'b0, board_data[i]};
		
		for (j = 0; j < W; j++)
			for (k = 0; k < H; k++) 
			begin
				if (j <= 8) final_color[j][k] = final_data[k][j] ? '1:24'b0;
				else final_color[j][k] = final_data[k][j] ? 24'b0:'1;
			end
		
	end
	
	// DFFs
	always_ff @(posedge clk) begin
		if (reset) begin
			result <= temp_color;
		end
		else begin
			if (on) result <= final_color;
			else result <= temp_color;
		end	
	end
	
endmodule

module update_screen_testbench();
	logic clk, reset, on, done;
	logic [7:0] score;
	logic [8:0] board_data [0:15];
	logic [23:0] result [17:0] [0:15];

	update_screen dut (clk, reset, board_data, on, done, score, result);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD / 2) clk <= ~clk;
	end
	initial begin
		reset <= 1; board_data <= {9'b0, 9'b1, 9'b0, 9'b1, 9'b0, 9'b1, 9'b0, 9'b1,
											9'b0, 9'b1, 9'b0, 9'b1, 9'b0, 9'b1, 9'b0, 9'b1}; 	
																	@(posedge clk);
		reset <= 0; on <= 0; done <= 0; score <= 9; 	@(posedge clk);
								   done <= 1; score <= 11; @(posedge clk);
						on <= 1; done <= 0; score <= 23; @(posedge clk);
																	@(posedge clk);
		$stop;
	end
	
endmodule