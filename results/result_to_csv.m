window_sizes = [2 4 8];
ids = [1 3];

for idx3 = 1:numel(ids)
    workspace_name = sprintf('results/test%d_0_complete.mat', ids(idx3));
    load(workspace_name);
    for idx4 = 1:numel(results)
        result = results{idx4};
        fprintf('%d;%d;%d;%f;%f;%f;%d;%d;%d\n', ids(idx3), result.shortened_cex, result.window_size, result.retraining_time, result.training_error, result.validation_error, result.num_cex, result.remaining_cex, idx4);
    end
    clear results;

    for idx5 = 1:numel(window_sizes)
        workspace_name = sprintf('results/test%d_%d_shortened.mat', ids(idx3), window_sizes(idx5));
        load(workspace_name);
        for idx4 = 1:numel(results)
            result = results{idx4};
            fprintf('%d;%d;%d;%f;%f;%f;%d;%d;%d\n', ids(idx3), result.shortened_cex, result.window_size, result.retraining_time, result.training_error, result.validation_error, result.num_cex, result.remaining_cex, idx4);
        end
        clear results;
    end
end
