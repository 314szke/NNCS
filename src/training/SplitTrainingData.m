function options = SplitTrainingData(trace_end_indices, options)
%% Validate input arguments
if isa(trace_end_indices, 'double') == 0
    error("SplitTrainingData:TypeError", "The input argument 'trace_end_indices' must have type 'double' array!");
end
if isstruct(options) == 0
    error("SplitTrainingData:TypeError", "The input argument 'options' must have type 'struct'!");
end
ratio_sum = options.training_data_ratio + options.validation_data_ratio + options.test_data_ratio;
if ratio_sum ~= 1
    error("SplitTrainingData:InvalidInput", "The ratios to define the data sets do not add up to 1!");
end


%% Create an array with digits 0, 1 and 2 with as many repeptions as needed to split the data in the good ratio,
%  then shuffle the array and assign the indices based on the digit at the corresponding index
num_traces = length(trace_end_indices);
num_validation_traces = round(options.validation_data_ratio * num_traces);
num_test_traces = round(options.test_data_ratio * num_traces);
num_training_traces = num_traces - (num_validation_traces + num_test_traces);

set_category = zeros(1, num_training_traces);
set_category = [set_category ones(1, num_validation_traces)];
set_category = [set_category repelem(2, num_test_traces)];
set_category = set_category(randperm(length(set_category)));

options.training_data_indices = [];
options.validation_data_indices = [];
options.test_data_indices = [];

start_idx = 1;
for idx = 1:num_traces
    end_idx = trace_end_indices(idx);
    if set_category(idx) == 0
        options.training_data_indices = [options.training_data_indices start_idx:end_idx];
    elseif set_category(idx) == 1
        options.validation_data_indices = [options.validation_data_indices start_idx:end_idx];
    elseif set_category(idx) == 2
        options.test_data_indices = [options.test_data_indices start_idx:end_idx];
    end
    start_idx = end_idx + 1;
end

end
