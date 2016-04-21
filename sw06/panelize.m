function [nof_panels, nof_x, nof_y, leftover_x, leftover_y] = panelize(roof_x, roof_y, panel_x, panel_y, beta, alpha, spacing_min)
% PANELIZE Function to estimate the number of panels placed on a roof
%   Parameters: 
%       roof_x:      roof size in x direction
%       roof_y:      roof size in y direction
%       panel_x:     panel size in x direction
%       panel_y:     panel size in y direction
%       beta:        angle of panels from horizontal mounting in radiant
%       alpha:       minimum free angle behind panels in radiant
%       spacing_min: minimum spacing behind panels for mounting and cleaning
%   Return values:
%       nof_panels: total number of panels
%       nof_x:      number of panels in x direction
%       nof_y:      number of panels in y direction
%       leftover_x: not used space in x direction
%       leftover_y: not used space in y direction
    nof_x = floor((roof_x - spacing_min) ./ panel_x);
    leftover_x = roof_x - (nof_x .* panel_x);
    panel_y_corr = panel_y .* cos(beta);
    panel_h = panel_y .* sin(beta);
    spacing_angle = panel_h ./ tan(alpha);
    spacing = zeros(length(spacing_angle), 1);
    for i = 1:length(spacing_angle)
        if (spacing_angle(i) > spacing_min)
            spacing(i) = spacing_angle(i);
        else
            spacing(i) = spacing_min;
        end
    end
    nof_y = floor((roof_y - panel_y) ./ (panel_y_corr + spacing)) + 1;
    leftover_y = roof_y - ((nof_y - 1) .* (panel_y_corr + spacing) + panel_y_corr);
    nof_panels = nof_x .* nof_y;
end
