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
nominal_model_path = sprintf('%s/switching_controller_nominal', model_path);
model_options = struct();
nominal_model = CreateModel(nominal_model_path, simulation, model_options);
nominal_model.SetInputGen('UniStep2');
input_parameters = nominal_model.expand_param_name('ref_u.+');
nominal_model.SetParamRanges(input_parameters, [0 1]);


%% Evaluate requirement on 100 quasi random traces
STL_ReadFile('specification/SwitchingController/switching_controller_specification.stl');
stl_options.segments = 2;
stl_options.stable_window_size = 3;
stl_options.step_size = 0.01;
stl_options.max_error = 0.04;
nominal_requirement = GetSwitchingControllerRequirement(phi_nominal, simulation, stl_options);

nominal_model.QuasiRandomSample(100);
nominal_requirement.Eval(nominal_model);


%% Show results
disp(nominal_requirement);
P = BreachSamplesPlot(nominal_requirement);
P.set_y_axis('ref_u1');
P.set_x_axis('ref_u0');
