function [net, tr] = TrainNeuralNetwork(data, options)
%% Validate input arguments
if isstruct(data) == 0
    error("TrainNeuralNetwork:TypeError", "The argument 'data' must have type 'struct'!");
end
fields = fieldnames(data);
if strcmp(fields{1}, 'REF') == 0
    error("TrainNeuralNetwork:TypeError", "The argument 'data' must have a field named 'REF'!");
end
if strcmp(fields{2}, 'U') == 0
    error("TrainNeuralNetwork:TypeError", "The argument 'data' must have a field named 'U'!");
end
if strcmp(fields{3}, 'Y') == 0
    error("TrainNeuralNetwork:TypeError", "The argument 'data' must have a field named 'Y'!");
end


%% Create neural network and train it on the given data
[in, out] = RestructureTrainingData(data.REF, data.U, data.Y, options.input_dimension);
if options.trim_data
    fprintf('Number of data points before trimming: %d.\n', length(out));
    [in, out] = TrimTrainingData(in, out, options.input_dimension, options.max_input_distance);
    fprintf('Number of data points after trimming: %d.\n', length(out));
end

net = feedforwardnet(options.neurons);
net.performFcn = options.loss_function;
net.trainFcn = options.optimizer_function;
net.divideFcn = options.divider_function;
net.initFcn = 'initlay';

for layer_idx = 1:length(options.neurons)
    net.layers{layer_idx}.transferFcn = options.activation_function;
    net.layers{layer_idx}.transferFcn = options.activation_function;
end

net.trainParam.max_fail = options.max_validation_checks;
net.trainParam.goal = options.target_error_rate;

net.performParam.regularization = options.regularization;
net.performParam.normalization = 'none';

net = configure(net, in, out);
net = init(net);
[net, tr] = train(net, in, out);

end