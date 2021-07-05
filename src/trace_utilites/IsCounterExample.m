function value = IsCounterExample(violations, trace_idx)
if isa(violations, 'double') == 0
    error("IsCounterExample:TypeError", "The parameter 'violations' must have type 'double' array!");
end
if isa(trace_idx, 'double') == 0
    error("IsCounterExample:TypeError", "The parameter 'trace_idx' must have type 'double'!");
end

value = (violations(trace_idx) ~= 0);
end