function merit = calculate_figure_of_meritm(matrix, row_wise_matches, column_wise_matches)
    [rows, cols] = size(matrix);
    % Row-wise: Compare consecutive elements in each row
    row_wise_comparisons = zeros(rows, cols - 1);
    for i = 1:rows
        for j = 1:(cols - 1)
            if matrix(i, j) == matrix(i, j + 1)
                row_wise_comparisons(i, j) = 1; % Match
            else
                row_wise_comparisons(i, j) = -1; % Mismatch
            end
        end
    end

    % Column-wise: Compare consecutive elements in each column
    column_wise_comparisons = zeros(rows - 1, cols);
    for j = 1:cols
        for i = 1:(rows - 1)
            if matrix(i, j) == matrix(i + 1, j)
                column_wise_comparisons(i, j) = 1; % Match
            else
                column_wise_comparisons(i, j) = -1; % Mismatch
            end
        end
    end

    % Calculate the merit by comparing the actual matches/mismatches
    row_merit = sum(sum(row_wise_comparisons == row_wise_matches));
    column_merit = sum(sum(column_wise_comparisons == column_wise_matches));

    % The total merit is the sum of row and column merits
    merit = row_merit + column_merit;
end