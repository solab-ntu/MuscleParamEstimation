function Results_Dir_CMC = f_cmc(File, Mot)
    
    % 
    % f_cmc: Execute CMC simulation
    %
    % Args:
    %   File: Structure containing the file name and path required for simulation
    %       path: Path of the current folder
    %       model: An OpenSim model file (.osim)
    %       setup_cmc: Setup for CMC simulation (.xml)
    %   Mot: Structure containing motion information
    %       motion_control_filename: Desired motion file name (.mot)
    %       time_duration: Time duration of desired motion 
    %       T_shift: Idle time before and after CMC simulation
    %
    % Return:
    %   Results_Dir_CMC: Directory of CMC simulation results
    %
    % Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
    %

    % import the OpenSim libraries
    import org.opensim.modeling.*;
   
    % CMC parameter
    Results_Dir_CMC = string(File.path) + "\Results\CMC_" + strrep(File.model, ".osim", "") + "_" + strrep(Mot.motion_control_filename, ".mot", "");
    input_model = Model(File.model);

    % CMC setup
    myCMC = CMCTool(File.setup_cmc, false); % CMCTool(const std::string & aFileName, bool aLoadModel = true )	
    myCMC.setDesiredKinematicsFileName("Motions\" + Mot.motion_control_filename);
    myCMC.setFinalTime(Mot.time_duration + Mot.T_shift * 2);
    myCMC.setResultsDir(Results_Dir_CMC);
    myCMC.updateModelForces(input_model, File.setup_cmc);  % forceset is tied to the model, so if "aLoadModel = false", "updateModelForces" is required
    myCMC.setModel(input_model);

    % CMC run
    if ~isfolder(Results_Dir_CMC)
        myCMC.run();
    end
end
