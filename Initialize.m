function Initialize
if endsWith(pwd, "NNCS") == 0
    error("Change working directory to the repo root (<path_to_repo>/NNCS)!\n");
end
if contains(path, 'breach') == 0
    addpath(genpath("../breach"));
end
if contains(path, 'NNCS') == 0
    addpath(genpath("./"));
end

InitBreach

warning('off', 'Simulink:Engine:StopTimeCorrected');

end