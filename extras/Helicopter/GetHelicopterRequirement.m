function requirement = GetHelicopterRequirement(stl_formula, options)
%% Validate input arguments
if isa(stl_formula, 'STL_Formula') == 0
    error("GetHelicopterRequirement:TypeError", "The input argument 'stl_formula' must have type 'STL_Formula'!");
end
if isstruct(options) == 0
    error("GetHelicopterRequirement:TypeError", "The input argument 'options' must have type 'struct'!");
end


%% Create the BreachRequirement and set its parameters
requirement = BreachRequirement(stl_formula);
requirement.SetParam('sim_time', options.simulation_time);
requirement.SetParam('stable_window_size', options.stable_window_size);
requirement.SetParam('max_error', options.max_error);

end
