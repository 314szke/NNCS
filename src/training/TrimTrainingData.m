function [new_in, new_out, new_error_weights, trace_end_indices] = TrimTrainingData(in, out, error_weights, trace_end_indices, epsilon, repetition)
%% Validate input arguments
if isa(in, 'double') == 0 || isa(out, 'double') == 0 || isa(error_weights, 'double') == 0 || isa(trace_end_indices, 'double') == 0 || isa(epsilon, 'double') == 0 || isa(repetition, 'double') == 0
    error("TrimTrainingData:TypeError", "The input arguments must have type 'double' array!");
end
if isempty(in) || isempty(out)
    error("TrimTrainingData:EmptyInput", "The input arguments must not be empty!");
end
if length(out) ~= length(in(1, :))
    error("TrimTrainingData:InputMismatch", "The dimensions of input argument 'in' must align with the argument 'out'!");
end
if epsilon < 0
    error("TrimTrainingData:InvalidInput", "The input argument 'epsilon' must not be negative!");
end
if repetition < 0
    error("TrimTrainingData:InvalidInput", "The input argument 'repetition' must not be negative!");
end


%% Remove each input vector which is less than epsilon distance far from the previous vector
new_in(:, 1) = in(:, 1);
new_out = out(1);
new_error_weights = error_weights(1);

trace_idx = 1;
last_idx = 1;
num_equal_consecutive = 0;

% In case the first trace has only one data point
if trace_end_indices(trace_idx) == 1
    trace_idx = 2;
end

for idx = 2:length(out)
    if InputVectorsAreEqual(in(:, idx), in(:, last_idx), epsilon)
        num_equal_consecutive = num_equal_consecutive + 1;
    else
        num_equal_consecutive = 0;
    end

    if num_equal_consecutive <= repetition
        new_in(:, end+1) = in(:, idx);
        new_out = [new_out out(idx)];
        new_error_weights = [new_error_weights error_weights(idx)];
        last_idx = idx;
    end

    if idx == trace_end_indices(trace_idx)
        trace_end_indices(trace_idx) = length(new_out);
        trace_idx = trace_idx + 1;
    end
end

end


function value = InputVectorsAreEqual(vec1, vec2, epsilon)
%% Validate input arguments
if isa(vec1, 'double') == 0 || isa(vec2, 'double') == 0 || isa(epsilon, 'double') == 0
    error("InputVectorsAreEqual:TypeError", "The input arguments must have type 'double' array!");
end

value = 1;
for vec_idx = 1:length(vec1)
    if abs(vec1(vec_idx) - vec2(vec_idx)) > epsilon
        value = 0;
        return;
    end
end
end
