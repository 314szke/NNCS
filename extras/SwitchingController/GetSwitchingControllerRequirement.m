function requirement = GetSwitchingControllerRequirement(stl_formula, simulation, options)
%% Validate input arguments
if isa(stl_formula, 'STL_Formula') == 0
    error("The parameter 'stl_formula' must have type 'STL_Formula'!");
end
if isstruct(options) == 0
    error("The parameter 'simulation' must have type 'struct'!");
end


%% Create the BreachRequirement
requirement = BreachRequirement(stl_formula);

% The length of a constant segment minus the window size of the error validation
interval_length = round(simulation.time_window / options.segments) - 3;
requirement.SetParam('interval_length', interval_length);

% The STL formula is evaluated until the last time point minus the formula horizon
sim_time = simulation.time_window - (interval_length + 3);
requirement.SetParam('sim_time', simulation.time_window);
requirement.SetParam('time_step', simulation.time_step);

% Step size determines how big of a jump in the reference is considered as a step
requirement.SetParam('step_size', options.step_size);
requirement.SetParam('max_error', options.max_error);

end