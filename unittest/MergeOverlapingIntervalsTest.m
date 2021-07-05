function tests = MergeOverlapingIntervalsTest
    tests = functiontests(localfunctions);
end

function testEmptyInput(testCase)
    intervals = [];
    outervals = MergeOverlapingIntervals(intervals);
    verifyEqual(testCase, outervals, []);
end

function testInvalidType(testCase)
    intervals.new_attribute = 1;
    testCase.verifyError(@()MergeOverlapingIntervals(intervals), 'MergeOverlapingIntervals:TypeError');
end

function testOneInterval(testCase)
    intervals.t_begin = 1;
    intervals.t_end = 2;
    outervals = MergeOverlapingIntervals(intervals);
    verifyEqual(testCase, outervals, intervals);
end

function testTwoIntervalsNoMerge(testCase)
    t1.t_begin = 1;
    t1.t_end = 2;
    t2.t_begin = 5;
    t2.t_end = 8;
    intervals = [t1 t2];
    outervals = MergeOverlapingIntervals(intervals);
    verifyEqual(testCase, outervals, intervals);
end

function testTwoIntervalsMerged(testCase)
    t1.t_begin = 1;
    t1.t_end = 5;
    t2.t_begin = 4;
    t2.t_end = 8;
    intervals = [t1 t2];
    outervals = MergeOverlapingIntervals(intervals);

    t3.t_begin = 1;
    t3.t_end = 8;
    expected_output = t3;
    verifyEqual(testCase, outervals, expected_output);
end

function testIntervalDuringOtherInterval(testCase)
    t1.t_begin = 2;
    t1.t_end = 10;
    t2.t_begin = 3;
    t2.t_end = 7;
    intervals = [t1 t2];
    outervals = MergeOverlapingIntervals(intervals);

    expected_output.t_begin = 2;
    expected_output.t_end = 10;
    verifyEqual(testCase, outervals, expected_output);
end

function testNotSortedIntervals(testCase)
    t1.t_begin = 14;
    t1.t_end = 18;
    t2.t_begin = 1;
    t2.t_end = 15;
    intervals = [t1 t2];
    outervals = MergeOverlapingIntervals(intervals);

    expected_output.t_begin = 1;
    expected_output.t_end = 18;
    verifyEqual(testCase, outervals, expected_output);
end

function testIntervalsMeet(testCase)
    t1.t_begin = 4;
    t1.t_end = 6;
    t2.t_begin = 6;
    t2.t_end = 9;
    intervals = [t1 t2];
    outervals = MergeOverlapingIntervals(intervals);

    expected_output.t_begin = 4;
    expected_output.t_end = 9;
    verifyEqual(testCase, outervals, expected_output);
end

function testEqualIntervals(testCase)
    t1.t_begin = 0;
    t1.t_end = 5;
    t2.t_begin = 0;
    t2.t_end = 5;
    intervals = [t1 t2];
    outervals = MergeOverlapingIntervals(intervals);

    expected_output.t_begin = 0;
    expected_output.t_end = 5;
    verifyEqual(testCase, outervals, expected_output);
end

function testEqualBeginnings(testCase)
    t1.t_begin = 0;
    t1.t_end = 5;
    t2.t_begin = 0;
    t2.t_end = 8;
    intervals = [t1 t2];
    outervals = MergeOverlapingIntervals(intervals);

    expected_output.t_begin = 0;
    expected_output.t_end = 8;
    verifyEqual(testCase, outervals, expected_output);
end

function testMultipleIntervals(testCase)
    t1.t_begin = 0;
    t1.t_end = 20;
    t2.t_begin = 4;
    t2.t_end = 11;
    t3.t_begin = 5;
    t3.t_end = 7;
    t4.t_begin = 25;
    t4.t_end = 30;
    t5.t_begin = 26;
    t5.t_end = 32;
    t6.t_begin = 27;
    t6.t_end = 29;
    intervals = [t1 t2 t3 t4 t5 t6];
    outervals = MergeOverlapingIntervals(intervals);

    t7.t_begin = 0;
    t7.t_end = 20;
    t8.t_begin = 25;
    t8.t_end = 32;
    expected_output = [t7 t8];
    verifyEqual(testCase, outervals, expected_output);
end
