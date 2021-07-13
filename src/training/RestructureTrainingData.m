function [in, out] = RestructureTrainingData(REF, U, Y, dimension)
%% Validate input arguments
if isa(REF, 'double') == 0 || isa(U, 'double') == 0 || isa(Y, 'double') == 0 || isa(dimension, 'double') == 0
    error("RestructureTrainingData:TypeError", "The input arguments must have type 'double' array!");
end
if isempty(REF) || isempty(U) || isempty(Y)
    error("RestructureTrainingData:EmptyInput", "The input arguments must not be empty!");
end
if length(REF) ~= length(U) || length(U) ~= length(Y)
    error("RestructureTrainingData:VaryingLength", "The input arguments must have the same length!");
end


%% Create a six dimensional vector with 3 reference and 3 Y values
in = zeros(dimension, length(REF));
out = U';

idx_half = (dimension / 2) + 1;
for idx = 1:length(REF)
    for dim_idx = 1:dimension
        if dim_idx < idx_half
            idx_offset = (idx - dim_idx) + 1;
            if idx_offset < 1
                in(dim_idx, idx) = 0;
            else
                in(dim_idx, idx) = REF(idx_offset);
            end
        else
            idx_offset = (idx - dim_idx) + idx_half;
            if idx_offset < 1
                in(dim_idx, idx) = 0;
            else
                in(dim_idx, idx) = Y(idx_offset);
            end
        end
    end
end

end
