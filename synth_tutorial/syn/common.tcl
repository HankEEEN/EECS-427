# common.tcl setup library files

# 0.13um IBM Artisan Library
# Set library paths

set ARTISAN "/afs/umich.edu/class/eecs427/tsmc65/stdcells/tcbn65gplus_200a/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn65gplus_200a"
set SYNOPSYS [get_unix_variable SYNOPSYS]
set search_path [list "." ${SYNOPSYS}/libraries/syn "${ARTISAN}/"]
set link_library "* tcbn65gplustc.db  dw_foundation.sldb"
set target_library "tcbn65gplustc.db"

