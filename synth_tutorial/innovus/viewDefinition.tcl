################################################
#  EECS 427 F15                                #
#  Created by Jaeyoung Kim                     #
#  Encounter Input configuration file          #
################################################

set my_toplevel mult

# Insert the standard cell timing TLF file
create_library_set \
	-name typical -timing {/afs/umich.edu/class/eecs427/tsmc65/stdcells/tcbn65gplus_200a/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn65gplus_200a/tcbn65gplusbc.lib}

# For timing based placement include the timing constraints in sdc format
# Get this constraints from synthesis Design Compiler
create_constraint_mode -name my_constraint_mode \
	-sdc_files	[list ./${my_toplevel}.sdc]

set delaycal_use_default_delay_limit {1000}
set delaycal_default_net_delay {1000.0ps}
set delaycal_default_net_load {0.5pf}
set delaycal_input_transition_delay {120.0ps}

create_rc_corner -name typical_rc_corner \
	-qx_tech_file		/afs/umich.edu/class/eecs427/tsmc65/rf1p9m6x1z1u/Assura/lvs_rcx/qrcTechFile \
	-preRoute_res		1 \
	-postRoute_res		1 \
	-preRoute_cap		1 \
	-postRoute_cap		1 \
	-postRoute_xcap		1 \
	-preRoute_clkres	0 \
	-preRoute_clkcap	0 \
	-postRoute_clkres	0 \
	-postRoute_clkcap	0

create_delay_corner -name typical_delay_corner -library_set typical -rc_corner typical_rc_corner
create_analysis_view -name typical_analysis_view -delay_corner typical_delay_corner -constraint_mode my_constraint_mode
set_analysis_view -setup {typical_analysis_view} -hold {typical_analysis_view}

set extract_shrink_factor {1.0}
#setLibraryUnit -time 1ns
#setLibraryUnit -cap 1pF


