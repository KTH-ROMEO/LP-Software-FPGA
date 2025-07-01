# Created by Microsemi Libero Software 11.9.6.7
# Mon Jun 23 08:48:48 2025

# (NEW DESIGN)

# create a new design
new_design -name "test_sim" -family "ProASIC3"

# set default back-annotation base-name
set_defvar "BA_NAME" "test_sim_ba"
set_defvar "IDE_DESIGNERVIEW_NAME" {Impl1}
set_defvar "IDE_DESIGNERVIEW_COUNT" "1"
set_defvar "IDE_DESIGNERVIEW_REV0" {Impl1}
set_defvar "IDE_DESIGNERVIEW_REVNUM0" "1"
set_defvar "IDE_DESIGNERVIEW_ROOTDIR" {C:\Users\Utente\Desktop\ROMEO_FPGA\LP-Software-FPGA\designer}
set_defvar "IDE_DESIGNERVIEW_LASTREV" "1"

# set working directory
set_defvar "DESDIR" "C:/Users/Utente/Desktop/ROMEO_FPGA/LP-Software-FPGA/designer/impl1"

# set back-annotation output directory
set_defvar "BA_DIR" "C:/Users/Utente/Desktop/ROMEO_FPGA/LP-Software-FPGA/designer/impl1"

# enable the export back-annotation netlist
set_defvar "BA_NETLIST_ALSO" "1"

# set EDIF options
set_defvar "EDNINFLAVOR" "GENERIC"

# set HDL options
set_defvar "NETLIST_NAMING_STYLE" "VHDL93"

# setup status report options
set_defvar "EXPORT_STATUS_REPORT" "1"
set_defvar "EXPORT_STATUS_REPORT_FILENAME" "test_sim.rpt"

# legacy audit-mode flags (left here for historical reasons)
set_defvar "AUDIT_NETLIST_FILE" "1"
set_defvar "AUDIT_DCF_FILE" "1"
set_defvar "AUDIT_PIN_FILE" "1"
set_defvar "AUDIT_ADL_FILE" "1"

# import of input files
import_source  \
-format "edif" -edif_flavor "GENERIC" -netlist_naming "VHDL" {../../synthesis/test_sim.edn}

# export translation of original netlist
export -format "vhdl" {../../synthesis/test_sim.vhd}
