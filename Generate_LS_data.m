function [mergedData] = Generate_LS_data(n, m)

%==========================================================================
% Function: Generate_LS_data
%==========================================================================
% 
% Author: Huan Lyu
% 
% Contact Information 1: huanlyu@nuist.edu.cn    
% Contact Information 2: 1726341330@qq.com    
% 
% Description:
%   The purpose of this function is to generate two linearly separable sets, A and B, 
%   in an 'n'-dimensional space with 'm' points. The function uses a randomly generated 
%   hyperplane to initially divide the points into sets A and B. Then, it shifts the points 
%   in sets A and B away from the hyperplane by a distance of 'shift_value' in opposite directions. 
%   This shift determines the degree of closeness between the two sets. The shift_value 
%   can be modified as needed. When the shift_value is 0, the two sets are essentially 
%   tightly packed together.
%
% Inputs:
%   n - Dimension of the space in which points are to be generated
%   m - Number of points to generate
%
% Outputs:
%   mergedData - A matrix comprised of sets A and B along with their labels. The matrix is structured
%                such that each point is represented by a column, and each dimension is represented by a row.
%                The first row contains the labels: a label of 0 indicates a point from set A, and a label of 1
%                indicates a point from set B.
%
% Usage:
%   mergedData = Generate_LS_data(3, 100);
%
%==========================================================================

    % 1. Randomly generate m points in n-dimensional space with values ranging from -1000 to 1000
    points = randi([-1000, 1000], n, m);

    % 2. Generate a random normal vector
    normal_vector = randn(n, 1);
    normal_vector = normal_vector / norm(normal_vector); % Normalize

    % 3. Calculate the distance of each point to the hyperplane P
    distances = sum(points .* normal_vector, 1)';

    % 4. Put the closest m/4 points into set A, and the remaining points into set B, effectively dividing them into two sets using the hyperplane
    [~, sorted_indices] = sort(distances);
    A_indices = sorted_indices(1:floor(m/4));
    B_indices = sorted_indices(floor(m/4)+1:end);

    A = points(:, A_indices);
    B = points(:, B_indices);
    
    % 5. Shift points in A and B away from the hyperplane by 10 units
    shift_value = 500;  % You can change this value as needed
    A = A - normal_vector * shift_value;
    B = B + normal_vector * shift_value;

    % 6. Merge sets A and B, and assign a label to each point; label 0 for set A, and label 1 for set B
    labels_A = zeros(1, size(A, 2));
    labels_B = ones(1, size(B, 2));
    
    mergedData = [labels_A, labels_B; A, B];

end
