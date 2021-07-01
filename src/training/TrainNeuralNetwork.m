function [net, tr] = TrainNeuralNetwork(data, options)
%% Parameter checking
if class(data) ~= 'struct'
    error("The parameter 'data' must have type 'struct'!");
end
fields = fieldnames(data);
if fields{1} ~= 'REF'
    error("The parameter 'data' must have a field named 'REF'!");
end
if fields{2} ~= 'U'
    error("The parameter 'data' must have a field named 'U'!");
end
if fields{3} ~= 'Y'
    error("The parameter 'data' must have a field named 'Y'!");
end


%% Create neural network and train it on the given data
[in, out] = RestructureTrainingData(data.REF, data.U, data.Y);

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