function ch3_fig_SobolExample()

    sample = 500;
    perturbation = 0.15;
    ans_muscle_param = [600, 0.15, 0.30];

    % create a Sobol sequence object & generate a Sobol set of N points
    s = sobolset(3);
    points = net(s, sample);
    lb = (1 - perturbation) * ans_muscle_param;
    ub = (1 + perturbation) * ans_muscle_param;
    muscle_param_sobol = lb + points .* (ub - lb);

    figure;  
    plot3(muscle_param_sobol(:, 1), muscle_param_sobol(:, 2), muscle_param_sobol(:, 3), 'k.')
    hold on;
    grid on;
    plot3(ans_muscle_param(1), ans_muscle_param(2), ans_muscle_param(3), 'r*', "MarkerSize", 14);

    xlabel("$F^M_O$",'interpreter','latex');
    ylabel("$L^M_O$",'interpreter','latex');
    zlabel("$L^T_S$",'interpreter','latex');
%     title("Samples: 500; Perturbation: 0.15", "FontSize", 14);
   
end