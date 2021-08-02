function model = CreateModelWithFixedInputGenerator(model_path, simulation, coverage_options, model_options)
%% Validate input arguments
if isa(model_path, 'char') == 0
    error("CreateModelWithFixedInputGenerator:TypeError", "The input argument 'model_path' must have type 'char' array!");
end
if isstruct(simulation) == 0
    error("CreateModelWithFixedInputGenerator:TypeError", "The input argument 'simulation' must have type 'struct'!");
end
if isstruct(coverage_options) == 0
    error("CreateModelWithFixedInputGenerator:TypeError", "The input argument 'coverage_options' must have type 'struct'!");
end
if isstruct(model_options) == 0
    error("CreateModelWithFixedInputGenerator:TypeError", "The input argument 'model_options' must have type 'struct'!");
end


%% Create model with input generator for falsification
model = CreateModel(model_path, simulation, model_options);

input_names = model.expand_signal_name('model_input');
input_generator = fixed_cp_signal_gen(input_names, coverage_options.dimension);
model.SetInputGen(input_generator);

input_parameters = model.GetInputParamList();
model.SetParamRanges(input_parameters, [coverage_options.min coverage_options.max]);

end
