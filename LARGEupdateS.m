function [Q, R] = LARGEupdateS (Q, R, p, x)

%==========================================================================
% function [Q, R] = LARGEupdateS (Q, R, p, x)
%
% Description  : Updates set S, such that the S is affinely independent
% Input        : Q, R - QR factorization of matrix of points in the support set
%                x ~ current solution
%                p ~ point to enter S
% Output       : Q, R - QR factorization of the matrix of the points in the 
%                new support set 
%==========================================================================

global epsTol
[n, m] = size(R); %number of points in S

affInd = 1;

[Q1, R1] = qrinsert(Q, R, 1, ones(1,m), 'row');
[~, R11] = qrinsert(Q1, R1, m+1, [1; p], 'col');

if size(R11,2) > n+1  %cardinality of {S, p} is >n+1 -> affinely dependent
    affInd = 0;
elseif abs(R11(m+1,m+1)) < epsTol   %rank[S, p]<m+1 -> affinely dependent
    affInd = 0;
end

if affInd == 0  
    opts.UT = true;    
    
    Z = linsolve (R1, Q1'*[-1 1; -p x], opts);

    %minimum ratio rule:
    minratio = Inf; ii = 0;
    TT = -Z(:,2)./Z(:,1);
    for i = 1:m
        if Z(i,1)<0 && TT(i) < minratio
            ii = i; 
            minratio = TT(i);
        end
    end   
    
    [Q, R] = qrdelete(Q, R, ii);   
end  
end