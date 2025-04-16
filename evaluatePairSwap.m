function [swap_decision,Decision_value] = evaluatePairSwap(numcompare, pairRef, pairP)
    % Initialize MSE matrices to store error for each pair of images
    mse_P1_ref2 = zeros(numcompare, numcompare);
    mse_P2_ref2 = zeros(numcompare, numcompare);
    
    % Loop over each image in pairRef{2}
    for i = 1:numcompare
        imgRef = pairRef{2}{i};  % Reference image from pairRef{2}
        
        % Compare with each image in pairP{1,18}{1} (PairP{1})
        for j = 1:numcompare
            imgP1 = pairP{1}{j};  % Comparison image from pairP{1,18}{1}
            mse_P1_ref2(i, j) = immse(imgRef, imgP1);
        end
        
        % Compare with each image in pairP{1,18}{2} (PairP{2})
        for j = 1:numcompare
            imgP2 = pairP{2}{j};  % Comparison image from pairP{1,18}{2}
            mse_P2_ref2(i, j) = immse(imgRef, imgP2);
        end
    end
    
    % Determine the minimum MSE and corresponding indices for each reference image in PairRef{2}
    [min_mse_P1_ref2, ~] = min(mse_P1_ref2, [], 2);
    [min_mse_P2_ref2, ~] = min(mse_P2_ref2, [], 2);
    
    % Compare average MSE across all pairs for each set in PairRef{2}
    avg_mse_P1_ref2 = mean(min_mse_P1_ref2);
    avg_mse_P2_ref2 = mean(min_mse_P2_ref2);
    
    % Initialize MSE matrices for PairRef{1}
    mse_P1 = zeros(numcompare, numcompare);
    mse_P2 = zeros(numcompare, numcompare);
    
    % Loop over each image in pairRef{1}
    for i = 1:numcompare
        imgRef = pairRef{1}{i};  % Reference image from pairRef{1}
        
        % Compare with each image in pairP{1,18}{1} (PairP{1})
        for j = 1:numcompare
            imgP1 = pairP{1}{j};  % Comparison image from pairP{1,18}{1}
            mse_P1(i, j) = immse(imgRef, imgP1);
        end
        
        % Compare with each image in pairP{1,18}{2} (PairP{2})
        for j = 1:numcompare
            imgP2 = pairP{2}{j};  % Comparison image from pairP{1,18}{2}
            mse_P2(i, j) = immse(imgRef, imgP2);
        end
    end
    
    % Determine the minimum MSE and corresponding indices for each reference image in PairRef{1}
    [min_mse_P1_ref1, ~] = min(mse_P1, [], 2);
    [min_mse_P2_ref1, ~] = min(mse_P2, [], 2);
    
    % Compare average MSE across all pairs for each set in PairRef{1}
    avg_mse_P1_ref1 = mean(min_mse_P1_ref1);
    avg_mse_P2_ref1 = mean(min_mse_P2_ref1);
    avg_mse_P1_ref2 = mean(min_mse_P1_ref2);
    avg_mse_P2_ref2 = mean(min_mse_P2_ref2);
    
    p1r1p2r2=avg_mse_P1_ref1 + avg_mse_P2_ref2;
    p1r2p2r1=avg_mse_P1_ref2 + avg_mse_P2_ref1;
    Decision_value= abs(p1r1p2r2-p1r2p2r1);
    % Determine if cell swapping in PairP is needed
    % if (avg_mse_P1 < avg_mse_P2 && avg_mse_P1_ref2 > avg_mse_P2_ref2) || ...
    %    (avg_mse_P1 > avg_mse_P2 && avg_mse_P1_ref2 < avg_mse_P2_ref2)
    % worked to some extent but wrong logically
    %     if (avg_mse_P1_ref1 > avg_mse_P2_ref1 && avg_mse_P1_ref2 < avg_mse_P2_ref2)
    %     fprintf('Swapping cells in PairP is suggested.\n');
    %     swap_decision = 1; % Binary value indicating swap needed
    % else
    %     fprintf('No need to swap cells in PairP.\n');
    %     swap_decision = 0; % Binary value indicating no swap needed
    % end


        if avg_mse_P1_ref1 + avg_mse_P2_ref2 > avg_mse_P1_ref2 + avg_mse_P2_ref1
        fprintf(['Swap with decision value= ' num2str(Decision_value) '.\n']);
        swap_decision = 1; % Binary value indicating swap needed
    else
        fprintf(['No swap with decision value= ' num2str(Decision_value) '.\n']);
        swap_decision = 0; % Binary value indicating no swap needed
    end


end
