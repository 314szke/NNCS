function UpdateNeuralNetwork(net, model_path, block_name)
%% Validate input arguments
if isa(net, 'network') == 0
    error("UpdateNeuralNetwork:TypeError", "The parameter 'net' must have type 'network'!");
end
if isa(model_path, 'char') == 0
    error("UpdateNeuralNetwork:TypeError", "The parameter 'model_path' must have type 'char' array!");
end
if isa(block_name, 'char') == 0
    error("UpdateNeuralNetwork:TypeError", "The parameter 'block_name' must have type 'char' array!");
end


%% Create temporary model
temporary_model = 'nn_tmp';
gensim(net, 'InputMode', 'none', 'OutputMode', 'none');
save_system('untitled', temporary_model);


%% Copy the neural network structure from the temporary model to the real one
load_system(model_path);
load_system(temporary_model);

% Delete old NN block
[~, model_name, ~] = fileparts(model_path);
nn_block = sprintf('%s/%s', model_name, block_name);
Simulink.SubSystem.deleteContents(nn_block);

% Create temporary file for the inner part of the new neural network block
temporary_file = 'file_tmp';
new_system(temporary_file);
load_system(temporary_file);

new_nn_bock = sprintf('%s/%s', temporary_model, 'Feed-Forward Neural Network');
Simulink.SubSystem.copyContentsToBlockDiagram(new_nn_bock, temporary_file);

% Save the newly generated network to the original model
Simulink.BlockDiagram.copyContentsToSubsystem(temporary_file, nn_block);


%% Connect the new block
input_name = sprintf('%s_in', block_name);
output_name = sprintf('%s_out', block_name);
input_line = find_system(model_name, 'FindAll', 'on', 'type', 'line', 'name', input_name);
output_line = find_system(model_name, 'FindAll', 'on', 'type', 'line', 'name', output_name);

nn_port_handle = get_param(nn_block, 'PortHandles');
source_block = get_param(input_line, 'SrcBlockHandle');
source_port_handler = get_param(source_block, 'PortHandles');
dest_block = get_param(output_line, 'DstBlockHandle');
destination_port_handler = get_param(dest_block, 'PortHandles');

% Delete old lines and create new ones
delete_line(input_line);
line_handler = add_line(model_name, source_port_handler.Outport(1), nn_port_handle.Inport(1));
set_param(line_handler, 'Name', input_name);

delete_line(output_line);
line_handler = add_line(model_name, nn_port_handle.Outport(1), destination_port_handler.Inport(1));
set_param(line_handler, 'Name', output_name);


%% Close systems and cleanup temporary file
close_system(model_path, 1);
close_system(temporary_model, 0);
close_system(temporary_file, 0);
delete(strcat(temporary_model, '.slx'));

end
