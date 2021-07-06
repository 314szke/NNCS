function [model, requirement, num_cex] = EvaluateModel(model, trace_system, requirement)
%% Validate input arguments
if isa(model, 'BreachSimulinkSystem') == 0
    error("EvaluateModel:TypeError", "The parameter 'model' must have type 'BreachSimulinkSystem'!");
end
if isa(trace_system, 'BreachTraceSystem') == 0
    error("EvaluateModel:TypeError", "The parameter 'trace_system' must have type 'BreachTraceSystem'!");
end
if isa(requirement, 'BreachRequirement') == 0
    error("EvaluateModel:TypeError", "The parameter 'requirement' must have type 'BreachRequirement'!");
end


%% Simulate the model and evaluate the performance on the given requirement
model.SetInputGen(trace_system);
model.Sim();

requirement.Eval(model);
summary = requirement.GetSummary();
num_cex = summary.num_traces_violations;

if num_cex ~= 0
    fprintf('The model violated the STL requirement on %d/%d input traces.\n', num_cex, summary.num_traces_evaluated);
    [~, unique_intervals] = FindExplanatoryIntervals(requirement, @IsCounterExample);

    fprintf('Number of unique violating intervals found: %d.\n', length(unique_intervals.intervals));
    for idx = 1:numel(unique_intervals.intervals)
        fprintf('Interval %d at [%f, %f].\n', idx, unique_intervals.intervals(idx).t_begin, unique_intervals.intervals(idx).t_end);
    end
end

end