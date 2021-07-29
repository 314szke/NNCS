function [in, out, error_weights, trace_end_indices] = PrepareTrainingData(data, options)
%% Validate input arguments
if isstruct(data) == 0
    error("PrepareTrainingData:TypeError", "The input argument 'data' must have type 'struct'!");
end
if isstruct(options) == 0
    error("PrepareTrainingData:TypeError", "The input argument 'options' must have type 'struct'!");
end
if isempty(fieldnames(data))
    error("PrepareTrainingData:InvalidInput", "The input argument 'data' must not be empty!");
end


%% Create input and output for training
in = [];
out = [];
error_weights = [];
trace_end_indices = zeros(1, length(data.REF));

% Restructure data trace by trace to apply shifting
for trace_idx = 1:length(data.REF)
    [partial_in, partial_out] = RestructureTrainingData(data.REF{trace_idx}, data.U{trace_idx}, data.Y{trace_idx}, options.input_dimension);
    in = [in partial_in];
    out = [out; partial_out];
    error_weights = [error_weights data.weights{trace_idx}];
    trace_end_indices(trace_idx) = length(out);
end
out = out';

% Trim the whole training data to avoid too many consecutive repetitions
if options.trimming_enabled
    fprintf('Number of data points before trimming: %d.\n', length(out));
    [in, out, error_weights, trace_end_indices] = TrimTrainingData(in, out, error_weights, trace_end_indices, options.trim_distance_criteria, options.trim_allowed_repetition);
    fprintf('Number of data points after trimming: %d.\n', length(out));
end

end
