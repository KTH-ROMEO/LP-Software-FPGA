# Created by Microsemi Libero Software 11.9.6.7
# Thu Oct 09 14:45:48 2025

# (OPEN DESIGN)

open_design "Toplevel.adb"

# set default back-annotation base-name
set_defvar "BA_NAME" "Toplevel_ba"
set_defvar "IDE_DESIGNERVIEW_NAME" {Impl1}
set_defvar "IDE_DESIGNERVIEW_COUNT" "1"
set_defvar "IDE_DESIGNERVIEW_REV0" {Impl1}
set_defvar "IDE_DESIGNERVIEW_REVNUM0" "1"
set_defvar "IDE_DESIGNERVIEW_ROOTDIR" {C:\Users\Utente\Desktop\ROMEO_FPGA\LP-Software-FPGA\designer}
set_defvar "IDE_DESIGNERVIEW_LASTREV" "1"


# import of input files
import_source  \
-format "edif" -edif_flavor "GENERIC" -netlist_naming "VHDL" {../../synthesis/Toplevel.edn} -merge_physical "yes" -merge_timing "yes"
compile
report -type "status" {Toplevel_compile_report.txt}
report -type "pin" -listby "name" {Toplevel_report_pin_byname.txt}
report -type "pin" -listby "number" {Toplevel_report_pin_bynumber.txt}

save_design
