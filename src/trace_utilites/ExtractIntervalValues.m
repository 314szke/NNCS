function values = ExtractIntervalValues(trace_values, time_values, intervals)
%% Validate input arguments
if isa(trace_values, 'double') == 0
    error("ExtractIntervalValues:TypeError", "The input argument 'trace_values' must have type 'double' array!");
end
if isa(time_values, 'double') == 0
    error("ExtractIntervalValues:TypeError", "The input argument 'time_values' must have type 'double' array!");
end
if isempty(intervals)
    values = [];
    return;
end
if isstruct(intervals) == 0
    error("ExtractIntervalValues:TypeError", "The input argument 'intervals' must have type 'struct'!");
end
fields = fieldnames(intervals);
if strcmp(fields{1}, 't_begin') == 0
    error("ExtractIntervalValues:TypeError", "The input argument 'intervals' must have a field named 't_begin'!");
end
if strcmp(fields{2}, 't_end') == 0
    error("ExtractIntervalValues:TypeError", "The input argument 'intervals' must have a field named 't_end'!");
end


%% Take trace values in time points which are inside an interval
values = [];
interval_idx = 1;

for idx = 1:length(time_values)
    if time_values(idx) > intervals(interval_idx).t_end
        interval_idx = interval_idx + 1;
        if interval_idx > length(intervals)
            break;
        end
    end
    if time_values(idx) >= intervals(interval_idx).t_begin
        values = [values trace_values(idx)];
    end
end

end