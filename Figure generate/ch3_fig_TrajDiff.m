function ch3_fig_TrajDiff()
    
    Users_Settings = f_get_users_settings('ch3_fig_TrajDiff.json');
    New_Param = Users_Settings;
    New_Param.mot_num = length(New_Param.mot_desired);

    [New_Param.mot(1), traj_desired, time] = f_generate_motion_example(New_Param.mot_desired(1));
    f_cmc(New_Param.file, New_Param.mot(1));
    New_Param.mot(1).traj_target = f_fwd_get_traj(New_Param.file, New_Param.mot(1), 0);

    figure;
    plot(time,traj_desired(:, 5), "DisplayName", "Desired", "LineWidth", 2);
    hold on;
    plot(New_Param.mot(1).traj_target(:, 1), New_Param.mot(1).traj_target(:, 2), ":", "DisplayName", "Target", "LineWidth", 2);
    legend;
    ylim([0 95])
    xlabel('Time');
    ylabel('Trajectory');

    figure;
    plot(time,traj_desired(:, 5), "DisplayName", "Desired", "LineWidth", 2);
    hold on;
    plot(New_Param.mot(1).traj_target(:, 1), New_Param.mot(1).traj_target(:, 2), ":", "DisplayName", "Target", "LineWidth", 2);
    legend;
    ylim([82 92])
    xlim([0.9 1.1])
    xlabel('Time');
    ylabel('Trajectory');

    function [Mot, traj, time] = f_generate_motion_example(Mot)
        % import the OpenSim libraries
        import org.opensim.modeling.*;
        
        % import motion file template
        template_filename = "motion_template.mot";
        motion_table = TimeSeriesTable(template_filename);
        
        % find index of joint 
        shoulder_index = motion_table.getColumnIndex("r_shoulder_elev") + 1;
        elbow_index = motion_table.getColumnIndex("r_elbow_flex") + 1;
        
        Mot.time_duration = 2;  
        
        Mot.T_shift = 0;
        f_moving_flexion = @(x) 90 * x;
        f_moving_extension = @(x) 90 * (2 - x);
        
        time = linspace(0, Mot.time_duration, 201)';

        traj = zeros(length(time), motion_table.getNumColumns);
        traj(:, shoulder_index) = Mot.shoulder_angle;
        traj(1:100, elbow_index) = f_moving_flexion(time(1:100));
        traj(101:201, elbow_index) = f_moving_extension(time(101:201));

        for i =  1 : length(time)
            motion_table.appendRow(time(i), RowVector.createFromMat(traj(i, :)));
        end

        % set name of motion
        Mot.motion_control_filename = "mot_ch3_fig_TrajDiff.mot";
        motion_table.addTableMetaDataString("name", Mot.motion_control_filename);
        
        % add new field for later calculations
        Mot.traj_target = [];
    
        % save motion file
        STOFileAdapter.write(motion_table, "Motions\" + Mot.motion_control_filename);
    end
end