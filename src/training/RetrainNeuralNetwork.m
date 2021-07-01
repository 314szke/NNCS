function [new_net, tr, trained_from_scratch] = RetrainNeuralNetwork(net, data, new_data, options)
%% Parameter checking
if class(net) ~= 'network'
    error("The parameter 'net' must have type 'network'!");
end
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
if class(new_data) ~= 'struct'
    error("The parameter 'new_data' must have type 'struct'!");
end
fields = fieldnames(new_data);
if fields{1} ~= 'REF'
    error("The parameter 'new_data' must have a field named 'REF'!");
end
if fields{2} ~= 'U'
    error("The parameter 'new_data' must have a field named 'U'!");
end
if fields{3} ~= 'Y'
    error("The parameter 'new_data' must have a field named 'Y'!");
end


%% Create input and output for training
if options.use_all_data == 1
    REF = [data.REF; new_data.REF];
    U = [data.U; new_data.U];
    Y = [data.Y; new_data.Y];
else
    REF = [new_data.REF];
    U = [new_data.U];
    Y = [new_data.Y];
end

[in, out] = RestructureTrainingData(REF, U, Y);


%% Retrain the network
trained_from_scratch = 0;
net.divideFcn=options.div;
net.trainParam.goal=options.error;
net.trainParam.max_fail=options.max_fail;

[new_net, tr] = train(net, in, out);

% We reached validation error limit -> drop learnt weights and biases
if tr.best_vperf > options.error_threshold
    fprintf('The validation error %f is higher than the given threshold %f.\n', tr.best_vperf, options.error_threshold);
    fprintf('2.1) Retrain with counter-examples from scratch.\n');

    net = feedforwardnet(options.neurons);
    net = configure(net, in, out);
    net = init(net);

    trained_from_scratch = 1;
    net.divideFcn=options.div;
    net.trainParam.goal=options.error;
    net.trainParam.max_fail=options.max_fail;

    [new_net2, tr2] = train(net, in, out);

    if tr2.best_vperf < tr.best_vperf
        fprintf('The new validation error %f is lower than the previous error %f.\n', tr2.best_vperf, tr.best_vperf);
        fprintf('Use NN from second retraining with newly learnt weights.\n');
        new_net = new_net2;
        tr = tr2;
    else
        fprintf('Retraining from scratch did not result in lower validation error (%f).\n', tr2.best_vperf);
        fprintf('Use NN from first retraining keeping the learnt weights.\n');
    end
end

end