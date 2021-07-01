%% Configure Nikos options structure
options.sim_cov =  0;
options.sim_ref = 0;
options.ref_Ts = 20;
options.input_choice = 4; % ensures Nikos model takes breach signal as inputs


%% Config Breach interface
Bnom = BreachSimulinkSystem('switching_controller_nominal', {}); % second argument means we don't care about parameters in the model other than input signals
Bnom.SetInputGen('UniStep2');
load_system('switching_controller_nominal_breach');
set_param('switching_controller_nominal_breach', 'FastRestart', 'on');

%% Inputs
input_params = Bnom.expand_param_name('In1_u.+'); % get all amplitude input parameters
Bnom.SetParamRanges(input_params, [0 1]);

%% Requirements
 STL_ReadFile('specs_tutorial_new.stl');
 Rnom = BreachRequirement(alw_stable_nom);

%%  Evaluate requirement on 100 quasi random traces
Bnom.QuasiRandomSample(100);
Rnom.Eval(Bnom)
BreachSamplesPlot(Rnom)

