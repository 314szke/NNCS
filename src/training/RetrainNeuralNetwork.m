function [new_net, tr, trained_from_scratch] = RetrainNeuralNetwork(net, data, new_data, options)
%% Validate input arguments
if isa(net, 'network') == 0
    error("RetrainNeuralNetwork:TypeError", "The argument 'net' must have type 'network'!");
end
if isstruct(data) == 0
    error("RetrainNeuralNetwork:TypeError", "The argument 'data' must have type 'struct'!");
end
fields = fieldnames(data);
if strcmp(fields{1}, 'REF') == 0
    error("RetrainNeuralNetwork:TypeError", "The argument 'data' must have a field named 'REF'!");
end
if strcmp(fields{2}, 'U') == 0
    error("RetrainNeuralNetwork:TypeError", "The argument 'data' must have a field named 'U'!");
end
if strcmp(fields{3}, 'Y') == 0
    error("RetrainNeuralNetwork:TypeError", "The argument 'data' must have a field named 'Y'!");
end
if isstruct(new_data) == 0
    error("RetrainNeuralNetwork:TypeError", "The argument 'new_data' must have type 'struct'!");
end
fields = fieldnames(new_data);
if strcmp(fields{1}, 'REF') == 0
    error("RetrainNeuralNetwork:TypeError", "The argument 'new_data' must have a field named 'REF'!");
end
if strcmp(fields{2}, 'U') == 0
    error("RetrainNeuralNetwork:TypeError", "The argument 'new_data' must have a field named 'U'!");
end
if strcmp(fields{3}, 'Y') == 0
    error("RetrainNeuralNetwork:TypeError", "The argument 'new_data' must have a field named 'Y'!");
end


%% Create input and output for training
if options.use_all_data == 1
    training_data.REF = [data.REF; new_data.REF];
    training_data.U = [data.U; new_data.U];
    training_data.Y = [data.Y; new_data.Y];
else
    training_data.REF = [new_data.REF];
    training_data.U = [new_data.U];
    training_data.Y = [new_data.Y];
end

[in, out] = RestructureTrainingData(training_data.REF, training_data.U, training_data.Y, options.input_dimension);
if options.trim_data
    fprintf('Number of data points before trimming: %d.\n', length(out));
    [in, out] = TrimTrainingData(in, out, options.input_dimension, options.max_input_distance);
    fprintf('Number of data points after trimming: %d.\n', length(out));
end


%% Retrain the network
trained_from_scratch = 0;
[new_net, tr] = train(net, in, out);

% We reached training error "RetrainNeuralNetwork:TypeError", limit -> drop learnt weights and biases
if tr.best_tperf > options.error_threshold, threshold
    fprintf('The training error "RetrainNeuralNetwork:TypeError", %f is higher than the given threshold %f.\n', tr.best_tperf, options.error_threshold, threshold);
    fprintf('2.1) Retrain with counter-examples from scratch.\n');

    [new_net2, tr2] = TrainNeuralNetwork(training_data, options);

    if tr2.best_tperf < tr.best_tperf
        fprintf('The new training error "RetrainNeuralNetwork:TypeError", %f is lower than the previous error "RetrainNeuralNetwork:TypeError", %f.\n', tr2.best_tperf, tr.best_tperf);
        fprintf('Use NN from second retraining with newly learnt weights.\n');
        new_net = new_net2;
        tr = tr2;
    else
        fprintf('Retraining from scratch did not result in lower training error "RetrainNeuralNetwork:TypeError", (%f).\n', tr2.best_tperf);
        fprintf('Use NN from first retraining keeping the learnt weights.\n');
    end
end

end