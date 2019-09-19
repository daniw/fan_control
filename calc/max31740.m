%% MAX31740 Dimensioning Script
% Script to dimension the circuit around a MAX31740 fan controller
%
%% Usage
% The section with the parameters allows to adjust the fan controller to the 
% needs of the application. 
%
% * f_sw1 PWM: switching frequency without solderjumper J5 installed. 
% * f_sw2 PWM: switching frequency with solderjumper J5 installed. 
% * temp_start: Temperature at which the fan starts spinning. 
% * temp_max: Temperature at which the fan is at maximum speed. 
% * d_min: Minimum fan duty cycle. 
% * always_on: Behaviour when desired fan speed is below d_min. 0 stops the fan below d_min, 1 keeps the fan at d_min. 
% * r_1_range: Vector that defines the desired range of resistance values for R1. 
% * series_r: E series that should be used for resistor values. 
% * series_c: E series that should be used for capacitor values. 
% * ntc_data_file: Path to the file with the temperature and resistance data of the used NTC thermistor. 
% * ntc_data_separator: Separator that is used to separate columns in the NTC thermistor data file. 
% * ntc_data_col_temp: Column number of the temperature data in the NTC thermistor data file. 
% * ntc_data_col_res: Column number of the resistance data in the NTC thermistor data file. 
%
%% Author
% daniw
%
% daniel.winz.amz@gmail.com

%% Clean workspace
clc;
clear;
close all;

%% Parameters for fan control design
% Switching frequency
f_sw1 = 25e3;
f_sw2 = 33;
% Start temperature
temp_start = 35;
% Temperature with maximum duty cycle
temp_max = 45;
% Minimum duty cycle in percent
d_min = 0;
% Low temperature behaviour
always_on = true;
% Other parameters
r_1_range = [10e3 100e3];
% E series for component selection
series_r = 'E24';
series_c = 'E6';
% NTC data
ntc_data_file = 'RT_curve_NTCALUG01T103G501.csv';
ntc_data_separator = ';';
ntc_data_col_temp = 1;
ntc_data_col_res = 2;

%% Read external data
% NTC data
ntc_data = dlmread(ntc_data_file, ntc_data_separator, 1, 0);
ntc_data_temp = ntc_data(:,ntc_data_col_temp);
ntc_data_r = ntc_data(:,ntc_data_col_res);

%% Calculation of component values
% Switching frequency
c_f1 = 10.5455e-6/f_sw1;
c_f2 = 10.5455e-6/f_sw2 - c_f1;
% Starting temperature
r_st = interp1(ntc_data_temp, ntc_data_r, temp_start, 'pchip');
% Minimum temperature

% Slope
r_ntc_max = interp1(ntc_data_temp, ntc_data_r, temp_max, 'pchip');
du_ntc_max = 0.5 - r_ntc_max / (r_ntc_max + r_st);
av = 0.5 / du_ntc_max;
r_slope = 25e3 / (av - 1);

% Minimum duty cycle
d_min = max(0, min(100, d_min));
[r_2, r_1, u_d_min] = e_series_divider(1, d_min/200, r_1_range, series_r);

%% Calculate E Series values for components
c_f1_e = e_series(c_f1, series_c);
c_f2_e = e_series(c_f2, series_c);
r_st_e = e_series(r_st, series_r, 'e48');
r_slope_e = e_series(r_slope, series_r);

%% Recalculate 
f1_e = 10.5455e-6 / c_f1_e;
f2_e = 10.5455e-6 / (c_f1_e + c_f2_e);
temp_start_e = interp1(ntc_data_r, ntc_data_temp, r_st_e, 'pchip');
av_e = (25e3 / r_slope_e) + 1;
du_ntc_max_e = 0.5 / av_e;
r_ntc_max_e = r_st_e * ((0.5 - du_ntc_max_e) / (0.5 + du_ntc_max_e));
temp_max_e = interp1(ntc_data_r, ntc_data_temp, r_ntc_max_e, 'pchip');
d_min_e = u_d_min * 200;

%% Display results
disp(['Component values: ']);
disp(['================= ']);
% C_f1
disp(['C_f1:    ' disp_units(c_f1_e, 'F')]);
disp(['C_f2:    ' disp_units(c_f2_e, 'F')]);
% R_st
disp(['R_st:    ' disp_units(r_st_e, 'Ohm')]);
% R_slope
disp(['R_slope: ' disp_units(r_slope_e, 'Ohm')]);
% R_1
disp(['R_1:     ' disp_units(r_1, 'Ohm')]);
% R_2
disp(['R_2:     ' disp_units(r_2, 'Ohm')]);

%% Display resulting operating parameters
disp([' ']);
disp(['Operating parameters: ']);
disp(['===================== ']);
disp(['Low switching frequency:  ' disp_units(f2_e, 'Hz')]);
disp(['High switching frequency: ' disp_units(f1_e, 'Hz')]);
disp(['Starting temperature:     ' disp_units(temp_start_e, '°C')]);
disp(['Max speed temperature:    ' disp_units(temp_max_e, '°C')]);
disp(['Minimum duty cycle:       ' disp_units(d_min_e, '%')]);

%% Plot duty as function of temperature
t = floor(temp_start_e)-2:0.01:ceil(temp_max_e)+2;
ntc = interp1(ntc_data_temp, ntc_data_r, t, 'pchip');
duty = 200 * (0.5 - ntc ./ (ntc + r_st_e)) * ((25e3 / r_slope_e) + 1);
if always_on
    duty(duty < d_min_e) = d_min_e;
else
    duty(duty < d_min_e) = 0;
end
duty(t > temp_max_e) = 100;
plot(t, duty, 'r', 'LineWidth', 2);
grid on; grid minor;
title('PWM duty cycle over temperature');
xlabel('Temperature [^\circ C]');
ylabel('PWM duty cycle [%]');
ylim([0 100]);
