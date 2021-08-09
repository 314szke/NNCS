# Framework to Create Neural Network Control Systems

This repository is based on [NNCS_matlab](https://github.com/nikos-kekatos/NNCS_matlab). It provides features to create, train and retrain neural network controllers to mimic given nominal controllers. The project provides methods to analyse the performance of the neural network controllers with respect to safety properties of the controlled system using formal verification tools of Breach.

## Getting started
### Prerequisites

The project was developed using Matlab (R2020a) and the latest version of [Breach](https://bitbucket.org/decyphir/breach-dev/src/master/) (Commit hash: *8071d643d24cf634850e4e5be1261effea10310a*).

### Installation

No installation required, the project is ready to use after cloning. The **Initialize.m** function adds the project to the Matlab path and initializes Breach. The initializer function assumes that the NNCS repository location is next to the Breach repository.

    <your_folder>
        |
        |_ breach/
        |_ NNCS/


The path to Breach can be changed in the **Initialize.m** function.
### Repository structure

The entry point of the repository is in the **main** folder. It contains the scripts to create and retrain neural network controllers. Additionally, the **retraining_experiment.m** script handles the execution of extensive experimentation with different configuration options; and **run_unittests.m** can be used to run all available unittests. The main scripts need configurations, which are located in the **configuration** folder.

The Simulink models are in the **models** folder and the Signal Temporal Logic (STL) specifications are in the **specification** folder. Additionally, there is a folder named **extras** which contain helper functions which are specific to given use cases.

The experimentation script uses workspace binaries which are stored in the **bin** folder. The result of the experiments are new workspace binaries which are stored in the **results** folder.
### Adding a new use case

Each use case has a unique name as an identifier (for example *SwitchingController* or *Helicopter*). To add a new use case, create folders with the use case name in the **models**, **specification**, **configuration** and if needed in the **extras** folders and create the needed files. You can execute the main scripts with the new use case by setting the corresponding configuration file at the beginning of the scripts.
### Experiments


    run retraining_experiment.m

The script will execute the retraining on the neural networks stored in the bin folder. Each file in the bin folder is expected to have a name according to the following regex: nn[0-9]+\.mat. For example: nn0.mat or nn42.mat are valid names. At the beginning of the experimentation script there are a few parameters you can set.

    environments: the list of neural network ids to use for retraining (corresponding to the number in the file names in the bin folder)

    window_sizes: the list of the sizes with which the counter-example intervals are extended with

    cex_thresholds: the list of the maximum number of counter-examples used for retraining

    MAX_TEST_ITERATION: the retraining stops if no counter-examples are found after falsification or this iteration limit is reached

    RETRAINING_ERROR_THRESHOLD: if this limit is reached, instead of retraining, we train a new neural network with the current data

    SHORTENED_CEX: if set to 1, shortened counter-examples are used and complete ones otherwise

    ACCUMULATE_CEX: if set to 1, then the counter-examples found in an iteration will be stored for the later iterations

    USE_POSITIVE_DIAGNOSIS: if set to 1, we use the explanation for the satisfaction of a Signal Temporal Logic formula as retraining data instead of the explanation for the violation

    USE_ALL_DATA_FOR_RETRAINING: if set to 1, both original training data and the newly generated training data is used for retraining, otherwise only the new one


After the executions the resulting workspace files are put in the results folder. The script **result_to_csv.m** will convert the data from Matlab workspace to CSV format in the **results.csv** file. **AnalyseExperiments.ipynb** is a Jupyter notebook to create plots based on the data in the CSV file.

### Tests

Independent functions have unittests in the unittest folder. They can be executed separately by opening the file and running selected test cases or with the **run_unittests.m** script in the main folder.

## Documentation
### Simulink models

All Simulink models must match the following requirements:
##### Model parameters

In the model parameters, the model must use **simulation.time_window** as the end of the simulation time and **simulation.time_step** to set the time steps during the simulation.
##### Inputs and Outputs

The inputs and the outputs of the model must be ports. The input port must be named **ref**, the output of the model as **y** and the output of the controller **u**. These names are expected throughout the code and must be present with the correct spelling.
##### Named Neural Network block

During training and retraining the neural network blocks of the models are updated using the **UpdateNeuralNetwork.m** function. The update only works if the following requirements are met. The neural network block must be named and set in the configuration files. The input and output lines of the neural network block must be named as the name of the neural network block, plus the suffix **_in** or **_out**. For example if the name of the nn block is **nn**, the name of the input line is **nn_in** and the name of the output line is **nn_out**. Both lines must have only one source and target handlers, so the models use an additional **Gain** block with parameter 1, which does not change the output, but provides a clear connection for the output line. (Branching a line to an output port also counts as a new handler for the line, so the output port must be placed after the **Gain** block.)
##### Different models

Each use case must have the following models:

**nominal model:** the model which contains only the nominal controller and the plant
**nn model:** the model which contains only the neural network controller and the plant
**shortened cex:** same as nn, used to store the new neural network after retraining without overriding the original nn model
**complete cex:** same as shortened cex, but uses complete traces for retraining
**parallel before retraining:** contains both the nominal controller and the neural network controller and two plants for each; it is used to plot the counter examples of the neural network and the correction of the nominal controller
**parallel after retraining:** similar to the model before retraining, but it contains a third component with a neural network controller and one more plant; it allows to plot the difference between the nominal controller, the neural network controller before and after retraining

The nn model is replicated two times and named shortened cex and complete cex. The replication allows comparisons between the original neural network and different results of retraining.


### Specifications

The specification files can contain variables. In this case, a specification handler function is needed in the **extras** folder. The handler function must receive a **struct** with the current values of the variables. As an example, see **extras/Helicopter/GetHelicopterRequirement.m**.

### Configurations

At the end of the execution of **create_nn.m** the Matlab workspace is saved. The workspace binary is needed to initialize the Simulink models in case we are working on multiple use cases and to enable retraining without repeating the initial training each time. The workspace binary contains all the configuration options of the **create_nn.m** script, thus the retraining configurations do not need to repeat options which were already set for the initial training. However, they can be repeated to override some values.

##### Create Neural Network

After the training of the initial neural network, all the models containing neural network blocks are updated. To do so, the configuration file needs to have the path for all the models and a cell array called **nn_models** which lists the path of the models and the names of the neural network blocks in the given models.

    model_path = 'models/SwitchingController';
    nn_model_path = sprintf('%s/switching_controller_nn', model_path);

    nn_models{1}.path = nn_model_path;
    nn_models{1}.block_name = 'nn';

The configuration needs to include values for the simulation time as well.

    simulation.time_window = 20;
    simulation.time_step = 0.01;
    simulation.time_values = 0:simulation.time_step:simulation.time_window;

Some Simulink models contain configuration variables. Those variables must be named **model_options.variable_name** inside the Simulink model and listed in the configuration file with the same variable name in the **model_options** structure.

    model_options.initial_condition = 3;
    nominal_model = CreateModel(nominal_model_path, simulation, model_options);

Currently, the only available method to create input for the models is using piece-wise constant functions over and input space. Here are the options for the input generation:

    coverage_options.min - the minimum value of the input space
    coverage_options.max - the maximum value of the input space
    coverage_options.cell_size - the sampling distance in the input space
    coverage_options.dimension - the number of constant segments of the input function
    coverage_options.coverage_point_type - 'random' or 'center' sampling of the coverage cells
    coverage_options.plot - 0 or 1 to display the coverage plot

The neural network models can have several input dimensions to feed back previous **ref** and **y** values. In the configuration the input dimension must be given, corresponding to model. The input data can be trimmed to eliminate too many consecutive repeating values. The trimming uses the given distance to determine equality and allows the specified number of repetitions.

    data_options.input_dimension - number of input dimensions for the neural network
    data_options.trimming_enabled - 0 or 1 to enable trimming
    data_options.trim_distance_criteria - the distance used to determine equality
    data_options.trim_allowed_repetition - the number of times consecutive repetitions can occur
    data_options.plot - 0 or 1 to plot the traces before and after trimming

The neural network training uses the Mean Squared Error (MSE) loss function (called performance function in Matlab). We can apply weights to the calculation of MSE. Currently, only the **gaussian** function or the **no_weight** function can be used. The no_weight function gives each trace point a weight of 1 and its only required parameter is the plot option. The weight generation takes the following options for the gaussian function:

    weight_options.function - 'gaussian' or 'no_weight' functions
    weight_options.max_weight - the height of the gaussian curve
    weight_options.min_weight - to avoid zero weight, the gaussian curve is shifted upwards with this value
    weight_options.max_position - sets the center of the bell curve
    weight_options.width - sets the width of the bell curve
    weight_options.plot - 0 or 1 to plot the weight function

The neural network training takes the following parameters. The loss function and the optimizer function should be changed with caution.

    training_options.neurons - array of integers setting the number of neurons for each hidden layer;
    training_options.loss_function - the loss function
    training_options.optimizer_function - the optimizer function, must be able to work with the loss function
    training_options.divider_function - 'divideind' or 'dividerand', recommended to use 'divideind' to not split traces
    training_options.activation_function - the activation function used in all hidden layers

    % The following ratios must sum up to 1
    training_options.training_data_ratio - the ratio of data used for training
    training_options.validation_data_ratio - the ratio of data used for validation (determining the performance (biased) of the neural network during training)
    training_options.test_data_ratio - the ratio of data used for test (determining the performance (non-biased) of the neural network with unseen data)

    training_options.max_validation_checks - if the validation performance stays the same for this amount of iterations, the training stops
    training_options.max_epochs - maximum number of training iterations
    training_options.target_error_rate - if the validation performance reaches or goes below this value, the training stops

And finally, the configuration needs to contain the name of the workspace binary file.

    workspace_name = 'nn.mat';

##### Retrain Neural Network

The configuration for the **retrain_nn.m** script contains a new cell array named **new_nn_models** which contains the models that should be updated with the newly trained neural network.

    nn_model_retrained_path = sprintf('%s/helicopter_nn_shortened_cex', model_path);

    new_nn_models{1}.path = nn_model_retrained_path;
    new_nn_models{1}.block_name = 'nn';

The configuration must contain the required configuration options for the specification files as well.

    STL_ReadFile('specification/Helicopter/helicopter_specification.stl');
    stl_options.simulation_time = simulation.time_window;
    stl_options.max_error = 0.01;

    nominal_requirement = GetHelicopterRequirement(phi_nominal, stl_options);

The configuration options for retraining are the following:

    options.num_falsification_traces - the number of traces that are generated during falsification
    options.use_positive_diagnosis - 0 or 1 to switch between diagnosis of satisfaction or violation
    options.window_size - positive number, determines the time window to include before the satisfaction or violation
    options.cex_threshold - positive integer, determines the maximum number of counter examples used out of the falsification traces for retraining
    options.plot - 0 or 1 to set if the parallel models should be plotted

There are two additional options that extend the configuration of the initial training:

    training_options.error_threshold - if the performance of the neural network is worse than this threshold, then the neural network is retrained from scratch
    data_options.use_all_data - 0 or 1 determines if the initial training data is used for retraining (if set to 0, only new data is used)

To make the retraining reproducible, the random generator of Matlab is fixed with a given seed. In case options.plot is 1, the following plotting labels are used.

    rng(1976); % random generator seed for Matlab
    plot_labels1 = {'ref', 'u', 'u_nn', 'y', 'y_nn'};
    plot_labels2 = {'ref', 'u', 'u_nn_old', 'u_nn_new', 'y', 'y_nn_old', 'y_nn_new'};

##### Retrain Neural Network Loop

The configuration for the **retrain_nn_loop.m** script is similar to the configuration of **retrain_nn.m**, except that it uses the environment variables set by the **retraining_experiment.m** script.
