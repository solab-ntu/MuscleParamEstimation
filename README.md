# MuscleParamEstimation
- The combination of biomechanics software, OpenSim, and mathematical computing software, MATLAB, is used to estimate musculotendon parameters in musculoskeletal models through optimization methods.
- The primary focus of the research centers around prediction tasks. Prior to parameter estimation, sensitivity analysis is performed to determine the desired tasks to be executed. 
- Multiple prediction tasks are executed to quantify the discrepancy between the predicted trajectories and the target trajectories, enabling the determination of parameter values for the evaluated muscles. 
- The optimal models resulting from the evaluation process are subjected to model validation to ensure their accuracy.

Author: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University

## MATLAB Code (.m)
The main code are used for muscle parameter estimation and sensitivity analysis, detailed settings can be made in the json file.

## JSON File (.json)
User settings will be set in JSON file.

- Users_settings_opt_BIC_1traj.json: Users settings in single trajectory case for optimization.
- Users_settings_opt_BIC_2traj.json: Users settings in multiple trajectories case for optimization.
- Users_settings_sa.json: Users settings for sensitivity analysis.

## XML File (.xml)
Files used to set up FWD and CMC simulations.

- xml_setup_FWD.xml: Used to set up FWD.
- xml_setup_CMC.xml: Used to set up CMC.
- xml_CMC_ComputedMuscleControl_Tasks.xml: Used to set up CMC.
- xml_CMC_ControlConstraints.xml: Used to set up CMC.
- xml_CMC_Reserve_Actuators.xml: Used to set up CMC.

## PowerShell Code (.ps1)
- OpenSim_TaskKill.ps1: Forcibly end the execution of FWD, see method 2 in "f_fwd_get_traj" function for details.

## Osim Model (.osim)
The OpenSim model file (.osim) used in simulation.

- arm26.osim: Upper extremity model.
- arm26_2500g.osim: Upper extremity model with 2500 gram load.

## Motion File (.mot)
- motion_template.mot: The template used to generate the desired motion.

## "Figure generate" Folder
Code and data for generating images in thesis

## "Functions" Folder
Functions needed to execute the main code

## "Motions" Folder
Folder for the generated desired motion.

## "Results" Folder
Folder for the simulation results.
