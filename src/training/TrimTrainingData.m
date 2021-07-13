function [new_in, new_out] = TrimTrainingData(in, out, dimension, epsilon)
%% Validate input arguments
if isa(in, 'double') == 0 || isa(out, 'double') == 0 || isa(epsilon, 'double') == 0 || isa(dimension, 'double') == 0
    error("TrimTrainingData:TypeError", "The input arguments must have type 'double' array!");
end
if isempty(in) || isempty(out)
    error("TrimTrainingData:EmptyInput", "The input arguments must not be empty!");
end
if length(out) ~= length(in(1, :))
    error("TrimTrainingData:InputMismatch", "The dimensions of input argument 'in' must align with the argument 'out'!");
end
if dimension < 1
    error("TrimTrainingData:InvalidInput", "The input argument 'dimension' must not be less than 1!");
end
if dimension ~= length(in(:, 1))
    error("TrimTrainingData:InputMismatch", "The input argument 'dimension' must align with the argument 'in' dimensions!");
end
if epsilon < 0
    error("TrimTrainingData:InvalidInput", "The input argument 'epsilon' must not be negative!");
end


%% Remove each input vector which is less than epsilon distance far from the previous vector
new_in(:, 1) = in(:, 1);
new_out = out(1);

last_idx = 1;
for idx = 2:length(out)
    if InputVectorsAreEqual(in(:, idx), in(:, last_idx), epsilon) == 0
        new_in(:, end+1) = in(:, idx);
        new_out = [new_out out(idx)];
        last_idx = idx;
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
