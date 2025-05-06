
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

% for j = 1:7
%     figure
%     scatter(time, week1(j,:), 'ko', 'filled')
%     title(days_of_the_week(j))
%     xlabel("Time - min")
%     ylabel("Occupancy")
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 2: AVERAGING WEEKLY DATA AND PLOTTING ALL DAYS ON ONE GRAPH

% Average occupancy across the four weeks
avg_week = (week1 + week2 + week3 + week4) / 4;

% Open hour masks (1 = open, 0 = closed)
open_mask = zeros(7,96);

% Monday (index 2): 12 AM–1 AM (1:4) and 8 AM–midnight (33:96)
open_mask(2, [1:4, 33:96]) = 1;

% Tuesday–Thursday (index 3–5): 12 AM–1 AM (1:4) and 8 AM–midnight (33:96)
open_mask(3:5, [1:4, 33:96]) = 1;

% Friday (index 6): 8 AM–9 PM (33:84)
open_mask(6,33:84) = 1;

% Saturday (index 7): 11 AM–9 PM (45:84)
open_mask(7,45:84) = 1;

% Sunday (index 1): 12 AM–1 AM (1:4) and 11 AM–midnight (45:96)
open_mask(1, [1:4, 45:96]) = 1;

% Apply masks (set closed times to NaN so MATLAB skips them when plotting)
masked_avg_week = avg_week;
masked_avg_week(open_mask == 0) = NaN;

% Plot all 7 days on one graph
figure
hold on
colors = lines(7); % get 7 distinct colors

for j = 1:7
    plot(time, masked_avg_week(j,:), 'Color', colors(j,:), 'LineWidth', 1.8)
end

% Set x-axis to clock times
xticks(0:60:1440) % every hour
xticklabels({'12 AM','1 AM','2 AM','3 AM','4 AM','5 AM','6 AM','7 AM','8 AM',...
             '9 AM','10 AM','11 AM','12 PM','1 PM','2 PM','3 PM','4 PM',...
             '5 PM','6 PM','7 PM','8 PM','9 PM','10 PM','11 PM','12 AM'})

xlim([0 1440])
xlabel('Time of Day')
ylabel('Average Occupancy')
title('Average Library Occupancy by Day of the Week (During Open Hours)')
legend(days_of_the_week, 'Location', 'northwest')
grid on
hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 3: AVERAGING WEEKLY DATA AND PLOTTING ALL DAYS ON ONE GRAPH
% Excluding data from February 14 and February 27

% Combine all weeks into a 3D matrix: day x time x week
all_data = cat(3, week1, week2, week3, week4);

% Days to remove (Feb 14 and 27)
remove_days = [14, 27];  % day indices (1-based from Feb 1)

% Feb 1, 2025 is a Saturday → index 7 (assuming Sunday = 1)
start_day_index = 7;

% Compute correct weekday indices (1=Sunday, ..., 7=Saturday)
remove_day_indices = mod(start_day_index + remove_days - 2, 7) + 1;

% Compute which week they fall in
remove_week_indices = floor((remove_days - 1) / 7) + 1;

% Remove the data (set to NaN so it's excluded from average)
for idx = 1:length(remove_days)
    d = remove_day_indices(idx);
    w = remove_week_indices(idx);
    all_data(d,:,w) = NaN;
end

% Compute average across weeks, ignoring NaNs
avg_week = mean(all_data, 3, 'omitnan');

% Open hour masks (1 = open, 0 = closed)
open_mask = zeros(7,96);

% Monday (index 2): 12 AM–1 AM (1:4) and 8 AM–midnight (33:96)
open_mask(2, [1:4, 33:96]) = 1;

% Tuesday–Thursday (index 3–5): 12 AM–1 AM (1:4) and 8 AM–midnight (33:96)
open_mask(3:5, [1:4, 33:96]) = 1;

% Friday (index 6): 8 AM–9 PM (33:84)
open_mask(6,33:84) = 1;

% Saturday (index 7): 11 AM–9 PM (45:84)
open_mask(7,45:84) = 1;

% Sunday (index 1): 12 AM–1 AM (1:4) and 11 AM–midnight (45:96)
open_mask(1, [1:4, 45:96]) = 1;

% Apply open hour mask
masked_avg_week = avg_week;
masked_avg_week(open_mask == 0) = NaN;

% Plot all 7 days on one graph
figure
hold on
colors = lines(7); % get 7 distinct colors

for j = 1:7
    plot(time, masked_avg_week(j,:), 'Color', colors(j,:), 'LineWidth', 1.8)
end

% Set x-axis to clock time labels
xticks(0:60:1440)
xticklabels({'12 AM','1 AM','2 AM','3 AM','4 AM','5 AM','6 AM','7 AM','8 AM',...
             '9 AM','10 AM','11 AM','12 PM','1 PM','2 PM','3 PM','4 PM',...
             '5 PM','6 PM','7 PM','8 PM','9 PM','10 PM','11 PM','12 AM'})

xlim([0 1440])
xlabel('Time of Day')
ylabel('Average Occupancy')
title('Average Library Occupancy by Day (Open Hours Only, Feb 14 & 27 Removed)')
legend(days_of_the_week, 'Location', 'northwest')
grid on
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 4: COMPARE SPECIFIC VS. AVERAGE DAYS (Feb 14 & 27)

% Manually pull Thursdays (index 5) and Fridays (index 6) from raw weeks
all_thursdays = [week1(5,:); week2(5,:); week3(5,:); week4(5,:)];  % 4 Thursdays
all_fridays   = [week1(6,:); week2(6,:); week3(6,:); week4(6,:)];  % 4 Fridays

% Feb 27 = week 4 Thursday (row 4), Feb 14 = week 2 Friday (row 2)
feb27_data = all_thursdays(4,:);
feb14_data = all_fridays(2,:);

% Averages without those dates
avg_thursday = mean(all_thursdays([1 2 3],:), 'omitnan');
avg_friday   = mean(all_fridays([1 3 4],:), 'omitnan');

% Open hour masks
friday_mask = zeros(1,96); friday_mask(33:84) = 1;
thursday_mask = zeros(1,96); thursday_mask([1:4, 33:96]) = 1;

% Apply masks (set closed hours to NaN)
avg_friday(friday_mask == 0) = NaN;
feb14_data(friday_mask == 0) = NaN;

avg_thursday(thursday_mask == 0) = NaN;
feb27_data(thursday_mask == 0) = NaN;

% Plot
figure
hold on

% Averages (dark colors)
plot(time, avg_friday, 'Color', [0 0 0.5], 'LineWidth', 2.2)        % dark blue
plot(time, avg_thursday, 'Color', [0 0.5 0], 'LineWidth', 2.2)      % dark green

% Individual dates (light colors)
plot(time, feb14_data, 'Color', [0.4 0.75 1], 'LineWidth', 2)       % light blue
plot(time, feb27_data, 'Color', [0.5 1 0.5], 'LineWidth', 2)        % light green

% Axes and labels
xticks(0:60:1440)
xticklabels({'12 AM','1 AM','2 AM','3 AM','4 AM','5 AM','6 AM','7 AM','8 AM',...
             '9 AM','10 AM','11 AM','12 PM','1 PM','2 PM','3 PM','4 PM',...
             '5 PM','6 PM','7 PM','8 PM','9 PM','10 PM','11 PM','12 AM'})

xlim([0 1440])
xlabel('Time of Day')
ylabel('Occupancy')
title('Occupancy Comparison: Feb 14 & 27 vs Weekly Averages')
legend({'Avg. Friday (excl. Feb 14)', 'Avg. Thursday (excl. Feb 27)', ...
        'Feb 14', 'Feb 27'}, ...
        'Location', 'northwest')
grid on
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 5: POLYNOMIAL REGRESSION WITH CROSS-VALIDATION FOR EACH DAY

rng(1); % For reproducibility
best_degrees = zeros(1,7);
best_mse_val = zeros(1,7);
best_r2_val = zeros(1,7);

for day = 1:7
    % Get filtered data for current day
    valid_idx = time > 250;
    filtered_time = time(valid_idx);
    filtered_occupancy = masked_avg_week(day, valid_idx);

    % Remove NaNs before regression
    non_nan_idx = ~isnan(filtered_occupancy);
    filtered_time = filtered_time(non_nan_idx);
    filtered_occupancy = filtered_occupancy(non_nan_idx);

    % Split into training (75%) and validation (25%) sets
    n = length(filtered_time);
    idx = randperm(n);
    n_train = round(0.75 * n);
    train_idx = idx(1:n_train);
    val_idx = idx(n_train+1:end);

    t_train = filtered_time(train_idx);
    y_train = filtered_occupancy(train_idx);
    t_val = filtered_time(val_idx);
    y_val = filtered_occupancy(val_idx);

    degrees = 1:4;
    mse_val = zeros(size(degrees));
    r2_val = zeros(size(degrees));
    mse_train = zeros(size(degrees));
    r2_train = zeros(size(degrees));

    fprintf('\nCross-Validation for %s:\n', days_of_the_week(day));
    fprintf('----------------------------------------\n');

    for d = degrees
        p = polyfit(t_train, y_train, d);
        y_fit_train = polyval(p, t_train);
        y_fit_val = polyval(p, t_val);

        mse_train(d) = mean((y_train - y_fit_train).^2);
        ss_res_train = sum((y_train - y_fit_train).^2);
        ss_tot_train = sum((y_train - mean(y_train)).^2);
        r2_train(d) = 1 - ss_res_train/ss_tot_train;

        mse_val(d) = mean((y_val - y_fit_val).^2);
        ss_res_val = sum((y_val - y_fit_val).^2);
        ss_tot_val = sum((y_val - mean(y_val)).^2);
        r2_val(d) = 1 - ss_res_val/ss_tot_val;

        fprintf('Degree %d: Train MSE = %.2f, Train R² = %.4f | Val MSE = %.2f, Val R² = %.4f\n', ...
            d, mse_train(d), r2_train(d), mse_val(d), r2_val(d));
    end

    % Plot MSE and R² vs degree for current day
    figure;
    subplot(1,2,1);
    plot(degrees, mse_train, '-o', 'LineWidth', 2, 'DisplayName', 'Train');
    hold on;
    plot(degrees, mse_val, '-s', 'LineWidth', 2, 'DisplayName', 'Validation');
    xlabel('Polynomial Degree');
    ylabel('MSE');
    title(sprintf('MSE vs Degree - %s', days_of_the_week(day)));
    legend; grid on;

    subplot(1,2,2);
    plot(degrees, r2_train, '-o', 'LineWidth', 2, 'DisplayName', 'Train');
    hold on;
    plot(degrees, r2_val, '-s', 'LineWidth', 2, 'DisplayName', 'Validation');
    xlabel('Polynomial Degree');
    ylabel('R²');
    title(sprintf('R² vs Degree - %s', days_of_the_week(day)));
    legend; grid on;

    % Select best degree based on validation MSE
    [~, best_degree] = min(mse_val);
    best_degrees(day) = best_degree;
    best_mse_val(day) = mse_val(best_degree);
    best_r2_val(day) = r2_val(best_degree);

    % Fit and plot best polynomial on all data for visual inspection
    p = polyfit(filtered_time, filtered_occupancy, best_degree);
    y_fit = polyval(p, filtered_time);

    figure
    hold on
    plot(filtered_time, filtered_occupancy, 'o', 'DisplayName', 'Original Data')
    plot(filtered_time, y_fit, '-', 'LineWidth', 2, 'DisplayName', sprintf('Best Fit (deg %d)', best_degree))
    xlabel('Time (minutes)')
    ylabel('Occupancy')
    title(sprintf('Poly Reg (CV) for %s (Degree %d, Val MSE: %.2f, Val R²: %.4f)', ...
        days_of_the_week(day), best_degree, best_mse_val(day), best_r2_val(day)))
    legend('Location', 'best')
    grid on
    hold off
end

% Display summary
fprintf('\nSummary of Best Polynomial Fits (Cross-Validation) for Each Day:\n');
fprintf('----------------------------------------\n');
fprintf('Day\t\tBest Degree\tVal MSE\t\tVal R²\n');
for day = 1:7
    fprintf('%s\t%d\t\t%.2f\t\t%.4f\n', days_of_the_week(day), best_degrees(day), best_mse_val(day), best_r2_val(day));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 6: LINEAR REGRESSION FOR EACH DAY (FILTERED)

for j = 1:7
    figure
    
    % Logical index for time > 250
    valid_idx = time > 250;
    
    % Filtered time and occupancy data
    filtered_time = time(valid_idx);
    filtered_occupancy = masked_avg_week(j, valid_idx);
    
    % Remove NaNs before regression
    non_nan_idx = ~isnan(filtered_occupancy);
    filtered_time = filtered_time(non_nan_idx);
    filtered_occupancy = filtered_occupancy(non_nan_idx);
    
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
