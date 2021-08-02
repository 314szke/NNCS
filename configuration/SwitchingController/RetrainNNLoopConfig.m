%% IMPORTANT: the variables with UPPER_CASE are set by the retraining_experiment.m script!

% Model names
if SHORTENED_CEX == 1
    nn_model_retrained_path = sprintf('%s/switching_controller_nn_shortened_cex', model_path);
else
    nn_model_retrained_path = sprintf('%s/switching_controller_nn_complete_cex', model_path);
end

% Set which models to update with the new neural network
new_nn_models{1}.path = nn_model_retrained_path;
new_nn_models{1}.block_name = 'nn';

% Update the models with the network in the workspace and create the required models
for idx = 1:length(nn_models)
    UpdateNeuralNetwork(net, nn_models{idx}.path, nn_models{idx}.block_name);
end
nominal_model = CreateModel(nominal_model_path, simulation, model_options);
nn_model = CreateModelWithFixedInputGenerator(nn_model_path, simulation, coverage_options, model_options);
plot_model1 = CreateModel(parallel_model_before_retraining_path, simulation, model_options);
% IMPORTANT: the retrained models are created at the final verification step!

% Setup the STL requirements
STL_ReadFile('specification/SwitchingController/switching_controller_specification.stl');
stl_options.segments = coverage_options.dimension;
stl_options.stable_window_size = 3;
stl_options.step_size = 0.01;
stl_options.max_error = 0.04;

nominal_requirement = GetSwitchingControllerRequirement(phi_nominal, simulation, stl_options);
nn_requirement = GetSwitchingControllerRequirement(phi_nn, simulation, stl_options);
nn_new_requirement = GetSwitchingControllerRequirement(phi_nn_new, simulation, stl_options);

% Setup parameters for retraining
options.num_falsification_traces = 100;
options.use_positive_diagnosis = USE_POSITIVE_DIAGNOSIS;
options.window_size = WINDOW_SIZE;
options.cex_threshold = CEX_THRESHOLD;
options.plot = 0;

% Other parameters
training_options.error_threshold = RETRAINING_ERROR_THRESHOLD;
data_options.use_all_data = USE_ALL_DATA_FOR_RETRAINING;

rng(1976); % random generator seed for Matlab
plot_labels1 = {'ref', 'u', 'u_nn', 'y', 'y_nn'};
plot_labels2 = {'ref', 'u', 'u_nn_old', 'u_nn_new', 'y', 'y_nn_old', 'y_nn_new'};
