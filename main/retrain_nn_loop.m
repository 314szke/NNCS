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
for idx = 1:numel(nn_models)
    UpdateNeuralNetwork(net, nn_models{idx}.path, nn_models{idx}.block_name);
end
nominal_model = CreateModel(nominal_model_path);
nn_model = CreateNeuralSwitchingControllerModel(nn_model_path, coverage_options);
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
options.use_positive_diagnosis = USE_POSITIVE_DIAGNOSIS;
options.window_size = WINDOW_SIZE;
options.cex_threshold = CEX_THRESHOLD;
options.plot = 0;

% Other parameters
training_options.error_threshold = VALIDATION_ERROR_THRESHOLD;
training_options.use_all_data = 1;
rng(1976); % random generator seed for Matlab


%% Retraining until no counter examples are remaining or the iteration limit is not reached
results = {};
for iteration = 1:MAX_TEST_ITERATION
    %% Setup iteration
    fprintf('# Retraining iteration %d/%d.\n', iteration, MAX_TEST_ITERATION);
    close all; bdclose('all');
    clear result;

    result.environment = SAVED_ENVIRONMENT;
    result.shortened_cex = SHORTENED_CEX;
    result.use_positive_diagnosis = USE_POSITIVE_DIAGNOSIS;
    result.accumulate_cex = ACCUMULATE_CEX;
    result.cex_threshold = CEX_THRESHOLD;
    result.validation_error_threshold = VALIDATION_ERROR_THRESHOLD;
    result.window_size = WINDOW_SIZE;
    result.use_all_data = training_options.use_all_data;


    %% Falsification
    fprintf('1) Find counter-examples with falsification.\n');
    [complete_new_data, shortened_new_data, num_cex, cex_traces] = GenerateCounterExampleData(nn_model, nominal_model, plot_model1, nn_requirement, nominal_requirement, plot_labels1, options);

    if SHORTENED_CEX == 1
        new_data = shortened_new_data;
    else
        new_data = complete_new_data;
    end

    if isempty(new_data)
        fprintf('No counter-examples found, the retraining stops.\n');
        result.num_cex = 0;
        results{end+1} = result;
        break;
    end
    fprintf('The neural network controller produced %i counter-examples in %i input traces.\n', num_cex, options.num_falsification_traces);


    %% Retraining with counter examples
    fprintf('2) Retrain with additional counter-example data.\n');
    retraining_timer = tic;
    [new_net, tr, trained_from_scratch] = RetrainNeuralNetwork(net, data, new_data, training_options);
    timer.retrain = toc(retraining_timer);

    fprintf('Retraining time: %0.2f seconds.\n', timer.retrain);
    fprintf('The target training error was %f.\n', training_options.target_error_rate);
    fprintf('The obtained training error is %f.\n', tr.best_perf);


    %% Save retrained model
    fprintf('3) Update the Simulink models.\n');
    for idx = 1:numel(new_nn_models)
        UpdateNeuralNetwork(net, new_nn_models{idx}.path, new_nn_models{idx}.block_name);
    end


    %% Test if the counter examples disappeared
    fprintf('4) Verify if counter-examples are eliminated.\n');
    nn_retrained_model = CreateModel(nn_model_retrained_path);
    [~, ~, remaining_cex] = EvaluateModel(nn_retrained_model, cex_traces, nn_requirement);

    %% Save retraining results
    result.retraining_time = timer.retrain;
    result.training_error = tr.best_perf;
    result.num_cex = num_cex;
    result.remaining_cex = remaining_cex;
    result.data_length = length(data.REF);
    result.cex_length = length(new_data.REF);
    result.trained_from_scratch = trained_from_scratch;
    results{end+1} = result;


    %% Save counter example data
    if ACCUMULATE_CEX == 1
        data.REF = [data.REF; new_data.REF];
        data.U = [data.U; new_data.U];
        data.Y = [data.Y; new_data.Y];
    end


    %% Update simulink models for next iteration
    for idx = 1:numel(nn_models)
        UpdateNeuralNetwork(net, nn_models{idx}.path, nn_models{idx}.block_name);
    end
end


%% Save execution
save(TEST_NAME);
