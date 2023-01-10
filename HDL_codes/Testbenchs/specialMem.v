module specialMem(clock, address, readEn, out);
    input clock, readEn;
    input [31:0] address;
    output reg [31:0] out;

    reg [31:0]   mem    [70:129];
    initial begin
        $readmemb("memory.txt", mem);
    end

    always @(posedge clock) begin
        if(readEn)
            out <= mem[address];
        else
            out <= 'bz; 
    end

endmodule