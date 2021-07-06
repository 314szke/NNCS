function unique_trace_indexes = FindUniqueTraces(trace_intervals, unique_intervals)
%% Validate input arguments
if isa(trace_intervals, 'cell') == 0
    error("FindUniqueTraces:TypeError", "The parameter 'trace_intervals' must have type 'cell' array!");
end
if isstruct(unique_intervals) == 0
    error("FindUniqueTraces:TypeError", "The parameter 'unique_intervals' must have type 'struct'!");
end
fields = fieldnames(unique_intervals);
if strcmp(fields{1}, 'intervals') == 0
    error("FindUniqueTraces:TypeError", "The parameter 'unique_intervals' must have a field named 'intervals'!");
end
if isstruct(unique_intervals.intervals) == 0
    error("FindUniqueTraces:TypeError", "The parameter 'unique_intervals.intervals' must have type 'struct' array!");
end
if isempty(trace_intervals) || isempty(unique_intervals.intervals)
    unique_trace_indexes = [];
    return;
end


%% Find the first counter-example trace which contains the unique interval
selected_trace_indexes = [];
for unique_idx = 1:numel(unique_intervals.intervals)
    trace_found = 0;
    for trace_idx = 1:numel(trace_intervals)
        if isempty(trace_intervals{trace_idx})
            continue;
        elseif length(trace_intervals{trace_idx}) == 1
            if EqualTimeIntervals(trace_intervals{trace_idx}, unique_intervals.intervals(unique_idx)) == 1
                selected_trace_indexes = [selected_trace_indexes trace_idx];
                trace_found = 1;
            end
        else
            intervals = trace_intervals{trace_idx};
            for idx = 1:numel(intervals)
                if EqualTimeIntervals(intervals(idx), unique_intervals.intervals(unique_idx)) == 1
                    selected_trace_indexes = [selected_trace_indexes trace_idx];
                    trace_found = 1;
                    break;
                end
            end
        end
        if trace_found == 1
            break;
        end
    end
end

if isempty(selected_trace_indexes)
    unique_trace_indexes = [];
else
    unique_trace_indexes = unique(selected_trace_indexes);
end

end


function value = EqualTimeIntervals(t1, t2)
%% Parameter checking
if isstruct(t1) == 0
    error("EqualTimeIntervals:TypeError", "The parameter 't1' must have type 'struct'!");
end
if isstruct(t2) == 0
    error("EqualTimeIntervals:TypeError", "The parameter 't2' must have type 'struct'!");
end
fields = fieldnames(t1);
if strcmp(fields{1}, 't_begin') == 0
    error("EqualTimeIntervals:TypeError", "The parameter 't1' must have a field named 't_begin'!");
end
if strcmp(fields{2}, 't_end') == 0
    error("EqualTimeIntervals:TypeError", "The parameter 't1' must have a field named 't_end'!");
end
fields = fieldnames(t2);
if strcmp(fields{1}, 't_begin') == 0
    error("EqualTimeIntervals:TypeError", "The parameter 't2' must have a field named 't_begin'!");
end
if strcmp(fields{2}, 't_end') == 0
    error("EqualTimeIntervals:TypeError", "The parameter 't2' must have a field named 't_end'!");
end


%% Check if the two intervals are equal
value = 1;
if t1.t_begin ~= t2.t_begin
    value = 0;
end
if t1.t_end ~= t2.t_end
    value = 0;
end

end
