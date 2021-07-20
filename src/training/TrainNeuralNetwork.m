function [net, tr] = TrainNeuralNetwork(in, out, options)
%% Validate input arguments
if isa(in, 'double') == 0
    error("TrainNeuralNetwork:TypeError", "The argument 'in' must have type 'double' array!");
end
if isa(out, 'double') == 0
    error("TrainNeuralNetwork:TypeError", "The argument 'out' must have type 'double' array!");
end
if isstruct(options) == 0
    error("TrainNeuralNetwork:TypeError", "The argument 'options' must have type 'struct'!");
end


%% Create neural network and train it on the given data
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