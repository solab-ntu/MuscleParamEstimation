function ch4_fig_SAExample()
    addpath(genpath('./Functions'));
    addpath(genpath('./Figure generate'));
%     File_Name = "ch4_fig_SAExample_SAhigh.json";
%     File_Name = "ch4_fig_SAExample_SAlow.json";

%     File_Name = "ch4_fig_SAExample_OptLong1.json";
%     File_Name = "ch4_fig_SAExample_OptShort1.json";
%     File_Name = "ch4_fig_SAExample_OptLong2.json";
%     File_Name = "ch4_fig_SAExample_OptShort2.json";

%     File_Name = "ch4_fig_SAExample_ValiLong1.json";
    File_Name = "ch4_fig_SAExample_ValiShort1.json";


    users_settings = f_get_users_settings(File_Name);
    sa_example_param = f_preprocess(users_settings);
    
    % Create a Sobol sequence object & Generate a Sobol set of N points
    s = sobolset(3);
    points = net(s, sa_example_param.sa_settings.sample);
    
    % param setting & obtain param ans and ub lb
    sa_example_param.interest.muscle_name = string(users_settings.interest.muscle_name);
    sa_example_param.interest.param_bool = users_settings.interest.param_bool;
    sa_example_param.interest.param_size = [1, 3];
    ans_muscle_param = f_ans_muscle_param(sa_example_param.file.model, sa_example_param.interest);

    lb = (1 - sa_example_param.sa_settings.perturbation) * ans_muscle_param;
    ub = (1 + sa_example_param.sa_settings.perturbation) * ans_muscle_param;
    muscle_param_sobol = lb + points .* (ub - lb);

    % compute
    parfor j = 1 : sa_example_param.sa_settings.sample
        nrmse_all_result(j) = f_nrmse_compute_catchME(muscle_param_sobol(j, :), sa_example_param);
        nrmse_speed(j) = nrmse_all_result(j).mot(1).nrmse_speed;
    end
    nrmse_speed_mean = mean(nrmse_speed(:), 'omitnan');

    figure;
    plot(sa_example_param.mot(1).traj_target(:, 1), sa_example_param.mot(1).traj_target(:, 3), "k", "LineWidth", 2);
    hold on;
    for j = 1 : sa_example_param.sa_settings.sample
         if isfield(nrmse_all_result(j).mot(1), 'traj')
            plot(nrmse_all_result(j).mot(1).traj(:, 1), nrmse_all_result(j).mot(1).traj(:, 3), "Color", [0.7, 0.7, 0.7], "LineStyle", "-", "LineWidth", 0.2);
            hold on;
         end
    end
    plot(sa_example_param.mot(1).traj_target(:, 1), sa_example_param.mot(1).traj_target(:, 3), "k", "LineWidth", 2);
    xlabel("Time (sec)");
    ylabel("Joint angle speed (deg/s)");
    xlim([0, 0.75]); % 1.06
    ylim([-50, 450]);
    
end