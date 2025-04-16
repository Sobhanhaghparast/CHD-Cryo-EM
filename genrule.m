function [ruled_indices] = genrule(i_range, j_range, mode)
    % Initialize the result storage
    results = [];

    % Check the mode and apply the corresponding logic
    switch mode
        case 'snake'
            % Original snake mode
            for row = i_range
                if mod(row, 2) ~= 0
                    % Odd row: move right within the specified column range
                    for col = j_range(1):(j_range(end) - 1)
                        ref = [row, col];
                        sample = [row, col + 1];
                        % Store the result
                        results = [results; ref, sample];
                        fprintf('ref: [%d, %d], sample: [%d, %d]\n', ref, sample);
                    end
                    if row < i_range(end)
                        % After reaching the last column, connect to the next row in the last column
                        ref = [row, j_range(end)];
                        sample = [row + 1, j_range(end)];
                        results = [results; ref, sample];
                        fprintf('ref: [%d, %d], sample: [%d, %d]\n', ref, sample);
                    end
                else
                    % Even row: move left within the specified column range
                    for col = j_range(end):-1:(j_range(1) + 1)
                        ref = [row, col];
                        sample = [row, col - 1];
                        results = [results; ref, sample];
                        fprintf('ref: [%d, %d], sample: [%d, %d]\n', ref, sample);
                    end
                    if row < i_range(end)
                        % After reaching the first column, connect to the next row in the first column
                        ref = [row, j_range(1)];
                        sample = [row + 1, j_range(1)];
                        results = [results; ref, sample];
                        fprintf('ref: [%d, %d], sample: [%d, %d]\n', ref, sample);
                    end
                end
            end

        case 'horizontal'
            % Horizontal mode: Traverse each row from left to right
            for row = i_range
                for col = j_range(1):(j_range(end) - 1)
                    ref = [row, col];
                    sample = [row, col + 1];
                    results = [results; ref, sample];
                    fprintf('ref: [%d, %d], sample: [%d, %d]\n', ref, sample);
                end
            end

        case 'vertical'
            % Vertical mode: Traverse each column from top to bottom
            for col = j_range
                for row = i_range(1):(i_range(end) - 1)
                    ref = [row, col];
                    sample = [row + 1, col];
                    results = [results; ref, sample];
                    fprintf('ref: [%d, %d], sample: [%d, %d]\n', ref, sample);
                end
            end

        otherwise
            error('Invalid mode specified. Choose ''snake'', ''horizontal'', or ''vertical''.');
    end

    ruled_indices = results;
end
