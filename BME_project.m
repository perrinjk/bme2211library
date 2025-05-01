
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP 1: SETTING UP DATA

rawData = readtable('C:/Users/alexs/Downloads/raw_occupancy_data.csv');
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

