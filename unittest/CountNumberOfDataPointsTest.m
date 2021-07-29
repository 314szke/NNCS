function tests = CountNumberOfDataPointsTest
    tests = functiontests(localfunctions);
end

function testWrongInput(testCase)
    data = 0;
    testCase.verifyError(@()CountNumberOfDataPoints(data), "CountNumberOfDataPoints:TypeError");
end

function testEmptyInput(testCase)
    data = struct();
    testCase.verifyError(@()CountNumberOfDataPoints(data), "CountNumberOfDataPoints:InvalidInput");
end

function testWithUniformTraceLength(testCase)
    data.REF = {[1 2]; [3 4]; [5 6]};
    num_data_points = CountNumberOfDataPoints(data);
    verifyEqual(testCase, num_data_points, 6);
end

function testWithDifferentTraceLength(testCase)
    data.REF = {[1 2 3 4]; [5 6]; [7 8 9 10 11]};
    num_data_points = CountNumberOfDataPoints(data);
    verifyEqual(testCase, num_data_points, 11);
end
