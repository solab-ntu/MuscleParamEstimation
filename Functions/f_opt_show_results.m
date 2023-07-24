function f_opt_show_results(OPT_Results, OPT_Param)

    % 
    % f_opt_show_results: Show the optimization execution results, including the optimal solution, prediction error (NRMSE), and trajectories.
    %
    % Args:
    %   OPT_Results: Structure containing optimization results
    %   OPT_Param: Structure containing users settings, motion number, motion information, and target trajectories.
    %
    % Return:
    %   No return
    %
    % Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
    %

    % compute optimal results
    opt_muscle_param = OPT_Results.x.opt;
    nrmse_optimal = f_nrmse_compute(opt_muscle_param, OPT_Param);
    
    % compute answer
    OPT_Param.interest.param_size = [length(OPT_Param.interest.muscle_name), sum(OPT_Param.interest.param_bool(1,:))];
    ans_muscle_param = f_ans_muscle_param(OPT_Param.file.model, OPT_Param.interest);

    % display results
    disp("Target muscle parameter: ");
    disp(round(ans_muscle_param, 4));
    disp("Optimal muscle parameter: ");
    disp(round(opt_muscle_param, 4));
    for i = 1 : OPT_Param.mot_num
        disp("Motion " + string(i) + " joint angle prediction error: " + string(round(nrmse_optimal.mot(i).nrmse_value, 6)));
        disp("Motion " + string(i) + " joint speed prediction error: " + string(round(nrmse_optimal.mot(i).nrmse_speed, 6)) + newline);
    end

    % plot optimal results
    for i = 1 : OPT_Param.mot_num
        figure;
        subplot(2, 1, 1); % joint angle traj
        plot(OPT_Param.mot(i).traj_target(:, 1), OPT_Param.mot(i).traj_target(:, 2), "k-", "LineWidth", 1.5, "DisplayName", "Target");
        hold on;
        plot(nrmse_optimal.mot(i).traj(:, 1), nrmse_optimal.mot(i).traj(:, 2), "r--", "LineWidth", 1.5, "DisplayName", "Optimal");
        xlabel("Time (sec)");
        ylabel("Joint angle value (deg)");
        title("Joint angle value with respect to time for motion " + string(i), "FontSize", 12);
        legend("Location", "northwest");
%         xlim([0, 1.06]); % 0.75
        
        subplot(2, 1, 2); % joint speed traj
        plot(OPT_Param.mot(i).traj_target(:, 1), OPT_Param.mot(i).traj_target(:, 3), "k-", "LineWidth", 1.5, "DisplayName", "Target");
        hold on;
        plot(nrmse_optimal.mot(i).traj(:, 1), nrmse_optimal.mot(i).traj(:, 3), "r--", "LineWidth", 1.5, "DisplayName", "Optimal");
        xlabel("Time (sec)");
        ylabel("Joint angle speed (deg/s)");
        title("Joint angle speed with respect to time for motion " + string(i), "FontSize", 12);
        legend("Location", "northwest");
%         xlim([0, 1.06]); % 0.75
    end
end