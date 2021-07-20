function [in, out] = PrepareTrainingData(data, options)
%% Validate input arguments
if isstruct(data) == 0
    error("PrepareTrainingData:TypeError", "The parameter 'data' must have type 'struct'!");
end
if isstruct(options) == 0
    error("PrepareTrainingData:TypeError", "The parameter 'options' must have type 'struct'!");
end
if isempty(fieldnames(data))
    error("PrepareTrainingData:InvalidInput", "The parameter 'data' must not be empty!");
end


%% Create input and output for training
in = [];
out = [];

for trace_idx = 1:length(data.REF)
    [partial_in, partial_out] = RestructureTrainingData(data.REF{trace_idx}, data.U{trace_idx}, data.Y{trace_idx}, options.input_dimension);
    in = [in partial_in];
    out = [out; partial_out];
end
out = out';

if options.trimming_enabled
    fprintf('Number of data points before trimming: %d.\n', length(out));
    [in, out] = TrimTrainingData(in, out, options.trim_distance_criteria, options.trim_allowed_repetition);
    fprintf('Number of data points after trimming: %d.\n', length(out));
end

end
