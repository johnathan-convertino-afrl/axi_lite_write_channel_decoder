# AXI Lite Write Channel Decoder
### When an address match is detected connect data path porition of channel and pass address in full.
---

![image](docs/manual/img/AFRL.png)

---

  author: Jay Convertino   
  
  date: 2025.12.16
  
  details: When an address match is detected connect data path porition of channel and pass address in full.
  
  license: MIT   
   
  Actions:  

  [![Lint Status](../../actions/workflows/lint.yml/badge.svg)](../../actions)  
  [![Manual Status](../../actions/workflows/manual.yml/badge.svg)](../../actions)  
  
---

### Version
#### Current
  - V1.0.0 - initial release

#### Previous
  - none

### DOCUMENTATION
  For detailed usage information, please navigate to one of the following sources. They are the same, just in a different format.

  - [axi_lite_write_channel_decoder.pdf](docs/manual/axi_lite_write_channel_decoder.pdf)
  - [github page](https://johnathan-convertino-afrl.github.io/axi_lite_write_channel_decoder/)

### PARAMETERS

 *   ADDRESS_WIDTH    : Width of the AXI LITE address port in bits.
 *   BUS_WIDTH        : Width of the AXI LITE bus data port in bytes.
 *   DATA_BUFFER      : Buffer data channel, 0 to disable.
 *   TIMEOUT_BEATS    : Number of clock cycles (beats) to count till timeout. 0 disables timeout.
 *   SLAVE_ADDRESS    : Array of Addresses for each slave (0 = slave 0 and so on).
 *   SLAVE_REGION     : Region for the address that is valid for the SLAVE ADDRESS.

### COMPONENTS
#### SRC

* up_apb3.v

#### TB

* tb_apb3.v
* tb_cocotb.py
* tb_cocotb.v
  
### FUSESOC

* fusesoc_info.core created.
* Simulation uses icarus to run data through the core.

#### Targets

* RUN WITH: (fusesoc run --target=sim VENDER:CORE:NAME:VERSION)
  - default (for IP integration builds)
  - lint
  - sim
  - sim_cocotb
