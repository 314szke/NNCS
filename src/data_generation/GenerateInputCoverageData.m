function [data, num_traces] = GenerateInputCoverageData(model, options)
%% Validate input arguments
if isa(model, 'BreachSimulinkSystem') == 0
    error("The parameter 'model' must have type 'BreachSimulinkSystem'!");
end
if isstruct(options) == 0
    error("The parameter 'options' must have type 'struct'!");
end
fields = fieldnames(options);
if strcmp(fields{1}, 'min') == 0
    error("The parameter 'options' must have a field named 'min'!");
end
if strcmp(fields{2}, 'max') == 0
    error("The parameter 'options' must have a field named 'max'!");
end
if strcmp(fields{3}, 'cell_size') == 0
    error("The parameter 'options' must have a field named 'cell_size'!");
end
if strcmp(fields{4}, 'dimension') == 0
    error("The parameter 'options' must have a field named 'dimension'!");
end
if strcmp(fields{5}, 'coverage_point_type') == 0
    error("The parameter 'options' must have a field named 'coverage_point_type'!");
end
if strcmp(fields{6}, 'plot') == 0
    error("The parameter 'options' must have a field named 'plot'!");
end


%% Create input generator with fixed number of control points and uniform length of intervals
input_names = model.expand_signal_name('model_input');
input_generator = fixed_cp_signal_gen(input_names, options.dimension);
model.SetInputGen(input_generator);
input_parameters = model.GetInputParamList();

% Shorten range to pick each lower left corner except in the top row and rightmost column
cell_range = [options.min (options.max - options.cell_size)];
model.SetParamRanges(input_parameters, cell_range);

% Generate coverage points in each lower left corner
input_range = options.max - options.min;
num_cells_per_dimension = input_range / options.cell_size;
num_cells = num_cells_per_dimension ^ options.dimension;
model.GridSample(num_cells_per_dimension);
lower_left_corners = model.GetParam(input_parameters);

% Position corners according to coverage type
if options.coverage_point_type == 'random'
    % Generate a random offset for each value in each cell in each dimension scaled with the cell size
    random_offset = rand(options.dimension, num_cells) * options.cell_size;
    coverage_points = lower_left_corners + random_offset;
elseif options.coverage_point_type == 'center'
    % Position lower left corners to the center
    coverage_points = lower_left_corners + (options.cell_size / 2);
else
    error('Undefined coverage point type %s!\n', options.coverage_point_type);
end

% Set back the input range to the complete range
input_range = [options.min options.max];
model.SetParamRanges(input_parameters, input_range);
model.SetParam(input_parameters, coverage_points);


%% Simulate the model and extract the trace data
model.Sim();
data = CreateDataWithCompleteTraces(model, num_cells);
num_traces = num_cells;


%% Plot result
if options.plot
    BreachSamplesPlot(model);
    plot_title = sprintf('Coverage points with %s position and %0.1f cell size', options.coverage_point_type, options.cell_size);
    title(plot_title);
    set(gca, 'XLim', input_range, 'YLim', input_range);
end

end