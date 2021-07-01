%% Configure Nikos options structure
options.dt=0.005;
options.ref_min=-0.5;
options.ref_max=0.5;
options.sim_cov =  0;
options.sim_ref = 0;
options.ref_Ts = 20;
options.T_train = 40;
options.input_choice = 3; % ensures Nikos model takes breach signal as inputs

%% Config Breach interface
Bnn = BreachSimulinkSystem('switching_controller_nn', {}); % second argument means we don't care about parameters in the model other than input signals
Bnn.SetInputGen('UniStep2');
load_system('switching_controller_nn_breach');
set_param('switching_controller_nn_breach', 'FastRestart', 'on');

%% Inputs
input_params = Bnn.expand_param_name('ref_u.+'); % get all amplitude input parameters
Bnn.SetParamRanges(input_params, [0 1]);

%% Requirements
 STL_ReadFile('specs_tutorial_new.stl');
 Rnn = BreachRequirement(alw_stable_nn);

%%  Evaluate requirement on 100 quasi random traces
Bnn.QuasiRandomSample(100);
Rnn.Eval(Bnn);

%% Show result
disp(Rnn)
P = BreachSamplesPlot(Rnn);
P.set_y_axis('ref_u1')
P.set_x_axis('ref_u0')
