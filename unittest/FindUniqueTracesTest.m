function tests = FindUniqueTracesTest
    tests = functiontests(localfunctions);
end

function testWrongInputOrder(testCase)
    unique_intervals.intervals = [];
    trace_intervals{1} = [];
    testCase.verifyError(@()FindUniqueTraces(unique_intervals, trace_intervals), "FindUniqueTraces:TypeError");
end

function testEmptyInput(testCase)
    trace_intervals = {};
    unique_intervals.intervals = struct();
    unique_trace_indexes = FindUniqueTraces(trace_intervals, unique_intervals);
    verifyEqual(testCase, unique_trace_indexes, []);
end

function testWithEmptyInterval(testCase)
    t1.t_begin = 3;
    t1.t_end = 4;
    % trace_intervals{1} is empty
    trace_intervals{2} = t1;
    unique_intervals.intervals = t1;
    unique_trace_indexes = FindUniqueTraces(trace_intervals, unique_intervals);
    verifyEqual(testCase, unique_trace_indexes, 2);
end

function testWithMultipleIntervalsPerTrace(testCase)
    t1.t_begin = 1;
    t1.t_end = 2;
    t2.t_begin = 7;
    t2.t_end = 12;
    t3.t_begin = 9;
    t3.t_end = 10;
    t4.t_begin = 14;
    t4.t_end = 16;
    t5.t_begin = 21;
    t5.t_end = 26;

    trace_intervals{1} = [t2 t4];
    trace_intervals{2} = [t1 t3 t5];
    trace_intervals{3} = [t4 t5];
    unique_intervals.intervals = [t1 t4 t5];
    unique_trace_indexes = FindUniqueTraces(trace_intervals, unique_intervals);
    verifyEqual(testCase, unique_trace_indexes, [1 2]);
end

function testNoMatch(testCase)
    t1.t_begin = 0;
    t1.t_end = 2;
    t2.t_begin = 6;
    t2.t_end = 8;

    trace_intervals{1} = t1;
    unique_intervals.intervals = t2;
    unique_trace_indexes = FindUniqueTraces(trace_intervals, unique_intervals);
    verifyEqual(testCase, unique_trace_indexes, []);
end
