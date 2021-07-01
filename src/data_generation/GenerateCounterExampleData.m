function [complete_new_data, shortened_new_data, num_cex, cex_traces] = GenerateCounterExampleData(nn_model, nominal_model, plot_model, nn_requirement, nominal_requirement, plot_labels, options)
%% Parameter checking
if class(nn_model) ~= "BreachSimulinkSystem"
    error("The parameter 'nn_model' must have type 'BreachSimulinkSystem'!");
end
if class(nominal_model) ~= "BreachSimulinkSystem"
    error("The parameter 'nominal_model' must have type 'BreachSimulinkSystem'!");
end
if class(plot_model) ~= "BreachSimulinkSystem"
    error("The parameter 'plot_model' must have type 'BreachSimulinkSystem'!");
end
if class(nn_requirement) ~= "BreachRequirement"
    error("The parameter 'nn_requirement' must have type 'BreachRequirement'!");
end
if class(nominal_requirement) ~= "BreachRequirement"
    error("The parameter 'nominal_requirement' must have type 'BreachRequirement'!");
end


%% Falsify random input traces for the nerual network controller
f_problem = FalsificationProblem(nn_model, nn_requirement);
f_problem.freq_update = 25;
f_problem.StopAtFalse = false;
f_problem.max_obj_eval = options.num_falsification_traces;
f_problem.setup_quasi_random('quasi_rand_seed', 1976, 'num_quasi_rand_samples', options.num_falsification_traces);
f_problem.solve();

falsification_result = f_problem.GetFalse();

% Initialize return variables to empty
complete_new_data = {};
shortened_new_data = {};
num_cex = 0;
cex_traces = [];

if isempty(falsification_result)
   return;
end

if options.plot == 1
    P = BreachSamplesPlot(falsification_result);
    P.set_y_axis('ref_u1')
    P.set_x_axis('ref_u0')
end


%% Diagnose counter-examples
[cex_intervals, unique_cex_intervals] = FindExplanatoryIntervals(falsification_result, @IsCounterExample);
unique_cex_trace_indexes = FindUniqueTraces(cex_intervals, unique_cex_intervals);
num_violations = length(unique_cex_intervals.intervals);

num_cex = length(unique_cex_trace_indexes);
if num_cex > options.cex_threshold
    fprintf('Number of counter-examples used out of %d is limited to the threshold %d.\n', num_cex, options.cex_threshold);
    num_cex = options.cex_threshold;
    unique_cex_trace_indexes = unique_cex_trace_indexes(1:num_cex);
end

cex_traces = BuildTraceSystem(falsification_result, cex_intervals, unique_cex_trace_indexes);


%% Simulate the nominal controller to obtain the correct control values
[nominal_model, evaluation_result, nominal_cex] = EvaluateModel(nominal_model, cex_traces, nominal_requirement);
if nominal_cex ~= 0
    fprintf('ERROR: The nominal controller could not correct the behaviour of the NN controller!\n');
    if options.plot == 1
        PlotModel(plot_model, evaluation_result, nominal_requirement, plot_labels);
    end
end


%% Create new data
if options.use_positive_diagnosis == 1
    [satisfaction_intervals, unique_intervals] = FindExplanatoryIntervals(evaluation_result, @IsValidExample);
    unique_trace_indexes = FindUniqueTraces(satisfaction_intervals, unique_intervals);
    result = evaluation_result;
    trace_intervals = satisfaction_intervals;
else
    result = falsification_result;
    trace_intervals = cex_intervals;
    unique_trace_indexes = unique_cex_trace_indexes;
end

complete_new_data = CreateDataWithCompleteTraces(nominal_model, num_cex);
shortened_new_data = CreateDataWithShortenedTraces(nominal_model, result, trace_intervals, unique_trace_indexes, options.window_size);

end
