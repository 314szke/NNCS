function model = CreateModel(model_path, simulation, model_options)
if isa(model_path, 'char') == 0
    error("CreateModel:TypeError", "The input argument 'model_path' must have type 'char' array!");
end
if isstruct(simulation) == 0
    error("CreateModel:TypeError", "The input argument 'simulation' must have type 'struct'!");
end
if isstruct(model_options) == 0
    error("CreateModel:TypeError", "The input argument 'model_options' must have type 'struct'!");
end

[~, model_name, ~] = fileparts(model_path);
model = BreachSimulinkSystem(model_name, {});
model.SetTime(simulation.time_values);

fields = fieldnames(model_options);
for idx = 1:length(fields)
    model.SetParam(fields{idx}, model_options.(fields{idx}));
end

load_system(strcat(model_name, '_breach'));
set_param(strcat(model_name, '_breach'), 'FastRestart', 'on');

end