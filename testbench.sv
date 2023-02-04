`include "cpu.sv"
`include "address.sv"

module testbench();
parameter M = 64;
parameter N  = 60;
parameter K = 32;
reg [19:0] address;
reg [31:0] data;
reg [2:0] command;
wire [31:0] res;
reg [31:0] result;
address addr();
reg [7:0] a [0:M*K-1];
reg [15:0] b [0:K*N*2-1];
reg [32:0] c [0:M * N * 4];
integer tag = 0;
integer index = 0;
integer offset = 0;
integer tactCounter = 0;
integer i;
integer pa = 0;
integer pc = M * K + N * K * 2;
integer y;
integer x;
integer pb;
integer s;
integer k;

cpu tb(
    .dat(data),
	.addr(address),
    .comm(command),
	.result(res)

);
initial begin
    for (i = 0; i < M * K; i++) begin
        addr.tag[i] = tag;
        addr.index[i] = index;
        addr.offset[i] = offset;
        offset++;
        if (offset == 16) begin
            offset = 0;
            index++;
            if (index == 32) begin
                index = 0;
                tag++;
            end
        end
    end
    for (i = 0; i < N * K * 2; i++) begin
        addr.tag[i + M * K] = tag;
        addr.index[i + M * K] = index;
        addr.offset[i + M * K] = offset;
        offset++;
        if (offset == 16) begin
            offset = 0;
            index++;
            if (index == 32) begin
                index = 0;
                tag++;
            end
        end
    end
    for (i = 0; i < M * N * 4; i++) begin
        addr.tag[i + M * N * 4] = tag;
        addr.index[i + M * N * 4] = index;
        addr.offset[i + M * N * 4] = offset;
        if (offset == 16) begin
            offset = 0;
            index++;
            if (index == 32) begin
                index = 0;
                tag++;
            end
        end
    end
    for (y = 0; y < M; y++) begin
        for (x = 0; x < N; x++) begin
            pb = M * K;
            s = 0;
            for (k = 0; k < K; k++) begin
                /*#18
                address = {addr.tag[i],addr.index[i],addr.offset[i]};
	            data = 0;
	            command = 3'd1;
                #18
                address = {addr.tag[i],addr.index[i],addr.offset[i]};
	            data = 0;
	            command = 3'd1;
                pb += 2 * N;
                */
            end
        end
        pa += K;
        pc += 4 * N;
    end
    //проверка того что кэш хоть как-то работает
    address = 19'b0100000000000001000;
	data =    32'b10000000000111110111111111111111;
	command = 3'd7;
    #18
    address = 19'b0100000000000001000;	
	data =    1;
	command = 3'd3;
    #18
    address = 19'b0100000110000001000;	
	data =    32'b10001100000111110111111111111111;
	command = 3'd7;
    #18
    address = 19'b0100000110000001000;	
	data =    1;
	command = 3'd3;
    #18
    address = 19'b0100000000000001000;	
	data =    32'b10000000000111110111111111111111;
	command = 3'd4;
    #18
    address = 19'b0100000000000001000;	
	data =    1;
	command = 3'd3;

    #700
    $finish;


end
always @(res) begin
    $display(res);
end
endmodule 