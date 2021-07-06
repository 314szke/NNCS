function tests = ExtractIntervalValuesTest
    tests = functiontests(localfunctions);
end

function testWrongInputOrder(testCase)
    trace_values = [];
    time_values = [];
    intervals.t_begin = 0;
    intervals.t_end = 30;
    testCase.verifyError(@()ExtractIntervalValues(intervals, trace_values, time_values), "ExtractIntervalValues:TypeError");
end

function testEmptyInput(testCase)
    trace_values = [];
    time_values = [];
    intervals.t_begin = 0;
    intervals.t_end = 30;
    values = ExtractIntervalValues(trace_values, time_values, intervals);
    verifyEqual(testCase, values, []);
end

function testOneInterval(testCase)
    trace_values = [0 1 2 3 4 5 6 7 8 9];
    time_values = [0 1 2 3 4 5 6 7 8 9];
    intervals.t_begin = 2;
    intervals.t_end = 7;
    values = ExtractIntervalValues(trace_values, time_values, intervals);
    verifyEqual(testCase, values, [2 3 4 5 6 7]);
end

function testMultipleIntervals(testCase)
    trace_values = [0 1 2 3 4 5 6 7 8 9];
    time_values = [0 1 2 3 4 5 6 7 8 9];
    t1.t_begin = 1;
    t1.t_end = 2;
    t2.t_begin = 5;
    t2.t_end = 7;
    t3.t_begin = 8;
    t3.t_end = 9;
    intervals = [t1 t2 t3];

    values = ExtractIntervalValues(trace_values, time_values, intervals);
    verifyEqual(testCase, values, [1 2 5 6 7 8 9]);
end
