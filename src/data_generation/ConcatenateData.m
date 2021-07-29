function new_data = ConcatenateData(data1, data2)
%% Validate input arguments
if isstruct(data1) == 0
    error("ConcatenateData:TypeError", "The input argument 'data1' must have type 'struct'!");
end
if isstruct(data2) == 0
    error("ConcatenateData:TypeError", "The input argument 'data2' must have type 'struct'!");
end


new_data.REF = {};
new_data.U = {};
new_data.Y = {};
new_data.weights = {};

if isempty(fieldnames(data1)) == 0
    new_data = data1;
end

if isempty(fieldnames(data2)) == 0
    for trace_idx = 1:length(data2.REF)
        new_data.REF{end+1} = data2.REF{trace_idx};
        new_data.U{end+1} = data2.U{trace_idx};
        new_data.Y{end+1} = data2.Y{trace_idx};
        new_data.weights{end+1} = data2.weights{trace_idx};
    end
end

end
