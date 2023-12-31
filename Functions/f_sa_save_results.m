function f_sa_save_results(SA_Results, SA_Param, Case_Index, TOC)

    % 
    % f_sa_save_results: Show and save the sensitivity analysis results in txt file
    %
    % Args:
    %   SA_Results: Structure containing sensitivity analysis results
    %   SA_Param: Structure containing users settings, motion number, motion information, and target trajectories.
    %   Case_Index: Task index
    %   TOC: For timing sensitivity analysis
    %
    % Return:
    %   No return
    %
    % Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
    %

    % show the results
    disp("* run sensitivity analysis for case " + string(Case_Index) + ": " + string(round(TOC, 1)) + " seconds");
    text_format = '%5d,%10.1f,%18s,%5d,%5d,%5d,%5d,%10.4f,%10.4f,%5d,%5d \n';
    fprintf(text_format, ...
                Case_Index, ...
                string(round(TOC, 1)), ...
                SA_Param.file.model, ...
                SA_Param.mot(1).direction, ...
                SA_Param.mot(1).shoulder_angle, ...
                SA_Param.mot(1).elbow_angle, ...
                SA_Results.mean, ...
                SA_Results.nan_num);

    % save the results
    fileID = fopen('sa_results.txt','a');
    fprintf(fileID, text_format, ...
                Case_Index, ...
                string(round(TOC, 1)), ...
                SA_Param.file.model, ...
                SA_Param.mot(1).direction, ...
                SA_Param.mot(1).shoulder_angle, ...
                SA_Param.mot(1).elbow_angle, ...
                SA_Results.mean, ...
                SA_Results.nan_num);
    fclose(fileID);
end