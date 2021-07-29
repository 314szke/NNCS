function outervals = ExtendIntervals(intervals, window_size, max_size)
%% Validate input arguments
if isempty(intervals)
    outervals = [];
    return;
end
if isstruct(intervals) == 0
    error("ExtendIntervals:TypeError", "The input argument 'intervals' must have type 'struct' array!");
end
fields = fieldnames(intervals);
if strcmp(fields{1}, 't_begin') == 0
    error("ExtendIntervals:TypeError", "The input argument 'intervals' must have a field named 't_begin'!");
end
if strcmp(fields{2}, 't_end') == 0
    error("ExtendIntervals:TypeError", "The input argument 'intervals' must have a field named 't_end'!");
end
if isa(window_size, 'double') == 0
    error("ExtendIntervals:TypeError", "The input argument 'window_size' must have type 'double'!");
end
if isa(max_size, 'double') == 0
    error("ExtendIntervals:TypeError", "The input argument 'max_size' must have type 'double'!");
end


%% Subtract from t_begin and add to t_end while keeping the time boundaries
for idx = 1:length(intervals)
    intervals(idx).t_begin = intervals(idx).t_begin - window_size;
    if intervals(idx).t_begin < 0
        intervals(idx).t_begin = 0;
    end

    intervals(idx).t_end = intervals(idx).t_end + 0.1;
    if intervals(idx).t_end > max_size
        intervals(idx).t_end = max_size;
    end
end

outervals = MergeOverlapingIntervals(intervals);

end
