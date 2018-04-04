function W = CSP_From_Cov( CovC, CovA )
% Common SPatial patterns from Covariance Matricies
% assmumed you have data that has both type A data and type B data
% and that you hand it 
% CovA = covariance of data when it has type A data
% CovC = covariance of composite type A and type B data (can be averaged
%        over either data that simultaneouly has both, or consecutively has
%        both types A and types B data.
%
% Revised 2/2016 
%
%
N = size(CovC,1);
CovC = CovC/trace(CovC);
CovA = CovA/trace(CovA);
%
[Uc,Lc,Vc] = svd(CovC);
verysmall = 1e-10;
sLci = Lc;
for ind=1:N
    sLci(ind,ind) = (Lc(ind,ind)>verysmall)/sqrt(Lc(ind,ind));
end
P = sLci * Uc';
Sa = P*CovA*P';
[Ba,Psia,Va] = svd(Sa);
W = Ba'*P;

end

