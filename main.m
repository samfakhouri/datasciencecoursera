% Success history intelligent optimizer (SHIO) optmization Code 
% code for paper: Fakhouri, H. N., Hamad, F., & Alawamrah, A. (2022). Success history intelligent optimizer. The Journal of Supercomputing, 78(5), 6461-6502.
%please give citation of the above paper

% benchmarkfunction = @YourCostFunction
% dimensionension = number of your variables
% part of this code is referenced to : https://www.mathworks.com/matlabcentral/fileexchange/44974-grey-wolf-optimizer-gwo
% we have modified the open source code of GWO equations and code to make SHIO code 
%                                                                   %
%   reference of code and credit to : S. Mirjalili, S. M. Mirjalili, A. Lewis             %
%               Grey Wolf Optimizer, Advances in Engineering        %
%               Software , in press,                                %


clear all 
clc
visFlag = 0;
SHIO_Particles_number=50; % Number of search agents



Maximum_numbef_of_iterations=1000; 




% Load details of the selected benchmark function
number_of_runs=1;

for i= [ 1 :1 : 5] 
%  for 23 function  use i= [ 1 :1 : 23] 

 if i== 1
        Function_name = 'F1';  
        display('The best optimal value of the objective funciton found F1 : ');
    end  
    
     if i== 2
        Function_name = 'F2'; 
         display('The best optimal value of the objective funciton found F2 : ');
     end 
    if i== 3
        Function_name = 'F3';  
        display('The best optimal value of the objective funciton found F3 : ');
    end  
    
     if i== 4
        Function_name = 'F4'; 
         display('The best optimal value of the objective funciton found F4 : ');
    end 
    if i== 5
        Function_name = 'F5';  
        display('The best optimal value of the objective funciton found F5 : ');
    end  
     if i== 6
        Function_name = 'F6'; 
         display('The best optimal value of the objective funciton found F6 : ');
    end  
    if i== 7
        Function_name = 'F7';  
        display('The best optimal value of the objective funciton found F7 : ');
    end  
     if i== 8
        Function_name = 'F8'; 
         display('The best optimal value of the objective funciton found F8 : ');
    end 
    if i== 9
        Function_name = 'F9';  
        display('The best optimal value of the objective funciton found F9 : ');
    end  
     if i== 10
        Function_name = 'F10'; 
         display('The best optimal value of the objective funciton found F10 : ');
     end  
    if i== 11
        Function_name = 'F11';  
        display('The best optimal value of the objective funciton found F11 : ');
    end  
     if i== 12
        Function_name = 'F12'; 
         display('The best optimal value of the objective funciton found F12 : ');
    end 
    if i== 13
        Function_name = 'F13';  
        display('The best optimal value of the objective funciton found F13 : ');
    end  
     if i== 14
        Function_name = 'F14'; 
         display('The best optimal value of the objective funciton found F14 : ');
     end 
      if i== 15
        Function_name = 'F15';  
        display('The best optimal value of the objective funciton found F15 : ');
    end  
     if i== 16
        Function_name = 'F16'; 
         display('The best optimal value of the objective funciton found F16 : ');
    end  
    if i== 17
        Function_name = 'F17';  
        display('The best optimal value of the objective funciton found F17 : ');
    end  
     if i== 18
        Function_name = 'F18'; 
         display('The best optimal value of the objective funciton found F18 : ');
     end 
     if i== 19
        Function_name = 'F19'; 
         display('The best optimal value of the objective funciton found F19 : ');
     end 
     if i== 20
        Function_name = 'F20'; 
         display('The best optimal value of the objective funciton found F20 : ');
     end 
     if i== 21
        Function_name = 'F21'; 
         display('The best optimal value of the objective funciton found F21 : ');
     end 
     if i== 22
        Function_name = 'F22'; 
         display('The best optimal value of the objective funciton found F22 : ');
     end 
     if i== 23
        Function_name = 'F23'; 
         display('The best optimal value of the objective funciton found F23 : ');
     end 
     

bestsolutionsofSHIO=zeros(1,number_of_runs);
%bestsolutionsofPSO=zeros(1,number_of_runs);
[lowerbound,upperbound,dimension,benchmarkfunction]=Get_Functions_details(Function_name);


for k= [ 1 :1 : number_of_runs]


[SHIO_best_solution_value,SHIO_best_particle_position,SHIO_convergence_curve, Trajectories,fitness_history, position_history]=SHIOoptmizer(SHIO_Particles_number,Maximum_numbef_of_iterations,lowerbound,upperbound,dimension,benchmarkfunction);


bestsolutionsofSHIO(k)=SHIO_best_solution_value;
disp(['run number', num2str(k)]);
disp(['is', num2str(SHIO_best_solution_value)]);

%[gBestScore, PSO_cg_curve]=PSO(SHIO_Particles_number,Maximum_numbef_of_iterations,lowerbound,upperbound,dimension,benchmarkfunction); % run PSO to compare to results





end 







disp(['the avarage for SHIO', num2str(k)]);
mm=mean(bestsolutionsofSHIO);
disp(['the mean OF SHIO is ',num2str(mm)]);

%mm2=mean(bestsolutionsofPSO);
%disp(['the mean OF PSO is ',num2str(mm2)]);

MINSSHIO=min(bestsolutionsofSHIO);
disp(['the min OF SHIO is ',num2str(MINSSHIO)]);

MAXSSHIO=max(bestsolutionsofSHIO);
disp(['the max OF SHIO is ',num2str(MAXSSHIO)]);


disp(['the std for ', num2str(k)]);
stdSHIO=std(bestsolutionsofSHIO);
disp(['the std OF SHIO is ',num2str(stdSHIO)]);




     end 


% %***********************************************************
%draw last function values



% %***********************************************************
%draw curve compare with Pso
figure('Position',[500 500 660 290])

%Draw search space
subplot(1,2,1);
func_plot(Function_name);
title('Parameter space')
xlabel('x_1');
ylabel('x_2');
zlabel([Function_name,'( x_1 , x_2 )'])

%Draw objective space
subplot(1,2,2);

semilogy(SHIO_convergence_curve,'Color','r')
hold on
%semilogy(PSO_cg_curve,'Color','b')
%title('Objective space')
xlabel('Iteration');
ylabel('Best score obtained so far');

axis tight

box on



%******************************************************** draw all shapes togather 

%please wait it take time

figure('Position',[454   445   894   297])
%Draw search space
subplot(1,5,1);
func_plot(Function_name);
title('Parameter space')
xlabel('x_1');
ylabel('x_2');
zlabel([Function_name,'( x_1 , x_2 )'])
box on
axis tight

subplot(1,5,2);
hold on
for k1 = 1: size(position_history,1)
    for k2 = 1: size(position_history,2)
        plot(position_history(k1,k2,1),position_history(k1,k2,2),'.','markersize',1,'MarkerEdgeColor','k','markerfacecolor','k');
    end
end
plot(SHIO_best_particle_position(1),SHIO_best_particle_position(2),'.','markersize',10,'MarkerEdgeColor','r','markerfacecolor','r');
title('Search history (x1 and x2 only)')
xlabel('x1')
ylabel('x2')
box on
axis tight

subplot(1,5,3);
hold on
plot(Trajectories(1,:));
title('Trajectory of 1st Particle')
xlabel('Iteration#')
box on
axis tight

subplot(1,5,4);
hold on
semilogy(mean(fitness_history),'Color','g', 'LineWidth',2);
title('Average fitness of all Particles')
xlabel('Iteration#')
box on
axis tight

%Draw objective space
subplot(1,5,5);
semilogy(SHIO_convergence_curve,'Color','r')
title('Convergence curve')
xlabel('Iteration#');
ylabel('Best score obtained so far');
box on
axis tight
set(gcf, 'position' , [39         479        1727         267]);
%******************************************************** draw all shapes togather 













