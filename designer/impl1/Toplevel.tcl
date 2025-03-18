# Created by Microsemi Libero Software 11.9.6.7
# Tue Mar 18 17:21:33 2025

# (OPEN DESIGN)

open_design "Toplevel.adb"

# set default back-annotation base-name
set_defvar "BA_NAME" "Toplevel_ba"
set_defvar "IDE_DESIGNERVIEW_NAME" {Impl1}
set_defvar "IDE_DESIGNERVIEW_COUNT" "1"
set_defvar "IDE_DESIGNERVIEW_REV0" {Impl1}
set_defvar "IDE_DESIGNERVIEW_REVNUM0" "1"
set_defvar "IDE_DESIGNERVIEW_ROOTDIR" {C:\Users\Jesus\Documents\KTH\ROMEO\Repositories\LP-Software-FPGA\designer}
set_defvar "IDE_DESIGNERVIEW_LASTREV" "1"


layout -timing_driven
report -type "status" {Toplevel_place_and_route_report.txt}
report -type "globalnet" {Toplevel_globalnet_report.txt}
report -type "globalusage" {Toplevel_globalusage_report.txt}
report -type "iobank" {Toplevel_iobank_report.txt}
report -type "pin" -listby "name" {Toplevel_report_pin_byname.txt}
report -type "pin" -listby "number" {Toplevel_report_pin_bynumber.txt}

save_design
