function Mot = f_generate_motion(Mot)

    % 
    % f_generate_motion: Generate desired motion
    %
    % Args:
    %   Mot: Structure containing generation parameters for the desired motion
    %       direction: Direction of elbow rotation (1: flexion / -1: extension)
    %       shoulder_angle: Fixed shoulder angle
    %       elbow_angle: 1-D array of elbow rotation angles. Col 1: theta 1 / Col 2: theta 2.
    %
    % Return:
    %   Mot: Structure containing motion information
    %       direction: Direction of elbow rotation (1: flexion / -1: extension)
    %       shoulder_angle: Fixed shoulder angle
    %       elbow_angle: 1-D array of elbow rotation angles. Col 1: theta 1 / Col 2: theta 2.
    %       motion_control_filename: Desired motion file name (.mot)
    %       time_duration: Time duration of desired motion 
    %       T_shift: Idle time before and after CMC simulation
    %       traj_target: New field for later calculations to save target trajectories.
    %
    % Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
    %

    % import the OpenSim libraries
    import org.opensim.modeling.*;

    % import motion file template
    template_filename = "motion_template.mot";
    motion_table = TimeSeriesTable(template_filename);
    
    % find index of joint 
    shoulder_index = motion_table.getColumnIndex("r_shoulder_elev") + 1;
    elbow_index = motion_table.getColumnIndex("r_elbow_flex") + 1;
    
    % compute the time duration
    elbow_range = Mot.elbow_angle(2) - Mot.elbow_angle(1);
    Mot.time_duration = 1/130 * elbow_range; % usually takes 1 second to flex the elbow to 130 degrees; time duration means complete a flexion "or" a extension

    % transformation of sine function used to generate desired motion
    Mot.T_shift = 0.03;
    switch Mot.direction
        case 1  % flexion (start from wave trough)
            f_moving_sin = @(t) (elbow_range / 2) * sin(2 * pi / (Mot.time_duration * 2) * (t - Mot.T_shift) - pi / 2) + elbow_range / 2 + Mot.elbow_angle(1);
        case -1 % extension (start from wave crest)
            f_moving_sin = @(t) (elbow_range / 2) * sin(2 * pi / (Mot.time_duration * 2) * (t - Mot.T_shift) + pi / 2) + elbow_range / 2 + Mot.elbow_angle(1);
    end

    % generate trajectories
    time = (0 : 0.005 : Mot.time_duration + Mot.T_shift * 2)'; % time series
    traj = zeros(length(time), motion_table.getNumColumns);
    traj(:, shoulder_index) = Mot.shoulder_angle; % fixed 
    for i = 1 : length(time)
        if time(i) < Mot.T_shift
            traj(i, elbow_index) = f_moving_sin(Mot.T_shift); % constant
        elseif time(i) > Mot.T_shift + Mot.time_duration
            traj(i, elbow_index) = f_moving_sin(Mot.T_shift + Mot.time_duration); % transformation of sine function
        else
            traj(i, elbow_index) = f_moving_sin(time(i)); % constant
        end
        motion_table.appendRow(time(i), RowVector.createFromMat(traj(i, :)));
    end

    % set motion name
    switch Mot.direction
        case 1  % flexion
            Mot.motion_control_filename = "mot_F_shoulder_" +  string(Mot.shoulder_angle) + "_elbow_" +  string(Mot.elbow_angle(1)) + "to" + string(Mot.elbow_angle(2)) + ".mot";
        case -1 % extension
            Mot.motion_control_filename = "mot_E_shoulder_" +  string(Mot.shoulder_angle) + "_elbow_" +  string(Mot.elbow_angle(1)) + "to" + string(Mot.elbow_angle(2)) + ".mot";
    end
    motion_table.addTableMetaDataString("name", Mot.motion_control_filename);
    
    % add new field for later calculations
    Mot.traj_target = [];

    % save as mot file format
    STOFileAdapter.write(motion_table, "Motions\" + Mot.motion_control_filename);
end