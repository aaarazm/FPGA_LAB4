module accelerator #
(
  // you can add parameters here
  // you can change these parameters

  // control interface parameters
  parameter integer avs_avalonslave_data_width = 32,
  parameter integer avs_avalonslave_address_width = 4,

  // control interface parameters
  parameter integer avm_avalonmaster_data_width = 32,
  parameter integer avm_avalonmaster_address_width = 32
)
(
  // user ports begin
  output wire DONE,

  // user ports end
  // dont change these ports

  // clock and reset
  input wire csi_clock_clk,
  input wire csi_clock_reset_n,

  // control interface ports
  input wire [avs_avalonslave_address_width - 1:0] avs_avalonslave_address,
  //output wire avs_avalonslave_waitrequest,
  input wire avs_avalonslave_read,
  input wire avs_avalonslave_write,
  output wire [avs_avalonslave_data_width - 1:0] avs_avalonslave_readdata,
  input wire [avs_avalonslave_data_width - 1:0] avs_avalonslave_writedata,

  // magnitude interface ports
  output wire [avm_avalonmaster_address_width - 1:0] avm_avalonmaster_address,
  input wire avm_avalonmaster_waitrequest,
  output wire avm_avalonmaster_read,
  output wire avm_avalonmaster_write,
  input wire [avm_avalonmaster_data_width - 1:0] avm_avalonmaster_readdata,
  output wire [avm_avalonmaster_data_width - 1:0] avm_avalonmaster_writedata
);

// define your extra ports as wire here
wire start;
wire waitRequest;
wire [avs_avalonslave_data_width-1:0] SLV_REG0;
wire [avs_avalonslave_data_width-1:0] rightAddress;
wire [avs_avalonslave_data_width-1:0] leftAddress;
wire [avs_avalonslave_data_width-1:0] outAddress;
wire [avm_avalonmaster_data_width-1:0] r_buf0;
wire [avm_avalonmaster_data_width-1:0] l_buf0;
wire [avm_avalonmaster_data_width-1:0] r_buf1;
wire [avm_avalonmaster_data_width-1:0] l_buf1;

reg done_reg = 0;
reg read;
reg write;
reg load_enable;
reg [1:0] load_buf;

reg [avm_avalonmaster_address_width-1:0] inAddress;
reg [avm_avalonmaster_data_width-1:0] writeData;
//reg [avm_avalonmaster_address_width-1:0] writeAddress;

// control interface instanciation
AVS_AVALONSLAVE #
(
  // you can add parameters here
  // you can change these parameters
  .AVS_AVALONSLAVE_DATA_WIDTH(avs_avalonslave_data_width),
  .AVS_AVALONSLAVE_ADDRESS_WIDTH(avs_avalonslave_address_width)
) AVS_AVALONSLAVE_INST // instance  of module must be here
(
  // user ports begin
  .START(start),
  .DONE(done_reg),
  .SLV_REG0(SLV_REG0),
  .rightAddress(rightAddress),
  .leftAddress(leftAddress),
  .outAddress(outAddress),
  // user ports end

  // dont change these ports
  .CSI_CLOCK_CLK(csi_clock_clk),
  .CSI_CLOCK_RESET_N(csi_clock_reset_n),
  .AVS_AVALONSLAVE_ADDRESS(avs_avalonslave_address),
  //.AVS_AVALONSLAVE_WAITREQUEST(avs_avalonslave_waitrequest),
  .AVS_AVALONSLAVE_READ(avs_avalonslave_read),
  .AVS_AVALONSLAVE_WRITE(avs_avalonslave_write),
  .AVS_AVALONSLAVE_READDATA(avs_avalonslave_readdata),
  .AVS_AVALONSLAVE_WRITEDATA(avs_avalonslave_writedata)
);

// magnitude interface instanciation
AVM_AVALONMASTER_MAGNITUDE #
(
  // you can add parameters here
  // you can change these parameters
  .AVM_AVALONMASTER_DATA_WIDTH(avm_avalonmaster_data_width),
  .AVM_AVALONMASTER_ADDRESS_WIDTH(avm_avalonmaster_address_width)
) AVM_AVALONMASTER_MAGNITUDE_INST // instance  of module must be here
(
  // user ports begin
  //.START(start),
  //.DONE(done),
  .load_enable(load_enable),
  .load_buf(load_buf),
  .r_buf0(r_buf0),
  .l_buf0(l_buf0),
  .r_buf1(r_buf1),
  .l_buf1(l_buf1),
  .READ(read),
  .WRITE(write),
  .waitRequest(waitRequest),
  .inAddress(inAddress),
  .writeData(writeData),
  //.writeAddress(writeAddress),
  // user ports end
  // dont change these ports
  .CSI_CLOCK_CLK(csi_clock_clk),
  .CSI_CLOCK_RESET_N(csi_clock_reset_n),
  .AVM_AVALONMASTER_ADDRESS(avm_avalonmaster_address),
  .AVM_AVALONMASTER_WAITREQUEST(avm_avalonmaster_waitrequest),
  .AVM_AVALONMASTER_READ(avm_avalonmaster_read),
  .AVM_AVALONMASTER_WRITE(avm_avalonmaster_write),
  .AVM_AVALONMASTER_READDATA(avm_avalonmaster_readdata),
  .AVM_AVALONMASTER_WRITEDATA(avm_avalonmaster_writedata)
);


reg [18:0] sizeIter;
reg [10:0] numIter;
reg [avs_avalonslave_data_width-1:0] r_buf_addr;
reg [avs_avalonslave_data_width-1:0] l_buf_addr;
reg [avs_avalonslave_data_width-1:0] out_addr;


reg [10:0] num;
reg [18:0] size;

reg [3:0] pState, nState;
reg [(avs_avalonslave_data_width*2)-1:0] sum;

wire [avm_avalonmaster_data_width-1:0] r_buf0_abs;
wire [avm_avalonmaster_data_width-1:0] l_buf0_abs;
wire [avm_avalonmaster_data_width-1:0] r_buf1_abs;
wire [avm_avalonmaster_data_width-1:0] l_buf1_abs;

wire [avs_avalonslave_data_width:0] add0, add1;
wire [avs_avalonslave_data_width+1:0] addToSum;
wire [(avs_avalonslave_data_width*2)-1:0] toSum;

assign DONE = done_reg;

assign r_buf0_abs = (r_buf0_abs[avm_avalonmaster_data_width-1]) ? ((~r_buf0_abs) + {{(avm_avalonmaster_data_width-1){1'b0}} , {1'b1}}) : r_buf0_abs;
assign l_buf0_abs = (l_buf0_abs[avm_avalonmaster_data_width-1]) ? ((~l_buf0_abs) + {{(avm_avalonmaster_data_width-1){1'b0}} , {1'b1}}) : l_buf0_abs;
assign r_buf1_abs = (r_buf1_abs[avm_avalonmaster_data_width-1]) ? ((~r_buf1_abs) + {{(avm_avalonmaster_data_width-1){1'b0}} , {1'b1}}) : r_buf1_abs;
assign l_buf1_abs = (l_buf1_abs[avm_avalonmaster_data_width-1]) ? ((~l_buf1_abs) + {{(avm_avalonmaster_data_width-1){1'b0}} , {1'b1}}) : l_buf1_abs;

assign add0 = r_buf0_abs + l_buf0_abs;
assign add1 = r_buf1_abs + l_buf1_abs;
assign addToSum = add0 + add1;
assign toSum = {{(avm_avalonmaster_data_width-2){1'b0}} , addToSum} + sum;

wire size_inc, num_inc, rl_inc, out_inc; // control signals for incrementing the iteratives and 

localparam [3:0] Idle = 0, read1 = 1, read2 = 2, read3 = 3, read4 = 4, add = 5, write1 = 6, write2 = 7, done = 8;

assign size_inc = (((nState == read2) & (pState == read1)) | ((nState == read4) & (pState == read3))) ? 1'b1:1'b0;
assign num_inc = ((pState == write1) & (nState == write2)) ? 1'b1:1'b0;
assign rl_inc = (((pState == read2) & (nState != read2)) | ((pState == read4) & (nState == add))) ? 1'b1:1'b0;
assign out_inc = (((pState == write1) & (nState == write2)) | ((pState == write2) & (nState == read1))) ? 1'b1:1'b0;

always @(posedge csi_clock_clk) begin : incrementing
  if(size_inc)
    sizeIter <= sizeIter + 1;
  if(num_inc)
    numIter <= numIter + 1;
  if(rl_inc) begin
    r_buf_addr <= r_buf_addr + 1;
    l_buf_addr <= l_buf_addr + 1;
  end
  if(out_inc)
    out_addr <= out_addr + 1;
end


always @(pState, waitRequest, sizeIter, numIter, start) begin : FSM_Sequentials
  nState <= Idle;
  case (pState)
    Idle: nState <= start ? read1 : Idle;

    read1: nState <= waitRequest ? read1 : read2;

    read2: begin
      if(waitRequest) begin
        nState <= read2;
      end
      else begin
        nState <= (sizeIter < size) ? read3 : write1;
      end
    end
    read3: nState <= waitRequest ? read3 : read4;

    read4: nState <= waitRequest ? read4 : add;

    add: nState <= (sizeIter < size) ? read1 : write1;
    write1: begin
      nState <= waitRequest ? write1 : write2;
      sizeIter <= 0;                              // resetting the size iterator
    end
    write2: begin
      if(waitRequest) begin
        nState <= write2;
      end
      else begin
        nState <= (numIter < num) ? read1 : done;
        sum <= 0;                                 // resetting the size iterattor
      end
    end
    done: nState <= start ? done : Idle;
    default: nState <= Idle;
  endcase
end

always @(pState, rightAddress, leftAddress, outAddress, SLV_REG0, l_buf_addr, r_buf_addr) begin : FSM_Combinational // use "always" or
  load_enable <= 0; load_buf <= 2'b00; write <= 0; read <= 0; writeData <= 0; done_reg <= 0;     // "always_comb" block?
  //if (csi_clock_reset_n == 0) begin
  //  pState <= Idle;
  //end
  case (pState)
    Idle: begin
      r_buf_addr  <= rightAddress;
      l_buf_addr  <= leftAddress;
      out_addr    <= outAddress;
      inAddress   <= leftAddress;
      numIter     <= 0;
      sizeIter    <= 0;
      sum         <= 0;
      {size, num} <= SLV_REG0[30:1];
      //if (start) begin
      //  //done_reg  <= 0;
      //  pState <= read1;
      //end
    end
    read1: begin
      load_buf    <= 2'b00;
      load_enable <= 1'b1;
      read        <= 1'b1;
      inAddress <= l_buf_addr;
      //if (!waitRequest) begin
      //  sizeIter <= sizeIter + 1;
      //  pState    <= read2;
      //end
    end
    read2: begin
      load_buf    <= 2'b01;
      load_enable <= 1'b1;
      read        <= 1'b1;
      inAddress   <= r_buf_addr;
      //if (!waitRequest) begin
      //  if (sizeIter < size) begin
      //    r_buf_addr <= r_buf_addr + 1;
      //    l_buf_addr <= l_buf_addr + 1;
      //    pState <= read3;
      //  end
      //  else begin
      //    r_buf_addr <= r_buf_addr + 1;
      //    l_buf_addr <= l_buf_addr + 1;
      //    pState      <= write1;
      //  end
      //end
    end
    read3: begin
      load_buf    <= 2'b10;
      load_enable <= 1'b1;
      read        <= 1'b1;
      inAddress   <= l_buf_addr;
      //if (!waitRequest) begin
      //  sizeIter <= sizeIter + 1;
      //  pState    <= read4;
      //end
    end
    read4: begin
      load_buf    <= 2'b11;
      load_enable <= 1'b1;
      read        <= 1'b1;
      inAddress   <= r_buf_addr;
      //if (!waitRequest) begin
      //  r_buf_addr <= r_buf_addr + 1;
      //  l_buf_addr <= l_buf_addr + 1;
      //  pState      <= add;
      //end
    end
    add: begin
      sum <= toSum;
      //if (sizeIter < size) begin
      //  pState <= read1;
      //end
      //else begin
      //  sizeIter <= 0;
      //  pState    <= write1;
      //end
    end
    write1: begin
      write        <= 1'b1;
      inAddress <= out_addr;
      writeData    <= sum[31:0];
      //if (!waitRequest) begin
      //  out_addr <= out_addr + 1;
      //  numIter  <= numIter + 1;
      //  pState    <= write2;
      //end
    end
    write2: begin
      write        <= 1'b1;
      inAddress <= out_addr;
      writeData    <= sum[63:32];
      //if (!waitRequest) begin
      //  out_addr <= out_addr + 1;
      //  if (numIter < num) begin
      //    sum   <= 0;
      //    pState <= read1;
      //  end
      //  else begin
      //    pState <= done;
      //  end
      //end
    end
    done: begin
      done_reg <= 1'b1;
      //if (!start) begin
      //  pState <= Idle;
      //end
    end
  endcase
end

always @(posedge csi_clock_clk) begin : FSM_StateTransition
  if (csi_clock_reset_n == 0) begin // active low reset
    pState <= Idle;
  end
  else begin
    pState <= nState;
  end
end


endmodule