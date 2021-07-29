function outervals = MergeOverlapingIntervals(intervals)
%% Validate input arguments
if isempty(intervals)
    outervals = [];
    return;
end
if isstruct(intervals) == 0
    error("MergeOverlapingIntervals:TypeError", "The input argument 'intervals' must have type 'struct' array!");
end
fields = fieldnames(intervals);
if strcmp(fields{1}, 't_begin') == 0
    error("MergeOverlapingIntervals:TypeError", "The input argument 'intervals' must have a field named 't_begin'!");
end
if strcmp(fields{2}, 't_end') == 0
    error("MergeOverlapingIntervals:TypeError", "The input argument 'intervals' must have a field named 't_end'!");
end


%% Sort by t_begin
table = struct2table(intervals);
unique_sorted_table = unique(table, 'rows', 'sort');
sorted_intervals = table2struct(unique_sorted_table);
% table2struct converts an array with n structs to nx1 shape, where 1xn is expected
sorted_intervals = reshape(sorted_intervals, [1, numel(sorted_intervals)]);


%% Merge overlaping intervals
last_idx = 1;
for idx = 2:numel(sorted_intervals)
    % The next interval starts earlier than current last interval's end
    if sorted_intervals(last_idx).t_end >= sorted_intervals(idx).t_begin
        % The next interval ends later than the current last interval's end
        if sorted_intervals(last_idx).t_end < sorted_intervals(idx).t_end
            sorted_intervals(last_idx).t_end = sorted_intervals(idx).t_end;
        end
        % Invalidate merged interval
        sorted_intervals(idx).t_begin = -1;
    else
        % The interval was not merged, so it is the new last interval
        last_idx = idx;
    end
end

% Collect intervals which are not invalid
outervals = sorted_intervals([sorted_intervals.t_begin] ~= -1);

end