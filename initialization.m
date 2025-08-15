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


% This function initialize the first population of search agents
function Positions=initialization(SearchAgents_no,dim,ub,lb)

Boundary_no= size(ub,2); % numnber of boundaries

% If the boundaries of all variables are equal and user enter a signle
% number for both ub and lb
if Boundary_no==1
    Positions=rand(SearchAgents_no,dim).*(ub-lb)+lb;
end

% If each variable has a different lb and ub
if Boundary_no>1
    for i=1:dim
        ub_i=ub(i);
        lb_i=lb(i);
        Positions(:,i)=rand(SearchAgents_no,1).*(ub_i-lb_i)+lb_i;
    end
end


