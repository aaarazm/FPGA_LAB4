module accelerator_TB();

    reg                                          DONE;
    reg                                          csi_clock_clk;
    reg                                          csi_clock_reset_n;
    reg  [avs_avalonslave_address_width - 1:0]   avs_avalonslave_address;
    reg                                          avs_avalonslave_read;
    reg                                          avs_avalonslave_write;
    reg  [avs_avalonslave_data_width - 1:0]      avs_avalonslave_writedata;
    reg                                          avm_avalonmaster_waitrequest;
    reg  [avm_avalonmaster_data_width - 1:0]     avm_avalonmaster_readdata;

    wire [avs_avalonslave_data_width - 1:0]      avs_avalonslave_readdata;
    wire [avm_avalonmaster_address_width - 1:0]  avm_avalonmaster_address;
    wire                                         avm_avalonmaster_read;
    wire                                         avm_avalonmaster_write;
    wire [avm_avalonmaster_data_width - 1:0]     avm_avalonmaster_writedata;
    
    localparam clk_period = 20ns;
    always #(clk_period/2) csi_clock_clk = ~csi_clock_clk;


    accelerator uut
    #(
        avs_avalonslave_data_width = 32,
        avs_avalonslave_address_width = 4,
        avm_avalonmaster_data_width = 32,
        avm_avalonmaster_address_width = 32
    )
    (
    .DONE                           (DONE),
    .csi_clock_clk                  (csi_clock_clk),
    .csi_clock_reset_n              (csi_clock_reset_n),
    .avs_avalonslave_address        (avs_avalonslave_address),
    .avs_avalonslave_waitrequest    (avs_avalonslave_waitrequest),
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

    

endmodule