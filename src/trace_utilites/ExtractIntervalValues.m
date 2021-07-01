function values = ExtractIntervalValues(trace_values, time_values, intervals)
%% Parameter checking
if class(trace_values) ~= 'double'
    error("The parameter 'trace_values' must have type 'double' array!");
end
if class(time_values) ~= 'double'
    error("The parameter 'time_values' must have type 'double' array!");
end
if class(intervals) ~= 'struct'
    error("The parameter 'intervals' must have type 'struct'!");
end
fields = fieldnames(intervals);
if fields{1} ~= 't_begin'
    error("The parameter 'intervals' must have a field named 't_begin'!");
end
if fields{2} ~= 't_end'
    error("The parameter 'intervals' must have a field named 't_end'!");
end


%% Take trace values in time points which are inside an interval
values = [];
interval_idx = 1;

for idx = 1:numel(time_values)
    if time_values(idx) > intervals(interval_idx).t_end
        interval_idx = interval_idx + 1;
        if interval_idx > numel(intervals)
            break;
        end
    end
    if time_values(idx) >= intervals(interval_idx).t_begin
        values = [values, trace_values(idx)];
    end
end

end