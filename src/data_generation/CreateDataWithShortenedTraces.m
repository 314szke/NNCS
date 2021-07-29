function data = CreateDataWithShortenedTraces(model, evaluation_result, trace_intervals, unique_trace_indexes, window_size, error_weights)
%% Validate input arguments
if isa(model, 'BreachSimulinkSystem') == 0
    error("CreateDataWithShortenedTraces:TypeError", "The input argument 'model' must have type 'BreachSimulinkSystem'!");
end
if isa(evaluation_result, 'BreachRequirement') == 0
    error("CreateDataWithShortenedTraces:TypeError", "The input argument 'evaluation_result' must have type 'BreachRequirement'!");
end
if isa(trace_intervals, 'cell') == 0
    error("CreateDataWithShortenedTraces:TypeError", "The input argument 'trace_intervals' must have type 'cell' array!");
end
if isa(unique_trace_indexes, 'double') == 0
    error("CreateDataWithShortenedTraces:TypeError", "The input argument 'unique_trace_indexes' must have type 'double' array!");
end
if isa(window_size, 'double') == 0
    error("CreateDataWithShortenedTraces:TypeError", "The input argument 'window_size' must have type 'double'!");
end
if isa(error_weights, 'double') == 0
    error("CreateDataWithShortenedTraces:TypeError", "The input argument 'error_weights' must have type 'double' array!");
end


%% Use only the trace values inside the intervals
data.REF = cell(1, length(unique_trace_indexes));
data.U = cell(1, length(unique_trace_indexes));
data.Y = cell(1, length(unique_trace_indexes));
data.weights = cell(1, length(unique_trace_indexes));

time_values = evaluation_result.GetTime();
max_time = time_values(end);

for trace_idx = 1:length(unique_trace_indexes)
    intervals = trace_intervals{unique_trace_indexes(trace_idx)};
    intervals = ExtendIntervals(intervals, window_size, max_time);

    values = ExtractIntervalValues(model.GetSignalValues({'ref'}, trace_idx), time_values, intervals);
    data.REF{trace_idx} = values;

    values = ExtractIntervalValues(model.GetSignalValues({'u'}, trace_idx), time_values, intervals);
    data.U{trace_idx} = values;

    values = ExtractIntervalValues(model.GetSignalValues({'y'}, trace_idx), time_values, intervals);
    data.Y{trace_idx} = values;

    values = ExtractIntervalValues(error_weights, time_values, intervals);
    data.weights{trace_idx} = values;
end

end
