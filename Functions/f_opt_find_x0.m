function [x, f, eflag] = f_opt_find_x0(countlimit, threshold, fun, nvars, lb, ub, opts)

    % 
    % f_opt_find_x0: Find initial values for muscle parameters
    %
    % Args:
    %   countlimit: Execute limit times
    %   threshold: Threshold for optimal value
    %   fun: Objective function
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

    % find initial values
    disp(newline + "** START: Find x0 with bestfval < " + string(threshold));

    StopIfErrorSmall = @(optimValues, state) optimValues.bestfval < threshold;
    opts.OutputFcn = StopIfErrorSmall;

    count = 1;
    eflag = nan;
    while ~(eflag == -1) % eflag = -1: optimization terminated by an output function or plot function.
        disp(newline + "* Find x0: " + num2str(count) + " times");
        [x, f, eflag] = particleswarm(fun, nvars,  lb, ub, opts);
        if (eflag == -1)
            disp(newline + "* Find x0: " + num2str(x));
            disp(newline + "* exitflag: " + num2str(eflag));
            break;
        end
        if count >= countlimit
            disp(newline + "* Failed to find x0 " + num2str(countlimit) + " times");
            break;  
        end
        count = count + 1;
    end

    if count < countlimit
        disp(newline + "** END: Find x0 with bestfval < " + string(threshold));
    else
        disp(newline + "** END: Find x0");
    end
end