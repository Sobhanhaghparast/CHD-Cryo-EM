function [L]=PCMDS(mds,pcx)

           if isempty(mds) 
        L = zeros(1, 4);
           else
        [U, S, V] = svd(mds);
        L = U * S(:, pcx) * transpose(V(pcx, pcx));
           end 

end