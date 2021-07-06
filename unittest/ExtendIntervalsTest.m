function tests = ExtendIntervalsTest
    tests = functiontests(localfunctions);
end

function testWrongInputOrder(testCase)
    intervals.t_begin = 1;
    intervals.t_end = 2;
    window_size = 5;
    max_size = 10;
    testCase.verifyError(@()ExtendIntervals(window_size, intervals, max_size), "ExtendIntervals:TypeError");
end

function testEmptyInput(testCase)
    intervals = [];
    window_size = 3;
    max_size = 7;
    outervals = ExtendIntervals(intervals, window_size, max_size);
    verifyEqual(testCase, outervals, []);
end

function testOneInterval(testCase)
    intervals.t_begin = 3;
    intervals.t_end = 6;
    window_size = 2;
    max_size = 9;

    outervals = ExtendIntervals(intervals, window_size, max_size);
    expected.t_begin = 1;
    expected.t_end = 6.1;
    verifyEqual(testCase, outervals, expected);
end

function testMultipleIntervals(testCase)
    t1.t_begin = 1;
    t1.t_end = 2;
    t2.t_begin = 5;
    t2.t_end = 7;
    t3.t_begin = 8;
    t3.t_end = 10;
    intervals = [t1 t2 t3];
    window_size = 1;
    max_size = 10;

    outervals = ExtendIntervals(intervals, window_size, max_size);
    t4.t_begin = 0;
    t4.t_end = 2.1;
    t5.t_begin = 4;
    t5.t_end = 10;
    expected = [t4 t5];
    verifyEqual(testCase, outervals, expected);
end

function testTimeBoundaries(testCase)
    t1.t_begin = 0;
    t1.t_end = 4;
    t2.t_begin = 10;
    t2.t_end = 20;
    intervals = [t1 t2];
    window_size = 6;
    max_size = 20;

    outervals = ExtendIntervals(intervals, window_size, max_size);
    expected.t_begin = 0;
    expected.t_end = 20;
    verifyEqual(testCase, outervals, expected);
end
