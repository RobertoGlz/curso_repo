** INFO ------------------------------------------------------------------------
** File name: 	        assignment_curso_econometria.do	      
** Creation date:       
** Last modified date:  
** Author:          	Marco Medina & Erick Molina
** Machine:				erick
** Version:				18.0
** Modifications:       
** 
** Files used:     		
**
** Files created:        
** Purpose:				Create a dataset 
**	                    
**

** 0. CLEAR & DEFINE DIRECTORY -------------------------------------------------

** Clearing
clear all 
clear mata 
set more off

** Directory
global directorio "C:/Users/erick/Dropbox/Aplicaciones/Overleaf/pilot3/Pilot_3_2022"

if "`c(username)'" == "Rob_9" {
	global directorio "C:/Users/Rob_9/Dropbox/CCL_CDMX/proy_curso_2024"
	global src "${directorio}/curso_src"
}

** 1. BUILD DATASET ------------------------------------------------------------

use "${src}/treatment_2w_2m_final_sample.dta", clear

** Rename id_actor for the merge. Remember the fuzzy match database has id_actor_treat
** 	and id_actor_admin
rename id_actor id_actor_treat

** Merge data
merge 1:1 id_actor_treat using "${src}/seguimiento_dem_p3.dta", keep(1 3)

** Sanity check: There are 10 case files that matched with admin but we couldn't
** 	recover their information.
tab _merge admin_sue
drop _merge

** Gen running variables
replace salario_diario = salario_diario - 211
replace antiguedad = antiguedad - 2.67

** Gen variables for main_treatment
gen t2 = [main_treatment == 2] if sample_main_treatments == 1
gen t3 = [main_treatment == 3] if sample_main_treatments == 1
gen t23 = [main_treatment == 2 | main_treatment == 3] if sample_main_treatments == 1

keep if sample_main_treatments == 1

/* Imppute 0 in update_prob to control units */
set seed 1234
replace update_prob = rnormal(0, 0.001)

** Gen variables for A/B treatment
gen tB = [group == 2] if sample_a_b == 1

** Gen outcome variables
capture gen termino_convenio = [modo_termino == 1]
capture gen solved_eventually = [termino_convenio == 1 | solved_conflict == 1]

/*
** Create labels
label var corte_dw "Wage above cutoff"
label define cortes_dw 0 "Wage below cutoff"  1 "Wage above cutoff"
label values corte_dw cortes_dw

label var corte_tenure "Tenure above cutoff"
label define cortes_tenure 0 "Tenure below cutoff"  1 "Tenure above cutoff"
label values corte_tenure cortes_tenure

label var t2 "Calculator"
label var t3 "Calculator + Letter"
label var tB "Uber"

label define treats_23 0 "Control"  1 "Calculator w./w.o. Letter"
label values t23 treats_23

label define main_treatments 1 "Control"  2 "Calculator" 3 "Calculator + Letter"
label values main_treatment main_treatments

label define groups 1 "Control"  2 "Uber"
label values group groups

label var entablo_demanda_2m "Sue (2m survey)"
label var admin_sue "Sue (admin)"
label var any_sue "Sue (2m survey + admin)"

/* Has hablado con abogado publico o coyote */
label var ha_hablado_con_abogado_pub_2w "Talked to Public Lawyer"
label var ha_hablado_con_informal_2w "Talked to Informal Lawyer"

label var conflicto_arreglado_2w "Solved Conflict (2w)"
label var conflicto_arreglado_2m "Solved Conflict (2m)"
label var solved_conflict "Solved Conflict (2w + 2m)"
label var termino_convenio "Solved Conflict (sue)"
label var solved_eventually "Solved Conflict (2w + 2m + sue)"

** Dependant variables
//local depvar entablo_demanda_2m admin_sue any_sue solved_conflict solved_eventually ///
//			 ha_hablado_con_abogado_pub_2w ha_hablado_con_informal_2w

*/