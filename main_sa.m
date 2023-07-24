% =========================================================================================== %
% This main code is used for sensitivity analysis, detailed settings can be made in the json file of 'Users_settings_sa'.
%
% Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
% =========================================================================================== %

clear; close all; 
addpath(genpath('./Functions'));

disp(newline + "---------- START RUNNING: " + string(datetime('now')) + " ----------");

disp(newline + "---------- INPUT USERS SETTING FOR SENSITIVITY ANALYSIS ----------");
users_settings = f_get_users_settings('Users_settings_sa.json'); % input file

case_index = 0;
for index_model = 1 : length(users_settings.sa_variable.model)
    users_settings.file.model = users_settings.sa_variable.model(index_model);
    for index_direction = 1 : length(users_settings.sa_variable.direction)
        users_settings.mot_desired(1).direction = users_settings.sa_variable.direction(index_direction);
        for index_shoulder = 1 : length(users_settings.sa_variable.shoulder_angle)
            users_settings.mot_desired(1).shoulder_angle = users_settings.sa_variable.shoulder_angle(index_shoulder);
            for index_elbow = 1 : length(users_settings.sa_variable.elbow_angle)
                users_settings.mot_desired(1).elbow_angle = users_settings.sa_variable.elbow_angle(index_elbow, :);
                case_index = case_index + 1;
                try
                    tic
                    disp(newline + "---------- Case " + string(case_index) + ": " + "PREPROCESS ----------");
                    sa_param = f_preprocess(users_settings);
                    
                    disp("---------- Case " + string(case_index) + ": " + "START SENSITIVITY ANALYSIS ----------");
                    sa_results = f_sensitivity_analysis(sa_param);
    
                    disp("---------- Case " + string(case_index) + ": " + "SAVE SENSITIVITY ANALYSIS RESULTS ----------");
                    f_sa_save_results(sa_results, sa_param, case_index, toc);
                catch ME
                    disp("Error in case"  + string(case_index)...
                                            + ": " + string(users_settings.sa_variable.model(index_model)) ...
                                            + ", " + string(users_settings.sa_variable.direction(index_direction)) ...
                                            + ", " + string(users_settings.sa_variable.shoulder_angle(index_shoulder)) ...
                                            + ", " + string(users_settings.sa_variable.elbow_angle(index_elbow, 1)) ...
                                            + ", " + string(users_settings.sa_variable.elbow_angle(index_elbow, 2)));
                    disp(ME); % throw(ME);
                end
            end
        end
    end
end

disp(newline + "---------- END RUNNING: " + string(datetime('now')) + " ----------");
rmdir('tmp', 's');