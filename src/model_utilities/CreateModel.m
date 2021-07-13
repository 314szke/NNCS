function model = CreateModel(model_path, simulation)
if isa(model_path, 'char') == 0
    error("CreateModel:TypeError", "The parameter 'model_path' must have type 'char' array!");
end
if isstruct(simulation) == 0
    error("CreateModel:TypeError", "The parameter 'simulation' must have type 'struct'!");
end

[~, model_name, ~] = fileparts(model_path);
model = BreachSimulinkSystem(model_name, 'all');
model.SetTime(0:simulation.time_step:simulation.time_window);
load_system(strcat(model_name, '_breach'));
set_param(strcat(model_name, '_breach'), 'FastRestart', 'on');

end