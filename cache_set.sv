module cache_set();

parameter size = 32;	


reg [127:0] segment [0:size - 1];
reg [9:0] tag_array [0:size - 1];

reg valid_array [0:size - 1]; 
reg dirty_array [0:size - 1];

initial
	begin: initialization
		integer i;
		for (i = 0; i < size; i = i + 1)
		begin
			valid_array[i] = 1'b0;
            dirty_array[i] = 1'b0;
			tag_array[i] = 'hz;
			segment[i] = 0;
		end
	end

endmodule 
