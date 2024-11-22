`timescale 1ps/1ps

module LC3 (
	input		clk,
	input		rst_n,

	input		start
);

localparam		IDLE 		= 0,
			FETCH		= 1,
			ADDRESS 	= 2,
			MEMORY		= 3,
			DECODE		= 4,
			REGISTER_RD	= 5,
			REGISTER_WR	= 6,
			ALU		= 7,
			DRMUX		= 8;

localparam      	ADD     = 4'b0001,
    	                AND     = 4'b0101,
    	                NOT     = 4'b1001,
    	                LD      = 4'b0010,
    	                LDR     = 4'b0110,
    	                LDI     = 4'b1010,
    	                LEA     = 4'b1110,
    	                ST      = 4'b0011,
    	                STR     = 4'b0111,
    	                STI     = 4'b1011,
    	                BR      = 4'b0000,
    	                JMP     = 4'b1100,
    	                HALT    = 4'b1111;

reg	[3:0]		state;
reg			fetch_start, decode_start, address_start, ALU_start, reg_rd_start, reg_wr_start, drMux_start, mem_start;
reg			inst_fetch;
reg			halt;
reg			indirect_step;

wire	[15:0]		fetch_addr;
wire			fetch_wea;
wire	[15:0]		pc;

wire	[3:0]		opCode;
wire	[8:0]		offset;
wire 	[4:0]		imm;
wire			imm_op;
wire	[2:0]		sr1ID, sr2ID, drID;
wire	[2:0]		br_nzp;
wire			decode_done;
//reg			decode_done_d1, decode_done_d2, decode_done_d3, decode_done_d4, decode_done_d5;

wire	[15:0]		sr1, sr2;
wire	[2:0]		result_nzp;

wire	[15:0]		ALU_out;

wire	[15:0]		addr;
wire			wea;

wire	[15:0]		mem_out;

wire	[15:0]		drMux_out;

always @ (posedge clk) begin
    if (!rst_n | halt) begin
        state			<= IDLE;
        fetch_start     	<= 0;
        address_start   	<= 0;
        mem_start       	<= 0;
        decode_start    	<= 0;
        reg_rd_start    	<= 0;
        reg_wr_start    	<= 0;
        ALU_start       	<= 0;
        drMux_start     	<= 0;
	inst_fetch		<= 0;
	indirect_step		<= 0;
	halt			<= 0;
	end
    else begin
    	case (state)
    	IDLE: begin
    		state		<= (start)? FETCH : state;
    	end
    	FETCH: begin
    		state		<= ADDRESS;
    	end
    	ADDRESS: begin
    		if (inst_fetch)
    			state	<= MEMORY;
		else 
			state 	<= (opCode == LEA)? DRMUX : MEMORY;
	//	if ((opCode == LEA) & decode_done_d1)
	//		state	<= DRMUX;
	//	else
		
    	end
    	MEMORY: begin
		if (inst_fetch)
			state 	<= DECODE;
		else begin 
		    case (opCode)	
		    LD, LDR:
			 state 	<= DRMUX;
		    ST, STR:
			state 	<= FETCH;
		    LDI:
			state 	<= (indirect_step == 1) ? DRMUX : ADDRESS;
		    STI:
			state 	<= (indirect_step == 1) ? DRMUX : FETCH;
		    
		    default: DECODE;
		    endcase
		end
    	end
    	DECODE: begin
    	    if (decode_done) begin
		case (opCode)
		    AND, ADD, NOT, ST, STI, STR, LDR, JMP:
			state	<= REGISTER_RD;	
		    LD, LDI, LEA:
			state 	<= ADDRESS;
		    BR:
			state	<= FETCH;		
	
		default: state 	<= IDLE;
		endcase 
    	end
	REGISTER_RD: begin
		case (opCode) 
	//	    ST, LDR, STI, STR:
	//		state 	<= ADDRESS;
		    ST:
			state	<= ADDRESS;
		    STI:
			state 	<= ADDRESS;
		    STR: 
			state 	<= ADDRESS;
		    LDR:
			state	<= ADDRESS;
		    JMP:
			state	<= FETCH;
		default:
			state	<= ALU;
		endcase
	end
    	REGISTER_WR: begin
    		state		<= FETCH;
    	end
    	ALU: begin
    		state		<= DRMUX;
    	end
    	DRMUX: begin
    		state		<= REGISTER_WR;
    	end
    	endcase
    
    	fetch_start		<= (state == FETCH);
    	address_start		<= (state == ADDRESS);
    	mem_start		<= (state == MEMORY);
    	decode_start		<= (state == DECODE);
    	reg_rd_start		<= (state == REGISTER_RD);//TODO
    	reg_wr_start		<= (state == REGISTER_WR);
    	ALU_start		<= (state == ALU);
    	drMux_start		<= (state == DRMUX);

	halt			<= (opCode == HALT) & decode_done; 

//	notification: FETCH => ADDRESS => MEMORY => DECODE 
	if (state == FETCH)
		inst_fetch 	<= 1;
	else if (decode_start)
		inst_fetch 	<= 0;

	// step LDI, STI
	if (state == DECODE)
		indirect_step 	<= 0;	
	else if ((state == MEMORY) & !inst_fetch)
		indirect_step 	<= ~indirect_step;
		
    end
end

fetch fetch_i (
	.clk(clk),
	.rst_n(rst_n),

	.fetch_start(fetch_start),
	.opCode_in(opCode),
	.offset_in(offset),
	.reg_in(sr1),
	.br_nzp(br_nzp),
	.result_nzp(result_nzp),
	
	.addr_out(fetch_addr),
	.wea_out(fetch_wea),
	.pc(pc)
);

decode decode_i (
    .clk(clk),
    .rst_n(rst_n),

    .decode_start(decode_start),
    .mem_in(mem_out),

    .opCode(opCode),
    .imm(imm),
    .sr1ID(sr1ID),
    .sr2ID(sr2ID),
    .drID(drID),
    .offset(offset),
    .imm_op(imm_op),
    .br_nzp(br_nzp),
    .decode_done(decode_done)
);

register register_i (
    .clk(clk),
    .rst_n(rst_n),

    .opCode(opCode),
    .start_rd(reg_rd_start),
    .start_wr(reg_wr_start),
    .sr1ID(sr1ID),
    .sr2ID(sr2ID),
    .drID(drID),

    .data_in(drMux_out),
    .sr1(sr1),
    .sr2(sr2),
    .result_nzp(result_nzp)
);

ALU ALU_i (
    .clk(clk),
    .rst_n(rst_n),

    .ALU_start(ALU_start),
    .opCode(opCode),
    .sr1(sr1),
    .sr2(sr2),
    .imm(imm),
    .imm_op(imm_op),

    .data_out(ALU_out)
);

Address Address_i (
    .clk(clk),
    .rst_n(rst_n),

    .addr_start(address_start),
    .inst_fetch(inst_fetch),
    .opCode(opCode),
    .offset(offset),
    .addr_in(fetch_addr),
    .wea_in(fetch_wea),
    .pc(pc),
    .mem_in(mem_out),
    .reg_in(sr1),

    .addr_out(addr),
    .wea_out(wea)
);

memory memory_i (
    .clk(clk),
    .rst_n(rst_n),

    .mem_start(mem_start),
    .addr(addr),
    .wea(wea),
    .data_in(sr2),

    .data_out(mem_out)
);

drMux drMux_i (
    .clk(clk),
    .rst_n(rst_n),

    .drMux_start(drMux_start),
    .opCode(opCode),
    .ALU_in(ALU_out),
    .Addr_in(addr),
    .mem_in(mem_out),

    .data_out(drMux_out)
);

endmodule
