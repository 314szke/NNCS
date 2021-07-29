function data = CreateDataWithCompleteTraces(model, num_traces, error_weights)
%% Validate input arguments
if isa(model, 'BreachSimulinkSystem') == 0
    error("CreateDataWithCompleteTraces:TypeError", "The input argument 'model' must have type 'BreachSimulinkSystem'!");
end
if isa(num_traces, 'double') == 0
    error("CreateDataWithCompleteTraces:TypeError", "The input argument 'num_traces' must have type 'double'!");
end
if isa(error_weights, 'double') == 0
    error("CreateDataWithCompleteTraces:TypeError", "The input argument 'error_weights' must have type 'double' array!");
end


%% Use the complete traces for retraining
data.REF = cell(1, num_traces);
data.U = cell(1, num_traces);
data.Y = cell(1, num_traces);
data.weights = cell(1, num_traces);

for trace_idx = 1:num_traces
    data.REF{trace_idx} = model.GetSignalValues({'ref'}, trace_idx);
    data.U{trace_idx} = model.GetSignalValues({'u'}, trace_idx);
    data.Y{trace_idx} = model.GetSignalValues({'y'}, trace_idx);
    data.weights{trace_idx} = error_weights;
end

end
