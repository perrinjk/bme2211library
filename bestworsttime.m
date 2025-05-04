% Ensure 96 time steps (0:15 to 23:45)
time_minutes = 0:15:1425;  % 96 time slots

% Class hours: 8 AM to 5 PM
class_start_min = 8 * 60;
class_end_min = 17 * 60;

class_start_idx = find(time_minutes >= class_start_min, 1, 'first');  % ≈33
class_end_idx = find(time_minutes >= class_end_min, 1, 'first');      % ≈69

% Guard against overflow
class_start_idx = min(class_start_idx, 96);
class_end_idx = min(class_end_idx, 96);

day_names = {'Sunday', 'Monday', 'Tuesday', 'Wednesday', ...
             'Thursday', 'Friday', 'Saturday'};

fprintf('=== Peak Occupancy by Day ===\n\n');

for d = 1:7
    day_data = all_data(d,:);
    if length(day_data) < 96
        warning('%s has fewer than 96 time points. Skipping.\n', day_names{d});
        continue;
    end

    if all(isnan(day_data))
        fprintf('%s: No data available.\n\n', day_names{d});
        continue;
    end

    %% Whole Day
    [max_val, max_idx] = max(day_data(1:96));
    [min_val, min_idx] = min(day_data(1:96));

    %% Class Hours
    class_slice = day_data(class_start_idx:class_end_idx);
    [max_class_val, rel_max_idx] = max(class_slice);
    [min_class_val, rel_min_idx] = min(class_slice);

    true_max_idx = min(class_start_idx + rel_max_idx - 1, 96);
    true_min_idx = min(class_start_idx + rel_min_idx - 1, 96);

    %% Output
    fprintf('--- %s ---\n', day_names{d});
    fprintf('Whole day:\n');
    fprintf('  Busiest    : %s (%.2f people)\n', ...
        minutesToClock(time_minutes(max_idx)), max_val);
    fprintf('  Least busy : %s (%.2f people)\n', ...
        minutesToClock(time_minutes(min_idx)), min_val);

    fprintf('Class hours (8 AM – 5 PM):\n');
    fprintf('  Busiest    : %s (%.2f people)\n', ...
        minutesToClock(time_minutes(true_max_idx)), max_class_val);
    fprintf('  Least busy : %s (%.2f people)\n\n', ...
        minutesToClock(time_minutes(true_min_idx)), min_class_val);
end

%% Helper: format minutes as HH:MM
function str = minutesToClock(mins)
    hrs = floor(mins / 60);
    mins = mod(mins, 60);
    str = sprintf('%02d:%02d', hrs, mins);
end