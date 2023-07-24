% =========================================================================================== %
% This main code is used for muscle parameter estimation, detailed settings can be made in the json file of 'Users_settings_opt'.
%
% Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
% =========================================================================================== %

clear; close all; 
addpath(genpath('./Functions'));

disp(newline + "---------- START RUNNING: " + string(datetime('now')) + " ----------");

disp(newline + "---------- INPUT USERS SETTING FOR OPTIMIZATION ----------");
users_settings = f_get_users_settings('Users_settings_opt_BIC_2traj.json'); % input file

disp(newline + "---------- PREPROCESS ----------");
opt_param = f_preprocess(users_settings);

val_error = 1;
while val_error > 0.01
    disp(newline + "---------- START OPTIMIZATION ----------");
    opt_results = f_optimization(opt_param);
    
    disp(newline + "---------- SHOW OPTIMAL RESULTS ----------");
    f_opt_show_results(opt_results, opt_param);
    
    disp(newline + "---------- VALIDATE OPTIMAL RESULTS ----------");
    val_error = f_opt_validate_results(opt_results, opt_param);
end

disp(newline + "---------- END RUNNING: " + string(datetime('now')) + " ----------");
rmdir('tmp', 's');