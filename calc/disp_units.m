% =============================================================================
%> @brief Returns value as string to be used with SI units
%> 
%> @param  value  Value to be converted
%> @param  unit   Unit to be appended after prefix
%> @retval result Value as string with prefix and SI unit
% =============================================================================
function result = disp_units(value, unit, spacer)
    if nargin == 1
        unit = '';
    end;
    if nargin <= 2
        spacer = ' ';
    end;
    if isinf(value)
        result = ['inf' unit];
        warning('infinite number converted');
    elseif value == 0
        result = [num2str(value) unit];
    elseif value > 1e24
        result = [num2str(value/1e24) spacer 'Y' unit];
    elseif value > 1e21
        result = [num2str(value/1e21) spacer 'Z' unit];
    elseif value > 1e18
        result = [num2str(value/1e18) spacer 'E' unit];
    elseif value > 1e15
        result = [num2str(value/1e15) spacer 'P' unit];
    elseif value > 1e12
        result = [num2str(value/1e12) spacer 'T' unit];
    elseif value > 1e9
        result = [num2str(value/1e9)  spacer 'G' unit];
    elseif value > 1e6
        result = [num2str(value/1e6)  spacer 'M' unit];
    elseif value > 1e3
        result = [num2str(value/1e3)  spacer 'k' unit];
    elseif value > 1e0
        result = [num2str(value/1e0)  spacer ''  unit];
    elseif value > 1e-3
        result = [num2str(value*1e3)  spacer 'm' unit];
    elseif value > 1e-6
        result = [num2str(value*1e6)  spacer 'u' unit];
    elseif value > 1e-9
        result = [num2str(value*1e9)  spacer 'n' unit];
    elseif value > 1e-12
        result = [num2str(value*1e12) spacer 'p' unit];
    elseif value > 1e-15
        result = [num2str(value*1e15) spacer 'f' unit];
    elseif value > 1e-18
        result = [num2str(value*1e18) spacer 'a' unit];
    elseif value > 1e-21
        result = [num2str(value*1e21) spacer 'z' unit];
    else
        result = [num2str(value*1e24) spacer 'y' unit];
    end;
end
