% Model names
nn_model_retrained_path = sprintf('%s/helicopter_nn_shortened_cex', model_path);

% Set which models to update with the new neural network
new_nn_models{1}.path = nn_model_retrained_path;
new_nn_models{1}.block_name = 'nn';
new_nn_models{2}.path = parallel_model_after_retraining_path;
new_nn_models{2}.block_name = 'nn_new';

% Update the models with the network in the workspace and create the required models
for idx = 1:length(nn_models)
    UpdateNeuralNetwork(net, nn_models{idx}.path, nn_models{idx}.block_name);
end
nominal_model = CreateModel(nominal_model_path, simulation, model_options);
nn_model = CreateModelWithFixedInputGenerator(nn_model_path, simulation, coverage_options, model_options);
plot_model1 = CreateModel(parallel_model_before_retraining_path, simulation, model_options);
% IMPORTANT: the retrained models are created at the final verification step!

% Setup the STL requirements
STL_ReadFile('specification/Helicopter/helicopter_specification.stl');
stl_options.simulation_time = simulation.time_window;
stl_options.stable_window_size = 3;
stl_options.max_error = 0.01;

nominal_requirement = GetHelicopterRequirement(phi_nominal, stl_options);
nn_requirement = GetHelicopterRequirement(phi_nn, stl_options);
nn_new_requirement = GetHelicopterRequirement(phi_nn_new, stl_options);

% Setup parameters for retraining
options.num_falsification_traces = 100;
options.use_shortened_cex = 0;
options.use_positive_diagnosis = 0;
options.window_size = 4;
options.cex_threshold = 25;
options.plot = 0;

% Other parameters
training_options.error_threshold = 0.1;
data_options.use_all_data = 1;

rng(1976); % random generator seed for Matlab
plot_labels1 = {'ref', 'u', 'u_nn', 'y', 'y_nn'};
plot_labels2 = {'ref', 'u', 'u_nn_old', 'u_nn_new', 'y', 'y_nn_old', 'y_nn_new'};
