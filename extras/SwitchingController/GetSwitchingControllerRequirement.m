function requirement = GetSwitchingControllerRequirement(stl_formula, simulation, options)
if class(stl_formula) ~= "STL_Formula"
    error("The parameter 'stl_formula' must have type 'STL_Formula'!");
end
if class(simulation) ~= "struct"
    error("The parameter 'simulation' must have type 'struct'!");
end

requirement = BreachRequirement(stl_formula);
requirement.SetParam('sim_time', simulation.time_window);
requirement.SetParam('time_step', simulation.time_step);
% The length of a constant segment minus the window size of the error validation
interval_length = round(simulation.time_window / options.segments) - 3;
requirement.SetParam('interval_length', interval_length);
requirement.SetParam('step_size', options.step_size);
requirement.SetParam('max_error', options.max_error);
end