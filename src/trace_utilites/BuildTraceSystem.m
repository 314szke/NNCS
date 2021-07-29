function trace_system = BuildTraceSystem(evaluation_result, unique_trace_indexes)
%% Validate input arguments
if isa(evaluation_result, 'BreachRequirement') == 0
    error("BuildTraceSystem:TypeError", "The input argument 'evaluation_result' must have type 'BreachRequirement'!");
end
if isa(unique_trace_indexes, 'double') == 0
    error("BuildTraceSystem:TypeError", "The input argument 'unique_trace_indexes' must have type 'double' array!");
end


%% Add the selected traces in unique_trace_indexes to the BreachTraceSystem object
time_values = evaluation_result.GetTime();
input_signals = evaluation_result.expand_signal_name('model_input');
trace_system = BreachTraceSystem(input_signals);

for idx = 1:length(unique_trace_indexes)
    trace_idx = unique_trace_indexes(idx);
    input_values = evaluation_result.GetSignalValues(input_signals, trace_idx);
    trace_system.AddTrace([time_values', input_values']);
end

trace_system.GenTraceIdx();

end
