function outervals = MergeOverlapingIntervals(intervals)
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


%% Sort by t_begin
table = struct2table(intervals);
unique_sorted_table = unique(table, 'rows', 'sort');
sorted_intervals = table2struct(unique_sorted_table);


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
        % Continue to the next non-overlapping interval
        last_idx = idx + 1;
    end
end

% Collect intervals which are not invalid
outervals = sorted_intervals([sorted_intervals.t_begin] ~= -1);

end