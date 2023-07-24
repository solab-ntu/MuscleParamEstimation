function SA_Results = f_sensitivity_analysis(SA_Param)

    % 
    % f_sensitivity_analysis: Used to perform sensitivity analysis (BIClong and BICshort only)
    %
    % Args:
    %   SA_Param: Structure containing users settings, motion number, motion information, and target trajectories.
    %
    % Return:
    %   SA_Results: Structure containing sensitivity analysis results
    %       mean(i): Mean prediction error (NRMSE) for muscle i
    %       nan_num: nan number
    %
    % Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
    %

    % import the OpenSim libraries
    import org.opensim.modeling.*;

    % update computed parameter
    sa_param_revise = SA_Param;
    sa_param_revise.interest.param_bool = [1, 1, 1];
    
    % create a Sobol sequence object & generate a Sobol set of N points
    s = sobolset(3);
    points = net(s, sa_param_revise.sa_settings.sample);

    % name and number of muscles to be evaluated
    muscle_list = ["BIClong"; "BICshort"]; % ["TRIlong"; "TRIlat"; "TRImed"; "BIClong"; "BICshort";  "BRA"];
    muscle_num = length(muscle_list);

    % initialize
    nrmse_result = zeros([sa_param_revise.sa_settings.sample, muscle_num]);
    SA_Results.mean = zeros(1, muscle_num);

    for i = 1 : muscle_num
        % interest muscle
        sa_param_revise.interest.muscle_name = muscle_list(i);
        sa_param_revise.interest.param_size = [1, 3];

        % computes the upper and lower bounds to which the sobol sequence is translated
        ans_muscle_param = f_ans_muscle_param(sa_param_revise.file.model, sa_param_revise.interest);
        lb = (1 - sa_param_revise.sa_settings.perturbation) * ans_muscle_param;
        ub = (1 + sa_param_revise.sa_settings.perturbation) * ans_muscle_param;
        muscle_param_sobol = lb + points .* (ub - lb);

%         % show where nan results are produced
%         figure;
%         plot3(ans_muscle_param(1), ans_muscle_param(2), ans_muscle_param(3), "r*")
%         hold on;
%         grid on;
%         title(sa_param_revise.interest.muscle_name);
%         xlabel("$F^M_O$",'interpreter','latex');
%         ylabel("$L^M_O$",'interpreter','latex');
%         zlabel("$L^T_S$",'interpreter','latex');
%         muscle_param_nan = [];

        % calculate the prediction error for each sample
        parfor j = 1 : sa_param_revise.sa_settings.sample
            nrmse_all_result = f_nrmse_compute_catchME(muscle_param_sobol(j, :), sa_param_revise);
            nrmse_result(j, i) = nrmse_all_result.mot(1).nrmse_speed;
%             % show where nan results are produced
%             if isnan(nrmse_result(j, i))
%                 muscle_param_nan = [muscle_param_nan; muscle_param_sobol(j, :)];
%             end
        end

        % average all prediction errors
        SA_Results.mean(i) = mean(nrmse_result(:, i), 'omitnan');
%         % show where nan results are produced
%         plot3(muscle_param_sobol(:, 1), muscle_param_sobol(:, 2), muscle_param_sobol(:, 3), "k.")
%         plot3(muscle_param_nan(:, 1), muscle_param_nan(:, 2), muscle_param_nan(:, 3), "r.")
    end
    SA_Results.nan_num = sum(isnan(nrmse_result));
end