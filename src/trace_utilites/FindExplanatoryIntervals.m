function [intervals_per_trace, unique_intervals] = FindExplanatoryIntervals(evaluation_result, criteria)
%% Parameter checking
if class(evaluation_result) ~= "BreachRequirement"
    error("The parameter 'evaluation_result' must have type 'BreachRequirement'!");
end
if class(criteria) ~= "function_handle"
    error("The parameter 'criteria' must have type 'function_handle'!");
end


%% Find all intervals of interest for STL satisfaction or violation
evaluation_summary = evaluation_result.GetSummary();
violations = evaluation_summary.num_violations_per_trace;
num_traces = evaluation_summary.num_traces_evaluated;

predicates = STL_ExtractPredicates(evaluation_result.req_monitors{1}.formula);
intervals_per_trace = {};
all_intervals = [];

for trace_idx = 1:num_traces
    % Filter for traces with violations or satisfactions
    if criteria(violations, trace_idx) == 0
        continue;
    end

    implicants = evaluation_result.Explain(1, trace_idx);
    intervals = [];

    for predicate_idx = 1:numel(predicates)
        pred = predicates(predicate_idx);
        pred_name = get_id(pred);
        implicant_pred = implicants(pred_name);

        for interval_idx = 1:numel(implicant_pred.Intervals)
            % Rename begin to t_begin and end to t_end to allow sorting in MergeOverlapingIntervals
            time.t_begin = implicant_pred.Intervals(interval_idx).begin;
            time.t_end = implicant_pred.Intervals(interval_idx).end;
            intervals = [intervals; time];
        end
    end

    intervals = MergeOverlapingIntervals(intervals);
    intervals_per_trace{trace_idx} = intervals;
    all_intervals = [all_intervals; intervals];
end


%% Find unique intervals and count number of occurences
if isempty(all_intervals)
    unique_intervals = {};
else
    table = struct2table(all_intervals);
    [unique_table, ~, ic] = unique(table, 'rows', 'sort');
    unique_intervals.intervals = table2struct(unique_table);
    unique_intervals.occurrences = accumarray(ic, 1);
end

end
