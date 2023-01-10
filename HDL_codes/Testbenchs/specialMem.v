module specialMem(address, readEn, out);
    input readEn;
    input [31:0] address;
    output reg [31:0] out;

    reg [31:0]   mem    [70:129];

    initial begin
        $readmemb("memory.txt", mem);
    end

    always @(address, readEn) begin
        if(readEn)
            out <= mem[address];
        else
            out <= 'bz;
    end


endmodule