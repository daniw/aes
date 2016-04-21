%% Script to estimate the optimal panel setup

%% clean up workspace
clc;
clear;
close all;

%% Fixed parameters
% Roof size east to west
roof_x = 21;
% Roof size north to south
roof_y = 42;
% length of panels longer edge
panel_x = 1.636;
% length of panels shorter edge
panel_y = 0.992;
% Minimal spacing between modules for mounting and cleaning
spacing_min = 0.5;
% Minimum free angle behind modules
alpha = 19 * pi / 180;
% price per panel
price_panel = 224;
% Radiation 
radiation = [1000 1050 1100 1100 1050 1000 950 900 850 800 750];
% Angles for radiation above
beta_radiation = [0 7 26 33 51 62 69 76 81 87 90];

%% Variable parameters
% panel angle from horizontal
beta_increment = 0.1;
beta_array = [0:beta_increment:90];

% Loop to calculate possible angles
total       = zeros(2,length(beta_array));
nof_x       = zeros(2,length(beta_array));
nof_y       = zeros(2,length(beta_array));
leftover_x  = zeros(2,length(beta_array));
leftover_y  = zeros(2,length(beta_array));
for i = 1:length(beta_array)
    beta = beta_array(i)*pi/180;
    [total(:,i) nof_x(:,i) nof_y(:,i) leftover_x(:,i) leftover_y(:,i)] = panelize(roof_x, roof_y, [panel_x; panel_y], [panel_y; panel_x], beta, alpha, spacing_min);
end;

% calculate light output
radiation_int = interp1(beta_radiation, radiation, beta_array, 'spline');
radiation_total = total .* [radiation_int; radiation_int];

% calculate power per price
price = price_panel .* total;
power_price = radiation_total ./ price;

% plot results
figure(1);
plot(beta_array(1,:), total(1,:), beta_array(1,:), total(2,:), 'LineWidth', 2);
title('Number of panels as function of panel angle');
xlabel('Panel angle [\circ]');
ylabel('Number of panels [1]');
legend('landscape orientation', 'portrait orientation');
grid on;
grid minor;

%figure(2);
%plot(beta_array(1,:), leftover_y(1,:), beta_array(1,:), leftover_y(2,:), 'LineWidth', 2);
%title('Not used space as function of panel angle');
%xlabel('Panel angle [\circ]');
%ylabel('Not used space [m]');
%legend('landscape orientation', 'portrait orientation');
%grid on;
%grid minor;

figure(3);
plot(beta_array(1,:), radiation_total(1,:), beta_array(1,:), radiation_total(2,:), 'LineWidth', 2);
title('total radiation as function of panel angle');
xlabel('Panel angle [\circ]');
ylabel('radiation on all panels [W]');
legend('landscape orientation', 'portrait orientation');
grid on;
grid minor;

figure(4);
plot(beta_array(1,:), power_price(1,:), beta_array(1,:), power_price(2,:), 'LineWidth', 2);
title('Power per price as function of panel angle');
xlabel('Panel angle [\circ]');
ylabel('Power per price per Watt [W / CHF]');
legend('landscape orientation', 'portrait orientation');
grid on;
grid minor;

weight_radiation = 1;
weight_price = 7;
%j = 1;
%for weight_price = [0.0:0.001:1.0];    % Prepared loop for weighting factor iterations
    %weight_radiation = 1 - weight_price;
    disp(['Output power weighting: ' num2str(weight_radiation)]);
    disp(['Panel price weighting:  ' num2str(weight_price)]);

    beta_eval = beta_array;

    eval_result = zeros(2,length(beta_eval));
    eval_price_max = max(max(power_price));
    eval_price_min = min(min(power_price));
    eval_price_span = eval_price_max - eval_price_min;
    eval_radiation_max = max(max(radiation_total));
    eval_radiation_min = min(min(radiation_total));
    eval_radiation_span = eval_radiation_max - eval_radiation_min;
    i = 1;
    for beta_eval_curr = beta_eval
        radiation_eval_l = radiation_total(1,round(beta_eval_curr / beta_increment + 1));
        radiation_eval_p = radiation_total(2,round(beta_eval_curr / beta_increment + 1));
        price_eval_l = power_price(1,round(beta_eval_curr / beta_increment + 1));
        price_eval_p = power_price(2,round(beta_eval_curr / beta_increment + 1));
        eval_result(1, i) = weight_radiation * ((radiation_eval_l - eval_radiation_min) ./ eval_radiation_span) + weight_price * ((price_eval_l - eval_price_min) ./ eval_price_span);
        eval_result(2, i) = weight_radiation * ((radiation_eval_p - eval_radiation_min) ./ eval_radiation_span) + weight_price * ((price_eval_p - eval_price_min) ./ eval_price_span);
        i = i + 1;
    end;
    [beta_opt_weighted, beta_opt] = max(max(eval_result));
    [beta_opt_weighted, eval_l_p] = max(max(eval_result'));
    %[beta_opt_weighted(j), beta_opt(j)] = max(max(eval_result));

    figure(5);
    plot(beta_eval(1,:), eval_result(1,:), beta_eval(1,:), eval_result(2,:), 'LineWidth', 2);
    rectangle('Position',[(beta_opt-1)*beta_increment - 1.0,beta_opt_weighted - 0.1,2.0,0.2], 'EdgeColor', 'r', 'LineWidth', 2, 'Curvature', [1 1])
    %rectangle('Position',[(beta_opt(j)-1)*beta_increment - 1.0,beta_opt_weighted(j) - 0.1,2.0,0.2], 'EdgeColor', 'r', 'LineWidth', 2, 'Curvature', [1 1])
    title(['Weighted result  Weighting factors:    ' 'Output power: ' num2str(weight_radiation) '    ' 'Panel price: ' num2str(weight_price)]);
    xlabel('Panel angle [\circ]');
    ylabel('Weighted result');
    legend('landscape orientation', 'portrait orientation');
    grid on;
    grid minor;
    %hold on;

    %pause(0.1);
    %j = j + 1;
%end;
disp(['Maximum weighted result at an angle of     ' num2str(beta_opt * beta_increment) ' degrees']);
panel_orientation = ['landscape'; 'portrait '];
disp(['Panel orientation:                         ' panel_orientation(eval_l_p,:)]);
nof_x_opt = nof_x(eval_l_p, beta_opt);
disp(['Number of panels in east-west direction:   ' num2str(nof_x_opt)]);
nof_y_opt = nof_y(eval_l_p, beta_opt);
disp(['Number of panels in north-south direction: ' num2str(nof_y_opt)]);
nof_tot_opt = nof_x_opt * nof_y_opt;
disp(['Total number of panels:                    ' num2str(nof_tot_opt)]);

