module AVM_AVALONMASTER_MAGNITUDE #
(
  // you can add parameters here
  // you can change these parameters
  parameter integer AVM_AVALONMASTER_DATA_WIDTH = 32,
  parameter integer AVM_AVALONMASTER_ADDRESS_WIDTH = 32
)
(
  // user ports begin

  // these are just some example ports. you can change them all
  //input wire START,
  input wire load_enable,
  input wire READ,
  input wire WRITE,
  input wire [1:0] load_buf,
  input wire [AVM_AVALONMASTER_ADDRESS_WIDTH - 1:0] inAddress,
  input wire [AVM_AVALONMASTER_DATA_WIDTH - 1:0] writeData,
  //input wire [AVM_AVALONMASTER_ADDRESS_WIDTH - 1:0] writeAddress,
  //output wire DONE,
  output wire waitRequest,
  output wire [AVM_AVALONMASTER_DATA_WIDTH - 1:0] r_buf0,
  output wire [AVM_AVALONMASTER_DATA_WIDTH - 1:0] l_buf0,
  output wire [AVM_AVALONMASTER_DATA_WIDTH - 1:0] r_buf1,
  output wire [AVM_AVALONMASTER_DATA_WIDTH - 1:0] l_buf1,

  // user ports end
  // dont change these ports
  input wire CSI_CLOCK_CLK,
  input wire CSI_CLOCK_RESET_N,
  output wire [AVM_AVALONMASTER_ADDRESS_WIDTH - 1:0] AVM_AVALONMASTER_ADDRESS,
  input wire AVM_AVALONMASTER_WAITREQUEST,
  output wire AVM_AVALONMASTER_READ,
  output wire AVM_AVALONMASTER_WRITE,
  input wire [AVM_AVALONMASTER_DATA_WIDTH - 1:0] AVM_AVALONMASTER_READDATA,
  output wire [AVM_AVALONMASTER_DATA_WIDTH - 1:0] AVM_AVALONMASTER_WRITEDATA
);

  // output wires and registers
  // you can change name and type of these ports
  //reg done;
  reg [AVM_AVALONMASTER_ADDRESS_WIDTH - 1:0] address;
  wire read;
  wire write;
  reg [AVM_AVALONMASTER_DATA_WIDTH - 1:0] writedata;
  reg [AVM_AVALONMASTER_DATA_WIDTH - 1:0] R_BUF0;
  reg [AVM_AVALONMASTER_DATA_WIDTH - 1:0] L_BUF0;
  reg [AVM_AVALONMASTER_DATA_WIDTH - 1:0] R_BUF1;
  reg [AVM_AVALONMASTER_DATA_WIDTH - 1:0] L_BUF1;

  // I/O assignment
  // never directly send values to output
  //assign DONE = done;
  assign waitRequest = AVM_AVALONMASTER_WAITREQUEST;
  assign read = READ;
  assign write = WRITE;
  assign r_buf0 = R_BUF0;
  assign l_buf0 = L_BUF0;
  assign r_buf1 = R_BUF1;
  assign l_buf1 = L_BUF1;
  //assign address = ;
  assign AVM_AVALONMASTER_ADDRESS = inAddress;
  assign AVM_AVALONMASTER_READ = read;
  assign AVM_AVALONMASTER_WRITE = write;
  assign AVM_AVALONMASTER_WRITEDATA = writedata;


  /****************************************************************************
  * all main function must be here or in main module. you MUST NOT use control
  * interface for the main operation and only can import and export some wires
  * from/to it
  ****************************************************************************/

  // user logic begin
  always @(posedge CSI_CLOCK_CLK)
  begin
    if(CSI_CLOCK_RESET_N == 0)
    begin
      //done <= 0;
      R_BUF0 <= 0;
      L_BUF0 <= 0;
      R_BUF1 <= 0;
      L_BUF1 <= 0;
    end
    else if (load_enable) begin
      case (load_buf)
        0: R_BUF0 <= AVM_AVALONMASTER_READDATA;
        1: L_BUF0 <= AVM_AVALONMASTER_READDATA;
        2: R_BUF1 <= AVM_AVALONMASTER_READDATA;
        3: L_BUF1 <= AVM_AVALONMASTER_READDATA;
        default: begin
          R_BUF0 <= R_BUF0;
          L_BUF0 <= L_BUF0;
          R_BUF1 <= R_BUF1;
          L_BUF1 <= L_BUF1;
        end
      endcase
    end
  end

  // user logic end

endmodule