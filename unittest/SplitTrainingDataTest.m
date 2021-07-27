function tests = SplitTrainingDataTest
    tests = functiontests(localfunctions);
end

function setupOnce(testCase)
    % random generator seed for Matlab to fix randomness in unittests
    rng(4224);
end

function testInvalidInputType(testCase)
    trace_end_indices = [1 2];
    options = 10;
    testCase.verifyError(@()SplitTrainingData(trace_end_indices, options), 'SplitTrainingData:TypeError');

    trace_end_indices = 'string';
    options = struct();
    testCase.verifyError(@()SplitTrainingData(trace_end_indices, options), 'SplitTrainingData:TypeError');
end

function testInvalidInputRatios(testCase)
    trace_end_indices = [1 2];
    options.training_data_ratio = 0.8;
    options.validation_data_ratio = 0.2;
    options.test_data_ratio = 0.2;
    testCase.verifyError(@()SplitTrainingData(trace_end_indices, options), 'SplitTrainingData:InvalidInput');
end

function testEmptyInput(testCase)
    trace_end_indices = [];
    options.training_data_ratio = 0.4;
    options.validation_data_ratio = 0.2;
    options.test_data_ratio = 0.4;

    new_options = SplitTrainingData(trace_end_indices, options);

    verifyEqual(testCase, new_options.training_data_indices, []);
    verifyEqual(testCase, new_options.validation_data_indices, []);
    verifyEqual(testCase, new_options.test_data_indices, []);
end

function testWithOneTrace(testCase)
    trace_end_indices = 8;
    options.training_data_ratio = 0.7;
    options.validation_data_ratio = 0.1;
    options.test_data_ratio = 0.2;

    new_options = SplitTrainingData(trace_end_indices, options);

    verifyEqual(testCase, new_options.training_data_indices, [1 2 3 4 5 6 7 8]);
    verifyEqual(testCase, new_options.validation_data_indices, []);
    verifyEqual(testCase, new_options.test_data_indices, []);
end

function testWithMultipleTraces(testCase)
    trace_end_indices = [4 10 20 25 37 42 51 66 73 88 90];
    options.training_data_ratio = 0.5;
    options.validation_data_ratio = 0.2;
    options.test_data_ratio = 0.3;

    new_options = SplitTrainingData(trace_end_indices, options);
    expected_training = [5 6 7 8 9 10 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 43 44 45 46 47 48 49 50 51 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88];
    expected_validation = [1 2 3 4 89 90];
    expected_test = [11 12 13 14 15 16 17 18 19 20 38 39 40 41 42 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66];

    verifyEqual(testCase, new_options.training_data_indices, expected_training);
    verifyEqual(testCase, new_options.validation_data_indices, expected_validation);
    verifyEqual(testCase, new_options.test_data_indices, expected_test);
end
