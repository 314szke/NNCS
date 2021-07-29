%% IMPORTANT: Execute this script from retraining_experiment.m !

fprintf('0) Initialize the execution.\n');
% Load workspace from initial training
load(SAVED_ENVIRONMENT);

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
nominal_model = CreateModel(nominal_model_path, simulation);
nn_model = CreateSwitchingControllerNeuralModel(nn_model_path, simulation, coverage_options);
plot_model1 = CreateModel(parallel_model_before_retraining_path, simulation);
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


%% Retraining until no counter examples are remaining or the iteration limit is not reached
results = {};
for iteration = 1:MAX_EXPERIMENT_ITERATION
    %% Setup iteration
    fprintf('# Retraining iteration %d/%d.\n', iteration, MAX_EXPERIMENT_ITERATION);
    close all; bdclose('all');
    clear result;

    result.environment = SAVED_ENVIRONMENT;
    result.max_iteration = MAX_EXPERIMENT_ITERATION;
    result.shortened_cex = SHORTENED_CEX;
    result.use_positive_diagnosis = USE_POSITIVE_DIAGNOSIS;
    result.accumulate_cex = ACCUMULATE_CEX;
    result.cex_threshold = CEX_THRESHOLD;
    result.retraining_error_threshold = RETRAINING_ERROR_THRESHOLD;
    result.window_size = WINDOW_SIZE;
    result.use_all_data = USE_ALL_DATA_FOR_RETRAINING;
    result.error_weight_function = weight_options.function;


    %% Falsification
    fprintf('1) Find counter-examples with falsification.\n');
    error_weights = GenerateErrorWeights(simulation.time_values, weight_options);
    [complete_new_data, shortened_new_data, num_cex, cex_traces] = GenerateCounterExampleData(nn_model, nominal_model, plot_model1, nn_requirement, nominal_requirement, error_weights, plot_labels1, options);

    if SHORTENED_CEX == 1
        new_data = shortened_new_data;
    else
        new_data = complete_new_data;
    end

    if isempty(fieldnames(new_data))
        fprintf('No counter-examples found, the retraining stops.\n');
        result.retraining_time = 0;
        result.training_error = 0;
        result.num_cex = 0;
        result.remaining_cex = 0;
        result.data_length = CountNumberOfDataPoints(data);
        result.cex_length = 0;
        result.trained_from_scratch = 0;
        results{end+1} = result;
        break;
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


    %% Retraining with counter examples
    fprintf('3) Retrain with additional counter-example data.\n');
    retraining_timer = tic;
    [new_net, tr, trained_from_scratch] = RetrainNeuralNetwork(net, in, out, error_weights, training_options);
    timer.retrain = toc(retraining_timer);

    fprintf('Retraining time: %0.2f seconds.\n', timer.retrain);
    fprintf('The target training error was %f.\n', training_options.target_error_rate);
    fprintf('The obtained training error is %f.\n', tr.best_tperf);


    %% Save retrained model
    fprintf('4) Update the Simulink models.\n');
    for idx = 1:length(new_nn_models)
        UpdateNeuralNetwork(new_net, new_nn_models{idx}.path, new_nn_models{idx}.block_name);
    end


    %% Verify if the counter examples disappeared
    fprintf('5) Verify if counter-examples are eliminated.\n');
    nn_retrained_model = CreateModel(nn_model_retrained_path, simulation);
    [~, ~, remaining_cex] = EvaluateModel(nn_retrained_model, cex_traces, nn_requirement);


    %% Save retraining results
    result.retraining_time = timer.retrain;
    result.training_error = tr.best_tperf;
    result.num_cex = num_cex;
    result.remaining_cex = remaining_cex;
    result.data_length = CountNumberOfDataPoints(data);
    result.cex_length = CountNumberOfDataPoints(new_data);
    result.trained_from_scratch = trained_from_scratch;
    results{end+1} = result;


    %% Save counter example data
    if ACCUMULATE_CEX == 1
        data = ConcatenateData(data, new_data);
    end


    %% Update simulink models for next iteration
    fprintf('6) Update the Simulink models for the next iteration.\n');
    for idx = 1:length(nn_models)
        UpdateNeuralNetwork(new_net, nn_models{idx}.path, nn_models{idx}.block_name);
    end
end


%% Save execution
save(EXPERIMENT_NAME);
