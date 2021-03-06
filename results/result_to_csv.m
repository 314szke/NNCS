%% Initialize
Initialize
clear; close all; clc; bdclose('all');


%% Convert experiment results to CSV format
files = dir('results/experiment*');
fileID = fopen('results/results.csv','w');
fprintf(fileID, 'BinaryName;IterationID;MaxIteration;CexThreshold;NumCex;RemainingCex;WindowSize;ShortenedCex;AccumulateCex;UsePositiveDiagnosis;UseAllDataForRetraining;RetrainingErrorThreshold;RetrainingTime;TrainingError;ErrorWeightFunction;TrainedFromScratch;DataLength;CexLength\n');

for file_idx = 1:length(files)
    file_name = files(file_idx).name;
    load(file_name);

    for result_idx = 1:length(results)
        result = results{result_idx};
        fprintf(fileID, '%s;%d;%d;%d;%d;%d;%0.2f;%d;%d;%d;%d;%0.4f;%0.4f;%0.6f;%s;%d;%d;%d\n', ...
            result.environment, ...
            result_idx, ...
            result.max_iteration, ...
            result.cex_threshold, ...
            result.num_cex, ...
            result.remaining_cex, ...
            result.window_size, ...
            result.shortened_cex, ...
            result.accumulate_cex, ...
            result.use_positive_diagnosis, ...
            result.use_all_data, ...
            result.retraining_error_threshold, ...
            result.retraining_time, ...
            result.training_error, ...
            result.error_weight_function, ...
            result.trained_from_scratch, ...
            result.data_length, ...
            result.cex_length);
    end

    clear result;
    clear results;
end

fclose(fileID);
