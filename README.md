# APB3 SLAVE
### APB3 slave to Analog Devices uP interface
---

![image](docs/manual/img/AFRL.png)

---

  author: Jay Convertino   
  
  date: 2024.03.19
  
  details: Interface analog devices uP interface devices to APB3 bus
  
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

  - [up_apb3.pdf](docs/manual/up_apb3.pdf)
  - [github page](https://johnathan-convertino-afrl.github.io/up_apb3/)

### PARAMETERS

* ADDRESS_WIDTH : Bit width of the address bus.
* BUS_WIDTH     : Bus width in number of bytes.

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
