%% Initialize workspace and set execution parameters
Initialize
clear; close all; clc; bdclose('all');
fprintf('0) Initialize the execution.\n');

% Load workspace from initial training
load('nn.mat');

% Model names
nn_model_retrained_path = sprintf('%s/switching_controller_nn_shortened_cex', model_path);

% Set which models to update with the new neural network
new_nn_models{1}.path = nn_model_retrained_path;
new_nn_models{1}.block_name = 'nn';
new_nn_models{2}.path = parallel_model_after_retraining_path;
new_nn_models{2}.block_name = 'nn_old';

% Update the models with the network in the workspace and create the required models
for idx = 1:numel(nn_models)
    UpdateNeuralNetwork(net, nn_models{idx}.path, nn_models{idx}.block_name);
end
nominal_model = CreateModel(nominal_model_path);
nn_model = CreateNeuralSwitchingControllerModel(nn_model_path, coverage_options);
plot_model1 = CreateModel(parallel_model_before_retraining_path);
% IMPORTANT: the retrained models are created at the final verification step!

% Setup the STL requirements
STL_ReadFile('specification/SwitchingController/switching_controller_specification.stl');
stl_options.segments = coverage_options.dimension;
stl_options.step_size = 0.01;
stl_options.max_error = 0.01;

nominal_requirement = GetSwitchingControllerRequirement(phi_nominal, simulation, stl_options);
nn_requirement = GetSwitchingControllerRequirement(phi_nn, simulation, stl_options);
nn_new_requirement = GetSwitchingControllerRequirement(phi_nn_new, simulation, stl_options);

% Setup parameters for retraining
options.num_falsification_traces = 100;
options.use_positive_diagnosis = 0;
options.window_size = 4;
options.cex_threshold = 5;
options.plot = 1;

% Other parameters
training_options.error_threshold = 0.1;
training_options.use_all_data = 1;
rng(1976); % random generator seed for Matlab
plot_labels1 = {'ref', 'u', 'u_nn', 'y', 'y_nn'};
plot_labels2 = {'ref', 'u', 'u_nn_old', 'u_nn_new', 'y', 'y_nn_old', 'y_nn_new'};


%% Falsification
fprintf('1) Find counter-examples with falsification.\n');
[~, shortened_new_data, num_cex, cex_traces] = GenerateCounterExampleData(nn_model, nominal_model, plot_model1, nn_requirement, nominal_requirement, plot_labels1, options);
if isempty(shortened_new_data)
    fprintf('No counter-examples found, the retraining stops.\n');
    return;
end
fprintf('The neural network controller produced %i counter-examples in %i input traces.\n', num_cex, options.num_falsification_traces);


%% Retraining
fprintf('2) Retrain with additional counter-example data.\n');
retraining_timer = tic;
[new_net, tr, ~] = RetrainNeuralNetwork(net, data, shortened_new_data, training_options);
timer.retrain = toc(retraining_timer);

fprintf('Retraining time: %0.2f seconds.\n', timer.retrain);
fprintf('The target training error was %f.\n', training_options.target_error_rate);
fprintf('The obtained training error is %f.\n', tr.best_tperf);


%% Save the new neural network
fprintf('3) Update the Simulink models.\n');
for idx = 1:numel(new_nn_models)
    UpdateNeuralNetwork(net, new_nn_models{idx}.path, new_nn_models{idx}.block_name);
end


%% Verification
fprintf('4) Verify if counter-examples are eliminated.\n');
nn_retrained_model = CreateModel(nn_model_retrained_path);
[~, evaluation_result, remaining_cex] = EvaluateModel(nn_retrained_model, cex_traces, nn_requirement);

if options.plot == 1
    plot_model2 = CreateModel(parallel_model_after_retraining_path);
    PlotModel(plot_model2, evaluation_result, nn_new_requirement, plot_labels2);
end
fprintf('Number of counter-examples remaining after retraining: %i/%i.\n', remaining_cex, num_cex);
