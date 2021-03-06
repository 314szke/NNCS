function tests = PrepareTrainingDataTest
    tests = functiontests(localfunctions);
end

function testWrongInputType(testCase)
    data = 0;
    options = struct();
    testCase.verifyError(@()PrepareTrainingData(data, options), "PrepareTrainingData:TypeError");
end

function testEmptyInput(testCase)
    data = struct();
    options = struct();
    testCase.verifyError(@()PrepareTrainingData(data, options), "PrepareTrainingData:InvalidInput");
end

function testWithOneTrace(testCase)
    data.REF = {[7 7 7]};
    data.U = {[4 5 6]};
    data.Y = {[1 2 3]};
    data.weights = {[1 2 3]};

    options.input_dimension = 6;
    options.trimming_enabled = 0;
    options.trim_distance_criteria = 0;
    options.trim_allowed_repetition = 0;

    [in, out, error_weights, trace_end_indices] = PrepareTrainingData(data, options);

    expected_in = [[7 7 7]; [0 7 7]; [0 0 7]; [1 2 3]; [0 1 2]; [0 0 1]];
    expected_out = [4 5 6];
    expected_weights = [1 2 3];
    expected_indices = 3;

    verifyEqual(testCase, in, expected_in);
    verifyEqual(testCase, out, expected_out);
    verifyEqual(testCase, error_weights, expected_weights);
    verifyEqual(testCase, trace_end_indices, expected_indices);
end

function testWithMultipleTraces(testCase)
    data.REF = {[7 7 7]; [8 8 9 9]};
    data.U = {[4 5 6]; [7 8 10 12]};
    data.Y = {[1 2 3]; [6 7 8 9]};
    data.weights = {[1 2 3]; [0 0 1 1]};

    options.input_dimension = 4;
    options.trimming_enabled = 0;
    options.trim_distance_criteria = 0;
    options.trim_allowed_repetition = 0;

    [in, out, error_weights, trace_end_indices] = PrepareTrainingData(data, options);

    expected_in = [[7 7 7 8 8 9 9]; [0 7 7 0 8 8 9]; [1 2 3 6 7 8 9]; [0 1 2 0 6 7 8]];
    expected_out = [4 5 6 7 8 10 12];
    expected_weights = [1 2 3 0 0 1 1];
    expected_indices = [3 7];

    verifyEqual(testCase, in, expected_in);
    verifyEqual(testCase, out, expected_out);
    verifyEqual(testCase, error_weights, expected_weights);
    verifyEqual(testCase, trace_end_indices, expected_indices);
end

function testWithTrimmingEnabled(testCase)
    data.REF = {[0 0 0 0 1 1 1 1]; [2 2 2 2 2 8 8 8 8 8]};
    data.U = {[5 5 5 5 6 6 6 6]; [3 3 3 3 3 7 7 7 7 7]};
    data.Y = {[1 1.1 1.3 2 2 2 2 2]; [4 4 4 5 5.5 5.6 5.65 6 7 8]};
    data.weights = {[7 0 1 4 3 5 7 2]; [0 0 1 1 2 1 1 0 0 0]};

    options.input_dimension = 4;
    options.trimming_enabled = 1;
    options.trim_distance_criteria = 0.1;
    options.trim_allowed_repetition = 1;

    [in, out, error_weights, trace_end_indices] = PrepareTrainingData(data, options);

    expected_in = [[0 0 0 0 1 1 1 2 2 2 2 2 8 8 8 8 8]; [0 0 0 0 0 1 1 0 2 2 2 2 2 8 8 8 8]; [1 1.1 1.3 2 2 2 2 4 4 4 5 5.5 5.6 5.65 6 7 8]; [0 1 1.1 1.3 2 2 2 0 4 4 4 5 5.5 5.6 5.65 6 7]];
    expected_out = [5 5 5 5 6 6 6 3 3 3 3 3 7 7 7 7 7];
    expected_weights = [7 0 1 4 3 5 7 0 0 1 1 2 1 1 0 0 0];
    expected_indices = [7 17];

    verifyEqual(testCase, in, expected_in);
    verifyEqual(testCase, out, expected_out);
    verifyEqual(testCase, error_weights, expected_weights);
    verifyEqual(testCase, trace_end_indices, expected_indices);
end
