%% Initialize workspace
Initialize
clear; close all; clc; bdclose('all');


%% Run each test
suite = testsuite('unittest');
results = run(suite);
disp(results);
