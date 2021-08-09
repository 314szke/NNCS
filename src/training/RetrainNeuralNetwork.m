function [new_net, tr, trained_from_scratch] = RetrainNeuralNetwork(net, in, out, error_weights, options)
%% Validate input arguments
if isa(net, 'network') == 0
    error("RetrainNeuralNetwork:TypeError", "The input argument 'net' must have type 'network'!");
end
if isa(in, 'double') == 0
    error("RetrainNeuralNetwork:TypeError", "The input argument 'in' must have type 'double' array!");
end
if isa(out, 'double') == 0
    error("RetrainNeuralNetwork:TypeError", "The input argument 'out' must have type 'double' array!");
end
if isa(error_weights, 'double') == 0
    error("RetrainNeuralNetwork:TypeError", "The input argument 'error_weights' must have type 'double' array!");
end
if isstruct(options) == 0
    error("RetrainNeuralNetwork:TypeError", "The input argument 'options' must have type 'struct'!");
end


%% Retrain the network
trained_from_scratch = 0;

net.trainParam.max_fail = options.max_validation_checks;
net.trainParam.goal = options.target_error_rate;
net.trainParam.epochs = options.max_epochs;

if strcmp(options.divider_function, 'divideind')
    net.divideParam.trainInd = options.training_data_indices;
    net.divideParam.valInd = options.validation_data_indices;
    net.divideParam.testInd = options.test_data_indices;
end

[new_net, tr] = train(net, in, out, {}, {}, error_weights);

% We reached the training error limit -> drop learnt weights and biases
if tr.best_tperf > options.error_threshold
    fprintf('The training error %f is higher than the given threshold %f.\n', tr.best_tperf, options.error_threshold);
    fprintf('2.1) Retrain with counter-examples from scratch.\n');

    [new_net2, tr2] = TrainNeuralNetwork(training_data, options);

    if tr2.best_tperf < tr.best_tperf
        fprintf('The new training error %f is lower than the previous error %f.\n', tr2.best_tperf, tr.best_tperf);
        fprintf('Use the NN from the second retraining with newly learnt weights.\n');
        new_net = new_net2;
        tr = tr2;
        trained_from_scratch = 1;
    else
        fprintf('Retraining from scratch did not result in lower training error (%f).\n', tr2.best_tperf);
        fprintf('Use the NN from the first retraining, keeping the learnt weights.\n');
    end
end

end