function data = CreateDataWithCompleteTraces(model, num_traces)
%% Parameter checking
if class(model) ~= "BreachSimulinkSystem"
    error("The parameter 'model' must have type 'BreachSimulinkSystem'!");
end
if class(num_traces) ~= 'double'
    error("The parameter 'num_traces' must have type 'double' array!");
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