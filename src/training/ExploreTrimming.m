function ExploreTrimming(time_values, data, options)
%% Validate input arguments
if isa(time_values, 'double') == 0
    error("ExploreTrimming:TypeError", "The input argument 'time_values' must have type 'double' array!");
end
if isstruct(data) == 0
    error("ExploreTrimming:TypeError", "The input argument 'data' must have type 'struct'!");
end
if isstruct(options) == 0
    error("ExploreTrimming:TypeError", "The input argument 'options' must have type 'struct'!");
end


%% Display the control action before and after trimming to determine the trimming coefficients
for trace_idx = 1:length(data.REF)
    figure;
    plot(time_values, data.REF{trace_idx}, time_values, data.Y{trace_idx});

    figure;
    plot(time_values, data.U{trace_idx});

    [in, out] = RestructureTrainingData(data.REF{trace_idx}, data.U{trace_idx}, data.Y{trace_idx}, options.input_dimension);
    [~, out, ~, ~] = TrimTrainingData(in, out, out, out, options.trim_distance_criteria, options.trim_allowed_repetition);

    trimmed_time = zeros(1, length(out));
    out_idx = 1;
    U = data.U{trace_idx};
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

    if trace_idx < length(data.REF)
        answer = input('Press ENTER to continue to the next example or type STOP to stop displaying plots!', 's');
        close all;
        if strcmp(answer, 'STOP')
            return;
        end
    end
end

end
