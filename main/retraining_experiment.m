%% Initialize
Initialize
clear; close all; clc; bdclose('all');


%% Run tests
window_sizes = [2 4 8];
networks = [0 1 2 3 4];

MAX_TEST_ITERATION = 10;
WINDOW_SIZE = 0;
CEX_THRESHOLD = 5;
ACCUMULATE_CEX = 0;
VALIDATION_ERROR_THRESHOLD = 0.01;
USE_POSITIVE_DIAGNOSIS = 1;

for test_idx = 1:numel(networks)
    SAVED_ENVIRONMENT = sprintf('bin/nn%d.mat', networks(test_idx));
    fprintf('### Run tests with %s\n', SAVED_ENVIRONMENT);

    fprintf('## Run with complete counter examples.\n');
    SHORTENED_CEX = 0;
    TEST_NAME = sprintf('results/test%d_%d_complete', networks(test_idx), 0);
    run('retraining_loop.m')

    for window_idx = 1:numel(window_sizes)
        WINDOW_SIZE = window_sizes(window_idx);
        SHORTENED_CEX = 1;
        TEST_NAME = sprintf('results/test%d_%d_shortened', networks(test_idx), WINDOW_SIZE);

        fprintf('## Run with shortened counter examples with window size %d.\n', WINDOW_SIZE);
        run('retraining_loop.m')
    end
end