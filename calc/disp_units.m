% =============================================================================
%> @brief Returns value as string to be used with SI units
%> 
%> @param  value  Value to be converted
%> @param  unit   Unit to be appended after prefix
%> @retval result Value as string with prefix and SI unit
% =============================================================================
function result = disp_units(value, unit)
    if nargin == 1
        unit = '';
    end;
    if isinf(value)
        result = ['inf' unit];
        warning('infinite number converted');
    elseif value > 1e24
        result = [num2str(value/1e24) 'Y' unit];
    elseif value > 1e21
        result = [num2str(value/1e21) 'Z' unit];
    elseif value > 1e18
        result = [num2str(value/1e18) 'E' unit];
    elseif value > 1e15
        result = [num2str(value/1e15) 'P' unit];
    elseif value > 1e12
        result = [num2str(value/1e12) 'T' unit];
    elseif value > 1e9
        result = [num2str(value/1e9) 'G' unit];
    elseif value > 1e6
        result = [num2str(value/1e6) 'M' unit];
    elseif value > 1e3
        result = [num2str(value/1e3) 'k' unit];
    elseif value > 1e0
        result = [num2str(value/1e0) '' unit];
    elseif value > 1e-3
        result = [num2str(value*1e3) 'm' unit];
    elseif value > 1e-6
        result = [num2str(value*1e6) 'u' unit];
    elseif value > 1e-9
        result = [num2str(value*1e9) 'n' unit];
    elseif value > 1e-12
        result = [num2str(value*1e12) 'p' unit];
    elseif value > 1e-15
        result = [num2str(value*1e15) 'f' unit];
    elseif value > 1e-18
        result = [num2str(value*1e18) 'a' unit];
    elseif value > 1e-21
        result = [num2str(value*1e21) 'z' unit];
    else
        result = [num2str(value*1e24) 'y' unit];
    end;
end
