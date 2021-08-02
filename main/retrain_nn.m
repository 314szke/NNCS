%% Initialize workspace and set execution parameters
Initialize
clear; close all; clc; bdclose('all');
fprintf('0) Initialize the execution.\n');

% Load workspace from initial training
load('nn.mat');

% Load configuration from file
config_path = 'configuration/SwitchingController/RetrainNNConfig.m';
run(config_path);


%% Falsification
fprintf('1) Find counter-examples with falsification.\n');
error_weights = GenerateErrorWeights(simulation.time_values, weight_options);
[complete_new_data, shortened_new_data, num_cex, cex_traces] = GenerateCounterExampleData(nn_model, nominal_model, plot_model1, nn_requirement, nominal_requirement, error_weights, plot_labels1, options);

if options.use_shortened_cex
    new_data = shortened_new_data;
else
    new_data = complete_new_data;
end

if isempty(fieldnames(new_data))
    fprintf('No counter-examples found, the retraining stops.\n');
    return;
end
fprintf('The neural network controller produced %i counter-examples in %i input traces.\n', num_cex, options.num_falsification_traces);


%% Prepare training data
fprintf('2) Restructure and trim the training data.\n');
if data_options.use_all_data == 1
    training_data = ConcatenateData(new_data, data);
else
    training_data = new_data;
end

[in, out, error_weights, trace_end_indices] = PrepareTrainingData(training_data, data_options);
training_options = SplitTrainingData(trace_end_indices, training_options);


%% Retraining
fprintf('3) Retrain with additional counter-example data.\n');
retraining_timer = tic;
[new_net, tr, ~] = RetrainNeuralNetwork(net, in, out, error_weights, training_options);
timer.retrain = toc(retraining_timer);

fprintf('Retraining time: %0.2f seconds.\n', timer.retrain);
fprintf('The target training error was %f.\n', training_options.target_error_rate);
fprintf('The obtained training error is %f.\n', tr.best_tperf);


%% Save the new neural network
fprintf('4) Update the Simulink models.\n');
for idx = 1:length(new_nn_models)
    UpdateNeuralNetwork(new_net, new_nn_models{idx}.path, new_nn_models{idx}.block_name);
end


%% Verification
fprintf('5) Verify if counter-examples are eliminated.\n');
nn_retrained_model = CreateModel(nn_model_retrained_path, simulation, model_options);
[~, evaluation_result, remaining_cex] = EvaluateModel(nn_retrained_model, cex_traces, nn_requirement);
fprintf('Number of counter-examples remaining after retraining: %i/%i.\n', remaining_cex, num_cex);

if options.plot == 1
    plot_model2 = CreateModel(parallel_model_after_retraining_path, simulation, model_options);
    PlotModel(plot_model2, evaluation_result, nn_new_requirement, plot_labels2);
end
