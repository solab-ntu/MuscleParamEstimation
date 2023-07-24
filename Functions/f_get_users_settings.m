function Users_Settings = f_get_users_settings(Json_Filename)

    % 
    % f_get_users_settings: Convert data from json file to matlab structure
    %
    % Args:
    %   Json_Filename: An input information file (.json)
    %
    % Return:
    %   Users_Settings: Structure containing users settings
    %
    % Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
    %

    % load JSON file into a MATLAB string
    json_str = fileread(Json_Filename);
    
    % convert the JSON string to a MATLAB structure
    Users_Settings = jsondecode(json_str);
    
    % convert the data into string, because the result is char.
    if isfield(Users_Settings, 'interest')
        Users_Settings.interest.muscle_name = string(Users_Settings.interest.muscle_name);
    end
    if isfield(Users_Settings, 'sa_variable')
        Users_Settings.sa_variable.model = string(Users_Settings.sa_variable.model);
    end
    if isfield(Users_Settings.file, 'model')
        Users_Settings.file.model = string(Users_Settings.file.model);
    end
    
    % current folder
    Users_Settings.file.path = pwd;
end