function model = CreateSwitchingControllerNeuralModel(model_path, simulation, options)
%% Validate input arguments
if isa(model_path, 'char') == 0
    error("CreateSwitchingControllerNeuralModel:TypeError", "The input argument 'model_path' must have type 'char' array!");
end
if isstruct(simulation) == 0
    error("CreateSwitchingControllerNeuralModel:TypeError", "The input argument 'simulation' must have type 'struct'!");
end
if isstruct(options) == 0
    error("CreateSwitchingControllerNeuralModel:TypeError", "The input argument 'options' must have type 'struct'!");
end


%% Create model with input generator for falsification
model = CreateModel(model_path, simulation);

input_names = model.expand_signal_name('model_input');
input_generator = fixed_cp_signal_gen(input_names, options.dimension);
model.SetInputGen(input_generator);

input_parameters = model.GetInputParamList();
model.SetParamRanges(input_parameters, [options.min options.max]);

end
