module cpu(
	input wire clk,
	input wire nreset,
	output wire led,
	output wire [23:0] debug_port1,
	output wire [23:0] debug_port2,
	output wire [23:0] debug_port3,
	output wire [23:0] debug_port4,
	output wire [23:0] debug_port5,
	output wire [23:0] debug_port6,
	output wire [23:0] debug_port7
	);

	
	wire reset;
	wire [31:0] regdata1, regdata2, memdata;
	wire [31:0] inst;
	reg [31:0] inst_full [100:0];
	reg [31:0] pc;
	reg [1:0] state;
	
	
	
	// Reg files and memory controller
	wire [3:0] regaddrIn, regaddrOut1, regaddrOut2;
	wire regwr, regrd1, regrd2, memwr, memrd;
	wire [31:0] regdataIn, memaddrIn, memaddrOut, memdataIn; 
	wire bf;
	wire [31:0] branchimm;
	
	// Controls the LED on the board.
	assign led = 1'b1;
	assign reset = ~nreset;
	
	// Read in the instruction file
	initial begin
		$readmemb("inst.txt", inst_full);
	end
	
	assign inst = inst_full[pc];
	
	//decode decoder(inst, b, l, t, s, ldr, str, p, u, bit, w, offset, cond, op, rn, rd, rm, operand, branchimm);
//
//	cycles operation(clk, pc, state, op, b, l, t, s, ldr, str, p, u, bit, w, offset, cond, rn, rd, rm, operand, regdata1, regdata2, memdata,
//						 regaddrIn, regaddrOut1, regaddrOut2, regdataIn, regwr, regrd1, regrd2, 
//						 memaddrIn, memaddrOut, memdataIn, memwr, memrd, bf)

	operation run(clk, inst, pc, regdata1, regdata2, memdata,
						 regaddrIn, regaddrOut1, regaddrOut2, regdataIn, regwr, regrd1, regrd2, 
						 memaddrIn, memaddrOut, memdataIn, memwr, memrd, bf, branchimm);
	

	registers RAM(clk, regaddrIn, regaddrOut1, regaddrOut2, regdataIn, regwr, regrd1, regrd2, regdata1, regdata2);
	
	memory MEM(clk, memaddrIn, memaddrOut, memdataIn, memwr, memrd, memdata);
	
	
	
//	interpreter inter(b, l, t, offset, op, rn, rd, rm, operand, out1, out2, out3, out4, out5);
	
	always @(posedge clk) begin
		if (reset) begin
			pc <= 32'b0;
		end
		else begin
				if (!bf) pc <= pc + 1;
				else pc <= pc + ((branchimm + 4'b1000) >> 2);
		end
	end
	
	
	// These are how you communicate back to the serial port debugger.
	assign debug_port1 = pc << 2;
	assign debug_port2 = 0;
	
	
	// Logic for register fields
	assign debug_port3 = 0;
	assign debug_port4 = 0;
	assign debug_port5 = 0;
	assign debug_port6 = 0;	
	assign debug_port7 = 0;
	

endmodule

module cpu_testbench();
	reg clk, nreset;
	wire led;
	wire [7:0] debug_port1,debug_port2, debug_port3, debug_port4, 
				  debug_port5, debug_port6, debug_port7;

	cpu dut(clk, nreset, led, debug_port1, debug_port2, debug_port3, 
					 debug_port4, debug_port5, debug_port6, debug_port7);

	// Set up the clock.
	always begin
		clk = 1; #5; clk = 0; #5;
	end

	// Set up the inputs to the design. Each line is a clock cycle.
	integer i;
	initial begin
						#10;
		nreset <= 0;	#10;
		nreset <= 1; #700;
  end
endmodule