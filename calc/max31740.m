%% Clean workspace
clc;
clear;
close all;

%% Parameters for fan control design
% Switching frequency
f_sw1 = 25e3;
f_sw2 = 33;
% Start temperature
temp_start = 30;
% Temperature with maximum duty cycle
temp_max = 40;
% Other parameters
%r_1 = 10e3;
% E series for component selection
series_r = 'E24'
series_c = 'E6'

%% Read external data
% NTC data
ntc_data = dlmread('RT_curve_NTCALUG01T103G501.csv', ';', 1, 0);
ntc_data_temp = ntc_data(:,1);
ntc_data_r = ntc_data(:,2);

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

%% Calculate E Series values for components
c_f1_e = e_series(c_f1, series_c);
c_f2_e = e_series(c_f2, series_c);
r_st_e = e_series(r_st, series_r);
r_slope_e = e_series(r_slope, series_r);

%% Recalculate 
f1_e = 10.5455e-6 / c_f1_e;
f2_e = 10.5455e-6 / (c_f1_e + c_f2_e);
temp_start_e = interp1(ntc_data_r, ntc_data_temp, r_st_e, 'pchip');
av_e = (25e3 / r_slope_e) + 1
du_ntc_max_e = 0.5 / av_e;
r_ntc_max_e = r_st_e * ((0.5 - du_ntc_max_e) / (0.5 + du_ntc_max_e));
temp_max_e = interp1(ntc_data_r, ntc_data_temp, r_ntc_max_e, 'pchip');

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

%% Display resulting operating parameters
disp([' ']);
disp(['Operating parameters: ']);
disp(['===================== ']);
disp(['Low switching frequency:  ' disp_units(f2_e, 'Hz')]);
disp(['High switching frequency: ' disp_units(f1_e, 'Hz')]);
disp(['Starting temperature:     ' disp_units(temp_start_e, '°C')]);
disp(['Max speed temperature:    ' disp_units(temp_max_e, '°C')]);

%% Plot duty as function of temperature
t = floor(temp_start_e)-2:0.01:ceil(temp_max_e)+2;
ntc = interp1(ntc_data_temp, ntc_data_r, t, 'pchip');
duty = 200 * (0.5 - ntc ./ (ntc + r_st_e)) * ((25e3 / r_slope_e) + 1);
duty(t < temp_start_e) = 0;
duty(t > temp_max_e) = 100;
plot(t, duty, 'r', 'LineWidth', 2);
grid on; grid minor;
title('PWM duty cycle over temperature');
xlabel('Temperature [^\circ C]');
ylabel('PWM duty cycle [%]');