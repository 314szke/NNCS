function tests = RestructureTrainingDataTest
    tests = functiontests(localfunctions);
end

function testInvalidInputType(testCase)
    REF = 'not';
    U = 'double';
    Y = 'input';
    dimension = 'types';
    testCase.verifyError(@()RestructureTrainingData(REF, U, Y, dimension), 'RestructureTrainingData:TypeError');
end

function testEmptyInput(testCase)
    REF = [];
    U = [];
    Y = [];
    dimension = 0;
    testCase.verifyError(@()RestructureTrainingData(REF, U, Y, dimension), 'RestructureTrainingData:EmptyInput');
end

function testVaryingArrayLength(testCase)
    REF = [0; 1];
    U = 0;
    Y = 0;
    dimension = 1;
    testCase.verifyError(@()RestructureTrainingData(REF, U, Y, dimension), 'RestructureTrainingData:VaryingLength');
end

function testInvalidDimension(testCase)
    REF = 1;
    U = 1;
    Y = 1;
    dimension = -1;
    testCase.verifyError(@()RestructureTrainingData(REF, U, Y, dimension), 'RestructureTrainingData:InvalidInput');
end

function testWithOneElement(testCase)
    REF = 1;
    U = 2;
    Y = 3;
    dimension = 6;
    [in, out] = RestructureTrainingData(REF, U, Y, dimension);

    expected_in = [1; 0; 0; 3; 0; 0];
    expected_out = 2;
    verifyEqual(testCase, in, expected_in);
    verifyEqual(testCase, out, expected_out);
end

function testWithTwoElements(testCase)
    REF = [1; 2];
    U = [3; 4];
    Y = [5; 6];
    dimension = 6;
    [in, out] = RestructureTrainingData(REF, U, Y, dimension);

    expected_in = [[1 2]; [0 1]; [0 0]; [5 6]; [0 5]; [0 0]];
    expected_out = [3 4];
    verifyEqual(testCase, in, expected_in);
    verifyEqual(testCase, out, expected_out);
end

function testWithMultipleElements(testCase)
    REF = [1; 2; 3; 4];
    U = [5; 6; 7; 8];
    Y = [9; 10; 11; 12];
    dimension = 6;
    [in, out] = RestructureTrainingData(REF, U, Y, dimension);

    expected_in = [[1 2 3 4]; [0 1 2 3]; [0 0 1 2]; [9 10 11 12]; [0 9 10 11]; [0 0 9 10]];
    expected_out = [5 6 7 8];
    verifyEqual(testCase, in, expected_in);
    verifyEqual(testCase, out, expected_out);
end

function testWithDifferentDimension(testCase)
    REF = [1; 2; 3; 4];
    U = [5; 6; 7; 8];
    Y = [9; 10; 11; 12];
    dimension = 8;
    [in, out] = RestructureTrainingData(REF, U, Y, dimension);

    expected_in = [[1 2 3 4]; [0 1 2 3]; [0 0 1 2]; [0 0 0 1]; [9 10 11 12]; [0 9 10 11]; [0 0 9 10]; [0 0 0 9]];
    expected_out = [5 6 7 8];
    verifyEqual(testCase, in, expected_in);
    verifyEqual(testCase, out, expected_out);
end
