function PlotModel(model, evaluation_result, plot_requirement, plot_labels)
%% Parameter checking
if class(model) ~= "BreachSimulinkSystem"
    error("The parameter 'model' must have type 'BreachSimulinkSystem'!");
end
if class(evaluation_result) ~= "BreachRequirement"
    error("The parameter 'evaluation_result' must have type 'BreachRequirement'!");
end
if class(plot_requirement) ~= "BreachRequirement"
    error("The parameter 'plot_requirement' must have type 'BreachRequirement'!");
end
if class(plot_labels) ~= "cell"
    error("The parameter 'plot_labels' must have type 'cell' array!");
end


%% Simulate each trace of the given evaluation_result with the given model and plot the diagnostic
[trace_intervals, unique_intervals] = FindExplanatoryIntervals(evaluation_result, @IsCounterExample);
unique_trace_indexes = FindUniqueTraces(trace_intervals, unique_intervals);

for trace_idx = 1:numel(unique_trace_indexes)
    fprintf('Example %d/%d\n', trace_idx, numel(unique_trace_indexes));

    trace_system = BuildTraceSystem(evaluation_result, trace_intervals, unique_trace_indexes(trace_idx));
    model.SetInputGen(trace_system);
    model.Sim();
    model.PlotSignals(plot_labels);

    plot_requirement.Eval(model);
    plot_requirement.PlotDiagnostics();

    if trace_idx < numel(unique_trace_indexes)
        input('Press ENTER to continue to the next example!');
        close all;
    end
end

end
