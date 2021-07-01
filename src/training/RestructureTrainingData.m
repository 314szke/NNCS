function [in, out] = RestructureTrainingData(REF, U, Y)
%% Parameter checking
if class(REF) ~= 'double'
    error("The parameter 'REF' must have type 'double' array!");
end
if class(U) ~= 'double'
    error("The parameter 'U' must have type 'double' array!");
end
if class(Y) ~= 'double'
    error("The parameter 'Y' must have type 'double' array!");
end


%% Create a six dimensional vector with 3 reference and 3 Y values
in1 = [REF(1) REF(2)];
in2 = [0 REF(1)];
in3 = [0 0];
in4 = [Y(1) Y(2)];
in5 = [0 Y(1)];
in6 = [0 0];
out = [U(1) U(2)];

for idx = 3:numel(REF)
    in1 = [in1, REF(idx)];
    in2 = [in2, in1(idx-1)];
    in3 = [in3, in1(idx-2)];
    in4 = [in4, Y(idx)];
    in5 = [in5, in4(idx-1)];
    in6 = [in6, in4(idx-2)];
    out = [out, U(idx)];
end

in = [in1; in2; in3; in4; in5; in6];
end