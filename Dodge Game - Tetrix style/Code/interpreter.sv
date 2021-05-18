/* Determine the output for HEXs and found LEDR (LEDR9)
	
	@parameter:
		input : 
			clk	: clock signal
			reset	: reset signal
			found	: 1 if the data is found in the RAM,
					  0 otherwise
			addr	: 5-bit address of the data in the RAM 
					  (if found)
						
		output: 
			out	: 14-bit data for HEX1 and HEX0
			led	: signal for LEDR9
*/
module interpreter(clk, reset, addr, out);
	input logic clk, reset;
	input logic [7:0] addr;
	output logic [13:0] out;
	
	integer i, j;
	logic [6:0] a, b;
	
	// Change the last 4 bits of address to dec for translation
	assign i = addr[0] + addr[1]*2 + addr[2]*4 + addr[3]*8;
	assign j = addr[4] + addr[5]*2 + addr[6]*4 + addr[7]*8;
	
	always_comb begin		
		case (i)
			0			: b = 7'b1000000; // 0
			1			: b = 7'b1111001; // 1
			2			: b = 7'b0100100; // 2
			3			: b = 7'b0110000; // 3
			4			: b = 7'b0011001; // 4
			5			: b = 7'b0010010; // 5
			6			: b = 7'b0000010; // 6
			7			: b = 7'b1111000; // 7
			8			: b = 7'b0000000; // 8
			9			: b = 7'b0010000; // 9
			10			: b = 7'b0001000; // A
			11			: b = 7'b0000000; // B
			12			: b = 7'b1000110; // C
			13			: b = 7'b1000000; // D
			14			: b = 7'b0000110; // E
			default	: b = 7'b0001110; // F
		endcase
		case (j)
			0			: a = 7'b1000000; // 0
			1			: a = 7'b1111001; // 1
			2			: a = 7'b0100100; // 2
			3			: a = 7'b0110000; // 3
			4			: a = 7'b0011001; // 4
			5			: a = 7'b0010010; // 5
			6			: a = 7'b0000010; // 6
			7			: a = 7'b1111000; // 7
			8			: a = 7'b0000000; // 8
			9			: a = 7'b0010000; // 9
			10			: a = 7'b0001000; // A
			11			: a = 7'b0000000; // B
			12			: a = 7'b1000110; // C
			13			: a = 7'b1000000; // D
			14			: a = 7'b0000110; // E
			default	: a = 7'b0001110; // F
		endcase
	end
	
	
	always_ff @(posedge clk) begin
		if (reset) begin
			out <= 14'b11111111111111;
		end
		else out <= {a,b};
	end
	
endmodule
