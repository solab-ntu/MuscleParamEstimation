function Traj_Interp = f_fwd_get_traj(File, Mot, Tmp_Model)

    % 
    % f_fwd_get_traj: Execute Forward Dynamics simulation and obtain the kinematic trajectories (joint angle & joint speed)
    %
    % Args:
    %   File: Structure containing the file name and path required for simulation
    %       path: Path of the current folder
    %       model: An OpenSim model file (.osim)
    %       setup_fwd: Setup for FWD simulation (.xml)
    %   Mot: Structure containing motion information
    %       motion_control_filename: Desired motion file name (.mot)
    %       time_duration: Time duration of desired motion 
    %       T_shift: Idle time before and after CMC simulation
    %   Tmp_Model: If the executed model is a temporary file (tmpfile.osim or 0)
    %
    % Return:
    %   Traj_Interp: 2-D Array of kinematic trajectories (interpolation). Col 1: time / Col 2: joint angle / Col 3: joint speed.
    %
    % Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
    %

    % import the OpenSim libraries
    import org.opensim.modeling.*;

    % FWD parameter
    controls_filename = string(File.path) + "\Results\CMC_" + strrep(File.model, ".osim", "") + "_" + strrep(Mot.motion_control_filename, ".mot", "") + "\CMC_arm26_controls.xml";
    states_filename = string(File.path) + "\Results\CMC_" + strrep(File.model, ".osim", "") + "_" + strrep(Mot.motion_control_filename, ".mot", "") + "\CMC_arm26_states.sto";

    if ischar(Tmp_Model) 
        % for tmp model (predictive model in the paper)
        results_dir_fwd = strrep(Tmp_Model, ".osim", "");
        input_model = Model(Tmp_Model);
    else 
        % for targer model
        results_dir_fwd = string(File.path) + "\Results\FWD_" + strrep(File.model, ".osim", "") + "_" + strrep(Mot.motion_control_filename, ".mot", "");
        input_model = Model(File.model);
    end

    % FWD setup
    myFWD = ForwardTool(File.setup_fwd, true, false); % ForwardTool	(const std::string & aFileName, bool aUpdateFromXMLNode = true, bool aLoadModel = true)	
    myFWD.setFinalTime(Mot.time_duration + Mot.T_shift);
    myFWD.setControlsFileName(controls_filename);
    myFWD.setStatesFileName(states_filename);
    myFWD.setResultsDir(results_dir_fwd);
    myFWD.updateModelForces(input_model, File.setup_fwd); % forceset is tied to the model, so if "aLoadModel = false", "updateModelForces" is required
    myFWD.setModel(input_model);
    
    % FWD run
    % method 1
    myFWD.run();

%     % method 2: use cmd to execute FWD. The purpose is to independently monitor the execution time of FWD and force it to end if necessary
%     % remember to revise path of <force_set_files> in "xml_setup_FWD.xml" file, for example, C:\Users\users\Desktop\code\xml_CMC_Reserve_Actuators.xml.
%     if ischar(Tmp_Model)
%         % new setup file for tmp model
%         model_filename = Tmp_Model;
%         myFWD.setModelFilename(model_filename);
%         setup_fwd_new = results_dir_fwd + '.xml';
%         myFWD.print(setup_fwd_new);
%         [~, ~] = system('opensim-cmd run-tool ' + setup_fwd_new + ' >nul');
%     else
%         % run directly for target model
%         myFWD.run();
%     end
%     % check if forward dynamics has been executed
%     if ~isfile(results_dir_fwd + "\FWD_arm26_states_degrees.mot")
%         error('MyComponent:NotFinish', 'Force-kill the forward simulation');
%     end

    % read the simulation results
    mot_filename = results_dir_fwd + "\FWD_arm26_states_degrees.mot";
    mot_table = TimeSeriesTable(mot_filename);
    mot_table_m = f_osimTableToStruct_revise(mot_table); % revise only diff in uninform user that label has changed, in original code "osimTableToStruct" on line 92

    % extract specific joint data
    traj_origin = [mot_table_m.time, ...
                          mot_table_m.a_jointset_r_elbow_r_elbow_flex_value, ...
                          mot_table_m.a_jointset_r_elbow_r_elbow_flex_speed];
    if anynan(traj_origin)
        error('MyComponent:ExistNaN', 'Exist NaNs in fwd results');
    end

    % reshape through interpolation
    Traj_Interp(:, 1) = traj_origin(1, 1) : 0.001 : traj_origin(end, 1); % time 
    Traj_Interp(:, 2) = interpn(traj_origin(:, 1), traj_origin(:, 2), Traj_Interp(:, 1), 'spline')'; % value
    Traj_Interp(:, 3) = interpn(traj_origin(:, 1), traj_origin(:, 3), Traj_Interp(:, 1), 'spline')'; % speed
end