function Results = f_opt_validate_results(OPT_Results, OPT_Param)

    % 
    % f_opt_validate_results: Validate the optimal model, including executing another task and corresponding prediction results
    %
    % Args:
    %   OPT_Results: Structure containing optimization results
    %   OPT_Param: Structure containing users settings, motion number, motion information, and target trajectories.
    %
    % Return:
    %   Results: NRMSE of the joint speed item from the target trajectory
    %
    % Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
    %

    % update compute parameters
    opt_param_revise = OPT_Param;
    opt_param_revise = rmfield(opt_param_revise, 'mot');
    opt_param_revise.mot_num = 1;

    % get target trajectories by
    % (1) motion generate (2) CMC (3) FWD (4) extract trajectory for specific joint speed (5) interpolation
    opt_param_revise.mot(1) = f_generate_motion(opt_param_revise.mot_validate(1));
    f_cmc(opt_param_revise.file, opt_param_revise.mot(1));
    opt_param_revise.mot(1).traj_target = f_fwd_get_traj(opt_param_revise.file, opt_param_revise.mot(1), 0);
    
    % compute validate results
    opt_muscle_param = OPT_Results.x.opt;
    nrmse_val = f_nrmse_compute(opt_muscle_param, opt_param_revise);
    
    % display results
    disp("Validation task joint angle prediction error: " + string(round(nrmse_val.mot(1).nrmse_value, 4)));
    disp("Validation task joint speed prediction error: " + string(round(nrmse_val.mot(1).nrmse_speed, 4)));
    Results = nrmse_val.mot(1).nrmse_speed;

    % plot validate results
    figure;
    subplot(2, 1, 1); % joint angle traj
    plot(opt_param_revise.mot(1).traj_target(:, 1), opt_param_revise.mot(1).traj_target(:, 2), "k-", "LineWidth", 1.5, "DisplayName", "Target");
    hold on;
    plot(nrmse_val.mot(1).traj(:, 1), nrmse_val.mot(1).traj(:, 2), "r--", "LineWidth", 1.5, "DisplayName", "Optimal");
    xlabel("Time (sec)");
    ylabel("Joint angle value (deg)");
    title("Joint angle value with respect to time (Task )", "FontSize", 12);
    legend("Location", "northwest");
%     xlim([0,0.75]);
    
    subplot(2, 1, 2); % joint speed traj
    plot(opt_param_revise.mot(1).traj_target(:, 1), opt_param_revise.mot(1).traj_target(:, 3), "k-", "LineWidth", 1.5, "DisplayName", "Target");
    hold on;
    plot(nrmse_val.mot(1).traj(:, 1), nrmse_val.mot(1).traj(:, 3), "r--", "LineWidth", 1.5, "DisplayName", "Optimal");
    xlabel("Time (sec)");
    ylabel("Joint angle speed (deg/s)");
    title("Joint angle speed with respect to time (Task )", "FontSize", 12);
    legend("Location", "northwest");
%     xlim([0,0.75]);
end