//******************************************************************************
// file:    tb_coctb.v
//
// author:  JAY CONVERTINO
//
// date:    2025/03/26
//
// about:   Brief
// Test bench wrapper for cocotb
//
// license: License MIT
// Copyright 2025 Jay Convertino
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.BUS_WIDTH
//
//******************************************************************************

`timescale 1ns/100ps

/*
 * Module: tb_cocotb
 *
 * Parameters:
 *
 *   ADDRESS_WIDTH    - Width of the AXI LITE address port in bits.
 *   BUS_WIDTH        - Width of the AXI LITE bus data port in bytes.
 *   DATA_BUFFER      - Buffer data channel, 0 to disable.
 *   TIMEOUT_BEATS    - Number of clock cycles (beats) to count till timeout. 0 disables timeout.
 *   SLAVE_ADDRESS    - Array of Addresses for each slave (0 = slave 0 and so on).
 *   SLAVE_REGION     - Region for the address that is valid for the SLAVE ADDRESS.
 *
 * Ports:
 *
 *   connected        - Core has established channel connection
 *   aclk             - Input clock
 *   arstn            - Input negative reset
 *   s_axi_awaddr     - Slave write input channel address
 *   s_axi_awprot     - Slave write input channel protection mode
 *   s_axi_awvalid    - Slave write input channel address is valid.
 *   s_axi_awready    - Slave write input channel is ready.
 *   s_axi_wdata      - Slave write input channel data
 *   s_axi_wstrb      - Slave write input channel valid bytes
 *   s_axi_wvalid     - Slave write input channel data valid
 *   s_axi_wready     - Slave write input channel is ready.
 *   s_axi_bresp      - Slave write input channel response to write(s).
 *   s_axi_bvalid     - Slave write input channel response valid.
 *   s_axi_bready     - Slave write input channel response ready.
 *   m_axi_awaddar    - Master write output channel address.
 *   m_axi_awprot     - Master write output channel protection mode.
 *   m_axi_awvalid    - Master write output channel address is valid.
 *   m_axi_awready    - Master write output channel is ready.
 *   m_axi_wdata      - Master write output channel data.
 *   m_axi_wstrb      - Master write output channel data bytes valid.
 *   m_axi_wvalid     - Master write output channel data is valid.
 *   m_axi_wvalid     - Master write output channel data ready.
 *   m_axi_bresp      - Master write output channel response.
 *   m_axi_bvalid     - Master write output channel response valid.
 *   m_axi_bready     - Master write output channel response ready.
 *
 */
module tb_cocotb #(
    parameter integer              ADDRESS_WIDTH = 32,
    parameter integer              BUS_WIDTH     = 4,
    parameter [ADDRESS_WIDTH-1:0]  SLAVE_ADDRESS = 32'h44A20000,
    parameter [ADDRESS_WIDTH-1:0]  SLAVE_REGION  = 32'h0000FFFF
  ) 
  (
    output  wire                            connected,
    input   wire                            aclk,
    input   wire                            arstn,
    input   wire [ADDRESS_WIDTH-1:0]        s_axi_awaddr,
    input   wire [2:0]                      s_axi_awprot,
    input   wire                            s_axi_awvalid,
    output  wire                            s_axi_awready,
    input   wire [BUS_WIDTH*8-1:0]          s_axi_wdata,
    input   wire [BUS_WIDTH-1:0]            s_axi_wstrb,
    input   wire                            s_axi_wvalid,
    output  wire                            s_axi_wready,
    output  wire [1:0]                      s_axi_bresp,
    output  wire                            s_axi_bvalid,
    input   wire                            s_axi_bready,
    output  wire [ADDRESS_WIDTH-1:0]        m_axi_awaddr,
    output  wire [2:0]                      m_axi_awprot,
    output  wire                            m_axi_awvalid,
    input   wire                            m_axi_awready,
    output  wire [BUS_WIDTH*8-1:0]          m_axi_wdata,
    output  wire [BUS_WIDTH-1:0]            m_axi_wstrb,
    output  wire                            m_axi_wvalid,
    input   wire                            m_axi_wready,
    input   wire [1:0]                      m_axi_bresp,
    input   wire                            m_axi_bvalid,
    output  wire                            m_axi_bready,
    input   wire [ADDRESS_WIDTH-1:0]        s_axi_araddr,
    input   wire [2:0]                      s_axi_arprot,
    input   wire                            s_axi_arvalid,
    output  wire                            s_axi_arready,
    output  wire [BUS_WIDTH*8-1:0]          s_axi_rdata,
    output  wire [1:0]                      s_axi_rresp,
    output  wire                            s_axi_rvalid,
    input   wire                            s_axi_rready,
    output  wire [ADDRESS_WIDTH-1:0]        m_axi_araddr,
    output  wire [2:0]                      m_axi_arprot,
    output  wire                            m_axi_arvalid,
    input   wire                            m_axi_arready,
    input   wire [BUS_WIDTH*8-1:0]          m_axi_rdata,
    input   wire [1:0]                      m_axi_rresp,
    input   wire                            m_axi_rvalid,
    output  wire                            m_axi_rready
  );
  // fst dump command
  initial begin
    $dumpfile ("tb_cocotb.fst");
    $dumpvars (0, tb_cocotb);
    #1;
  end
  
  wire  [ADDRESS_WIDTH-1:0] w_m_axi_awaddr;
  
  assign m_axi_awaddr = w_m_axi_awaddr & SLAVE_REGION;
  
  //Group: Instantiated Modules

  /*
   * Module: dut
   *
   * Device under test, axi_lite_wr_addr
   */
  axi_lite_write_channel_decoder #(
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .BUS_WIDTH(BUS_WIDTH),
    .SLAVE_ADDRESS(SLAVE_ADDRESS),
    .SLAVE_REGION(SLAVE_REGION)
  ) dut (
    .connected(connected),
    .aclk(aclk),
    .arstn(arstn),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awprot(s_axi_awprot),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),
    .m_axi_awaddr(w_m_axi_awaddr),
    .m_axi_awprot(m_axi_awprot),
    .m_axi_awvalid(m_axi_awvalid),
    .m_axi_awready(m_axi_awready),
    .m_axi_wdata(m_axi_wdata),
    .m_axi_wstrb(m_axi_wstrb),
    .m_axi_wvalid(m_axi_wvalid),
    .m_axi_wready(m_axi_wready),
    .m_axi_bresp(m_axi_bresp),
    .m_axi_bvalid(m_axi_bvalid),
    .m_axi_bready(m_axi_bready)
  );
  
endmodule

