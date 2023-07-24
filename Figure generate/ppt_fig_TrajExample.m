function ppt_fig_TrajExample()
        
        X1 = [0; 0.5; 1];
        Y1 = [0; 90; 0];

        X2 = [0; 0.25; 0.5; 0.85; 1];
        Y2 = [0;    85;  60;    55; 1];

       f1_coef = polyfit(X1, Y1, 2);
       f2_coef = polyfit(X2, Y2, 4);

        point = linspace(0, 1);
   
        y1 = polyval(f1_coef, point);
        y2 = polyval(f2_coef, point);

        figure(1);
        plot(point, y1, "LineWidth", 2);
        xlim([0 1]);
        ylim([0, 95]);

        figure(2);
        plot(point, y2, "LineWidth", 2);
        xlim([0 1]);
        ylim([0, 95]);

end