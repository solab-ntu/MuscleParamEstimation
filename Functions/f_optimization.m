function OPT_Results = f_optimization(OPT_Param)

    % 
    % f_optimization: Used to perform optimizations to find initial and optimal values
    %
    % Args:
    %   OPT_Param: Structure containing users settings, motion number, motion information, and target trajectories.
    %
    % Return:
    %   OPT_Results: Structure containing optimization results
    %
    % Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
    %

    %% optimization parameter settings
    lb = OPT_Param.opt_settings.lb;
    ub = OPT_Param.opt_settings.ub; 
    x_size = [length(OPT_Param.interest.muscle_name), sum(OPT_Param.interest.param_bool(1,:))]; % array size of muscle parameters of interest
    nvars = x_size(1) * x_size(2);

    % Objective and Nonlinear Constraints in the Same Function: https://www.mathworks.com/help/optim/ug/objective-and-nonlinear-constraints-in-the-same-function.html
    xLast = [];                  % last place compute_nrmse was called
    nrmse_speed = [];
    fun = @objfun;          % the objective function, nested below
    cfun = @constr;         % the constraint function, nested below

    %% options for algorithm
    options_particle = optimoptions("particleswarm", "Display", "iter", "UseParallel", true, "FunctionTolerance", 1e-4);
    options_pattern = optimoptions("patternsearch", "Display", "iter", "UseParallel", true, "Algorithm", "nups", "SearchFcn", "searchneldermead");

%     % add option to search function
%     options_fminsearch = optimset("TolFun", 1e-2, "TolX", 1e-2);
%     options_pattern = optimoptions("patternsearch", "Display", "iter", "UseParallel", true, "Algorithm", "nups", SearchFcn={@searchneldermead, 1, options_fminsearch});
    
    %% optimization
    threshold_x0 = 0.05;
    threshold_x   = 0.0001;
    opt_limit_x0 = 3;
    opt_limit_x = 1;

    lb_r = reshape(lb, [1, nvars]);
    ub_r = reshape(ub, [1, nvars]);

    % find initial values
    tic
    [x.x0, f.f0, eflag.eflag0] = f_opt_find_x0(opt_limit_x0, threshold_x0, fun, nvars, lb_r, ub_r, options_particle);
    disp(newline + "*** Find x0: " + string(round(toc, 1)) + " seconds");

    % find optimal values
    tic
    try
        [x.opt, f.opt, eflag.opt] = f_opt_find_x(opt_limit_x, threshold_x, x.x0, fun, cfun, nvars, lb_r, ub_r, options_pattern);
    catch ME
        if  (strcmp(ME.identifier,'MATLAB:nonLogicalConditional'))
            x.opt = nan;
            f.opt = nan; 
            eflag.opt = nan;
        end
    end
    disp(newline + "*** Find x: " + string(round(toc, 1)) + " seconds");

    disp(newline + "OPT parameter: " + num2str(x.opt));

    x.x0 = reshape(x.x0, x_size);
    x.opt = reshape(x.opt, x_size);

    OPT_Results.x = x;
    OPT_Results.f = f;
    OPT_Results.eflag = eflag;
      
    %% function
    % objective function
    function y = objfun(x)
        % check if computation is necessary
        if ~isequal(x, xLast) 
            x_reshape = reshape(x, x_size);
            nrmse_results = f_nrmse_compute_catchME(x_reshape, OPT_Param);
            for i = 1 : OPT_Param.mot_num
                    nrmse_speed(i) = nrmse_results.mot(i).nrmse_speed;
            end
            xLast = x;
        end

        % now compute objective function
        y = mean(nrmse_speed);
    end

    % constraint function
    function [c, ceq] = constr(x)
        % check if computation is necessary
        if ~isequal(x, xLast) 
            x_reshape = reshape(x, x_size);
            nrmse_results = f_nrmse_compute_catchME(x_reshape, OPT_Param);
            for i = 1 : OPT_Param.mot_num
                    nrmse_speed(i) = nrmse_results.mot(i).nrmse_speed;
            end
            xLast = x;
        end

        % now compute constraint function
        c = [];
        for i = 1 : OPT_Param.mot_num
            c = [c; nrmse_speed(i) - 0.01]; % NRMSE <= tolerance error = 0.01
        end
        ceq = [];
    end
end