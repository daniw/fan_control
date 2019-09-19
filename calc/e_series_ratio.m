%% e_series_ratio
% Select component values for a specific ratio based on e-series component values
% 
%% Syntax
% 
%  r2 = e_series_ratio(ratio, r1_range)
%  r2 = e_series_ratio(ratio, r1_range, series)
%  r2 = e_series_ratio(ratio, r1_range, series, dir)
%  [r2, r1, ratio, erratio, r2_sort, r1_sort, ratio_sort, error_sort] = e_series_ratio(___)
% 
%% Description
% 
% e_series_ratio selects the values of two components from an e-series to 
% best match the desired ratio between the two components. 
%
% $$ ratio = \frac{R_2}{R_1}$$
% 
%% Parameters
%
% * ratio: Desired ratio between the two components
% * r1_range: Scalar or vector to specify input side component value or value range
% * series: (default: 'e24') E-series to choose component values from
% * dir: (default: 'nearest') Direction to be used for rounding of ratio
% 
%% Return values
%
% * r2: Value of best matching other component
% * r1: Value of best matching given component
% * ratio: Resulting output voltage with selected best matching component values
% * error: Error of the output voltage with the selected best matching component values
% * r2_sort: List of considered values for other component sorted for absolute error
% * r1_sort: List of considered values for given component sorted for absolute error
% * ratio_sort: List of ratios of considered component combinations sorted for absolute error
% * error_sort: List of resulting errors of considered component combinations sorted for absolute error
%
%% Examples
% 
%  e_series_ratio(pi, 10e3)
%  ans = 
%          30000
%
%  [r2, r1] = e_series_ratio(pi, 10e3)
%  r2 = 
%          30000
%  r1 = 
%          10000
%
%  [r2, r1] = e_series_ratio(pi, [10e3 30e3])
%  r2 = 
%          47000
%  r1 = 
%          16000
%
%  [r2, r1, ratio, error] = e_series_ratio(pi, [10e3 30e3])
%  r2 = 
%          47000
%  r1 = 
%          16000
%  ratio = 
%          3.1333
%  error = 
%          0.0083
%
%  [r2, r1, ratio, error] = e_series_ratio(pi, [10e3 30e3], 'e12')
%  r2 = 
%          47000
%  r1 = 
%          15000
%  ratio = 
%          3.1333
%  error = 
%          0.0083
%
%  [r2, r1, ratio, error] = e_series_ratio(pi, [10e3 30e3], 'e12', 'up')
%  r2 = 
%          39000
%  r1 = 
%          12000
%  ratio = 
%          3.2500
%  error = 
%          0.1084
%
%  [r2, r1, ratio, error, r2_sort, r1_sort, ratio_sort, error_sort] = e_series_ratio(pi, [10e3 30e3], 'e12', 'up')
%  r2 =
%          39000
%  r1 =
%          12000
%  ratio =
%          3.5294
%  error =
%          0.2294
%  r2_sort =
%          39000       33000      120000      100000       82000       56000       68000
%  r1_sort =
%          12000       10000       33000       27000       22000       15000       18000
%  ratio_sort =
%          3.2500    3.3000    3.6364    3.7037    3.7273    3.7333    3.7778
%  error_sort =
%          0.1084    0.1584    0.4948    0.5621    0.5857    0.5917    0.6362
%
%% Author
% daniw
%
% daniel.winz.amz@gmail.com

function [r2_best, r1_best, ratio_best, error_best, r2_sort, r1_sort, ratio_sort, error_sort] = e_series_ratio(ratio, range, series, dir)
    % E series values
    e3   = [1.0 2.2 4.7 10.0];
    e6   = [1.0 1.5 2.2 3.3 4.7 6.8 10.0];
    e12  = [1.0 1.2 1.5 1.8 2.2 2.7 3.3 3.9 4.7 5.6 6.8 8.2 ...
            10.0];
    e24  = [1.0 1.1 1.2 1.3 1.5 1.6 1.8 2.0 2.2 2.4 2.7 3.0 ...
            3.3 3.6 3.9 4.3 4.7 5.1 5.6 6.2 6.8 7.5 8.2 9.1 ...
            10.0];
    e48  = [1.00 1.05 1.10 1.15 1.21 1.27 1.33 1.40 1.47 1.54 1.62 1.69 ...
            1.78 1.87 1.96 2.05 2.15 2.26 2.37 2.49 2.61 2.74 2.87 3.01 ...
            3.16 3.32 3.48 3.65 3.83 4.02 4.22 4.42 4.64 4.87 5.11 5.36 ...
            5.62 5.90 6.19 6.49 6.81 7.15 7.50 7.87 8.25 8.66 9.09 9.53 ...
            10.00];
    e96  = [1.00 1.02 1.05 1.07 1.10 1.13 1.15 1.18 1.21 1.24 1.27 1.30 ...
            1.33 1.37 1.40 1.43 1.47 1.50 1.54 1.58 1.62 1.65 1.69 1.74 ...
            1.78 1.82 1.87 1.91 1.96 2.00 2.05 2.10 2.15 2.21 2.26 2.32 ...
            2.37 2.43 2.49 2.55 2.61 2.67 2.74 2.80 2.87 2.94 3.01 3.09 ...
            3.16 3.24 3.32 3.40 3.48 3.57 3.65 3.74 3.83 3.92 4.02 4.12 ...
            4.22 4.32 4.42 4.53 4.64 4.75 4.87 4.99 5.11 5.23 5.36 5.49 ...
            5.62 5.76 5.90 6.04 6.19 6.34 6.49 6.65 6.81 6.98 7.15 7.32 ...
            7.50 7.68 7.87 8.06 8.25 8.45 8.66 8.87 9.09 9.31 9.53 9.76 ...
            10.00];
    e192 = [1.00 1.01 1.02 1.04 1.05 1.06 1.07 1.09 1.10 1.11 1.13 1.14 ...
            1.15 1.17 1.18 1.20 1.21 1.23 1.24 1.26 1.27 1.29 1.30 1.32 ...
            1.33 1.35 1.37 1.38 1.40 1.42 1.43 1.45 1.47 1.49 1.50 1.52 ...
            1.54 1.56 1.58 1.60 1.62 1.64 1.65 1.67 1.69 1.72 1.74 1.76 ...
            1.78 1.80 1.82 1.84 1.87 1.89 1.91 1.93 1.96 1.98 2.00 2.03 ...
            2.05 2.08 2.10 2.13 2.15 2.18 2.21 2.23 2.26 2.29 2.32 2.34 ...
            2.37 2.40 2.43 2.46 2.49 2.52 2.55 2.58 2.61 2.64 2.67 2.71 ...
            2.74 2.77 2.80 2.84 2.87 2.91 2.94 2.98 3.01 3.05 3.09 3.12 ...
            3.16 3.20 3.24 3.28 3.32 3.36 3.40 3.44 3.48 3.52 3.57 3.61 ...
            3.65 3.70 3.74 3.79 3.83 3.88 3.92 3.97 4.02 4.07 4.12 4.17 ...
            4.22 4.27 4.32 4.37 4.42 4.48 4.53 4.59 4.64 4.70 4.75 4.81 ...
            4.87 4.93 4.99 5.05 5.11 5.17 5.23 5.30 5.36 5.42 5.49 5.56 ...
            5.62 5.69 5.76 5.83 5.90 5.97 6.04 6.12 6.19 6.26 6.34 6.42 ...
            6.49 6.57 6.65 6.73 6.81 6.90 6.98 7.06 7.15 7.23 7.32 7.41 ...
            7.50 7.59 7.68 7.77 7.87 7.96 8.06 8.16 8.25 8.35 8.45 8.56 ...
            8.66 8.76 8.87 8.98 9.09 9.20 9.31 9.42 9.53 9.65 9.76 9.88 ...
            10.00];
    % Check input parameters
    if isnumeric(ratio)
        if ratio == inf
            r2_best = 0;
            r1_best = inf;
            ratio_best = 0;
            error_best = 0;
            r2_sort = 0;
            r1_sort = inf;
            ratio_sort = 0;
            error_sort = 0;
        elseif ratio == 0
            r2_best = inf;
            r1_best = 0;
            ratio_best = 0;
            error_best = 0;
            r2_sort = inf;
            r1_sort = 0;
            ratio_sort = 0;
            error_sort = 0;
        elseif ratio < 0
            error('Ratio must be positive');
        else
            % Select E series
            if nargin <= 2
                series = 'e24';
                e_serie = e24;
            else
                switch series
                    case {3, '3', 'E3', 'e3'}
                        e_serie = e3;
                    case {6, '6', 'E6', 'e6'}
                        e_serie = e6;
                    case {12, '12', 'E12', 'e12'}
                        e_serie = e12;
                    case {24, '24', 'E24', 'e24'}
                        e_serie = e24;
                    case {48, '48', 'E48', 'e48'}
                        e_serie = e48;
                    case {96, '96', 'E96', 'e96'}
                        e_serie = e96;
                    case {192, '192', 'E192', 'e192'}
                        e_serie = e192;
                    otherwise
                        error(['unknown E series "' num2str(series) '" selected']);
                end
            end
            % Rounding Direction
            if nargin >=4
                switch dir
                    case {'nearest', 'Nearest', 'n', 'N'}
                        dir = 'nearest';
                    case {'up', 'Up', 'u', 'U'}
                        dir = 'next';
                    case {'down', 'Down', 'd', 'D'}
                        dir = 'previous';
                    otherwise
                        warning(['Unknown rounding direction "' dir '" using nearest instead']);
                        dir = 'nearest';
                end
            else
                dir = 'nearest';
            end
            %% Create R1 vector
            if numel(range) == 1
                r1_list = e_series(range, series);
            else
                % Calculate decade
                r1_start_exponent = floor(log10(min(range)));
                r1_end_exponent = floor(log10(max(range)));
                % Calculate remainder
                r1_start_remainder = min(range) ./ (10.^r1_start_exponent);
                r1_end_remainder = max(range) ./ (10.^r1_end_exponent);
                % Select extreme r1 value from E series
                r1_start_remainder = interp1(e_serie, e_serie, r1_start_remainder, 'nearest');
                r1_end_remainder = interp1(e_serie, e_serie, r1_end_remainder, 'nearest');
                % Create r1 list
                exponent = r1_start_exponent;
                r1_list = e_serie(find(and(e_serie >= r1_start_remainder*10^(r1_start_exponent-exponent), e_serie <= r1_end_remainder*10^(r1_end_exponent-exponent)))) * 10^exponent;
                while exponent < r1_end_exponent
                    exponent = exponent + 1;
                    r1_list = [r1_list e_serie(find(and(e_serie >= r1_start_remainder*10^(r1_start_exponent-exponent), e_serie <= r1_end_remainder*10^(r1_end_exponent-exponent)))) * 10^exponent];
                end
            end
            % Calculate r2 vectors
            switch dir
                case 'next'
                    r2_list = e_series(r1_list * ratio, series, 'up');
                case 'previous'
                    r2_list = e_series(r1_list * ratio, series, 'down');
                case 'nearest'
                    r2_list = [e_series(r1_list * ratio, series, 'down') e_series(r1_list * ratio, series, 'up')];
                    r1_list = [r1_list r1_list];
                otherwise
                    error(['Unknown rounding command']);
            end
            % Calculate ratios and errors
            ratio_list = r2_list ./ r1_list;
            error_list = abs(ratio_list - ratio);
            % Sort results
            [error_sort, index_sort] = sort(error_list);
            ratio_sort = ratio_list(index_sort);
            r1_sort = r1_list(index_sort);
            r2_sort = r2_list(index_sort);
            % Select best result
            r1_best = r1_sort(1);
            r2_best = r2_sort(1);
            ratio_best = ratio_sort(1);
            error_best = error_sort(1);
        end
    else
        error('Ratio needs to be a number');
    end
end
