function model = CreateModel(model_path)
if class(model_path) ~= "char"
    error("The parameter 'model_path' must have type 'char'!");
end

[~, model_name, ~] = fileparts(model_path);
model = BreachSimulinkSystem(model_name, {});
load_system(strcat(model_name, '_breach'));
set_param(strcat(model_name, '_breach'), 'FastRestart', 'on');

end