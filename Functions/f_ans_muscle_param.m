function Param_Value = f_ans_muscle_param(Model_Filename, Interest)

    % 
    % f_ans_muscle_param: Get answers for muscle parameters of interest from established model
    %
    % Args:
    %   Model_Filename: An OpenSim model file (.osim)
    %   Interest: Structure containing information on muscle parameters of interest
    %       param_size: Array size of muscle parameters of interest
    %       muscle_name: Muscle name of interest
    %       param_bool: Muscle parameters of interest. The order is maximum isometric force, optimal fiber length, and tendon slack length.
    %
    % Return:
    %   Param_Value: Answers for muscle parameters of interest
    %
    % Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
    %

    % import the OpenSim libraries
    import org.opensim.modeling.*;

    % initialize
    Param_Value = zeros(Interest.param_size);
    
    % get muscle list
    input_model = Model(Model_Filename);
    muscles = input_model.getMuscles();
    
    % get muscle and muscle param values
    for i = 1 : length(Interest.muscle_name)
        muscle = muscles.get(Interest.muscle_name(i));
        j = 1;
        if Interest.param_bool(i, 1)
            Param_Value(i, j) = muscle.getMaxIsometricForce();
            j = j+1;
        end
        if Interest.param_bool(i, 2)
            Param_Value(i, j) = muscle.getOptimalFiberLength();
            j = j+1;
        end
        if Interest.param_bool(i, 3)
            Param_Value(i, j) = muscle.getTendonSlackLength();
        end
    end
end