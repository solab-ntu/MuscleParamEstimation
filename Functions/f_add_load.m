function f_add_load(Model_Filename, Mass)  

    % 
    % f_add_load: Adding load to an established model
    %
    % Args:
    %   Model_Filename: An OpenSim model file (.osim)
    %   Mass: The mass of the load (unit: g)
    %
    % Return:
    %   No return
    %
    % Authors: Yi-Hsuan Lin, System Optimization Laboratory, Department of Mechanical Engineering, National Taiwan University
    %

    % import the OpenSim libraries
    import org.opensim.modeling.*
    
    % add a "Body" object to represent the load and set the parameters of the load
    model = Model(Model_Filename);
    Load = Body();
    Load.setName('external_load');
    Load.setMass(Mass/1000);
    Load.setMassCenter(Vec3(0))
    Load.setInertia(Inertia(0));
    sphere = Sphere(0.01);
    sphere.setColor(Vec3(1, 0, 0));
    Load.attachGeometry(sphere);
    model.addBody(Load);
    
    % create a weld joint to attach the new body to the hand
    locationInParent    = Vec3(0, 0, 0);
    orientationInParent = Vec3(0, 0, 0);
    locationInChild     = Vec3(-0.015, 0.32, -0.07);
    orientationInChild  = Vec3(0, 0,0 );
    Hand = model.getBodySet.get('r_ulna_radius_hand');
    weld_joint = WeldJoint('load_hand', Hand, locationInParent, orientationInParent, ...
                                                               Load, locationInChild, orientationInChild);
    model.addJoint(weld_joint);
    
    % satisfy all connections in the model and save as an osim file.
    model.finalizeConnections();
    model.print(strrep(Model_Filename, ".osim", "") + '_' + string(Mass) + 'g.osim');
end