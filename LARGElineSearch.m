function [x_new, flag] = LARGElineSearch (x, Q, R, p)

%==========================================================================
% function [x_new, flag] = LARGElineSearch (x, Q, R, p)
%
% Description  : Finds the direction d and performs the line search: computes 
%                the stepsize alpha that minimizes x + alpha*d implementing
%                our developed new approach
% Input        : x ~ current solution
%                Q, R ~ QR decomposition of matrix of points in the support set
%                p ~ point s.t. {S, p} is affinely independent
% Output       : x_new ~ new solution
%                flag ~ flag = 0 if x+alpha*d intersects the bisectors related 
%                       to p first; OR flag = i if x+alpha*d intersects the 
%                       opposite facet to point i
%==========================================================================

global epsTol
[n, m] = size(R);
alphas = -Inf*ones(1, 3);
flags = Inf*ones(1,3);

%1. Direction d for the line search
pm = Q*R(:,m);
em = [zeros(m-1,1); 1];
[Q2, R2] = qrupdate(Q, R, p-pm, em);
[Q2, R2] = qrupdate(Q2, R2, -pm, ones(m,1));

A = zeros(n, n);
A(1:m,:) = R2';
A(m+1:n,m+1:n) = eye(n-m);

ee = [zeros(m-1,1);1;zeros(n-m,1)];
opts.UT = true;
g = linsolve (A, ee, opts);
d = Q2*g;

%2. Intersection of x+alpha*d and the bisectors related to p:
alphas(1) = ((pm-p)'*(1/2*(p+pm)-x)) / ((pm-p)'*d);
flags(1) = 0;

%3.1. Find the facet that x+alpha*d intersects

%a. find the projections
[Q3, ~] = qrdelete(Q2, R2, m, 'col');
V = Q3(:,1:m-1)*Q3(:,1:m-1)';
Vpm = V*pm;
xx = V*x - Vpm + pm;
pp = V*p - Vpm + pm;


[Q3, R3] = qrinsert(Q, R, 1, ones(1,m), 'row');
opts.UT = true;
Z = linsolve (R3, Q3'*[1 1; xx pp], opts);   
pi = Z(:,1);
omega = Z(:, 2);


%b. Case 1: is there a j s.t. pi(j)=0 and omega(j)=0?
omTmp = omega;
omTmp(omTmp<-epsTol | omTmp>epsTol)=Inf; %only leave the zeros
piTmp = pi;
piTmp(piTmp<-epsTol | piTmp > epsTol)=Inf; %only leave the zeros


[minSum, k] = min(piTmp + omTmp);


if minSum < Inf %minSum=0+0, which means we have 0/0, so we have case 1
    x_new = x;
    flag = k;
    return
end

%c. Case 2: find the min and the max ratios
ratios = pi./omega;

ratiosPos = ratios;
ratiosPos(~(pi >= -epsTol & omega > 0)) = Inf;
[~, flags(2)] = min(ratiosPos);
alphas(2) = LARGEfacetIntersection (Q2, R2, flags(2), m, n, d, p, pm, x);

ratiosNeg = ratios;
ratiosNeg(~(pi <= epsTol & omega < 0)) = -Inf;
[maxRNeg, flags(3)] = max(ratiosNeg);
if maxRNeg > 0
    alphas(3) = LARGEfacetIntersection (Q2, R2, flags(3), m, n, d, p, pm, x);
end

%4. New solution and info about update S
if (alphas(3)>0)
    alphas;
end
alphas(alphas < -epsTol) = Inf;  %alpha is the minimum one that is non neg
[alpha, jj] = min(alphas);
flag = flags(jj);
x_new = x+alpha*d;

end