simSetSimulator "-vcssv" -exec "./simv" -args "-no_save" -uvmDebug on -simDelim
debImport "-i" "-simflow" "-dbdir" "./simv.daidir"
srcTBInvokeSim
verdiSetActWin -dock widgetDock_<Member>
verdiWindowResize -win $_Verdi_1 "830" "337" "900" "700"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcHBSelect "pc_new_tb.pc_new_dut" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "pc_new_tb.pc_new_dut" -win $_nTrace1
srcSetScope "pc_new_tb.pc_new_dut" -delim "." -win $_nTrace1
srcHBSelect "pc_new_tb.pc_new_dut" -win $_nTrace1
wvCreateWindow
verdiSetActWin -win $_nWave3
srcSignalView -on
verdiSetActWin -dock widgetDock_<Signal_List>
srcSignalViewSelect "pc_new_tb.pc_new_dut.i_sys_clk"
srcSignalViewSelect "pc_new_tb.pc_new_dut.i_sys_clk" \
           "pc_new_tb.pc_new_dut.i_sys_rstn" "pc_new_tb.pc_new_dut.i_scan_en" \
           "pc_new_tb.pc_new_dut.i_scan_in" "pc_new_tb.pc_new_dut.o_scan_out" \
           "pc_new_tb.pc_new_dut.i_stall" "pc_new_tb.pc_new_dut.i_disp\[7:0\]" \
           "pc_new_tb.pc_new_dut.i_rf_addr_n\[15:0\]" \
           "pc_new_tb.pc_new_dut.i_bcond" "pc_new_tb.pc_new_dut.i_jump" \
           "pc_new_tb.pc_new_dut.o_pc\[15:0\]"
srcSignalViewSelect "pc_new_tb.pc_new_dut.i_sys_clk" \
           "pc_new_tb.pc_new_dut.i_sys_rstn" "pc_new_tb.pc_new_dut.i_scan_en" \
           "pc_new_tb.pc_new_dut.i_scan_in" "pc_new_tb.pc_new_dut.o_scan_out" \
           "pc_new_tb.pc_new_dut.i_stall" "pc_new_tb.pc_new_dut.i_disp\[7:0\]" \
           "pc_new_tb.pc_new_dut.i_rf_addr_n\[15:0\]" \
           "pc_new_tb.pc_new_dut.i_bcond" "pc_new_tb.pc_new_dut.i_jump" \
           "pc_new_tb.pc_new_dut.o_pc\[15:0\]" \
           "pc_new_tb.pc_new_dut.ADDR_WIDTH" \
           "pc_new_tb.pc_new_dut.OFFSET_WIDTH" \
           "pc_new_tb.pc_new_dut.r_pc\[15:0\]"
srcSignalViewSelect "pc_new_tb.pc_new_dut.i_sys_clk" \
           "pc_new_tb.pc_new_dut.i_sys_rstn" "pc_new_tb.pc_new_dut.i_scan_en" \
           "pc_new_tb.pc_new_dut.i_scan_in" "pc_new_tb.pc_new_dut.o_scan_out" \
           "pc_new_tb.pc_new_dut.i_stall" "pc_new_tb.pc_new_dut.i_disp\[7:0\]" \
           "pc_new_tb.pc_new_dut.i_rf_addr_n\[15:0\]" \
           "pc_new_tb.pc_new_dut.i_bcond" "pc_new_tb.pc_new_dut.i_jump" \
           "pc_new_tb.pc_new_dut.o_pc\[15:0\]" \
           "pc_new_tb.pc_new_dut.ADDR_WIDTH"
srcSignalViewSelect "pc_new_tb.pc_new_dut.i_sys_clk" \
           "pc_new_tb.pc_new_dut.i_sys_rstn" "pc_new_tb.pc_new_dut.i_scan_en" \
           "pc_new_tb.pc_new_dut.i_scan_in" "pc_new_tb.pc_new_dut.o_scan_out" \
           "pc_new_tb.pc_new_dut.i_stall" "pc_new_tb.pc_new_dut.i_disp\[7:0\]" \
           "pc_new_tb.pc_new_dut.i_rf_addr_n\[15:0\]" \
           "pc_new_tb.pc_new_dut.i_bcond" "pc_new_tb.pc_new_dut.i_jump" \
           "pc_new_tb.pc_new_dut.o_pc\[15:0\]"
srcSignalViewSelect "pc_new_tb.pc_new_dut.r_pc\[15:0\]"
srcSignalViewSelect "pc_new_tb.pc_new_dut.i_sys_clk"
srcSignalViewSelect "pc_new_tb.pc_new_dut.i_sys_clk" \
           "pc_new_tb.pc_new_dut.i_sys_rstn" "pc_new_tb.pc_new_dut.i_scan_en" \
           "pc_new_tb.pc_new_dut.i_scan_in" "pc_new_tb.pc_new_dut.o_scan_out" \
           "pc_new_tb.pc_new_dut.i_stall" "pc_new_tb.pc_new_dut.i_disp\[7:0\]" \
           "pc_new_tb.pc_new_dut.i_rf_addr_n\[15:0\]" \
           "pc_new_tb.pc_new_dut.i_bcond" "pc_new_tb.pc_new_dut.i_jump"
srcSignalViewSelect "pc_new_tb.pc_new_dut.i_sys_clk" \
           "pc_new_tb.pc_new_dut.i_sys_rstn" "pc_new_tb.pc_new_dut.i_scan_en" \
           "pc_new_tb.pc_new_dut.i_scan_in" "pc_new_tb.pc_new_dut.o_scan_out" \
           "pc_new_tb.pc_new_dut.i_stall" "pc_new_tb.pc_new_dut.i_disp\[7:0\]" \
           "pc_new_tb.pc_new_dut.i_rf_addr_n\[15:0\]" \
           "pc_new_tb.pc_new_dut.i_bcond" "pc_new_tb.pc_new_dut.i_jump" \
           "pc_new_tb.pc_new_dut.o_pc\[15:0\]"
srcSignalViewSelect "pc_new_tb.pc_new_dut.i_sys_clk" \
           "pc_new_tb.pc_new_dut.i_sys_rstn" "pc_new_tb.pc_new_dut.i_scan_en" \
           "pc_new_tb.pc_new_dut.i_scan_in" "pc_new_tb.pc_new_dut.o_scan_out" \
           "pc_new_tb.pc_new_dut.i_stall" "pc_new_tb.pc_new_dut.i_disp\[7:0\]" \
           "pc_new_tb.pc_new_dut.i_rf_addr_n\[15:0\]" \
           "pc_new_tb.pc_new_dut.i_bcond" "pc_new_tb.pc_new_dut.i_jump" \
           "pc_new_tb.pc_new_dut.o_pc\[15:0\]" \
           "pc_new_tb.pc_new_dut.r_pc\[15:0\]"
srcSignalViewSelect "pc_new_tb.pc_new_dut.i_sys_clk" \
           "pc_new_tb.pc_new_dut.i_sys_rstn" "pc_new_tb.pc_new_dut.i_scan_en" \
           "pc_new_tb.pc_new_dut.i_scan_in" "pc_new_tb.pc_new_dut.o_scan_out" \
           "pc_new_tb.pc_new_dut.i_stall" "pc_new_tb.pc_new_dut.i_disp\[7:0\]" \
           "pc_new_tb.pc_new_dut.i_rf_addr_n\[15:0\]" \
           "pc_new_tb.pc_new_dut.i_bcond" "pc_new_tb.pc_new_dut.i_jump" \
           "pc_new_tb.pc_new_dut.o_pc\[15:0\]" \
           "pc_new_tb.pc_new_dut.r_pc\[15:0\]" \
           "pc_new_tb.pc_new_dut.r_scan_out" \
           "pc_new_tb.pc_new_dut.w_rf_addr\[15:0\]" \
           "pc_new_tb.pc_new_dut.w_pc_plus1\[15:0\]" \
           "pc_new_tb.pc_new_dut.w_br_addend\[15:0\]" \
           "pc_new_tb.pc_new_dut.w_pc_addout\[15:0\]" \
           "pc_new_tb.pc_new_dut.w_pc_next\[15:0\]"
wvAddSignal -win $_nWave3 "/pc_new_tb/pc_new_dut/i_sys_clk" \
           "/pc_new_tb/pc_new_dut/i_sys_rstn" \
           "/pc_new_tb/pc_new_dut/i_scan_en" "/pc_new_tb/pc_new_dut/i_scan_in" \
           "/pc_new_tb/pc_new_dut/o_scan_out" "/pc_new_tb/pc_new_dut/i_stall" \
           "/pc_new_tb/pc_new_dut/i_disp\[7:0\]" \
           "/pc_new_tb/pc_new_dut/i_rf_addr_n\[15:0\]" \
           "/pc_new_tb/pc_new_dut/i_bcond" "/pc_new_tb/pc_new_dut/i_jump" \
           "/pc_new_tb/pc_new_dut/o_pc\[15:0\]" \
           "/pc_new_tb/pc_new_dut/r_pc\[15:0\]" \
           "/pc_new_tb/pc_new_dut/r_scan_out" \
           "/pc_new_tb/pc_new_dut/w_rf_addr\[15:0\]" \
           "/pc_new_tb/pc_new_dut/w_pc_plus1\[15:0\]" \
           "/pc_new_tb/pc_new_dut/w_br_addend\[15:0\]" \
           "/pc_new_tb/pc_new_dut/w_pc_addout\[15:0\]" \
           "/pc_new_tb/pc_new_dut/w_pc_next\[15:0\]"
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G1" 18)}
wvSetPosition -win $_nWave3 {("G1" 18)}
srcHBSelect "pc_new_tb" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "pc_new_tb" -win $_nTrace1
srcSetScope "pc_new_tb" -delim "." -win $_nTrace1
srcHBSelect "pc_new_tb" -win $_nTrace1
srcHBSelect "pc_new_tb.pc_new_dut" -win $_nTrace1
srcHBSelect "pc_new_tb.pc_new_dut" -win $_nTrace1
srcSetScope "pc_new_tb.pc_new_dut" -delim "." -win $_nTrace1
srcHBSelect "pc_new_tb.pc_new_dut" -win $_nTrace1
srcHBSelect "pc_new_tb" -win $_nTrace1
srcSetScope "pc_new_tb" -delim "." -win $_nTrace1
srcHBSelect "pc_new_tb" -win $_nTrace1
srcSignalViewSelect "pc_new_tb.r_sys_clk"
verdiSetActWin -dock widgetDock_<Signal_List>
srcSignalViewSelect "pc_new_tb.r_sys_clk" "pc_new_tb.r_sys_rstn" \
           "pc_new_tb.r_scan_en" "pc_new_tb.r_scan_in" "pc_new_tb.w_scan_out" \
           "pc_new_tb.r_stall" "pc_new_tb.r_disp\[7:0\]" \
           "pc_new_tb.r_rf_addr_n\[15:0\]" "pc_new_tb.r_bcond" \
           "pc_new_tb.r_jump" "pc_new_tb.r_pc\[15:0\]" "pc_new_tb.w_pc" \
           "pc_new_tb.r_pattern_in\[15:0\]" "pc_new_tb.r_pattern_out\[15:0\]"
wvSetPosition -win $_nWave3 {("G1" 9)}
wvSetPosition -win $_nWave3 {("G1" 17)}
wvSetPosition -win $_nWave3 {("G1" 0)}
wvSetPosition -win $_nWave3 {("G2" 0)}
wvAddSignal -win $_nWave3 "/pc_new_tb/r_sys_clk" "/pc_new_tb/r_sys_rstn" \
           "/pc_new_tb/r_scan_en" "/pc_new_tb/r_scan_in" \
           "/pc_new_tb/w_scan_out" "/pc_new_tb/r_stall" \
           "/pc_new_tb/r_disp\[7:0\]" "/pc_new_tb/r_rf_addr_n\[15:0\]" \
           "/pc_new_tb/r_bcond" "/pc_new_tb/r_jump" "/pc_new_tb/r_pc\[15:0\]" \
           "/pc_new_tb/w_pc" "/pc_new_tb/r_pattern_in\[15:0\]" \
           "/pc_new_tb/r_pattern_out\[15:0\]"
wvSetPosition -win $_nWave3 {("G2" 0)}
wvSetPosition -win $_nWave3 {("G2" 14)}
wvSetPosition -win $_nWave3 {("G2" 14)}
wvScrollUp -win $_nWave3 12
wvScrollDown -win $_nWave3 0
srcTBRunSim
wvSetCursor -win $_nWave3 1389960.536779 -snap {("G1" 1)}
wvZoomAll -win $_nWave3
verdiSetActWin -win $_nWave3
srcSignalView -off
verdiDockWidgetMaximize -dock windowDock_nWave_3
wvSelectSignal -win $_nWave3 {( "G1" 11 )} 
wvSelectSignal -win $_nWave3 {( "G1" 11 12 )} 
wvSelectSignal -win $_nWave3 {( "G1" 11 12 13 14 15 )} 
wvSelectSignal -win $_nWave3 {( "G1" 14 )} 
wvSelectSignal -win $_nWave3 {( "G1" 11 )} 
wvSelectSignal -win $_nWave3 {( "G1" 12 )} 
wvSelectSignal -win $_nWave3 {( "G1" 11 )} 
wvSelectSignal -win $_nWave3 {( "G1" 11 12 )} 
wvSelectSignal -win $_nWave3 {( "G1" 11 12 15 )} 
wvSelectSignal -win $_nWave3 {( "G1" 11 12 15 16 )} 
wvSelectSignal -win $_nWave3 {( "G1" 11 12 15 16 17 )} 
wvSelectSignal -win $_nWave3 {( "G1" 11 12 15 16 17 18 )} 
wvSelectSignal -win $_nWave3 {( "G1" 11 12 15 16 17 18 )} {( "G2" 8 )} 
wvSelectSignal -win $_nWave3 {( "G1" 11 12 15 16 17 18 )} {( "G2" 7 8 )} 
wvSelectSignal -win $_nWave3 {( "G1" 6 )} 
wvSelectSignal -win $_nWave3 {( "G1" 2 )} 
wvSelectSignal -win $_nWave3 {( "G1" 3 )} 
wvSelectSignal -win $_nWave3 {( "G1" 4 )} 
wvSelectSignal -win $_nWave3 {( "G1" 5 )} 
wvSelectSignal -win $_nWave3 {( "G1" 6 )} 
wvSelectSignal -win $_nWave3 {( "G1" 7 )} 
