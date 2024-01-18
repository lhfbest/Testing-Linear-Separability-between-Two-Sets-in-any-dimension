function [LS,LS_Degree,time] = LS_Testing (A,B)

%==========================================================================
% LS_Testing Function
%==========================================================================
%
% SYNOPSIS: 
%   This function qualitatively determines whether the point sets A and B are linearly separable (LS),
%   and quantifies their LS degree.
%
% INPUTS:
%   A       - Point set A as an N x M1 matrix, where N is the number of dimensions and M1 is the number of points. 
%             Points are represented as column vectors.
%   B       - Point set B as an N x M2 matrix, where N is the number of dimensions and M2 is the number of points. 
%             Points are represented as column vectors.
%
% OUTPUTS:
%   LS          - Linear Separability Indicator (0 or 1)
%   LS_Degree   - Degree of linear separability. The value ranges between 0
%                 and 1, where 0 indicates NLS, and the higher the value, the
%                 more linearly separable it is. 
%   time        - Time taken to execute the function
%
%
% EXAMPLE USAGE:
%   [LS, LS_Degree, time] = LS_Testing(A, B)
%
% SEE ALSO:
%   - LARGEupdateS
%   - LARGElineSearch
%   - LARGEfacetIntersection
% 
% NOTES:
%   - The function uses GPU for speeding up the computation and employs adaptive block computation 
%     based on the available GPU memory. Block size may affect the running time, and can be adjusted 
%     according to specific requirements.
% 
%   - When the system has limited GPU memory and the task is large, it may result in abnormal 
%     blocksize and errors. You can increase the GPU utilization ratio or use a GPU with larger memory.
% 
%   - The code is used on a relatively newer version of MATLAB (the experiments in the paper were 
%     conducted using MATLAB 2023b). If the MATLAB version is too old, it may result in errors.
% 
%   - The approach for constructing the minimum covering ball in this code is based on Cavaleiro, Marta, and Farid Alizadeh.
%     "A faster dual algorithm for the Euclidean minimum covering ball problem." Annals of operations research (2018): 1-13..
%     We are very grateful to them for their contributions to the theoretical aspects of the algorithm!
% 
%   - This code is implemented solely to verify the feasibility of the algorithm presented in the paper. 
%     There are many aspects where efficiency can be further optimized. Your corrections and suggestions are most welcome!
% 
% Author: Huan Lyu
% 
% Based on reference: 
%   Shuiming Zhong and Huan Lyu, 'A New Sufficient & Necessary Condition for
%   Testing Linear Separability between Two Sets', TPAMI 2024.
% 
% Contact Information 1: huanlyu@nuist.edu.cn    
% Contact Information 2: 1726341330@qq.com   
% 
% Creation Date: 2024-01-17
% Last Modified Date: 2024-01-17
%==========================================================================

tic

% Get information about the current GPU device,and calculate the block size based on the current GPU memory situation
n =  size(B,1);  %Dimensiom
sizeA =  size(A,2);  % size of set A
sizeB =  size(B,2);  % size of set B
m= sizeA+sizeB;
deviceInfo = gpuDevice();
GPU_ratio = 0.2;  %GPU utilization ratio
availableMemory = deviceInfo.AvailableMemory * GPU_ratio;  %Perform computations using 20% of the available GPU memory.
blockSize = sqrt( (availableMemory/4-n*m -sizeA*sizeB) / (2*(n+1))   );
blockSize = 2^floor(log2(blockSize));   %Convert blockSize to a power of 2

global epsTol
global epsTol2
global epsTol3
global count
epsTol = 10^-4 ;  
epsTol2 = 10^-4 ; 
epsTol3 = 10^-6;
count=0;

sizeA = size(A,2);
sizeB = size(B,2);

Diff = A(:, 1) - B(:, 1);
norm_Diff = norm(Diff);
p1 = Diff / norm_Diff;

Diff = A(:, 1) - B(:, 2);
norm_Diff = norm(Diff);
p2 = Diff / norm_Diff;

%0. INITIALIZATION:
[Q, R] = qr([p1, p2]);      %QR of the initial support set
x = (p1+p2)/2;              %initial center
z = 1/2*sqrt((p1-p2)'*(p1-p2)); %initial radius

iter = 0;
isOpt = 0;

normsOfPsq = ones(1, sizeA*sizeB);

p = p1;

radii = [];


while isOpt == 0   
     iter = iter+1;
     z;

    A = single(A);
    B = single(B);
    x = single(x);

    A_gpu = gpuArray(A);
    B_gpu = gpuArray(B);
    x_gpu = gpuArray(x);
    
    distances_gpu = gpuArray.zeros(size(A, 2), size(B, 2), 'single'); 

    x_reshaped_gpu = reshape(x_gpu, [length(x_gpu), 1, 1]);

    numBlocksA = ceil(size(A, 2) / blockSize);
    numBlocksB = ceil(size(B, 2) / blockSize);

    for blockA = 1:numBlocksA
        for blockB = 1:numBlocksB
            rangeA = (blockA-1)*blockSize + 1:min(blockA*blockSize, size(A, 2));
            rangeB = (blockB-1)*blockSize + 1:min(blockB*blockSize, size(B, 2));
            
            A_block = A_gpu(:, rangeA);
            B_block = B_gpu(:, rangeB);

            Diff_gpu = A_block - permute(B_block, [1, 3, 2]);

            norm_Diff_gpu = sqrt(sum(Diff_gpu.^2, 1));

            p_gpu = bsxfun(@rdivide, Diff_gpu, norm_Diff_gpu);

            distances_gpu_block = -2 * squeeze(sum(x_reshaped_gpu .* p_gpu, 1));

            distances_gpu(rangeA, rangeB) = distances_gpu_block;
        end
    end

    distances = gather(distances_gpu);
    distances = reshape(distances', 1, []);

    size(distances);
    size(normsOfPsq);
    
    distances = distances + normsOfPsq;

    [maxdist, ip] = max(distances);

    if sqrt(maxdist + x'*x) < z + epsTol   
        break;
    end
        
    iA = ceil(ip / sizeB);
    iB = ip - (iA-1)*sizeB;

    Diff = A(:, iA) - B(:, iB);
    norm_Diff = norm(Diff);
    p = Diff / norm_Diff;

    % Compute p using the indices
    Diff = A(:, iA) - B(:, iB);
    norm_Diff = norm(Diff);
    p = Diff / norm_Diff;

    %2. UPDATE S
    [Q, R] = LARGEupdateS(Q, R, p, x);

    %3. SOLVING M(S and p)
    flag = 1;
    while flag ~= 0
        
        [x, flag] = LARGElineSearch (x, Q, R, p); 

        if flag == 0
            z = norm(x-p);
            break
        else
            [Q, R] = qrdelete(Q, R, flag, 'col');   %S=S without p_flag
        end
    end
    [Q, R] = qrinsert(Q, R, 1, p, 'col');  %add p to S  
    
    
    radii = [radii, z];
    if iter >= 6
        recent_increases = diff(radii(end-4:end));
        if all(abs(recent_increases) < epsTol2)
            %disp('Stopping iteration due to small radius growth.');
            break;
        end
    end
 
end



if z>1-epsTol3
    disp('Linear separability = NLS');
    LS=0;

elseif z<=1-epsTol3
    disp('Linear separability = LS');
    LS=1;
end

LS_Degree = 1-z;

fprintf('LS_Degree = %.6f\n', LS_Degree);

time = toc;

fprintf('Use time = %.3f\n', time);

end