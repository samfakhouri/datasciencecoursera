% Success history intelligent optimizer (SHIO) optmization Code 
% code for paper: Fakhouri, H. N., Hamad, F., & Alawamrah, A. (2022). Success history intelligent optimizer. The Journal of Supercomputing, 78(5), 6461-6502.


% benchmarkfunction = @YourCostFunction
% dimensionension = number of your variables
% part of this code is referenced to : https://www.mathworks.com/matlabcentral/fileexchange/44974-grey-wolf-optimizer-gwo
% we have modified the open source code of GWO equations and code to make SHIO code 
%                                                                   %
%   reference of code and credit to : S. Mirjalili, S. M. Mirjalili, A. Lewis             %
%               Grey Wolf Optimizer, Advances in Engineering        %
%               Software , in press,                                %

function [ o ] = ObjectiveFunction ( x )

o = sum (x .^ 2);  % Sphere test function 

end