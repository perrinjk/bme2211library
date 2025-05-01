
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

% Monday–Thursday: 8 AM–1 AM (8:00 = index 33, 1:00 = index 4 of next day → here we stop at midnight = 96)
open_mask(2:5,33:96) = 1;

% Friday: 8 AM–9 PM → 33 to 84
open_mask(6,33:84) = 1;

% Saturday: 11 AM–9 PM → 45 to 84
open_mask(7,45:84) = 1;

% Sunday: 11 AM–midnight = 45 to 96
open_mask(1,45:96) = 1;

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

legend(days_of_the_week, 'Location', 'northwest')
xlabel('Time of Day (minutes past midnight)')
ylabel('Average Occupancy')
title('Average Library Occupancy by Day of the Week (During Open Hours)')
grid on
hold off