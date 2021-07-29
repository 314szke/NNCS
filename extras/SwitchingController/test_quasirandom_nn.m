%% Initialize workspace and set execution parameters
Initialize
% Some parameters are used for the phi_* requirements only
warning('off', 'SetParam:param_not_in_list');
clear; close all; clc; bdclose('all');

% Simulink parameters
simulation.time_window = 20;
simulation.time_step = 0.01;
simulation.time_values = 0:simulation.time_step:simulation.time_window;


%% Config Breach interface
model_path = 'models/SwitchingController';
nn_model_path = sprintf('%s/switching_controller_nn', model_path);
nn_model = CreateModel(nn_model_path, simulation);
nn_model.SetInputGen('UniStep2');
input_parameters = nn_model.expand_param_name('ref_u.+');
nn_model.SetParamRanges(input_parameters, [0 1]);


%% Evaluate the requirement on 100 quasi random traces
STL_ReadFile('specification/SwitchingController/switching_controller_specification.stl');
stl_options.segments = 2;
stl_options.stable_window_size = 3;
stl_options.step_size = 0.01;
stl_options.max_error = 0.04;
requirement = GetSwitchingControllerRequirement(alw_stable_nn, simulation, stl_options);

nn_model.QuasiRandomSample(100);
requirement.Eval(nn_model);


%% Show results
disp(requirement);
P = BreachSamplesPlot(requirement);
P.set_y_axis('ref_u1');
P.set_x_axis('ref_u0');
