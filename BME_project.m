%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 1: SETTING UP DATA

rawData = readtable('raw_occupancy_data.csv');
%{
IMPORTANT NUMBERS:
96 = number of measurements per day
%}

% days of the week
days_of_the_week = ["Sunday","Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

% time in minutes for one whole day (15 min intervals)
% starts at midnight (0 min) and ends at 11:45 (1425 min)
time = zeros(1,96);
for j = 2:96
    time(j) = time(j-1) + 15; % create 15 min intervals
end


% SELECTION MATRICES for open hours only
open_time_mon_thu = ones(96,1);
for j = 5:32 % 1am to 8am (closed)
    open_time_mon_thu(j) = 0;
end

open_time_fri = ones(96,1);
for j = 5:32 % 1am to 8am (closed)
    open_time_fri(j) = 0;
end
for j = 85:96 % 9pm to modnight (closed)
    open_time_fri(j) = 0;
end

open_time_sat = zeros(96,1);
for j = 45:85 % 11am to 9pm (open)
    open_time_sat(j) = 0;
end

open_time_sun = zeros(96,1);
for j = 45:96 % 11am to 1am (open)
    open_time_sat(j) = 0;
end



% row = day of the week, column = time of day
week1 = zeros(7,96);
week2 = zeros(7,96);
week3 = zeros(7,96);
week4 = zeros(7,96);



row_num = 0; % row number in C (raw data table)
% FILL WEEK 1 DATA
for k = 1:7 % day of the week
    for h = 1:96 % time of day
        week1(k,h) = rawData{row_num+h,5}; % assign a day's values
    end
    row_num = row_num + 96; % move the starting point to midnight of next day
end

% FILL WEEK 2 DATA
for k = 1:7 % day of the week
    for h = 1:96 % time of day
        week2(k,h) = rawData{row_num+h,5}; % assign a day's values
    end
    row_num = row_num + 96; % move the starting point to midnight of next day
end

% FILL WEEK 3 DATA
for k = 1:7 % day of the week
    for h = 1:96 % time of day
        week3(k,h) = rawData{row_num+h,5}; % assign a day's values
    end
    row_num = row_num + 96; % move the starting point to midnight of next day
end

% FILL WEEK 4 DATA
for k = 1:7 % day of the week
    for h = 1:96 % time of day
        week4(k,h) = rawData{row_num+h,5}; % assign a day's values
    end
    row_num = row_num + 96; % move the starting point to midnight of next day
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT BASIC OCCUPANCY DATA PER DAY (WEEK 1)

for j = 1:7
    figure
    scatter(time, week1(j,:), 'ko', 'filled')
    title(days_of_the_week(j))
    xlabel("Time - min")
    ylabel("Occupancy")
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 5: POLYNOMIAL REGRESSION FOR AVERAGE OCCUPANCY

% Compare different polynomial degrees and select the best one
degrees = 1:4; % Try degrees 1 to 4
mse_vals = zeros(size(degrees));
r2_vals = zeros(size(degrees));

fprintf('\nComparing Polynomial Degrees for Sunday:\n');
fprintf('----------------------------------------\n');

for d = degrees
    p = polyfit(time, week1(1,:), d);
    y_fit = polyval(p, time);
    mse = mean((week1(1,:) - y_fit).^2);
    ss_res = sum((week1(1,:) - y_fit).^2);
    ss_tot = sum((week1(1,:) - mean(week1(1,:))).^2);
    r2 = 1 - ss_res/ss_tot;
    mse_vals(d) = mse;
    r2_vals(d) = r2;
    fprintf('Degree %d: MSE = %.2f, R² = %.4f\n', d, mse, r2);
end

% Plot MSE and R² vs degree
figure;
subplot(1,2,1);
plot(degrees, mse_vals, '-o', 'LineWidth', 2);
xlabel('Polynomial Degree');
ylabel('MSE');
title('MSE vs Polynomial Degree');
grid on;

subplot(1,2,2);
plot(degrees, r2_vals, '-o', 'LineWidth', 2);
xlabel('Polynomial Degree');
ylabel('R²');
title('R² vs Polynomial Degree');
grid on;

% Find the best degree based on MSE and R²
[~, best_degree] = min(mse_vals);
fprintf('\nBest polynomial degree based on MSE: %d\n', best_degree);

% Fit the best polynomial
p = polyfit(time, week1(1,:), best_degree);
y_fit = polyval(p, time);

% Calculate final error metrics for the best fit
mse_poly = mean((week1(1,:) - y_fit).^2);
ss_res_poly = sum((week1(1,:) - y_fit).^2);
ss_tot_poly = sum((week1(1,:) - mean(week1(1,:))).^2);
r2_poly = 1 - ss_res_poly/ss_tot_poly;

% Display final metrics
fprintf('\nFinal Polynomial Regression Metrics (Sunday, Degree %d):\n', best_degree);
fprintf('Mean Squared Error (MSE): %.2f\n', mse_poly);
fprintf('R-squared (R²): %.4f\n', r2_poly);

% Plot the original data and the best fitted curve
figure
hold on
plot(time, week1(1,:), 'o', 'DisplayName', 'Original Data')
plot(time, y_fit, '-', 'LineWidth', 2, 'DisplayName', 'Best Fitted Curve')
xlabel('Time (minutes)')
ylabel('Occupancy')
title(sprintf('Polynomial Regression for Sunday (Degree %d, MSE: %.2f, R²: %.4f)', best_degree, mse_poly, r2_poly))
legend('Location', 'best')
grid on
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 6: LINEAR REGRESSION FOR EACH DAY (FILTERED)

for j = 1:7
    figure
    
    % Logical index for time > 250
    valid_idx = time > 250;
    
    % Filtered time and occupancy data
    filtered_time = time(valid_idx);
    filtered_occupancy = week1(j, valid_idx);
    
    % Scatter plot
    scatter(filtered_time, filtered_occupancy, 'ko', 'filled')
    hold on
    
    % Linear fit on filtered data
    p = polyfit(filtered_time, filtered_occupancy, 1); % Linear regression
    fit_line = polyval(p, filtered_time);              % Evaluate the fit
    
    % Calculate error metrics for linear regression
    mse_linear = mean((filtered_occupancy - fit_line).^2);
    ss_res_linear = sum((filtered_occupancy - fit_line).^2);
    ss_tot_linear = sum((filtered_occupancy - mean(filtered_occupancy)).^2);
    r2_linear = 1 - ss_res_linear/ss_tot_linear;
    
    % Display metrics
    fprintf('\nLinear Regression Metrics (%s):\n', days_of_the_week(j));
    fprintf('Mean Squared Error (MSE): %.2f\n', mse_linear);
    fprintf('R-squared (R²): %.4f\n', r2_linear);
    
    % Plot the line of best fit
    plot(filtered_time, fit_line, 'r-', 'LineWidth', 2)
    
    % Labels and title
    title(sprintf('%s (MSE: %.2f, R²: %.4f)', days_of_the_week(j), mse_linear, r2_linear))
    xlabel("Time - min")
    ylabel("Occupancy")
    legend('Data', 'Line of Best Fit')
    grid on
end

