function error_weights = GenerateErrorWeights(time_values, options)
%% Validate input arguments
if isa(time_values, 'double') == 0
    error("GenerateErrorWeights:TypeError", "The input argument 'time_values' must have type 'double' array!");
end
if isstruct(options) == 0
    error("GenerateErrorWeights:TypeError", "The input argument 'options' must have type 'struct'!");
end


%% Calculate the error weights using the given function
if isempty(time_values)
    error_weights = [];
    return;
end

if strcmp(options.function, 'gaussian')
    a = options.max_weight;
    b = options.max_position;
    c = options.width;
    error_weights = arrayfun(@(x) gaussian(x, a, b, c), time_values);
    error_weights = arrayfun(@(x) x + options.min_weight, error_weights);
elseif strcmp(options.function, 'no_weight')
    error_weights = arrayfun(@(x) 1, time_values);
end

if options.plot
    figure;
    plot(time_values, error_weights);
    title('Error weights applied to the MSE loss function');
end

end


function x = gaussian(x, a, b, c)
    x = a .* exp(((x-b) .^ 2) / (-2 .* (c .^ 2)));
    x = round(x, 4);
end
