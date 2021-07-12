# Framework to Create Neural Network Control Systems

This repository is based on [NNCS_matlab](https://github.com/nikos-kekatos/NNCS_matlab). It provides features to create, train and retrain neural network controllers to mimic given nominal controllers. The project provides methods to analyse the performance of the neural network controllers with respect to safety properties of the controlled system using the formal verification tools of Breach.

## Getting started
### Prerequisites

The project was developed using Matlab (R2020a) and the latest version of [Breach](https://bitbucket.org/decyphir/breach-dev/src/master/).

### Installation

No installation required, the project is ready to use after cloning. The **Initialize.m** function adds the project to the Matlab path and initializes Breach. The function assumes that the repository location is next to Breach.

    <your_folder>
        |
        |_ breach/
        |_ NNCS/


The path to Breach can be changed in the **Initialize.m** function.
### Repository structure

The entry point of the repository is in the **main** folder. It contains the scripts to create and retrain neural network controllers. Additionally, the **retraining_experiment.m** handles the execution of extensive experimentation with different configuration options and **run_unittests.m** can be used to run all available unittests.

The Simulink models are in the **models** folder and the Signal Temporal Logic (STL) specifications are in the **specification** folder. Additionally, there is a folder named **extras** which contain helper functions which are specific to given use cases.

The experimentation script uses workspace binaries which are stored in the **bin** folder. The result of the experiments are new workspace binaries which are stored in the **results** folder.
## Adding a new use case

## Experiments


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


After the executions the resulting workspace files are put in the results folder. The script **result_to_csv.m** will convert the data from Matlab workspace to CSV format in the **results.csv** file. AnalyseExperiments.ipynb is a Jupyter notebook to create plots based on the data in the CSV file.

## Tests

Independent functions have unittests in the unittest folder. They can be executed separately by opening the file and running selected test cases or with the **run_unittests.m** script in the main folder.
