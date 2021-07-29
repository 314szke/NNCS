function tests = TrimTrainingDataTest
    tests = functiontests(localfunctions);
end

function testInvalidInputType(testCase)
    in = struct();
    out = 'double';
    error_weights = [];
    trace_end_indices = [];
    epsilon = 1;
    repetition = 1;
    testCase.verifyError(@()TrimTrainingData(in, out, error_weights, trace_end_indices, epsilon, repetition), 'TrimTrainingData:TypeError');
end

function testEmptyInput(testCase)
    in = [];
    out = [];
    error_weights = [];
    trace_end_indices = [];
    epsilon = 0.1;
    repetition = 2;
    testCase.verifyError(@()TrimTrainingData(in, out, error_weights, trace_end_indices, epsilon, repetition), 'TrimTrainingData:EmptyInput');
end

function testDifferentDimensions(testCase)
    in = [[1 2]; [3 4]];
    out = [3; 4; 5];
    error_weights = [];
    trace_end_indices = [];
    epsilon = 0.1;
    repetition = 3;
    testCase.verifyError(@()TrimTrainingData(in, out, error_weights, trace_end_indices, epsilon, repetition), 'TrimTrainingData:InputMismatch');
end

function testInvalidErrorWeights(testCase)
    in = [[1 2]; [3 4]; [5 6];];
    out = [1 2];
    error_weights = struct();
    trace_end_indices = [];
    epsilon = 0.4;
    repetition = 1;
    testCase.verifyError(@()TrimTrainingData(in, out, error_weights, trace_end_indices, epsilon, repetition), 'TrimTrainingData:TypeError');
end

function testInvalidTraceEndIndices(testCase)
    in = [[1 2]; [3 4]; [5 6];];
    out = [1 2];
    error_weights = [];
    trace_end_indices = struct();
    epsilon = 0.4;
    repetition = 1;
    testCase.verifyError(@()TrimTrainingData(in, out, error_weights, trace_end_indices, epsilon, repetition), 'TrimTrainingData:TypeError');
end

function testInvalidEpsilon(testCase)
    in = 1;
    out = 1;
    error_weights = [];
    trace_end_indices = [];
    epsilon = -0.1;
    repetition = 6;
    testCase.verifyError(@()TrimTrainingData(in, out, error_weights, trace_end_indices, epsilon, repetition), 'TrimTrainingData:InvalidInput');
end

function testInvalidRepetition(testCase)
    in = 1;
    out = 1;
    error_weights = [];
    trace_end_indices = [];
    epsilon = 0.1;
    repetition = -6;
    testCase.verifyError(@()TrimTrainingData(in, out, error_weights, trace_end_indices, epsilon, repetition), 'TrimTrainingData:InvalidInput');
end

function testNoTrimming(testCase)
    in = [[1 2]; [3 4]; [5 6]; [7 8]];
    out = [1 2];
    error_weights = [3 4];
    trace_end_indices = 2;
    epsilon = 0.5;
    repetition = 0;

    [new_in, new_out, new_weights, new_indices] = TrimTrainingData(in, out, error_weights, trace_end_indices, epsilon, repetition);
    verifyEqual(testCase, new_in, in);
    verifyEqual(testCase, new_out, out);
    verifyEqual(testCase, new_weights, error_weights);
    verifyEqual(testCase, new_indices, trace_end_indices);
end

function testOneRepetition(testCase)
    in = [[1 1.25 3]; [1 1.11 4]; [1 1.2 5]];
    out = [11 12 13];
    error_weights = [0 0.5 0];
    trace_end_indices = [1 3];
    epsilon = 0.3;
    repetition = 0;

    [new_in, new_out, new_weights, new_indices] = TrimTrainingData(in, out, error_weights, trace_end_indices, epsilon, repetition);
    expected_in = [[1 3]; [1 4]; [1 5]];
    expected_out = [11 13];
    expected_weights = [0 0];
    expected_indices = [1 2];

    verifyEqual(testCase, new_in, expected_in);
    verifyEqual(testCase, new_out, expected_out);
    verifyEqual(testCase, new_weights, expected_weights);
    verifyEqual(testCase, new_indices, expected_indices);
end

function testMultipleRepetition(testCase)
    in = [[0.5 0.5 0.5 0.5 0.9 0.9]; [0 0.1 0.15 0.5 0.6 0.7]];
    out = [1; 2; 3; 4; 5; 6];
    error_weights = [0 2 4 8 16 32];
    trace_end_indices = [3 6];
    epsilon = 0.25;
    repetition = 0;

    [new_in, new_out, new_weights, new_indices] = TrimTrainingData(in, out, error_weights, trace_end_indices, epsilon, repetition);
    expected_in = [[0.5 0.5 0.9]; [0 0.5 0.6]];
    expected_out = [1 4 5];
    expected_weights = [0 8 16];
    expected_indices = [1 3];

    verifyEqual(testCase, new_in, expected_in);
    verifyEqual(testCase, new_out, expected_out);
    verifyEqual(testCase, new_weights, expected_weights);
    verifyEqual(testCase, new_indices, expected_indices);
end

function testSlowProgression(testCase)
    in = [[0.4 0.4 0.4 0.4 0.4 0.4 0.4]; [0.1 0.15 0.2 0.25 0.3 0.35 0.4]];
    out = [1; 2; 3; 4; 5; 6; 7];
    error_weights = [1 2 3 4 5 6 7];
    trace_end_indices = [2 5 7];
    epsilon = 0.1;
    repetition = 0;

    [new_in, new_out, new_weights, new_indices] = TrimTrainingData(in, out, error_weights, trace_end_indices, epsilon, repetition);
    expected_in = [[0.4 0.4 0.4]; [0.1 0.25 0.4]];
    expected_out = [1 4 7];
    expected_weights = [1 4 7];
    expected_indices = [1 2 3];

    verifyEqual(testCase, new_in, expected_in);
    verifyEqual(testCase, new_out, expected_out);
    verifyEqual(testCase, new_weights, expected_weights);
    verifyEqual(testCase, new_indices, expected_indices);
end

function testWithAllowedRepetition(testCase)
    in = [[0.2 0.21 0.212 0.213]; [0.5 0.51 0.512 0.513]];
    out = [1; 2; 3; 4];
    error_weights = [8 9 10 11];
    trace_end_indices = 4;
    epsilon = 0.2;
    repetition = 2;

    [new_in, new_out, new_weights, new_indices] = TrimTrainingData(in, out, error_weights, trace_end_indices, epsilon, repetition);
    expected_in = [[0.2 0.21 0.212]; [0.5 0.51 0.512]];
    expected_out = [1 2 3];
    expected_weights = [8 9 10];
    expected_indices = 3;

    verifyEqual(testCase, new_in, expected_in);
    verifyEqual(testCase, new_out, expected_out);
    verifyEqual(testCase, new_weights, expected_weights);
    verifyEqual(testCase, new_indices, expected_indices);
end
