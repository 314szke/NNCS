function unique_trace_indexes = FindUniqueTraces(trace_intervals, unique_intervals)
%% Parameter checking
if class(trace_intervals) ~= 'cell'
    error("The parameter 'trace_intervals' must have type 'cell' array!");
end
if class(unique_intervals) ~= 'struct'
    error("The parameter 'unique_intervals' must have type 'struct'!");
end
fields = fieldnames(unique_intervals);
if fields{1} ~= 'intervals'
    error("The parameter 'unique_intervals' must have a field named 'intervals'!");
end
if class(unique_intervals.intervals) ~= 'struct'
    error("The parameter 'unique_intervals.intervals' must have type 'struct' array!");
end


%% Find the first counter-example trace which contains the unique interval
selected_trace_indexes = [];
for unique_idx = 1:numel(unique_intervals.intervals)
    trace_found = 0;
    for trace_idx = 1:numel(trace_intervals)
        if length(trace_intervals{trace_idx}) == 0
            continue;
        elseif length(trace_intervals{trace_idx}) == 1
            if EqualTimeIntervals(trace_intervals{trace_idx}, unique_intervals.intervals(unique_idx)) == 1
                selected_trace_indexes = [selected_trace_indexes; trace_idx];
                trace_found = 1;
            end
        else
            intervals = trace_intervals{trace_idx};
            for idx = 1:numel(intervals)
                if EqualTimeIntervals(intervals(idx), unique_intervals.intervals(unique_idx)) == 1
                    selected_trace_indexes = [selected_trace_indexes; trace_idx];
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

unique_trace_indexes = unique(selected_trace_indexes);

end


function value = EqualTimeIntervals(t1, t2)
%% Parameter checking
if class(t1) ~= 'struct'
    error("The parameter 't1' must have type 'struct'!");
end
if class(t2) ~= 'struct'
    error("The parameter 't2' must have type 'struct'!");
end
fields = fieldnames(t1);
if fields{1} ~= 't_begin'
    error("The parameter 't1' must have a field named 't_begin'!");
end
if fields{2} ~= 't_end'
    error("The parameter 't1' must have a field named 't_end'!");
end
fields = fieldnames(t2);
if fields{1} ~= 't_begin'
    error("The parameter 't2' must have a field named 't_begin'!");
end
if fields{2} ~= 't_end'
    error("The parameter 't2' must have a field named 't_end'!");
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