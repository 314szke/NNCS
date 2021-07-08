%% Initialize
Initialize
clear; close all; clc; bdclose('all');


%% Run experiments
% Dynamic settings
environments = [0 1 2];
window_sizes = [1 2 4];
cex_thresholds = [5 10 100];

% Static settings (does not change per experiment case)
MAX_EXPERIMENT_ITERATION = 10;
RETRAINING_ERROR_THRESHOLD = 0.01;

% Binary settings
SHORTENED_CEX = 0;
ACCUMULATE_CEX = 0;
USE_POSITIVE_DIAGNOSIS = 0;
USE_ALL_DATA_FOR_RETRAINING = 0;

% Number of experiment cases = window sizes + cex thresholds + binary settings
num_cases = length(cex_thresholds) * (4 + (length(window_sizes) * 8));
case_counter = 0;

for experiment_idx = 1:length(environments)
    SAVED_ENVIRONMENT = sprintf('bin/nn%d.mat', environments(experiment_idx));
    fprintf('### Run experiments with %s\n', SAVED_ENVIRONMENT);

    for threshold_idx = 1:length(cex_thresholds)
        fprintf('## Run experiment %d/%d\n', case_counter, num_cases);
        CEX_THRESHOLD = cex_thresholds(threshold_idx);
        WINDOW_SIZE = 0;
        SHORTENED_CEX = 0;
        ACCUMULATE_CEX = 0;
        USE_POSITIVE_DIAGNOSIS = 0;
        USE_ALL_DATA_FOR_RETRAINING = 0;

        % Complete counter-examples, ACCUMULATE_CEX = 0 and USE_ALL_DATA_FOR_RETRAINING = 0
        EXPERIMENT_NAME = sprintf('results/experiment%d', case_counter);
        case_counter = case_counter + 1;
        run('retrain_nn_loop.m')

        % Complete counter-examples, ACCUMULATE_CEX = 1 and USE_ALL_DATA_FOR_RETRAINING = 0
        ACCUMULATE_CEX = 1;
        EXPERIMENT_NAME = sprintf('results/experiment%d', case_counter);
        case_counter = case_counter + 1;
        run('retrain_nn_loop.m')

        % Complete counter-examples, ACCUMULATE_CEX = 1 and USE_ALL_DATA_FOR_RETRAINING = 1
        USE_ALL_DATA_FOR_RETRAINING = 1;
        EXPERIMENT_NAME = sprintf('results/experiment%d', case_counter);
        case_counter = case_counter + 1;
        run('retrain_nn_loop.m')

        % Complete counter-examples, ACCUMULATE_CEX = 0 and USE_ALL_DATA_FOR_RETRAINING = 1
        ACCUMULATE_CEX = 0;
        EXPERIMENT_NAME = sprintf('results/experiment%d', case_counter);
        case_counter = case_counter + 1;
        run('retrain_nn_loop.m')

        for window_idx = 1:length(window_sizes)
            WINDOW_SIZE = window_sizes(window_idx);
            SHORTENED_CEX = 1;

            % Shortened counter-examples, ACCUMULATE_CEX = 0 and USE_ALL_DATA_FOR_RETRAINING = 1 and USE_POSITIVE_DIAGNOSIS = 0
            EXPERIMENT_NAME = sprintf('results/experiment%d', case_counter);
            case_counter = case_counter + 1;
            run('retrain_nn_loop.m')

            % Shortened counter-examples, ACCUMULATE_CEX = 1 and USE_ALL_DATA_FOR_RETRAINING = 1 and USE_POSITIVE_DIAGNOSIS = 0
            ACCUMULATE_CEX = 1;
            EXPERIMENT_NAME = sprintf('results/experiment%d', case_counter);
            case_counter = case_counter + 1;
            run('retrain_nn_loop.m')

            % Shortened counter-examples, ACCUMULATE_CEX = 1 and USE_ALL_DATA_FOR_RETRAINING = 1 and USE_POSITIVE_DIAGNOSIS = 1
            USE_POSITIVE_DIAGNOSIS = 1;
            EXPERIMENT_NAME = sprintf('results/experiment%d', case_counter);
            case_counter = case_counter + 1;
            run('retrain_nn_loop.m')

            % Shortened counter-examples, ACCUMULATE_CEX = 0 and USE_ALL_DATA_FOR_RETRAINING = 1 and USE_POSITIVE_DIAGNOSIS = 1
            ACCUMULATE_CEX = 0;
            EXPERIMENT_NAME = sprintf('results/experiment%d', case_counter);
            case_counter = case_counter + 1;
            run('retrain_nn_loop.m')

            % Shortened counter-examples, ACCUMULATE_CEX = 0 and USE_ALL_DATA_FOR_RETRAINING = 0 and USE_POSITIVE_DIAGNOSIS = 1
            USE_ALL_DATA_FOR_RETRAINING = 0;
            EXPERIMENT_NAME = sprintf('results/experiment%d', case_counter);
            case_counter = case_counter + 1;
            run('retrain_nn_loop.m')

            % Shortened counter-examples, ACCUMULATE_CEX = 1 and USE_ALL_DATA_FOR_RETRAINING = 0 and USE_POSITIVE_DIAGNOSIS = 1
            ACCUMULATE_CEX = 1;
            EXPERIMENT_NAME = sprintf('results/experiment%d', case_counter);
            case_counter = case_counter + 1;
            run('retrain_nn_loop.m')

            % Shortened counter-examples, ACCUMULATE_CEX = 1 and USE_ALL_DATA_FOR_RETRAINING = 0 and USE_POSITIVE_DIAGNOSIS = 0
            USE_POSITIVE_DIAGNOSIS = 0;
            EXPERIMENT_NAME = sprintf('results/experiment%d', case_counter);
            case_counter = case_counter + 1;
            run('retrain_nn_loop.m')

            % Shortened counter-examples, ACCUMULATE_CEX = 0 and USE_ALL_DATA_FOR_RETRAINING = 0 and USE_POSITIVE_DIAGNOSIS = 0
            ACCUMULATE_CEX = 0;
            EXPERIMENT_NAME = sprintf('results/experiment%d', case_counter);
            case_counter = case_counter + 1;
            run('retrain_nn_loop.m')
        end
    end
end
