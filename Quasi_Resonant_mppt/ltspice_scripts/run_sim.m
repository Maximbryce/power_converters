%% Read in params for the runs
file_name = 'params.csv';
[~,~,params] = xlsread('params.csv');
table_size = size(params);

ltspice_asc_file_name = 'resonant_full_bridge_ln_5_solar';

num_variables = table_size(2);
num_steps = table_size(1) - 1; 

%% Make a result directory with unique datetime
result_dir_name = sprintf('run_%s', datestr(now,'mm-dd-yyyy_HH-MM-SS'));
mkdir(result_dir_name);

%% Make results table
results = table;

%% Do the runs
for step_num = 1:num_steps
    step_params(step_num, params, num_variables);
    dos('run_ltspice.bat');
    [~,tasks] = system('tasklist');
    while(contains(tasks, 'LTspice.exe')) % Keep waiting till the simulation is done
        [~,tasks] = system('tasklist');
        pause(2);
    end
    results = [results;get_results_from_sim(ltspice_asc_file_name, params, step_num)];
    copyfile(strcat(ltspice_asc_file_name, '.raw'), strcat(result_dir_name, "\", strcat(ltspice_asc_file_name, '_step_', num2str(step_num), '.raw')))
    copyfile('params.csv', strcat(result_dir_name, "\", 'params.csv'))
end
%% Copy results
copyfile(strcat(ltspice_asc_file_name, '.asc'), strcat(result_dir_name, "\", strcat(ltspice_asc_file_name, '.asc')))
writetable(results, strcat(result_dir_name, "\", 'results.csv'))


%% Random functions
function step_params(step, table, num_variables)
    fileID = fopen('sim_params.txt', 'w');
    for i = 1:num_variables
        write_param(table(1, i), string(table(step+1, i)), fileID); % step+1 bc first row is the variable names
    end
    fclose(fileID);
end


function write_param(name, value, fileID)
    string_to_write = strcat('.param', " ", name, sprintf(' %s',value));
    fprintf(fileID, string_to_write);
    fprintf(fileID, '\n');
end

function results = get_results_from_sim(name, params, step_num)
    raw_data = LTspice2Matlab(strcat(name, '.raw'));
    %M1_power = get_component_power_trace(raw_data, 'V(vin+)', 'V(vc+)', 'I(V1)');
    %M1_power = trim_signal(M1_power, 3e-3, 3e-3 + 1/(120e+3)*4);
    %plot(M1_power.time, abs(M1_power.trace))

    mosfet_losses = get_mosfet_losses(raw_data);
    diode_losses = get_diode_losses(raw_data);

    result_names = ["mosfet_losses", "diode_losses"];
    var_names = [result_names, params(1,:)];
    values = [mosfet_losses, diode_losses, params(1+step_num,:)];
    results = array2table(values,'VariableNames', var_names);
end


function mosfet_losses = get_mosfet_losses(raw_data)
    M2_average_power = get_component_average_power(raw_data, 'V(vin+)', 'V(vc+)', 'I(V1)');
    M3_average_power = get_component_average_power(raw_data, 'V(vin+)', 'V(vc-)', 'I(V7)');
    M1_average_power = get_component_average_power(raw_data, 'V(vc+)', 'g', 'I(V9)');
    M4_average_power = get_component_average_power(raw_data, 'V(vc-)', 'g', 'I(V8)');
    
    mosfet_losses = M2_average_power + M3_average_power + M1_average_power + M4_average_power;
end

function diode_losses = get_diode_losses(raw_data)
    D2_average_power = get_component_average_power(raw_data, 'V(vsec+)', 'V(vout+)', 'I(D2)');
    D3_average_power = get_component_average_power(raw_data, 'V(vsec+)', 'V(vout-)', 'I(D3)');
    D4_average_power = get_component_average_power(raw_data, 'V(vout+)', 'g', 'I(D4)');
    D1_average_power = get_component_average_power(raw_data, 'V(vout-)', 'g', 'I(D1)');
    
    diode_losses = D2_average_power + D3_average_power + D4_average_power + D1_average_power;
end

function trimmed_signal = trim_signal(signal, time_start, time_stop)
    start_index = find( signal.time > time_start, 1 );
    end_index = find( signal.time > time_stop, 1 );
    
    trimmed_signal = struct();
    trimmed_signal.time = signal.time(start_index:end_index);
    trimmed_signal.trace = signal.trace(start_index:end_index);
end

function average_power = get_component_average_power(raw_data, upper_voltage_net, lower_voltage_net, current_trace)
    power_trace = get_component_power_trace(raw_data, upper_voltage_net, lower_voltage_net, current_trace);
    
    total_energy = trapz(power_trace.time, abs(power_trace.trace));
    total_time = power_trace.time(end) - power_trace.time(1);
    
    average_power = total_energy/total_time;

end

function power = get_component_power_trace(raw_data, upper_voltage_net, lower_voltage_net, current_trace)
    upper_voltage = get_trace(raw_data, upper_voltage_net);
    current = get_trace(raw_data, current_trace);
    
    if(lower_voltage_net == 'g')
        power = struct();
        power.time = raw_data.time_vect;
        power.trace = upper_voltage.trace.*current.trace;
    else
        lower_voltage = get_trace(raw_data, lower_voltage_net);
        power = struct();
        power.time = raw_data.time_vect;
        power.trace = (upper_voltage.trace - lower_voltage.trace) .*current.trace;
    end
end

function data = get_trace(raw_data, trace_name)
    % First get the index of that particular trace
    index = find(ismember(raw_data.variable_name_list, trace_name));
    if(isempty(index))
        error(strcat('No trace name: ', trace_name))
    end
    data = struct();
    data.trace = raw_data.variable_mat(index,:);
    data.time = raw_data.time_vect;
end
