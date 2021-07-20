function [new_net, tr, trained_from_scratch] = RetrainNeuralNetwork(net, in, out, options)
%% Validate input arguments
if isa(net, 'network') == 0
    error("RetrainNeuralNetwork:TypeError", "The argument 'net' must have type 'network'!");
end
if isa(in, 'double') == 0
    error("RetrainNeuralNetwork:TypeError", "The argument 'in' must have type 'double' array!");
end
if isa(out, 'double') == 0
    error("RetrainNeuralNetwork:TypeError", "The argument 'out' must have type 'double' array!");
end
if isstruct(options) == 0
    error("RetrainNeuralNetwork:TypeError", "The argument 'options' must have type 'struct'!");
end


%% Retrain the network
trained_from_scratch = 0;
[new_net, tr] = train(net, in, out);

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