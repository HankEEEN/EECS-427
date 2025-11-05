###################################
# EECS 427 F15
# Changed by Jaeyoung Kim for SOC 14.2 compatibility
# Changed on October 15th 2015
# Encounter basic script
###################################

# Warning Message Suppressions
# Suppress ANTENNADIFFAREA
 suppressMessage ENCLF-201
# Surpress VIARULE GENERATE for turn-vias from LEF file
 suppressMessage ENCPP-557
# Surpess max_fanout of output/inout pin missing from library
 suppressMessage TECHLIB-436
# Surpess physical pins missing from timing library
 suppressMessage IMPVL-159

set my_toplevel mult

# Setup design and create floorplan
source mult.globals
setDesignMode -process 65
init_design

# Initialize Floorplan
floorPlan -s 80 80 10 10 10 10
setFlipping f
redraw
fit

# Declare global VDD, VSS nets
clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VDD -type tiehi
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VSS -type tielo
applyGlobalNets

saveDesign initialized.enc

# Create Power Rings
addRing -nets {VDD VSS} -around each_block -center 1 -layer {top M3 bottom M3 left M2 right M2} -width {top 2 bottom 2 left 2 right 2} -spacing {top 1 bottom 1 left 1 right 1}

# Add Stripes (optional but always very recommended)
# Should add more stripes in other metal layers
setAddStripeMode -break_at block_ring -stacked_via_bottom_layer M3 -stacked_via_top_layer M5

addStripe -direction vertical -nets {VDD VSS}  -extend_to design_boundary -set_to_set_distance 24.3 -width 1.2 -spacing 5.4 -layer M4 -create_pins 1 -xleft_offset 0

saveDesign power.enc

# Place I/O pins in block boundary
loadIoFile ${my_toplevel}.save.io

# Then preplace the scan cells as jtag cells
#specifyJtag -hinst scan_chain0
#placeJtag -nrRow 1 -nrRowTop 3 -nrRowBottom 3 -nrRowLeft 6 -nrRowRight 3 -contour

# Place standard cells but count ONLY m1 and m2 as obstructions
setDesignMode -congEffort High -topRoutingLayer 3

setOptMode -allEndPoints true
placeDesign -prePlaceOpt
optDesign -preCTS

deletePlaceBlockage -all
addTieHiLo -cell "TIEH TIEL" -prefix tie 


redraw
saveDesign placed.enc
redraw

# Route power nets
# -noBlockPins -noPadRings replaced by -connect (unused for this time)
sroute -blockPinTarget nearestTarget

saveDesign power_routed.enc

# Run Clock Tree Generation
# Read the Encounter User Guide clkSynthesis commands to view syntax
#setCTSMode -engine ck
# ckSynthesis -rguide cts.rguide -report report.ctsrpt -macromodel report.ctsmdl -fix_added_buffers -forceReconvergent

setDesignMode -topRoutingLayer 4
clock_opt_design -cts
#setDesignMode -topRoutingLayer 3      //modilfied 021025

reset_ccopt_config
#createClockTreeSpec -output ${my_toplevel}.cts
create_ccopt_clock_tree_spec -file ${my_toplevel}.cts
#specifyClockTree -file ${my_toplevel}.cts
source ${my_toplevel}.cts


#Optimize Design after CTS
optDesign -postCTS


# Output Results of CTS
#trialRoute -highEffort -guide cts.rguide
earlyGlobalRoute

# Add filler cells
addFiller -cell FILL64 -prefix FILL -fillBoundary
addFiller -cell FILL32 -prefix FILL -fillBoundary
addFiller -cell FILL16 -prefix FILL -fillBoundary
addFiller -cell FILL8 -prefix FILL -fillBoundary
addFiller -cell FILL4 -prefix FILL -fillBoundary
addFiller -cell FILL2 -prefix FILL -fillBoundary
addFiller -cell FILL1 -prefix FILL -fillBoundary


# Connect all fixed VDD,VSS inputs to TIEHI/TIELO cells
globalNetConnect VDD -type tiehi
globalNetConnect VDD -type pgpin -pin VDD -override
globalNetConnect VSS -type tielo
globalNetConnect VSS -type pgpin -pin VSS -override

# Timing driven routing or timing optimization
setNanoRouteMode -drouteUseViaOfCut 2
setNanoRouteMode -drouteFixAntenna false
setNanoRouteMode -drouteSearchAndRepair true 
setNanoRouteMode -droutePostRouteSwapVia multicut
setDesignMode -bottomRoutingLayer 1

globalDetailRoute

# Fix Antenna errors
# Set the top metal lower than the maximum level to avoid adding diodes
setNanoRouteMode -routeInsertDiodeForClockNets true
setNanoRouteMode -drouteFixAntenna true
setNanoRouteMode -routeAntennaCellName "ANTENNA"     
#modified 01/17/2025
setNanoRouteMode -routeInsertAntennaDiode true
setNanoRouteMode -drouteSearchAndRepair true 

globalDetailRoute

# Save Desing
saveDesign routed.enc

# Output DEF, LEF and GDSII
#set dbgLefDefOutVersion 5.7
#defout ../def/${my_toplevel}.def  -placement -routing 
write_lef_abstract -5.7 ../lef/${my_toplevel}.lef
setStreamOutMode -SEvianames ON
streamOut ../gds2/${my_toplevel}.gds2 -mapFile /afs/umich.edu/class/eecs427/tsmc65/stdcells/PRTF_EDI_65nm_001_Cad_V24a/PR_tech/Cadence/GdsOutMap/PRTF_EDI_N65_gdsout_6X1Z1U.24a.map -libName tcbn65gplusbc -structureName ${my_toplevel} -stripes 1 -units 1000 -mode ALL

#editSelect -nets clk
#deleteSelectedFromFPlan

saveNetlist -includePowerGround -excludeLeafCell ../verilog/${my_toplevel}.apr.v

# Generate SDF
setExtractRCMode -engine postRoute -effortLevel high -relative_c_th 0.01 -total_c_th 0.01 -Reduce 0.0 -specialNet true
extractRC -outfile ${my_toplevel}.cap
#rcOut -spf ${my_toplevel}.spf
rcOut -spef ${my_toplevel}.spef

setUseDefaultDelayLimit 10000
setDelayCalMode -engine aae -signoff true -ecsmType ecsmOnDemand
write_sdf ../sdf/${my_toplevel}.apr.sdf

# Run Geometry and Connection checks
verifyGeometry -reportAllCells -noOverlap -report ${my_toplevel}.geom.rpt
fixVia -minCut
# Meant for power vias that are just too small
verifyConnectivity -type all -noAntenna -report ${my_toplevel}.conn.rpt

puts "**************************************"
puts "*                                    *"
puts "* Innovus script finished            *"
puts "*                                    *"
puts "**************************************"
