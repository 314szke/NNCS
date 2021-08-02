%% Initialize workspace and set execution parameters
Initialize
clear; close all; clc; bdclose('all');
fprintf('0) Initialize the execution.\n');

% Load configuration from file
config_path = 'configuration/SwitchingController/CreateNNConfig.m';
run(config_path);


%% Data generation
fprintf('1) Create coverage data.\n');
error_weights = GenerateErrorWeights(simulation.time_values, weight_options);
[data, num_traces, num_points] = GenerateInputCoverageData(nominal_model, error_weights, coverage_options);
fprintf('Number of data points generated with coverage: %d.\n', num_points);


%% Prepare training data
fprintf('2) Restructure and trim the training data.\n');
[in, out, error_weights, trace_end_indices] = PrepareTrainingData(data, data_options);
training_options = SplitTrainingData(trace_end_indices, training_options);

if data_options.trimming_enabled && data_options.plot
    ExploreTrimming(simulation.time_values, data, data_options);
end


%% Training
fprintf('3) Create and train the initial neural network.\n');
training_timer = tic;
[net, tr] = TrainNeuralNetwork(in, out, error_weights, training_options);
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
