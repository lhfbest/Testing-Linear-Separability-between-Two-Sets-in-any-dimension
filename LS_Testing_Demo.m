%==========================================================================
% LS_Testing_Demo
%==========================================================================
%
% SYNOPSIS: 
%   This code snippet demonstrates how to use the LS_Testing() function 
%   to test Linearly Separable (LS) or Non-Linearly Separable (NLS) data sets. 
%   The data can either be generated using custom functions or read from a CSV file.
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
% NOTES:
%
%   - This code is implemented solely to verify the feasibility of the algorithm presented in the paper. 
%     There are many aspects where efficiency can be further optimized. Your corrections and suggestions are most welcome!
% 
%   - The author's research interests include machine learning, classification
%     problems, clustering problems, etc. Exchange and collaboration are welcome.)
% 
% 
% Creation Date: 2024-01-17
% Last Modified Date: 2024-01-17
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear
close all

% Generate NLS or LS data for testing (dimension, size)
% data=Generate_NLS_data(3,100);  % Custom generation of non linearly separable data Generate_NLS_data(Dimension, Scale)
data=Generate_LS_data(3,100);  % Custom generation of linearly separable data Generate_LS_data(Dimension, Scale)


% Or read data from a CSV file.
% data=csvread('Dimension10_Size5000_NLS.csv');


% Get labels and data points. 
labels = data(1,:); 
values = data(2:end,:); 

% Split the data into sets A and B based on the labels.
A = values(:, labels == 0); 
B = values(:, labels == 1); 

[LS,LS_Degree,time]= LS_Testing(A,B);




