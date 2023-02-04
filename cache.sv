`include "cache_set.sv"
`include "ram.sv"
module cache(
    inout [15:0] d1,
	input [14:0] address,
	input clk,
	inout wire [2:0] c1,
	output [15:0] out1,
    output [15:0] out2
);


reg[15:0] first_data;
reg[15:0] second_data;
reg[2:0] prev_c1;
reg[15:0] first_temp_out;
reg[15:0] second_temp_out;
reg[9:0] tag;
reg[4:0] index;
reg[15:0] offset;
reg last_use [0:31];
reg own_c1bus = 0;
reg own_d1bus = 0;
reg[2:0] c1_bus_value = 0;
reg[15:0] d1_bus_value = 0;
ram ram();
cache_set first_cache_set();
cache_set second_cache_set();
assign c1 = own_c1bus ? c1_bus_value : 'hz;
assign d1 = own_d1bus ? d1_bus_value : 'hz;
initial
	begin: initialization
        integer i;
        for (i = 0; i < 32; i = i + 1)
		begin
			last_use[i] = 1'b0;
		end
        for (i = 0; i < 16; i = i + 1)
		begin
			first_data[i] = 1'b0;
            first_temp_out[i] = 1'b0;
            second_data[i] = 1'b0;
		end
        index = 0;
		tag = 0;
        offset = 16'b0;
		prev_c1 = 0;

	end

always @(posedge clk) begin
	if (c1 == 1 || c1 == 2 || c1 == 3 || c1 == 4 || c1 == 5|| c1 == 6 || c1 == 7) begin
            c1_bus_value = 3'b0;
            first_data = d1;
            tag= address[14:5];
			index= address[4:0];	
            prev_c1 = c1;
            #2
            second_data = d1;
            offset=(address[14:11])*8;
            if ((prev_c1 == 1) || (prev_c1 == 2) || (prev_c1 == 3)) begin
                if((first_cache_set.tag_array[index] == tag && first_cache_set.valid_array[index] == 1'b1) 
                || (second_cache_set.tag_array[index] == tag && second_cache_set.valid_array[index] == 1'b1)) begin
                    if(first_cache_set.tag_array[index] == tag) begin
                        if(prev_c1 == 3'd1) begin
                            last_use[index] = 1'b0;
                            c1_bus_value = 3'd7;
                            #2
                            own_c1bus = 1;
                            own_d1bus = 1;
                            first_temp_out[15:8] = first_cache_set.segment[index][offset+:8];
                            d1_bus_value = out1[15:8];
                            #2
                            d1_bus_value = out2[15:8];
                        end
                        else if(prev_c1 == 3'd2) begin
                            last_use[index] = 1'b0;
                            c1_bus_value = 3'd7;
                            #2
                            own_c1bus = 1;
                            own_d1bus = 1;
                            first_temp_out[15:0] = first_cache_set.segment[index][offset+:16];
                            d1_bus_value = out1;
                            #2
                            d1_bus_value = out2;
                            
                        end
                        else begin
                            last_use[index] = 1'b0;
                            c1_bus_value = 3'd7;
                            #2
                            own_c1bus = 1;
                            own_d1bus = 1;
                            first_temp_out[15:0] = first_cache_set.segment[index][offset+:16];
                            second_temp_out[15:0] = first_cache_set.segment[index][(offset+16)+:16];
                            d1_bus_value = out1;
                            #2
                            d1_bus_value = out2;
                        end
                    end
                    else begin
                        if(prev_c1 == 3'd1) begin
                            last_use[index] = 1'b1;
                            c1_bus_value = 3'd7;
                            #2
                            own_c1bus = 1;
                            own_d1bus = 1;
                            first_temp_out[15:8] = second_cache_set.segment[index][offset+:8];
                            d1_bus_value = out1[15:8];
                            #2
                            d1_bus_value = out2[15:8];
                        end
                        else if(prev_c1 == 3'd2) begin
                            last_use[index] = 1'b1;
                            c1_bus_value = 3'd7;
                            #2
                            own_c1bus = 1;
                            own_d1bus = 1;
                            first_temp_out[15:0] = second_cache_set.segment[index][offset+:16];
                            d1_bus_value = out1;
                            #2
                            d1_bus_value = out2;
                           
                        end
                        else begin
                            last_use[index] = 1'b1;
                            c1_bus_value = 3'd7;
                            #2
                            own_c1bus = 1;
                            own_d1bus = 1;
                            first_temp_out[15:0] = second_cache_set.segment[index][offset+:16];
                            second_temp_out[15:0]= second_cache_set.segment[index][(offset+16)+:16];
                            d1_bus_value = out1;
                            #2
                            d1_bus_value = out2;
                        end
                    end
                end
                else begin
                    if(last_use[index] == 1'b1) begin
                        if(first_cache_set.dirty_array[index]==1) begin
                            ram.ram[first_cache_set.tag_array[index]*32+index] = first_cache_set.segment[index];
                        end
                        first_cache_set.segment[index] = ram.ram[tag*32+index];
                        first_cache_set.tag_array[index] = tag;
                        first_cache_set.dirty_array[index] = 1'b0;
                        first_cache_set.valid_array[index] = 1'b1;
                        last_use[index] = 1'b0;
                        if(prev_c1 == 3'd1) begin
                            c1_bus_value = 3'd7;
                            #2
                            own_c1bus = 1;
                            own_d1bus = 1;
                            first_temp_out[15:8] = first_cache_set.segment[index][offset+:8];
                            d1_bus_value = out1[15:8];
                            #2
                            d1_bus_value = out2[15:8];
                        end
                        else if(prev_c1 == 3'd2) begin
                            c1_bus_value = 3'd7;
                            #2
                            own_c1bus = 1;
                            own_d1bus = 1;
                            first_temp_out[15:0] = first_cache_set.segment[index][offset+:16];
                            d1_bus_value = out1;
                            #2
                            d1_bus_value = out2;

                            
                        end
                        else begin
                            c1_bus_value = 3'd7;
                            #2
                            own_c1bus = 1;
                            own_d1bus = 1;
                            first_temp_out[15:0] = first_cache_set.segment[index][offset+:16];
                            second_temp_out[15:0] = first_cache_set.segment[index][offset+16+:16];
                            d1_bus_value = out1;
                            #2
                            d1_bus_value = out2;
                        end
                    end 
                    else begin
                        if(second_cache_set.dirty_array[index] == 1) begin
                            ram.ram[second_cache_set.tag_array[index]*32+index] = second_cache_set.segment[index];
                        end
                        second_cache_set.segment[index] = ram.ram[tag*32+index];
                        second_cache_set.tag_array[index] = tag;
                        second_cache_set.dirty_array[index] = 1'b0;
                        second_cache_set.valid_array[index] = 1'b1;
                        last_use[index] = 1'b1;
                        if(prev_c1 == 3'd1) begin
                            c1_bus_value = 3'd7;
                            #2
                            own_c1bus = 1;
                            own_d1bus = 1;
                            first_temp_out[15:8] = second_cache_set.segment[index][offset+:8];
                            d1_bus_value = out1[15:8];
                            #2
                            d1_bus_value = out2[15:8];
                            
                        end
                        else if(prev_c1 == 3'd2) begin
                            c1_bus_value = 3'd7;
                            #2
                            own_c1bus = 1;
                            own_d1bus = 1;
                            first_temp_out[15:0] = second_cache_set.segment[index][offset+:16];
                            d1_bus_value = out1;
                            #2
                            d1_bus_value = out2;
                        
                        end
                        else begin
                            c1_bus_value = 3'd7;
                            #2
                            own_c1bus = 1;
                            own_d1bus = 1;
                            first_temp_out[15:0] = second_cache_set.segment[index][offset+:16];
                            second_temp_out[15:0] = second_cache_set.segment[index][(offset+16)+:16];
                            d1_bus_value = out1;
                            #2
                            d1_bus_value = out2;
                        end
                    end
                end
            end
            else if  (prev_c1 == 3'd5 || prev_c1 == 3'd6 || prev_c1 == 3'd7) begin
				if((first_cache_set.tag_array[index] == tag && first_cache_set.valid_array[index] == 1'b1) 
                || (second_cache_set.tag_array[index] == tag && second_cache_set.valid_array[index] == 1'b1)) begin
                    if(first_cache_set.tag_array[index] == tag) begin
                        if(prev_c1 == 3'd5) begin
                            first_cache_set.segment[index][offset+:8] = first_data[15:8];
                        end
                        else if(prev_c1 == 3'd6) begin
                            first_cache_set.segment[index][offset+:16] = first_data[15:0];

                        end
                        else begin
                            first_cache_set.segment[index][offset+:16] = first_data[15:0];
                            first_cache_set.segment[index][(offset+16)+:16] = second_data[15:0];
                        end
                        first_cache_set.dirty_array[index] = 1'b1;
                        first_cache_set.valid_array[index] = 1'b1;
                        last_use[index] = 1'b0;
                    end
                    else begin
                        if(prev_c1 == 3'd5) begin
                            second_cache_set.segment[index][offset+:8] = first_data[15:8];
                        end
                        else if(prev_c1 == 3'd6) begin
                            second_cache_set.segment[index][offset+:16] = first_data[15:0];
        
                        end
                        else begin
                            second_cache_set.segment[index][offset+:16] = first_data[15:0];
                            second_cache_set.segment[index][(offset+16)+:16] = second_data[15:0];
                        end
                        second_cache_set.dirty_array[index] = 1'b1;
                        second_cache_set.valid_array[index] = 1'b1;
                        last_use[index] = 1'b1;
                    end
                end
                else begin
                    if(last_use[index] == 1'b1) begin
                        if(first_cache_set.dirty_array[index] == 1'b1) begin
                            ram.ram[first_cache_set.tag_array[index]*32+index] = first_cache_set.segment[index];
                        end
                        first_cache_set.segment[index] = ram.ram[tag*32+index];
                        if(prev_c1 == 3'd5) begin
                            first_cache_set.segment[index][offset+:8] = first_data[15:8];
                        end
                        else if(prev_c1 == 3'd6) begin
                            first_cache_set.segment[index][offset+:16] = first_data[15:0];
                        end
                        else begin
                            first_cache_set.segment[index][offset+:16] = first_data[15:0];
                            first_cache_set.segment[index][(offset+16)+:16] = second_data[15:0];
                        end
                        first_cache_set.tag_array[index] = tag;
                        first_cache_set.dirty_array[index] = 1'b1;
                        first_cache_set.valid_array[index] = 1'b1;
                        last_use[index] = 1'b0;
                    end 
                    else begin
                        if(second_cache_set.dirty_array[index] == 1) begin
                            ram.ram[second_cache_set.tag_array[index]*32+index] = second_cache_set.segment[index];
                        end
                        second_cache_set.segment[index] = ram.ram[tag*32+index];
                        if(prev_c1 == 3'd5) begin
                            second_cache_set.segment[index][offset+:8] = first_data[15:8];
                        end
                        else if(prev_c1 == 3'd6) begin
                            second_cache_set.segment[index][offset+:16] = first_data[15:0];
                        end
                        else begin
                            second_cache_set.segment[index][offset+:16] = first_data[15:0];
                            second_cache_set.segment[index][(offset+16)+:16] = second_data[15:0];
                        end
                        second_cache_set.tag_array[index] = tag;
                        second_cache_set.dirty_array[index] = 1'b1;
                        second_cache_set.valid_array[index] = 1'b1;
                        last_use[index] = 1'b1;
                    end
                end
            end
            else if (prev_c1 ==3'd4) begin
                if((first_cache_set.tag_array[index] == tag && first_cache_set.valid_array[index] == 1'b1) 
                || (second_cache_set.tag_array[index] == tag && second_cache_set.valid_array[index] == 1'b1)) begin
                    if(first_cache_set.tag_array[index] == tag) begin
                        if(first_cache_set.dirty_array[index] == 1'b1) begin
                            ram.ram[first_cache_set.tag_array[index]*32+index] = first_cache_set.segment[index];
                        end
                        first_cache_set.dirty_array[index] = 1'b0;
                        first_cache_set.valid_array[index] = 1'b0;
                    end
                    else begin
                        if(second_cache_set.dirty_array[index] == 1) begin
                            ram.ram[second_cache_set.tag_array[index]*32+index] = second_cache_set.segment[index];
                        end
                        second_cache_set.dirty_array[index] = 1'b0;
                        second_cache_set.valid_array[index] = 1'b0;
                    end
                end
            end
        end
        #2
        own_c1bus = 0;
        own_d1bus = 0;
	end
assign out1 = first_temp_out;
assign out2 = second_temp_out;
endmodule 

