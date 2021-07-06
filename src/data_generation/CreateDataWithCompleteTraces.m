function data = CreateDataWithCompleteTraces(model, num_traces)
%% Validate input arguments
if isa(model, 'BreachSimulinkSystem') == 0
    error("CreateDataWithCompleteTraces:TypeError", "The parameter 'model' must have type 'BreachSimulinkSystem'!");
end
if isa(num_traces, 'double') == 0
    error("CreateDataWithCompleteTraces:TypeError", "The parameter 'num_traces' must have type 'double'!");
end


%% Use the complete traces for retraining
ref_values = [];
u_values = [];
y_values = [];

for trace_idx = 1:num_traces
    u_values = [u_values, model.GetSignalValues({'u'}, trace_idx)];
    y_values = [y_values, model.GetSignalValues({'y'}, trace_idx)];
    ref_values = [ref_values, model.GetSignalValues({'ref'}, trace_idx)];
end

data.REF = ref_values';
data.U = u_values';
data.Y = y_values';

end