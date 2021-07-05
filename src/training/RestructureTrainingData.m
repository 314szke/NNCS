function [in, out] = RestructureTrainingData(REF, U, Y)
%% Validate input arguments
if strcmp(class(REF), 'double') == 0 || strcmp(class(U), 'double') == 0 || strcmp(class(Y), 'double') == 0
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

in1 = [REF(1) REF(2)];
in2 = [0 REF(1)];
in3 = [0 0];
in4 = [Y(1) Y(2)];
in5 = [0 Y(1)];
in6 = [0 0];

for idx = 3:length(REF)
    in1 = [in1, REF(idx)];
    in2 = [in2, in1(idx-1)];
    in3 = [in3, in1(idx-2)];
    in4 = [in4, Y(idx)];
    in5 = [in5, in4(idx-1)];
    in6 = [in6, in4(idx-2)];
end

in = [in1; in2; in3; in4; in5; in6];
out = U;

end