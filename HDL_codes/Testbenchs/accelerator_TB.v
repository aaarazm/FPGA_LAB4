`timescale 1ns/1ns
module accelerator_TB();

    localparam integer avs_avalonslave_data_width = 32;
    localparam integer avs_avalonslave_address_width = 4;
    localparam integer avm_avalonmaster_data_width = 32;
    localparam integer avm_avalonmaster_address_width = 32;

    reg                                          csi_clock_clk = 0;
    reg                                          csi_clock_reset_n;
    reg  [avs_avalonslave_address_width - 1:0]   avs_avalonslave_address;
    reg                                          avs_avalonslave_read;
    reg                                          avs_avalonslave_write;
    reg  [avs_avalonslave_data_width - 1:0]      avs_avalonslave_writedata;
    reg                                          avm_avalonmaster_waitrequest;
    wire  [avm_avalonmaster_data_width - 1:0]     avm_avalonmaster_readdata;

    wire                                         DONE;
    wire [avs_avalonslave_data_width - 1:0]      avs_avalonslave_readdata;
    wire [avm_avalonmaster_address_width - 1:0]  avm_avalonmaster_address;
    wire                                         avm_avalonmaster_read;
    wire                                         avm_avalonmaster_write;
    wire [avm_avalonmaster_data_width - 1:0]     avm_avalonmaster_writedata;
    
    localparam clk_period = 20;
    always #(clk_period/2) csi_clock_clk = ~csi_clock_clk;
    
    //reg [avs_avalonslave_data_width-1:0]   L_BUF    [70:77];
    //reg [avs_avalonslave_data_width-1:0]   R_BUF    [80:87];
    //
    //initial begin
    //    $readmemb("L_BUF.txt", L_BUF);
    //end
    //
    //initial begin
    //    $readmemb("R_BUF.txt", R_BUF);
    //end

    specialMem mem1
    (
        .address(avm_avalonmaster_address),
        .readEn(avm_avalonmaster_read),
        .out(avm_avalonmaster_readdata)
    );

    accelerator
    #(
        .avs_avalonslave_data_width(avs_avalonslave_data_width),
        .avs_avalonslave_address_width(avs_avalonslave_address_width),
        .avm_avalonmaster_data_width(avm_avalonmaster_data_width),
        .avm_avalonmaster_address_width(avm_avalonmaster_address_width)
    ) uut
    (
    .DONE                           (DONE),
    .csi_clock_clk                  (csi_clock_clk),
    .csi_clock_reset_n              (csi_clock_reset_n),
    .avs_avalonslave_address        (avs_avalonslave_address),
    .avs_avalonslave_read           (avs_avalonslave_read),
    .avs_avalonslave_write          (avs_avalonslave_write),
    .avs_avalonslave_readdata       (avs_avalonslave_readdata),
    .avs_avalonslave_writedata      (avs_avalonslave_writedata),
    .avm_avalonmaster_address       (avm_avalonmaster_address),
    .avm_avalonmaster_waitrequest   (avm_avalonmaster_waitrequest),
    .avm_avalonmaster_read          (avm_avalonmaster_read),
    .avm_avalonmaster_write         (avm_avalonmaster_write),
    .avm_avalonmaster_readdata      (avm_avalonmaster_readdata),
    .avm_avalonmaster_writedata     (avm_avalonmaster_writedata)
    );


    reg [avs_avalonslave_data_width-1:0] l_buf_addr = 32'h00000046;
    reg [avs_avalonslave_data_width-1:0] r_buf_addr = 32'h00000050;
    reg [avs_avalonslave_data_width-1:0] slv_reg0   = 32'h00004004;
    
    reg [avs_avalonslave_data_width-1:0] out_addr = 32'h00000064;



    initial begin
        {csi_clock_reset_n, avs_avalonslave_read,avs_avalonslave_write, avm_avalonmaster_waitrequest} = 4'b1000;
        avs_avalonslave_address = 4'h0;
        #30 csi_clock_reset_n = 1'b0;
        #21 csi_clock_reset_n = 1'b1;
        @(posedge csi_clock_clk)
        avs_avalonslave_writedata = slv_reg0;
        avs_avalonslave_write = 1'b1;
        @(posedge csi_clock_clk)
        avs_avalonslave_write = 1'b0;
        avs_avalonslave_address = 4'h1;
        @(posedge csi_clock_clk)
        avs_avalonslave_writedata = l_buf_addr;
        avs_avalonslave_write = 1'b1;
        @(posedge csi_clock_clk)
        avs_avalonslave_write = 1'b0;
        avs_avalonslave_address = 4'h2;
        @(posedge csi_clock_clk)
        avs_avalonslave_writedata = r_buf_addr;
        avs_avalonslave_write = 1'b1;
        @(posedge csi_clock_clk)
        avs_avalonslave_write = 1'b0;
        avs_avalonslave_address = 4'h3;
        @(posedge csi_clock_clk)
        avs_avalonslave_writedata = out_addr;
        avs_avalonslave_write = 1'b1;
        @(posedge csi_clock_clk)
        avs_avalonslave_write = 1'b0;
        avs_avalonslave_address = 4'h0;
        @(posedge csi_clock_clk)
        avs_avalonslave_read = 1'b1;
        @(posedge csi_clock_clk)
        avs_avalonslave_address = 4'h4;
        @(posedge csi_clock_clk)
        avs_avalonslave_address = 4'h8;
        @(posedge csi_clock_clk)
        avs_avalonslave_address = 4'hC;
        @(posedge csi_clock_clk)
        slv_reg0 = 32'h00004005;
        avs_avalonslave_address = 4'h0;
        avs_avalonslave_writedata = slv_reg0;
        avs_avalonslave_write = 1'b1;
        @(posedge csi_clock_clk)
        avs_avalonslave_write = 1'b0;
        #900

        @(posedge csi_clock_clk)
        slv_reg0 = 32'h00004004;
        avs_avalonslave_writedata = slv_reg0;
        avs_avalonslave_write = 1'b1;
        @(posedge csi_clock_clk)
        avs_avalonslave_write = 1'b0;


        #900 $stop;

    end



endmodule