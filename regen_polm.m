function [outputArg1] = Regen_polm(row_wise_matches,column_wise_matches,matrix_size,num_it)


% matrix_size = 7; % Define the size of the matrix


% Step 4: Initialize modified arrow matrix as ones
modified_arrowmatrix = ones(matrix_size, matrix_size);

% Step 5: Initialize optimization loop variables
max_iterations = num_it; % Set maximum number of iterations
figure_merit_scores = []; % To store figure of merit progression
iteration_numbers = []; % To store the iteration number corresponding to each merit score
flipped_pixel_map = zeros(size(modified_arrowmatrix)); % To track net flips
steps = 0; % Initialize step count

% Step 6: Calculate initial figure of merit
figure_merit_score = calculate_figure_of_meritm(modified_arrowmatrix, row_wise_matches, column_wise_matches);
figure_merit_scores = [figure_merit_scores, figure_merit_score];
iteration_numbers = [iteration_numbers, 0]; % Initial state at iteration 0
disp(['Initial figure of merit: ', num2str(figure_merit_score)]);

% Step 7: Optimization loop
for u = 1:max_iterations
    improved = false; % Flag to check if there's an improvement in this iteration
    
    for i = 1:matrix_size
        for j = 1:matrix_size
            % Flip the value at (i, j) in modified_arrowmatrix
            modified_arrowmatrix(i, j) = modified_arrowmatrix(i, j) * -1;
            
            % Recalculate the figure of merit
            new_figure_merit = calculate_figure_of_meritm(modified_arrowmatrix, row_wise_matches, column_wise_matches);
            
            % Compare with the previous figure of merit
            if new_figure_merit >= figure_merit_score
                figure_merit_score = new_figure_merit;
                figure_merit_scores = [figure_merit_scores, figure_merit_score]; % Store the merit score
                iteration_numbers = [iteration_numbers, u]; % Store the corresponding iteration number
                flipped_pixel_map(i, j) = flipped_pixel_map(i, j) + 1; % Increment flip count
                improved = true; % Set flag to true indicating improvement
            else
                % Revert the change if it does not improve the merit
                modified_arrowmatrix(i, j) = modified_arrowmatrix(i, j) * -1;
            end
            
            steps = steps + 1; % Increment step count
        end
    end
    
    % Stop if no improvement is detected
    if ~improved
        disp(['No improvement in iteration ', num2str(u)]);
        break;
    end
end


% Display the indices of elements that were flipped an odd number of times


%Step 9: Plot the progression of the figure of merit versus iteration
figure;
plot(iteration_numbers, figure_merit_scores, '-o');
xlabel('Iteration');
ylabel('Figure of Merit');
title('Figure of Merit Progression');
grid on;
% 
% % Step 10: Display the final modified matrix
% figure;
% imshow(modified_arrowmatrix, []);
% title('Final Polarities');

% Function to calculate figure of merit based on provided match/mismatch matrices

outputArg1=modified_arrowmatrix;

%apply_flipsm(modified_arrowmatrix, row_wise_matches, column_wise_matches);
end