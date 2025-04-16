function apply_flipsm(modified_arrowmatrix, row_wise_matches, column_wise_matches)

    % Get the size of the input matrix
    [num_rows, num_cols] = size(modified_arrowmatrix);

    % Step 1: Recalculate row-wise matches for modified_arrowmatrix
    row_wise_comparisons = zeros(num_rows, num_cols - 1); % Initialize matrix for row-wise matches
    for i = 1:num_rows
        for j = 1:(num_cols - 1)
            if modified_arrowmatrix(i, j) == modified_arrowmatrix(i, j + 1)
                row_wise_comparisons(i, j) = 1; % Match
            else
                row_wise_comparisons(i, j) = -1; % Mismatch
            end
        end
    end

    % Step 2: Recalculate column-wise matches for modified_arrowmatrix
    column_wise_comparisons = zeros(num_rows - 1, num_cols); % Initialize matrix for column-wise matches
    for j = 1:num_cols
        for i = 1:(num_rows - 1)
            if modified_arrowmatrix(i, j) == modified_arrowmatrix(i + 1, j)
                column_wise_comparisons(i, j) = 1; % Match
            else
                column_wise_comparisons(i, j) = -1; % Mismatch
            end
        end
    end

    % Step 3: Compare recalculated matches with original match/mismatch matrices
    row_wise_agreement = (row_wise_comparisons == row_wise_matches); % 1 means agreement, 0 means disagreement
    column_wise_agreement = (column_wise_comparisons == column_wise_matches); % 1 means agreement, 0 means disagreement

    % Step 4: Display results
    disp('Final Row-wise Matches Agreement (1 means match):');
    disp(row_wise_agreement);

    disp('Final Column-wise Matches Agreement (1 means match):');
    disp(column_wise_agreement);

    % Step 5: Visualization
    figure;
    subplot(1,3,1), imshow(modified_arrowmatrix, []); title('Final Polarities');
    subplot(1,3,2), imshow(row_wise_agreement, []); title('Row-wise Agreement');
    subplot(1,3,3), imshow(column_wise_agreement, []); title('Column-wise Agreement');
end
