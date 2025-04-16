%Devsheet swap

function [swap_decision,Decision_value]=polswap(ref, s,MDS_All,folderPath,pcx,pcn)
iref=ref(1);, jref=ref(2);
numRef=floor(size(MDS_All{iref,jref},1)/2);
is=s(1);, js=s(2);
numP=floor(size(MDS_All{is,js},1)/2);           
numcompare=floor(min(numRef,numP)/4);


[~,pairRef,~]=MDS_out(MDS_All{iref, jref},Loadim(iref-1,jref-1,folderPath),numcompare,pcx);

[~,pairC,~]=MDS_out(MDS_All{is, js},Loadim(is-1,js-1,folderPath),numcompare,pcn);
            

[swap_decision,Decision_value] = evaluatePairSwap( numcompare, pairRef, pairC);

