module AVS_AVALONSLAVE #
(
  // you can add parameters here
  // you can change these parameters
  parameter integer AVS_AVALONSLAVE_DATA_WIDTH = 32,
  parameter integer AVS_AVALONSLAVE_ADDRESS_WIDTH = 4
)
(
  // user ports begin
  input wire DONE,
  output wire START,
  output wire [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] SLV_REG0,
  output wire [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] rightAddress,
  output wire [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] leftAddress,
  output wire [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] outAddress,

  // user ports end
  // dont change these ports
  input wire CSI_CLOCK_CLK,
  input wire CSI_CLOCK_RESET_N,
  input wire [AVS_AVALONSLAVE_ADDRESS_WIDTH - 1:0] AVS_AVALONSLAVE_ADDRESS,
  //output wire AVS_AVALONSLAVE_WAITREQUEST, // No need to Use WaitRequest in this case (fixed response latency)
  input wire AVS_AVALONSLAVE_READ,
  input wire AVS_AVALONSLAVE_WRITE,
  output wire [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] AVS_AVALONSLAVE_READDATA,
  input wire [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] AVS_AVALONSLAVE_WRITEDATA
);

  // output wires and registers
  // you can change name and type of these ports
  wire start;

  //reg wait_request;
  reg [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] read_data;
  // these are slave registers. they MUST be here!
  reg [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] slv_reg0;
  reg [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] slv_reg1;
  reg [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] slv_reg2;
  reg [AVS_AVALONSLAVE_DATA_WIDTH - 1:0] slv_reg3;

  // I/O assignment
  // never directly send values to output
  assign START = start;

  //assign AVS_AVALONSLAVE_WAITREQUEST = wait_request;
  assign AVS_AVALONSLAVE_READDATA = read_data;
  assign SLV_REG0     = slv_reg0;
  assign rightAddress = slv_reg1;
  assign leftAddress  = slv_reg2;
  assign outAddress   = slv_reg3;
 
  // it is an example and you can change it or delete it completely
  always @(posedge CSI_CLOCK_CLK)
  begin
    slv_reg0[31] <= DONE;
    // usually resets are active low but you can change its trigger type
    if(CSI_CLOCK_RESET_N == 0)
    begin
      slv_reg0 <= 0;
      slv_reg1 <= 0;
      slv_reg2 <= 0;
      slv_reg3 <= 0;
    end
    
    else begin
      if(AVS_AVALONSLAVE_WRITE) begin
        // address is always bytewise so must devide it by 4 for 32bit word
        case(AVS_AVALONSLAVE_ADDRESS)
          0: slv_reg0[30:0] <= AVS_AVALONSLAVE_WRITEDATA[30:0];
          1: slv_reg1 <= AVS_AVALONSLAVE_WRITEDATA;
          2: slv_reg2 <= AVS_AVALONSLAVE_WRITEDATA;
          3: slv_reg3 <= AVS_AVALONSLAVE_WRITEDATA;
        default:
        begin
          slv_reg0 <= slv_reg0;
          slv_reg1 <= slv_reg1;
          slv_reg2 <= slv_reg2;
          slv_reg3 <= slv_reg3;
        end
        endcase
      end

      if (AVS_AVALONSLAVE_READ) begin
        case (AVS_AVALONSLAVE_ADDRESS)
          4'h0: read_data <= slv_reg0;
          4'h4: read_data <= slv_reg1;
          4'h8: read_data <= slv_reg2;
          4'hc: read_data <= slv_reg3;
          default: read_data <= 'bz;
        endcase
      end
    end
    // it is an example design
  end

  // do the other jobs yourself like last codes
  assign start = slv_reg0[0];

endmodule
