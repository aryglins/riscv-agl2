#DO NOT USE WITH MODELSIM-ALTERA VERSION
#This file contains the commands to create libraries and compile the library file into those libraries.
set path_to_quartus C:/altera/13.1/quartus
set type_of_sim compile_all

if {[string equal $type_of_sim "compile_all"]} {
	vlib lpm
	vmap lpm lpm
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220pack.vhd
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220model.vhd
	
	vlib altera_mf
	vmap altera_mf altera_mf
	vcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf_components.vhd
	vcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf.vhd
	
	vlib altera
	vmap altera altera
	vcom -work altera -2002 -explicit $path_to_quartus/eda/sim_lib/altera_primitives_components.vhd
	vcom -work altera -2002 -explicit $path_to_quartus/eda/sim_lib/altera_primitives.vhd
	
	vlib sgate
	vmap sgate sgate
	vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate_pack.vhd
	vcom -work sgate -2002 -explicit $path_to_quartus/eda/sim_lib/sgate.vhd
	
	# vlib cycloneive
	# vmap cycloneive cycloneive
	# vcom -work cycloneive -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneive_atoms.vhd
	# vcom -work cycloneive -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneive_components.vhd	
	
	vlib cycloneiii
	vmap cycloneiii cycloneiii
	vcom -work cycloneiii -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneiii_atoms.vhd
	vcom -work cycloneiii -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneiii_components.vhd	


} elseif {[string equal $type_of_sim "functional"]} {
# required for functional simulation of designs that call LPM & altera_mf functions
	vlib lpm
	vmap lpm lpm
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220pack.vhd
	vcom -work lpm -2002 -explicit $path_to_quartus/eda/sim_lib/220model.vhd
	
	vlib altera_mf
	vmap altera_mf altera_mf
	vcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf_components.vhd
	vcom -work altera_mf -2002 -explicit $path_to_quartus/eda/sim_lib/altera_mf.vhd
	
	vlib altera
	vmap altera altera
	vcom -work altera -2002 -explicit $path_to_quartus/eda/sim_lib/altera_primitives_components.vhd
	vcom -work altera -2002 -explicit $path_to_quartus/eda/sim_lib/altera_primitives.vhd
	
} elseif {[string equal $type_of_sim "cycloneiii"]} {
	# required for gate-level simulation of CYCLONEIII designs
	vlib cycloneiii
	vmap cycloneiii cycloneiii
	vcom -work cycloneiii -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneiii_atoms.vhd
	vcom -work cycloneiii -2002 -explicit $path_to_quartus/eda/sim_lib/cycloneiii_components.vhd
} else {
	puts "invalid code"
}
