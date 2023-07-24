function ch3_fig_SobolRand()

    samples = 1000;
    dim = 2;
    
    s = sobolset(dim);
    sobol_points = net(s, samples);
    rand_points = rand([samples, dim]);
    
    figure;
    plot(sobol_points(:, 1), sobol_points(:, 2), '.');
%     title("sobolset function in MATLAB", FontSize=14)

    figure;
    plot(rand_points(:, 1), rand_points(:, 2), '.');
%     title("rand function in MATLAB", FontSize=14)

end