`include "cache.sv"
module cpu(
    input [31:0] dat,
	input [19:0] addr,
	input [2:0] comm,
	output [31:0] result
);

reg[31:0] temp;
reg[31:0] res;
reg [14:0] address;
reg [15:0] data;
wire [15:0] d1;
reg clk;
reg [2:0] command;
wire [2:0] c1;
wire [15:0] out1;
wire[15:0] out2;
reg own_c1bus = 1;
reg own_d1bus = 1;
reg isres = 0;
reg flag = 1;
cache tb(
    .d1(d1),
	.address(address),
    .clk(clk),
	.c1(c1),
	.out1(out1),
    .out2(out2)
);
initial clk <= 1'b1;
always @(dat or addr or comm) begin

    if(comm == 1 || comm == 2 || comm == 3) begin
        #4
        @(negedge clk);
        own_c1bus = 1;
	    address = addr[19:5];		
	    data = dat[31:16];
	    command = comm;
        #2
	    address = addr[4:0];	
	    data =  dat[15:0];
	    command = comm;
        #2
        own_c1bus = 0;
        own_d1bus = 0;
        command = 0;
        wait(c1 == 7);
        #2
        isres = 0;
        temp[31:16] = d1;
        #2
        temp[15:0] = d1;
        #2
        isres = 1;
        $display("res ",temp, $time);

    end
    else begin
        #4
        @(negedge clk);
        own_c1bus = 1;
        own_d1bus = 1;
        #2
    	address = addr[19:5];	
    	data =    dat[31:16];
    	command = comm;
        #2
        address = addr[4:0];	
        data = dat[15:0];
	    command = comm;
        #2
        own_c1bus = 0;
        own_d1bus = 0;
        command = 0;
        end
end
	
always @(d1) begin
        $display(d1, $time);
end

assign c1 = own_c1bus ? command : 'hz;
assign d1 = own_d1bus ? data : 'hz;
assign result = isres? temp : 32'd0;
assign fl = flag;
always #1 clk = ~clk;
endmodule