function data = Generate_NLS_data(n, m)

%==========================================================================
% Function: Generate_NLS_data
%==========================================================================
%
% Author: Huan Lyu
% 
% Contact Information 1: huanlyu@nuist.edu.cn    
% Contact Information 2: 1726341330@qq.com    
%
% Description:
%   The function generates two sets of data points, A and B, that are not linearly separable.
%   It generates 'm' points in an 'n'-dimensional space. Points in set A are randomly created, 
%   while points in set B are based on set A but with added noise. Points in set A are labeled as 0,
%   and those in set B are labeled as 1.
%
% Inputs:
%   n - Dimension of the space where the points will be generated
%   m - Total number of points to be generated
%
% Outputs:
%   mergedData - A matrix comprised of sets A and B along with their labels. The matrix is structured
%                such that each point is represented by a column, and each dimension is represented by a row.
%                The first row contains the labels: a label of 0 indicates a point from set A, and a label of 1
%                indicates a point from set B.
%
% Usage:
%   data = Generate_NLS_data(3, 100);
%==========================================================================
    m=m-4;

    % Calculate the size of set A and set B
    num_A = floor(m/3);
    num_B = m - num_A; % To ensure the total number of points remains m

    % Generate set A
    points_A = 2000 * rand(n, num_A) - 1000; % Generate random points within the range [-1000, 1000]

    % Generate set B, based on set A with added noise
    indices = randi([1, num_A], 1, num_B); % Select base points for set B
    noise = randn(n, num_B); % Generate noise
    points_B = points_A(:, indices) + noise;
    
    
    % Adding XOR points to ensure that the data is linearly inseparable
    point1_A = zeros(n, 1);
    point2_A = [1; 1; zeros(n-2, 1)];
    points_A = [point1_A, point2_A, points_A];
    point1_B = [0; 1; zeros(n-2, 1)];
    point2_B = [1; 0; zeros(n-2, 1)];
    points_B = [point1_B, point2_B, points_B];
    
    % Merge data and set labels
    labels = [zeros(1, num_A+2), ones(1, num_B+2)];
    data = [labels; [points_A, points_B]];

end
