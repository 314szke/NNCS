function value = IsCounterExample(violations, trace_idx)
if class(violations) ~= 'double'
    error("The parameter 'violations' must have type 'double' array!");
end
if class(trace_idx) ~= 'double'
    error("The parameter 'trace_idx' must have type 'double'!");
end

value = (violations(trace_idx) ~= 0);
end