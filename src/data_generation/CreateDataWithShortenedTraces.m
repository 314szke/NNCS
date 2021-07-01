function data = CreateDataWithShortenedTraces(model, evaluation_result, trace_intervals, unique_trace_indexes, window_size)
%% Parameter checking
if class(model) ~= "BreachSimulinkSystem"
    error("The parameter 'model' must have type 'BreachSimulinkSystem'!");
end
if class(evaluation_result) ~= "BreachRequirement"
    error("The parameter 'evaluation_result' must have type 'BreachRequirement'!");
end
if class(trace_intervals) ~= 'cell'
    error("The parameter 'trace_intervals' must have type 'cell' array!");
end
if class(unique_trace_indexes) ~= 'double'
    error("The parameter 'unique_trace_indexes' must have type 'double' array!");
end
if class(window_size) ~= 'double'
    error("The parameter 'window_size' must have type 'double'!");
end


%% Use only the trace values inside the intervals
ref_values = [];
u_values = [];
y_values = [];

time_values = evaluation_result.GetTime();
max_time = time_values(end);

for trace_idx = 1:numel(unique_trace_indexes)
    intervals = trace_intervals{unique_trace_indexes(trace_idx)};
    intervals = ExtendIntervals(intervals, window_size, max_time);

    values = ExtractIntervalValues(model.GetSignalValues({'u'}, trace_idx), time_values, intervals);
    u_values = [u_values, values];

    values = ExtractIntervalValues(model.GetSignalValues({'y'}, trace_idx), time_values, intervals);
    y_values = [y_values, values];

    values = ExtractIntervalValues(model.GetSignalValues({'ref'}, trace_idx), time_values, intervals);
    ref_values = [ref_values, values];
end

data.REF = ref_values';
data.U = u_values';
data.Y = y_values';

end