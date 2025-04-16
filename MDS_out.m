function [outputArg1, outputArg2, outputArg3] = MDS_out(mds, Im, num, pcx)
    % Add the path for the required toolbox
    addpath(genpath('/home/shaghparast/Cryo-EM_simulated_data/drtoolbox'));

    % Check if mds is empty or has insufficient dimensions
    if isempty(mds) 
        % Use a default matrix of zeros (4x4)
        disp('mds is empty or does not have sufficient dimensions. Using default 4x4 zero matrix.');
        Low_d_Embeded = zeros(4, 4);
        Impol = {cell(1, num), cell(1, num)};
        orderedIm = cell(1, length(Im));  % Assuming Im is a cell array and we need to keep the same length
    else
        % Perform SVD and processing as usual
        [U, S, V] = svd(mds);
        Low_d_Embeded = U * S(:, pcx) * transpose(V(pcx, pcx));
        [out, idx] = sort(Low_d_Embeded);
        
        % Reorder images based on sorted indices
        orderedIm = cell(1, length(Im));
        for i = 1:length(Im)
            temp = Im{idx(i)};
            orderedIm{i} = temp;
        end
        
        Impol{1} = orderedIm(1:num);
        Impol{2} = orderedIm(end-num+1:end);
    end

    % Set output arguments
    outputArg1 = Low_d_Embeded;
    outputArg2 = Impol;
    outputArg3 = orderedIm;

    % Remove the path for the required toolbox
    rmpath(genpath('/home/shaghparast/Cryo-EM_simulated_data/drtoolbox'));
end
