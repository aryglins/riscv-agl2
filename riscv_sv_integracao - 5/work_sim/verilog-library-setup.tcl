#DO NOT USE WITH MODELSIM-ALTERA VERSION                                                                
#This file contains the commands to create libraries and compile the library file into those libraries. 
                                                                                                        
set path_to_quartus C:/altera/13.1/quartus 
set type_of_sim compile_all
             

if {[string equal $type_of_sim "compile_all"]} {                                                        
	# compiles all libraries     
	#lpm_ver altera_mf_ver  altera_ver sgate_ver cycloneive_ver
	vlib lpm_ver     
	vmap lpm_ver lpm_ver 	
	vlog -work lpm_ver $path_to_quartus/eda/sim_lib/220model.v  
	
	vlib altera_mf_ver
	vmap altera_mf_ver altera_mf_ver 
	vlog -work altera_mf_ver $path_to_quartus/eda/sim_lib/altera_mf.v  
	
	vlib altera_ver	 
	vmap altera_ver altera_ver  
	vlog -work altera_ver $path_to_quartus/eda/sim_lib/altera_primitives.v 
	
	vlib sgate_ver  
	vmap sgate_ver sgate_ver 
	vlog -work sgate_ver $path_to_quartus/eda/sim_lib/sgate.v   
		
	vlib cycloneiii_ver
	vmap cycloneiii_ver cycloneiii_ver                          
	vlog -work cycloneiii_ver $path_to_quartus/eda/sim_lib/cycloneiii_atoms.v
	
	# vlib cycloneive_ver
	# vmap cycloneive_ver cycloneive_ver                          
	# vlog -work cycloneive_ver $path_to_quartus/eda/sim_lib/cycloneive_atoms.v

                         
} elseif {[string equal $type_of_sim "functional"]} {                                                   
	# required for functional simulation of designs that call LPM & altera_mf functions                     
	vlib lpm_ver                                                                                          
	vmap lpm_ver lpm_ver                                                                                  
	vlog -work lpm_ver $path_to_quartus/eda/sim_lib/220model.v       
	
	vlib altera_mf_ver                                                                                    
	vmap altera_mf_ver altera_mf_ver                                                                      
	vlog -work altera_mf_ver $path_to_quartus/eda/sim_lib/altera_mf.v
	
	vlib altera_ver
	vmap altera_ver altera_ver
	vlog -work altera_ver $path_to_quartus/eda/sim_lib/altera_primitives.v   
	
}  else {                                                                                                
	puts "invalid code"
}                                                                                                