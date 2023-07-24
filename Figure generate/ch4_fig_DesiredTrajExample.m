function ch4_fig_DesiredTrajExample()
    
    users_settings = f_get_users_settings('ch4_fig_DesiredTrajExample.json');
    New_Param = users_settings;
    New_Param.mot_num = length(New_Param.mot_desired);
    for ii = 1 : New_Param.mot_num
        New_Param.mot(ii) = f_generate_motion_exampleee(New_Param.mot_desired(ii));
    end

    function Mot = f_generate_motion_exampleee(Mot)
        % import the OpenSim libraries
        import org.opensim.modeling.*;
    
        % import motion file template
        template_filename = "motion_template.mot";
        motion_table = TimeSeriesTable(template_filename);
        
        % find index of joint 
        shoulder_index = motion_table.getColumnIndex("r_shoulder_elev") + 1;
        elbow_index = motion_table.getColumnIndex("r_elbow_flex") + 1;
        
        elbow_range = Mot.elbow_angle(2) - Mot.elbow_angle(1);
        Mot.time_duration = 1/130 * elbow_range;
        % usually takes 1 second to flex the elbow to 130 degrees; time duration means complete a flexion "or" a extension
    
        Mot.T_shift = 0.03;
        switch Mot.direction
            case 1  % flexion (start from wave through)
                f_moving_sin = @(t) (elbow_range / 2) * sin(2 * pi / (Mot.time_duration * 2) * (t - Mot.T_shift) - pi / 2) + elbow_range / 2 + Mot.elbow_angle(1);
            case -1 % extension (start from wave crest)
                f_moving_sin = @(t) (elbow_range / 2) * sin(2 * pi / (Mot.time_duration * 2) * (t - Mot.T_shift) + pi / 2) + elbow_range / 2 + Mot.elbow_angle(1);
        end
    
        time = (0 : 0.005 : Mot.time_duration + Mot.T_shift * 2)';
        traj = zeros(length(time), motion_table.getNumColumns);
        traj(:, shoulder_index) = Mot.shoulder_angle;
        for i = 1 : length(time)
            if time(i) < Mot.T_shift
                traj(i, elbow_index) = f_moving_sin(Mot.T_shift);
            elseif time(i) > Mot.T_shift + Mot.time_duration
                traj(i, elbow_index) = f_moving_sin(Mot.T_shift + Mot.time_duration);
            else
                traj(i, elbow_index) = f_moving_sin(time(i));
            end
            motion_table.appendRow(time(i), RowVector.createFromMat(traj(i, :)));
        end

        figure;
        plot(time(:,1),traj(:,5));
        xlabel('Time (sec)');
        ylabel('Trajectory (deg)');
    
    end
end

