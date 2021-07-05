function [in, out] = RestructureTrainingData(REF, U, Y)
%% Validate input arguments
if isa(REF, 'double') == 0 || isa(U, 'double') == 0 || isa(Y, 'double') == 0
    error("RestructureTrainingData:TypeError", "The input arguments must have type 'double' array!");
end
if isempty(REF) || isempty(U) || isempty(Y)
    error("RestructureTrainingData:EmptyInput", "The input arguments must not be empty!");
end
if length(REF) ~= length(U) || length(U) ~= length(Y)
    error("RestructureTrainingData:VaryingLength", "The input arguments must have the same length!");
end


%% Create a six dimensional vector with 3 reference and 3 Y values
if length(REF) == 1
    in = [REF; 0; 0; Y; 0; 0];
    out = U;
    return;
end

preallocated_values = zeros(1, (length(REF) - 2));

in1 = [REF(1) REF(2) preallocated_values];
in2 = [0 REF(1) preallocated_values];
in3 = [0 0 preallocated_values];
in4 = [Y(1) Y(2) preallocated_values];
in5 = [0 Y(1) preallocated_values];
in6 = [0 0 preallocated_values];

for idx = 3:length(REF)
    in1(idx) = REF(idx);
    in2(idx) = in1(idx-1);
    in3(idx) = in1(idx-2);
    in4(idx) = Y(idx);
    in5(idx) = in4(idx-1);
    in6(idx) = in4(idx-2);
end

in = [in1; in2; in3; in4; in5; in6];
out = U;

end