//******************************************************************************
// file:    axi_lite_otm.v
//
// author:  JAY CONVERTINO
//
// date:    2025/12/01
//
// about:   Brief
// AXI Lite Single master to multiple slave crossbar.
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
// IN THE SOFTWARE.
//
//******************************************************************************

`resetall
`timescale 1 ns/100 ps
`default_nettype none

/*
 * Module: up_apb3
 *
 * APB3 slave to uP interface
 *
 * Parameters:
 *
 *   ADDRESS_WIDTH    - Width of the AXI LITE address port in bits.
 *   BUS_WIDTH        - Width of the AXI LITE bus data port in bytes.
 *   SLAVE_ADDRESS    - Array of Addresses for each slave (0 = slave 0 and so on).
 *   SLAVE_REGION     - Region for the address that is valid for the SLAVE ADDRESS.
 *
 * Ports:
 *
 *
 */
module axi_lite_write_channel_decoder #(
    parameter integer              ADDRESS_WIDTH = 32,
    parameter integer              BUS_WIDTH     = 4,
    parameter integer              DATA_BUFFER   = 1,
    parameter integer              TIMEOUT_BEATS = 32,
    parameter [ADDRESS_WIDTH-1:0]  SLAVE_ADDRESS = 32'h44A20000,
    parameter [ADDRESS_WIDTH-1:0]  SLAVE_REGION  = 32'h0000FFFF
  ) 
  (
    output  wire                            connected,
    input   wire                            aclk,
    input   wire                            arstn,
    //master interface
    //input master write address
    input   wire [ADDRESS_WIDTH-1:0]        s_axi_awaddr,
    input   wire [2:0]                      s_axi_awprot,
    input   wire                            s_axi_awvalid,
    output  wire                            s_axi_awready,
    //input master write data
    input   wire [BUS_WIDTH*8-1:0]          s_axi_wdata,
    input   wire [BUS_WIDTH-1:0]            s_axi_wstrb,
    input   wire                            s_axi_wvalid,
    output  wire                            s_axi_wready,
    //output master write data state
    output  wire [1:0]                      s_axi_bresp,
    output  wire                            s_axi_bvalid,
    input   wire                            s_axi_bready,
    //slave interfaces
    //output slave write address
    output  wire [ADDRESS_WIDTH-1:0]        m_axi_awaddr,
    output  wire [2:0]                      m_axi_awprot,
    output  wire                            m_axi_awvalid,
    input   wire                            m_axi_awready,
    //output slave write data
    output  wire [BUS_WIDTH*8-1:0]          m_axi_wdata,
    output  wire [BUS_WIDTH-1:0]            m_axi_wstrb,
    output  wire                            m_axi_wvalid,
    input   wire                            m_axi_wready,
    //input slave write data state
    input   wire [1:0]                      m_axi_bresp,
    input   wire                            m_axi_bvalid,
    output  wire                            m_axi_bready
  );
  
  wire                            w_connected;
  
  reg                             r_timeout;
  reg [31:0]                      r_timeout_counter;
  
  assign connected = w_connected;

  holdbuffer #(
    .BUS_WIDTH(ADDRESS_WIDTH+3)
  ) inst_addr_buffer (
    .clk(aclk),
    .rstn(arstn),
    .timeout(r_timeout),
    .enable(w_connected),
    .s_data({s_axi_awprot, s_axi_awaddr}),
    .s_data_last(1'b0),
    .s_data_valid(s_axi_awvalid),
    .s_data_ready(s_axi_awready),
    .s_data_ack(),
    .m_data({m_axi_awprot, m_axi_awaddr}),
    .m_data_last(),
    .m_data_valid(m_axi_awvalid),
    .m_data_ready(m_axi_awready),
    .m_data_ack(1'b0)
  );

  bus_addr_decoder #(
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .ADDRESS(SLAVE_ADDRESS),
    .REGION(SLAVE_REGION)
  ) inst_addr_verify (
    .timeout(r_timeout),
    .connected(w_connected),
    .aclk(aclk),
    .arstn(arstn),
    .addr(s_axi_awaddr),
    .valid(s_axi_awvalid)
  );
  
  generate
    if(DATA_BUFFER == 1) begin : gen_DATA_BUFFER
      holdbuffer #(
        .BUS_WIDTH(2)
      ) inst_data_resp_buffer (
        .clk(aclk),
        .rstn(arstn),
        .timeout(r_timeout),
        .enable(w_connected),
        .s_data(m_axi_bresp),
        .s_data_last(1'b0),
        .s_data_valid(m_axi_bvalid),
        .s_data_ready(m_axi_bready),
        .s_data_ack(),
        .m_data(s_axi_bresp),
        .m_data_last(),
        .m_data_valid(s_axi_bvalid),
        .m_data_ready(s_axi_bready),
        .m_data_ack(1'b0)
      );
      
      holdbuffer #(
        .BUS_WIDTH(BUS_WIDTH*8+BUS_WIDTH)
      ) inst_data_buffer (
        .clk(aclk),
        .rstn(arstn),
        .timeout(r_timeout),
        .enable(w_connected),
        .s_data({s_axi_wstrb, s_axi_wdata}),
        .s_data_last(1'b0),
        .s_data_valid(s_axi_wvalid),
        .s_data_ready(s_axi_wready),
        .s_data_ack(),
        .m_data({m_axi_wstrb, m_axi_wdata}),
        .m_data_last(),
        .m_data_valid(m_axi_wvalid),
        .m_data_ready(m_axi_wready),
        .m_data_ack(1'b0)
      );
    end else begin : gen_NO_DATA_BUFFER
      assign s_axi_bresp = m_axi_bresp;
      assign s_axi_bvalid = m_axi_bvalid & w_connected;
      assign m_axi_bready = s_axi_bready & w_connected;
      
      assign m_axi_wstrb = s_axi_wstrb;
      assign m_axi_wdata = s_axi_wdata;
      assign m_axi_wvalid = s_axi_wvalid & w_connected;
      assign s_axi_wready = m_axi_wready & w_connected;
    end
    
    if(TIMEOUT_BEATS == 0) begin : gen_NO_TIMEOUT
      always @(posedge aclk)
      begin
        r_timeout_counter <= {32{1'b0}};
        r_timeout <= 1'b0;
      end
    end else begin : gen_TIMEOUT
      always @(posedge aclk)
      begin
        if(arstn == 1'b0)
        begin
          r_timeout_counter <= {32{1'b0}};
          r_timeout <= 1'b0;
        end else begin
          r_timeout_counter <= {32{1'b0}};
          r_timeout <= r_timeout;

          if(!s_axi_awvalid && !m_axi_bvalid && !s_axi_wvalid && w_connected)
          begin
            r_timeout_counter <= r_timeout_counter + 1;
            
            if(r_timeout_counter >= TIMEOUT_BEATS)
            begin
              r_timeout_counter <= r_timeout_counter;
              r_timeout <= 1'b1;
            end
          end
          
          if(r_timeout)
          begin
            r_timeout_counter <= {32{1'b0}};
            r_timeout <= 1'b0;
          end
        end
      end
    end
  endgenerate
  
endmodule

`resetall
