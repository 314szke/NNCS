% Model names
model_path = 'models/SwitchingController';
nominal_model_path = sprintf('%s/switching_controller_nominal', model_path);
nn_model_path = sprintf('%s/switching_controller_nn', model_path);
parallel_model_before_retraining_path = sprintf('%s/switching_controller_parallel_before_retraining', model_path);
parallel_model_after_retraining_path = sprintf('%s/switching_controller_parallel_after_retraining', model_path);

% Set which models to update with the new neural network
nn_models{1}.path = nn_model_path;
nn_models{1}.block_name = 'nn';
nn_models{2}.path = parallel_model_before_retraining_path;
nn_models{2}.block_name = 'nn';
nn_models{3}.path = parallel_model_after_retraining_path;
nn_models{3}.block_name = 'nn_old';

% Simulink parameters
simulation.time_window = 20;
simulation.time_step = 0.01;
simulation.time_values = 0:simulation.time_step:simulation.time_window;

% Create required models
model_options = struct(); % there are no parameters for SwitchingController models
nominal_model = CreateModel(nominal_model_path, simulation, model_options);

% Input coverage parameters
coverage_options.min = 0;
coverage_options.max = 1;
coverage_options.cell_size = 0.1;
coverage_options.dimension = 2;
coverage_options.coverage_point_type = 'random';
coverage_options.plot = 0;

% Training data options
data_options.input_dimension = 6;
data_options.trimming_enabled = 1;
data_options.trim_distance_criteria = 0.001;
data_options.trim_allowed_repetition = 20;
data_options.plot = 0;

% Training error weight options
weight_options.function = 'gaussian';
weight_options.max_weight = 1;
weight_options.min_weight = 0.001;
weight_options.max_position = (simulation.time_window / 2) + 1;
weight_options.width = 1;
weight_options.plot = 0;

% Training parameters
training_options.neurons = [20 10];
training_options.loss_function = 'mse';
training_options.optimizer_function = 'trainlm';
training_options.divider_function = 'divideind';
training_options.activation_function = 'tansig';

training_options.training_data_ratio = 0.7;
training_options.validation_data_ratio = 0.1;
training_options.test_data_ratio = 0.2;

training_options.max_validation_checks = 10;
training_options.max_epochs = 15;
training_options.target_error_rate = 0.0001;

% Other parameters
workspace_name = 'nn.mat';
