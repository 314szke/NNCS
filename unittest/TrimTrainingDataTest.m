function tests = TrimTrainingDataTest
    tests = functiontests(localfunctions);
end

function testInvalidInputType(testCase)
    in = struct();
    out = 'double';
    epsilon = 1;
    repetition = 1;
    testCase.verifyError(@()TrimTrainingData(in, out, epsilon, repetition), 'TrimTrainingData:TypeError');
end

function testEmptyInput(testCase)
    in = [];
    out = [];
    epsilon = 0.1;
    repetition = 2;
    testCase.verifyError(@()TrimTrainingData(in, out, epsilon, repetition), 'TrimTrainingData:EmptyInput');
end

function testDifferentDimensions(testCase)
    in = [[1 2]; [3 4]];
    out = [3; 4; 5];
    epsilon = 0.1;
    repetition = 3;
    testCase.verifyError(@()TrimTrainingData(in, out, epsilon, repetition), 'TrimTrainingData:InputMismatch');
end

function testInvalidEpsilon(testCase)
    in = 1;
    out = 1;
    epsilon = -0.1;
    repetition = 6;
    testCase.verifyError(@()TrimTrainingData(in, out, epsilon, repetition), 'TrimTrainingData:InvalidInput');
end

function testInvalidRepetition(testCase)
    in = 1;
    out = 1;
    epsilon = 0.1;
    repetition = -6;
    testCase.verifyError(@()TrimTrainingData(in, out, epsilon, repetition), 'TrimTrainingData:InvalidInput');
end

function testNoTrimming(testCase)
    in = [[1 2]; [3 4]; [5 6]; [7 8]];
    out = [1 2];
    epsilon = 0.5;
    repetition = 0;

    [new_in, new_out] = TrimTrainingData(in, out, epsilon, repetition);
    verifyEqual(testCase, new_in, in);
    verifyEqual(testCase, new_out, out);
end

function testOneRepetition(testCase)
    in = [[1 1.25 3]; [1 1.11 4]; [1 1.2 5]];
    out = [11 12 13];
    epsilon = 0.3;
    repetition = 0;

    [new_in, new_out] = TrimTrainingData(in, out, epsilon, repetition);
    expected_in = [[1 3]; [1 4]; [1 5]];
    expected_out = [11 13];
    verifyEqual(testCase, new_in, expected_in);
    verifyEqual(testCase, new_out, expected_out);
end

function testMultipleRepetition(testCase)
    in = [[0.5 0.5 0.5 0.5 0.9 0.9]; [0 0.1 0.15 0.5 0.6 0.7]];
    out = [1; 2; 3; 4; 5; 6];
    epsilon = 0.25;
    repetition = 0;

    [new_in, new_out] = TrimTrainingData(in, out, epsilon, repetition);
    expected_in = [[0.5 0.5 0.9]; [0 0.5 0.6]];
    expected_out = [1 4 5];
    verifyEqual(testCase, new_in, expected_in);
    verifyEqual(testCase, new_out, expected_out);
end

function testSlowProgression(testCase)
    in = [[0.4 0.4 0.4 0.4 0.4 0.4 0.4]; [0.1 0.15 0.2 0.25 0.3 0.35 0.4]];
    out = [1; 2; 3; 4; 5; 6; 7];
    epsilon = 0.1;
    repetition = 0;

    [new_in, new_out] = TrimTrainingData(in, out, epsilon, repetition);
    expected_in = [[0.4 0.4 0.4]; [0.1 0.25 0.4]];
    expected_out = [1 4 7];
    verifyEqual(testCase, new_in, expected_in);
    verifyEqual(testCase, new_out, expected_out);
end

function testWithAllowedRepetition(testCase)
    in = [[0.2 0.21 0.212 0.213]; [0.5 0.51 0.512 0.513]];
    out = [1; 2; 3; 4];
    epsilon = 0.2;
    repetition = 2;

    [new_in, new_out] = TrimTrainingData(in, out, epsilon, repetition);
    expected_in = [[0.2 0.21 0.212]; [0.5 0.51 0.512]];
    expected_out = [1 2 3];
    verifyEqual(testCase, new_in, expected_in);
    verifyEqual(testCase, new_out, expected_out);
end
