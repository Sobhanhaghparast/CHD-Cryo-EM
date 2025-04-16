  function [swap_decision, Decision_value, best_pcx_ref, best_pcx_sample] = pcpolswap(ref, s, MDS_All, folderPath, pcx_ref, pcx_sample)
    iref = ref(1); jref = ref(2);
    numRef = floor(size(MDS_All{iref, jref}, 1) / 2);
    is = s(1); js = s(2);
    numP = floor(size(MDS_All{is, js}, 1) / 2);           
    numcompare = floor(min(numRef, numP) / 4);

    % Obtain the pairs for reference and sample with respective pcx values
    [~, pairRef, ~] = MDS_out(MDS_All{iref, jref}, Loadim(iref - 1, jref - 1, folderPath), numcompare, pcx_ref);
    [~, pairC, ~] = MDS_out(MDS_All{is, js}, Loadim(is - 1, js - 1, folderPath), numcompare, pcx_sample);

    % Evaluate the pair swap and get the decision value
    [swap_decision, Decision_value] = evaluatePairSwap(numcompare, pairRef, pairC);

    % Output best pcx values used for tracking
    best_pcx_ref = pcx_ref;
    best_pcx_sample = pcx_sample;
end
