function tests = GenerateErrorWeightsTest
    tests = functiontests(localfunctions);
end

function testInvalidInputType(testCase)
    time_values = {};
    options = struct();
    testCase.verifyError(@()GenerateErrorWeights(time_values, options), 'GenerateErrorWeights:TypeError');

    time_values = [1 2];
    options = 'string';
    testCase.verifyError(@()GenerateErrorWeights(time_values, options), 'GenerateErrorWeights:TypeError');
end

function testEmptyInput(testCase)
    time_values = [];
    options = struct();

    error_weights = GenerateErrorWeights(time_values, options);
    expected_weights = [];
    verifyEqual(testCase, error_weights, expected_weights);
end

function testGaussianFunction(testCase)
    time_values = [0 1 2 3 4 5 6 7 8 9];
    options.function = 'gaussian';
    options.max_weight = 2;
    options.min_weight = 0.001;
    options.max_position = 5;
    options.width = 1;
    options.plot = 0;

    error_weights = GenerateErrorWeights(time_values, options);
    expected_weights = [0.0010 0.0017 0.0232 0.2717 1.2141 2.0010 1.2141 0.2717 0.0232 0.0017];
    verifyEqual(testCase, error_weights, expected_weights, 'AbsTol', 0.00001);
end

function testNoWeightFunction(testCase)
    time_values = [0 1 2 3 4 5 6 7 8 9];
    options.function = 'no_weight';
    options.plot = 0;
    
    error_weights = GenerateErrorWeights(time_values, options);
    expected_weights = [1 1 1 1 1 1 1 1 1 1];
    verifyEqual(testCase, error_weights, expected_weights);
end
