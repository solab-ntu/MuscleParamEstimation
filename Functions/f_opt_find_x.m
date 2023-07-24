function [x, f, eflag] = f_opt_find_x(countlimit, threshold, x0, fun, cfun, nvars, lb, ub, opts)        

    % 
    % f_opt_find_x: Find optimal values for muscle parameters
    %
    % Args:
    %   countlimit: Execute limit times
    %   threshold: Threshold for optimal value
    %   x0: Initial point
    %   fun: Objective function
    %   cfun: Nonlinear constraints
    %   nvars: number of design variables
    %   lb: Lower bound for design variables
    %   ub: Upper bound for design variables
    %   opts: Options for optimization algorithm
    %
    % Return:
    %   x: Solution
    %   f: Objective value
    %   eflag: Algorithm stopping condition
    %
    % Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
    %

    % find optimal values
    if ~isnan(threshold)
        disp(newline + "** START: Find x with bestfval < " + string(threshold));
        opts.OutputFcn = @f_psoutputfcntemplate;
    else
        disp(newline + "** START: Find x");
    end

    count = 1;
    eflag = nan;
    while ~(eflag == -1) % eflag = -1: iterations stopped by output function or plot function.
        disp(newline + "* Find x: " + num2str(count) + " times");
        while true
            x0_rand = (0.95 + rand(1, nvars) .* (1.05 - 0.95)) .* x0; 
            if fun(x0_rand) < 0.5
                break;
            end
        end
        [x, f, eflag] = patternsearch(fun, x0_rand, [], [], [], [], lb, ub, cfun, opts); 
        if (eflag == -1) || (eflag > 0) || (isnan(threshold)) 
            disp(newline + "* Find x: " + num2str(x));
            disp(newline + "* exitflag: " + num2str(eflag));
            break;
        end
        if count >= countlimit
            disp(newline + "* Failed to find x " + num2str(countlimit) + " times");
            break;  
        end
        count = count + 1;
    end

    if count < countlimit && ~isnan(threshold)
        disp(newline + "** END: Find x with bestfval < " + string(threshold));
    else
        disp(newline + "** END: Find x");
    end

    function [stop,options,optchanged]  = f_psoutputfcntemplate(optimvalues, options, flag)
        stop = optimvalues.fval < threshold;
        optchanged = false;
    end
end