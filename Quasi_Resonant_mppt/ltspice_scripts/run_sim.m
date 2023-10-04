%% Read in params for the runs
file_name = 'params.csv';
[~,~,params] = xlsread('params.csv');
table_size = size(params);

ltspice_asc_file_name = 'QRS-boost-aux-switch';

num_variables = table_size(2);
num_steps = table_size(1) - 1; 

%% Make a result directory with unique datetime
result_dir_name = sprintf('run_%s', datestr(now,'mm-dd-yyyy_HH-MM-SS'));
mkdir(result_dir_name);

%% Make results table
results = table;

%% Do the runs
for step_num = 1:num_steps
    disp(['Trial: ', num2str(step_num), '/' , num2str(num_steps)])
    step_params(step_num, params, num_variables);
    dos('start .\ltspice.exe.lnk -b -Run D:\power_converters\Quasi_Resonant_mppt\ltspice_scripts\QRS-boost-aux-switch.asc');
    [~,tasks] = system('tasklist');
    while(contains(tasks, 'XVIIx86.exe')) % Keep waiting till the simulation is done
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

    power_mosfet_losses = get_component_average_power(raw_data, 'V(vc)', 'g', 'I(V2)');
    power_diode_losses = get_component_average_power(raw_data, 'V(vout+)', 'V(vc)', 'I(D1)');
    aux_mosfet_losses = get_component_average_power(raw_data, 'V(aux)', 'g', 'I(V1)');
    aux_diode_losses = get_component_average_power(raw_data, 'V(vout+)', 'V(aux)', 'I(D2)');

    output_power = get_component_average_power(raw_data, 'V(vout+)', 'g', 'I(V6)');
    input_power = get_component_average_power(raw_data, 'V(vin+)', 'g', 'I(R6)');

    input_voltage = get_avg_trace(raw_data, 'V(vin+)');
    input_current = get_avg_trace(raw_data, 'I(R6)');

    input_pk_pk_voltage = get_pk_pk_trace(raw_data, 'V(vin+)');
    input_pk_pk_current = get_pk_pk_trace(raw_data, 'I(R6)');

    efficiency = output_power/input_power;

    result_names = ["Step Num", "Acheived Avg Vin","pk-pk ripple Vin","Avg Iin", "pk-pk ripple Iin", "power_mosfet_losses", "power_diode_losses", "aux_mosfet_losses", "aux_diode_losses", "Pin", "Pout", "Eff"];
    var_names = [result_names, params(1,:)];
    var_values = [step_num, input_voltage, input_pk_pk_voltage, input_current, input_pk_pk_current, power_mosfet_losses, power_diode_losses, aux_mosfet_losses, aux_diode_losses, input_power, output_power, efficiency, params(1+step_num,:)];
    results = array2table(var_values,'VariableNames', var_names);
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

function avg_data = get_avg_trace(raw_data, trace_name)
    data = get_trace(raw_data, trace_name);

    total_value = trapz(data.time, abs(data.trace));
    total_time = data.time(end) - data.time(1);

    avg_data = total_value/total_time;
end

function max_data = get_max_trace(raw_data, trace_name)
    data = get_trace(raw_data, trace_name);
    max_data = max(data.trace);
end

function min_data = get_min_trace(raw_data, trace_name)
    data = get_trace(raw_data, trace_name);
    min_data = min(data.trace);
end

function pk_pk_data = get_pk_pk_trace(raw_data, trace_name)
    min = get_min_trace(raw_data, trace_name);
    max = get_max_trace(raw_data, trace_name);
    pk_pk_data = max-min;
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
