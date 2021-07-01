function outervals = ExtendIntervals(intervals, window_size, max_size)
%% Parameter checking
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
if class(window_size) ~= 'double'
    error("The parameter 'window_size' must have type 'double'!");
end
if class(max_size) ~= 'double'
    error("The parameter 'max_size' must have type 'double'!");
end


%% Subtract from t_begin and add to t_end while keeping the time boundaries
for idx = 1:numel(intervals)
    intervals(idx).t_begin = intervals(idx).t_begin - window_size;
    if intervals(idx).t_begin < 0
        intervals(idx).t_begin = 0;
    end

    intervals(idx).t_end = intervals(idx).t_end + 0.01;
    if intervals(idx).t_end > max_size
        intervals(idx).t_end = max_size;
    end
end
outervals = MergeOverlapingIntervals(intervals);
end