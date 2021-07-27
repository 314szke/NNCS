%% Initialize workspace and set execution parameters
Initialize
clear; close all; clc; bdclose('all');
fprintf('0) Initialize the execution.\n');

% Model names
model_path = 'models/SwitchingController';
nominal_model_path = sprintf('%s/switching_controller_nominal', model_path);
nn_model_path = sprintf('%s/switching_controller_nn', model_path);
parallel_model_before_retraining_path = sprintf('%s/switching_controller_parallel_before_retraining', model_path);
parallel_model_after_retraining_path = sprintf('%s/switching_controller_parallel_after_retraining', model_path);

% Set which models to update with the new neural network
nn_models{1}.path = nn_model_path;
nn_models{1}.block_name = 'nn';
nn_models{2}.path = parallel_model_before_retraining_path;
nn_models{2}.block_name = 'nn';
nn_models{3}.path = parallel_model_after_retraining_path;
nn_models{3}.block_name = 'nn_old';

% Simulink parameters
simulation.time_window = 20;
simulation.time_step = 0.01;

% Create required models
nominal_model = CreateModel(nominal_model_path, simulation);

% Input coverage parameters
coverage_options.min = 0;
coverage_options.max = 1;
coverage_options.cell_size = 0.1;
coverage_options.dimension = 2;
coverage_options.coverage_point_type = 'random';
coverage_options.plot = 0;

% Training data options
data_options.input_dimension = 6;
data_options.trimming_enabled = 1;
data_options.trim_distance_criteria = 0.001;
data_options.trim_allowed_repetition = 20;
data_options.plot = 0;

% Training parameters
training_options.neurons = [20 10];
training_options.loss_function = 'mse';
training_options.optimizer_function = 'trainlm';
training_options.divider_function = 'divideind';
training_options.training_data_ratio = 0.7;
training_options.validation_data_ratio = 0.1;
training_options.test_data_ratio = 0.2;
training_options.activation_function = 'tansig';
training_options.max_validation_checks = 50;
training_options.target_error_rate = 1e-3;
training_options.regularization = 0;

% Other parameters
workspace_name = 'nn.mat';


%% Data generation
fprintf('1) Create coverage data.\n');
[data, num_traces, num_points] = GenerateInputCoverageData(nominal_model, coverage_options);
fprintf('Number of data points generated with coverage: %d.\n', num_points);


%% Prepare training data
fprintf('2) Restructure and trim the training data.\n');
[in, out, trace_end_indices] = PrepareTrainingData(data, data_options);
training_options = SplitTrainingData(trace_end_indices, training_options);
if data_options.trimming_enabled && data_options.plot
    ExploreTrimming(nominal_model.GetTime(), data, data_options);
end


%% Training
fprintf('3) Create and train the initial neural network.\n');
training_timer = tic;
[net, tr] = TrainNeuralNetwork(in, out, training_options);
timer.train = toc(training_timer);

fprintf('Training time: %0.2f seconds.\n', timer.train);
fprintf('The target training error was %f.\n', training_options.target_error_rate);
fprintf('The obtained training error is %f.\n', tr.best_tperf);


%% Save the neural network
fprintf('4) Update the Simulink models.\n');
for idx = 1:length(nn_models)
    UpdateNeuralNetwork(net, nn_models{idx}.path, nn_models{idx}.block_name);
end


%% Prepare workspace for retraining
fprintf('5) Save workspace.\n');
save(workspace_name);
