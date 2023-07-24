function NRMSE_Results = f_nrmse_compute(Muscle_Param_Value, Compute_Param)
    
    % 
    % f_nrmse_compute: Calculate prediction error (NRMSE)
    %
    % Args:
    %   Muscle_Param_Value: Muscle parameter values of the model to be calculated
    %   Compute_Param: Structure containing several structure of calculation parameters
    %       file: Structure containing the file name and path required for simulation
    %       interest: Structure containing information on muscle parameters of interest
    %       mot(i): Structure containing motion information
    %       mot_num: motion number
    %
    % Return:
    %   NRMSE_Results: Structure containing i motion information and results
    %       mot(i): Structure containing motion results
    %           traj: 2-D Array of kinematic trajectories of this model performing this motion. Col 1: time / Col 2: joint angle / Col 3: joint speed.
    %           nrmse_value: NRMSE of the joint angle item from the target trajectory
    %           nrmse_speed: NRMSE of the joint speed item from the target trajectory
    %
    % Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
    %
    
    % generate temporary file name
    temp_model = [tempname(string(Compute_Param.file.path) + "\tmp") '.osim'];

    % update muscle parameter value of the temp model
    f_update_muscle_param(Muscle_Param_Value, Compute_Param.file, Compute_Param.interest, temp_model)

    for i = 1 : Compute_Param.mot_num
        % execute FWD and obtain the kinematic trajectories (joint angle & joint speed)
        NRMSE_Results.mot(i).traj = f_fwd_get_traj(Compute_Param.file, Compute_Param.mot(i), temp_model);
        % evaluation the prediction error (NRMSE)
        NRMSE_Results.mot(i).nrmse_value = f_nrmse_evaluation(Compute_Param.mot(i).traj_target(:, 2), NRMSE_Results.mot(i).traj(:, 2));
        NRMSE_Results.mot(i).nrmse_speed = f_nrmse_evaluation(Compute_Param.mot(i).traj_target(:, 3), NRMSE_Results.mot(i).traj(:, 3));
    end
    
    %% function
    function f_update_muscle_param(Muscle_Param_Value, File, Interest, Output_Model_Filename)

        % 
        % f_update_muscle_param: Update the new muscle parameters to the model
        %
        % Args:
        %   Muscle_Param_Value: Muscle parameter values of the model to be calculated
        %   File: Structure containing the file name and path required for simulation
        %   Interest: Structure containing information on muscle parameters of interest
        %   Output_Model_Filename: After updating, the output model file name
        %
        % Return:
        %   No return
        %
        % Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
        %

        % import the OpenSim libraries
        import org.opensim.modeling.*;
    
        % get muscle list
        input_model = Model(File.model);
        muscles = input_model.getMuscles();
    
        % get muscle and set muscle param values
        for ii = 1 : length(Interest.muscle_name)
            muscle = muscles.get(Interest.muscle_name(ii));
            j = 1;
            if Interest.param_bool(ii, 1)
                muscle.setMaxIsometricForce(Muscle_Param_Value(ii, j));
                j = j+1;
            end
            if Interest.param_bool(ii, 2)
                muscle.setOptimalFiberLength(Muscle_Param_Value(ii, j));
                j = j+1;
            end
            if Interest.param_bool(ii, 3)
                muscle.setTendonSlackLength(Muscle_Param_Value(ii, j));
            end
        end
    
        % save model
        input_model.print(Output_Model_Filename);
    end
    
    function  NRMSE = f_nrmse_evaluation(V1, V2)

        % 
        %  f_nrmse_evaluation: Evaluation the prediction error (NRMSE)
        %
        % Args:
        %   V1: Target trajectory
        %   V2: Predicted trajectory
        %
        % Return:
        %   NRMSE: Prediction error
        %
        % Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
        %

        % evaluate error
        rmse = sqrt(mean((V1 - V2) .^ 2));
        NRMSE = rmse / (max(V1) - min(V1));
    end
end