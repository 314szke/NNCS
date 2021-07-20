function tests = ConcatenateDataTest
    tests = functiontests(localfunctions);
end

function testWrongInput(testCase)
    data1 = 5;
    data2 = 'text';
    testCase.verifyError(@()ConcatenateData(data1, data2), "ConcatenateData:TypeError");
end

function testEmptyInput(testCase)
    data1 = struct();
    data2 = struct();
    new_data = ConcatenateData(data1, data2);
    expected.REF = {};
    expected.U = {};
    expected.Y = {};
    verifyEqual(testCase, new_data, expected);
end

function testData1IsEmpty(testCase)
    trace1 = [0 1 2 3];
    trace2 = [4 5 6];
    data1 = struct();
    data2.REF = {trace1 trace2};
    data2.U = {trace1 trace2};
    data2.Y = {trace1 trace2};
    new_data = ConcatenateData(data1, data2);
    verifyEqual(testCase, new_data, data2);
end

function testData2IsEmpty(testCase)
    trace1 = [0 1 2 3];
    trace2 = [4 5 6];
    data1.REF = {trace1 trace2};
    data1.U = {trace1 trace2};
    data1.Y = {trace1 trace2};
    data2 = struct();
    new_data = ConcatenateData(data1, data2);
    verifyEqual(testCase, new_data, data1);
end

function testConcatenation(testCase)
    ref1 = [1 1 1 2 2 2];
    ref2 = [0 0 0 4 4 4];
    ref3 = [3 3 3 4 4 4];
    ref4 = [0 0 0 6 6 6];

    u1 = [1 2 3 4 5 6];
    u2 = [9 8 7 6 5 4];
    u3 = [5 6 1 4 6 3];
    u4 = [1 1 1 7 6 8];

    y1 = [2 2 2 3 3 3];
    y2 = [1 1 1 5 5 5];
    y3 = [9 9 9 8 8 8];
    y4 = [1 1 1 7 7 7];

    data1.REF = {ref1 ref2};
    data1.U = {u1 u2};
    data1.Y = {y1 y2};

    data2.REF = {ref3 ref4};
    data2.U = {u3 u4};
    data2.Y = {y3 y4};

    new_data = ConcatenateData(data1, data2);
    expected_data.REF = {ref1 ref2 ref3 ref4};
    expected_data.U = {u1 u2 u3 u4};
    expected_data.Y = {y1 y2 y3 y4};

    verifyEqual(testCase, new_data, expected_data);
end
