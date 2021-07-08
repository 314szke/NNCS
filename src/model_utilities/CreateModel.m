function model = CreateModel(model_path)
if isa(model_path, 'char') == 0
    error("CreateModel:TypeError", "The parameter 'model_path' must have type 'char' array!");
end

[~, model_name, ~] = fileparts(model_path);
model = BreachSimulinkSystem(model_name, 'all');
load_system(strcat(model_name, '_breach'));
set_param(strcat(model_name, '_breach'), 'FastRestart', 'on');

end