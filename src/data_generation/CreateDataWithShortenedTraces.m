function data = CreateDataWithShortenedTraces(model, evaluation_result, trace_intervals, unique_trace_indexes, window_size)
%% Validate input arguments
if isa(model, 'BreachSimulinkSystem') == 0
    error("CreateDataWithCompleteTraces:TypeError", "The parameter 'model' must have type 'BreachSimulinkSystem'!");
end
if isa(evaluation_result, 'BreachRequirement') == 0
    error("CreateDataWithCompleteTraces:TypeError", "The parameter 'evaluation_result' must have type 'BreachRequirement'!");
end
if isa(trace_intervals, 'cell') == 0
    error("CreateDataWithCompleteTraces:TypeError", "The parameter 'trace_intervals' must have type 'cell' array!");
end
if isa(unique_trace_indexes, 'double') == 0
    error("CreateDataWithCompleteTraces:TypeError", "The parameter 'unique_trace_indexes' must have type 'double' array!");
end
if isa(window_size, 'double') == 0
    error("CreateDataWithCompleteTraces:TypeError", "The parameter 'window_size' must have type 'double'!");
end


%% Use only the trace values inside the intervals
ref_values = [];
u_values = [];
y_values = [];

time_values = evaluation_result.GetTime();
max_time = time_values(end);

for trace_idx = 1:length(unique_trace_indexes)
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