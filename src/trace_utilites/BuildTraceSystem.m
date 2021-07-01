function trace_system = BuildTraceSystem(evaluation_result, trace_intervals, unique_trace_indexes)
%% Parameter checking
if class(evaluation_result) ~= "BreachRequirement"
    error("The parameter 'evaluation_result' must have type 'BreachRequirement'!");
end
if class(trace_intervals) ~= 'cell'
    error("The parameter 'trace_intervals' must have type 'cell' array!");
end
if class(unique_trace_indexes) ~= 'double'
    error("The parameter 'unique_trace_indexes' must have type 'double' array!");
end


%% Add the selected traces in unique_trace_indexes to the BreachTraceSystem object
time_values = evaluation_result.GetTime();
input_signals = evaluation_result.expand_signal_name('model_input');
trace_system = BreachTraceSystem([input_signals]);

for idx = 1:numel(unique_trace_indexes)
    trace_idx = unique_trace_indexes(idx);
    input_values = evaluation_result.GetSignalValues(input_signals, trace_idx);
    trace_system.AddTrace([time_values', input_values']);
end

trace_system.GenTraceIdx();

end