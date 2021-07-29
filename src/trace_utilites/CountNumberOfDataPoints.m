function num_data_points = CountNumberOfDataPoints(data)
%% Validate input arguments
if isstruct(data) == 0
    error("CountNumberOfDataPoints:TypeError", "The input argument 'data' must have type 'struct'!");
end
if isempty(fieldnames(data))
    error("CountNumberOfDataPoints:InvalidInput", "The input argument 'data' must not be empty!");
end

num_data_points = 0;
for idx = 1:length(data.REF)
    num_data_points = num_data_points + length(data.REF{idx});
end

end
