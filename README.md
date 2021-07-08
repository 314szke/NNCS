# Neural Network Control Systems

### 1) Initial steps

### 2) Create and train neural network controllers
### 3) Experiments

    run retraining_experiment.m

The testing script will execute the retraining on the neural networks stored in the bin folder. At the beginning of the retraining script there are a few parameters you can set.

    window_sizes: shortened counter examples will be tested with the sizes listed here

    networks: list of the neural networks to use from the bin folder

    MAX_TEST_ITERATION: the retraining stops if no counter-examples are found after falsification or this iteration limit is reached

    WINDOW_SIZE: used to set the current window size during the iterations

    ACCUMULATE_CEX: if set to 1, then the counter-examples found in an iteration will be stored for the later iterations

    RETRAINING_ERROR_THRESHOLD: if the previous retraining validation error was higher than this value, the neural network is trained from scratch


After the executions the resulting workspace files are put in the results folder. The script result_to_csv.m will convert the data from the workspace to csv format (printed to the console). AnalyseExperiments.ipynb is a Jupyter notebook to create plots based on the csv file.

