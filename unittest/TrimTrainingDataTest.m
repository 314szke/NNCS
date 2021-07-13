function tests = TrimTrainingDataTest
    tests = functiontests(localfunctions);
end

function testInvalidInputType(testCase)
    in = struct();
    out = 'double';
    dimension = 0;
    epsilon = 1;
    testCase.verifyError(@()TrimTrainingData(in, out, dimension, epsilon), 'TrimTrainingData:TypeError');
end

function testEmptyInput(testCase)
    in = [];
    out = [];
    dimension = 1;
    epsilon = 0.1;
    testCase.verifyError(@()TrimTrainingData(in, out, dimension, epsilon), 'TrimTrainingData:EmptyInput');
end

function testDifferentDimensions(testCase)
    in = [[1 2]; [3 4]];
    out = [3; 4; 5];
    dimension = 1;
    epsilon = 0.1;
    testCase.verifyError(@()TrimTrainingData(in, out, dimension, epsilon), 'TrimTrainingData:InputMismatch');
end

function testInvalidDimension(testCase)
    in = 1;
    out = 1;
    dimension = 0;
    epsilon = 0.1;
    testCase.verifyError(@()TrimTrainingData(in, out, dimension, epsilon), 'TrimTrainingData:InvalidInput');
end

function testUnalignedDimension(testCase)
    in = [[1 2]; [3 4]];
    out = 1;
    dimension = 3;
    epsilon = 0.1;
    testCase.verifyError(@()TrimTrainingData(in, out, dimension, epsilon), 'TrimTrainingData:InputMismatch');
end

function testInvalidEpsilon(testCase)
    in = 1;
    out = 1;
    dimension = 1;
    epsilon = -0.1;
    testCase.verifyError(@()TrimTrainingData(in, out, dimension, epsilon), 'TrimTrainingData:InvalidInput');
end

function testNoTrimming(testCase)
    in = [[1 2]; [3 4]; [5 6]; [7 8]];
    out = [1; 2];
    dimension = 4;
    epsilon = 0.5;

    [new_in, new_out] = TrimTrainingData(in, out, dimension, epsilon);
    verifyEqual(testCase, new_in, in);
    verifyEqual(testCase, new_out, out);
end

function testOneRepetition(testCase)
    in = [[1 1.25 3]; [1 1.11 4]; [1 1.2 5]];
    out = [11; 12; 13];
    dimension = 3;
    epsilon = 0.3;

    [new_in, new_out] = TrimTrainingData(in, out, dimension, epsilon);
    expected_in = [[1 3]; [1 4]; [1 5]];
    expected_out = [11; 13];
    verifyEqual(testCase, new_in, expected_in);
    verifyEqual(testCase, new_out, expected_out);
end

function testMultipleRepetition(testCase)
    in = [[0.5 0.5 0.5 0.5 0.9 0.9]; [0 0.1 0.15 0.5 0.6 0.7]];
    out = [1; 2; 3; 4; 5; 6];
    dimension = 2;
    epsilon = 0.25;

    [new_in, new_out] = TrimTrainingData(in, out, dimension, epsilon);
    expected_in = [[0.5 0.5 0.9]; [0 0.5 0.6]];
    expected_out = [1; 4; 5];
    verifyEqual(testCase, new_in, expected_in);
    verifyEqual(testCase, new_out, expected_out);
end

function testSlowProgression(testCase)
    in = [[0.4 0.4 0.4 0.4 0.4 0.4 0.4]; [0.1 0.15 0.2 0.25 0.3 0.35 0.4]];
    out = [1; 2; 3; 4; 5; 6; 7];
    dimension = 2;
    epsilon = 0.1;

    [new_in, new_out] = TrimTrainingData(in, out, dimension, epsilon);
    expected_in = [[0.4 0.4 0.4]; [0.1 0.25 0.4]];
    expected_out = [1; 4; 7];
    verifyEqual(testCase, new_in, expected_in);
    verifyEqual(testCase, new_out, expected_out);
end
