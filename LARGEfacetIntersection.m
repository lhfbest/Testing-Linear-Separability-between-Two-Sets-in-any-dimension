function alpha = LARGEfacetIntersection (Q2, R2, j, m, n, d, p, pm, x)


%==========================================================================
% function alpha = LARGEfacetIntersection (Q2, R2, k, m, n, d, p, pm, x)
%
% Description  : Finds the intersection of the line x+alpha*d with the facet 
%                opposed to point corresponding to index j    
% Input        : to see the input variables, go to LARGELineSearch.m
% Output       : alpha, the intersection value with the facet
%==========================================================================

global epsTol
[Q3, R3] = qrdelete(Q2, R2, j, 'col');
if j == m
    [Q3, ~] = qrupdate(Q3, R3, pm-p, ones(m-1,1));
end

temp = d'*Q3(:, m:n);
i = find(abs(temp) > epsTol, 1);
alpha = ((p-x)'*Q3(:,i+m-1)) / temp(i);

end
