new_project \
    -name {Toplevel} \
    -location {C:\SPIDER2\Firmware\SPIDER2-Datahub-FPGA-General\designer\impl1\Toplevel_fp} \
    -mode {single}
set_programming_file -file {C:\SPIDER2\Firmware\SPIDER2-Datahub-FPGA-General\designer\impl1\Toplevel.pdb}
set_programming_action -action {PROGRAM}
run_selected_actions
save_project
close_project
