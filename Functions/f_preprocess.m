function New_Param = f_preprocess(User_Settings)

    % 
    % f_preprocess: Preprocessing includes obtaining users settings, generating target trajectories, parallel setting, and generating temporary folder.
    %
    % Args:
    %   Users_Settings: Structure containing users settings
    %
    % Return:
    %   New_Param: New structure containing users settings, motion number, motion information, and target trajectories.
    %
    % Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
    %

    %  setup new parameters and get target trajectories by
    % (1) motion generate (2) CMC (3) FWD (4) extract trajectory for specific joint speed (5) interpolation
    New_Param = User_Settings;
    New_Param.mot_num = length(New_Param.mot_desired);
    for i = 1 : New_Param.mot_num
        New_Param.mot(i) = f_generate_motion(New_Param.mot_desired(i));
        f_cmc(New_Param.file, New_Param.mot(i));
        New_Param.mot(i).traj_target = f_fwd_get_traj(New_Param.file, New_Param.mot(i), 0);
    end
    
    % parallel setting
    % https://www.mathworks.com/matlabcentral/answers/791324-matlab-only-uses-half-of-the-number-of-logical-cores-how-can-i-use-all-of-them
    p = gcp('nocreate'); % if no pool, do not create new one.
    if isempty(p)
        c = parcluster;
        c.NumWorkers = 6;
        p = c.parpool(6);
    end
    
    % generating temporary folder
    if isfolder('tmp')
        rmdir('tmp', 's');
    end
    mkdir tmp;
end