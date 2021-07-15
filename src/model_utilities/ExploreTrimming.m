function ExploreTrimming(model, num_traces, input_dimension, trimming_options)
%% Validate input arguments
if isa(model, 'BreachSimulinkSystem') == 0
    error("ExploreTrimming:TypeError", "The parameter 'model' must have type 'BreachSimulinkSystem'!");
end
if isa(num_traces, 'double') == 0
    error("ExploreTrimming:TypeError", "The parameter 'num_traces' must have type 'double'!");
end
if isa(input_dimension, 'double') == 0
    error("ExploreTrimming:TypeError", "The parameter 'input_dimension' must have type 'double'!");
end
if isstruct(trimming_options) == 0
    error("ExploreTrimming:TypeError", "The parameter 'trimming_options' must have type 'struct'!");
end


%% Display the control action before and after trimming to determine the trimming coefficients
time_values = model.GetTime();
for trace_idx = 1:num_traces
    figure;
    REF = model.GetSignalValues({'ref'}, trace_idx);
    Y = model.GetSignalValues({'y'}, trace_idx);
    plot(time_values, REF, time_values, Y);

    figure;
    U = model.GetSignalValues({'u'}, trace_idx);
    plot(time_values, U);

    [in, out] = RestructureTrainingData(REF, U, Y, input_dimension);
    [~, out] = TrimTrainingData(in, out, trimming_options.max_distance_criteria, trimming_options.allowed_repetition);

    trimmed_time = zeros(1, length(out));
    out_idx = 1;
    for time_idx = 1:length(time_values)
        if U(time_idx) == out(out_idx)
            trimmed_time(out_idx) = time_values(time_idx);
            out_idx = out_idx + 1;
            if out_idx > length(out)
                break;
            end
        end
    end

    figure;
    scatter(trimmed_time, out);

    if trace_idx < num_traces
        answer = input('Press ENTER to continue to the next example or type STOP to stop displaying plots!', 's');
        close all;
        if strcmp(answer, 'STOP')
            return;
        end
    end
end

end
