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




function [best_solution_value,first_solution_position,Convergence_curve, Trajectories,fitness_history, position_history]=SHIOoptmizer(Particles_Number,Maximum_numbef_of_iterations,lowerbound,upperbound,dimension,benchmarkfunction)

% initialize alpha, beta, and delta_pos
first_solution_position=zeros(1,dimension);
first_solution_value=inf; %change this to -inf for maximization problems

second_solution_position=zeros(1,dimension);
second_solution_value=inf; %change this to -inf for maximization problems

third_solution_position=zeros(1,dimension);
third_solution_value=inf; %change this to -inf for maximization problems


best_solution_value=inf;
a=1.5;

FirstP_D_1= zeros(1,Maximum_numbef_of_iterations) ;
N=Particles_Number;

fitness_history=zeros(N,Maximum_numbef_of_iterations);
position_history=zeros(N,Maximum_numbef_of_iterations,dimension);
Trajectories=zeros(Particles_Number,Maximum_numbef_of_iterations);
fitness1 = zeros(1,N);







%Initialize the mean_solution_position of search particles
mean_solution_position=initialization(Particles_Number,dimension,upperbound,lowerbound);

Convergence_curve=zeros(1,Maximum_numbef_of_iterations);

l=0;% Loop counter



   %********************************************************************** 
   for i=1:size(mean_solution_position,1)
        fitness1(1,i)=benchmarkfunction(mean_solution_position(i,:));
  fitness_history(i,1)=fitness1(1,i);
    position_history(i,1,:)=mean_solution_position(i,:);
    Trajectories(:,1)=mean_solution_position(:,1);
   end 



   
   
   
   
   
   %sorting **********************************************
   
   
   %[sorted_fitness,sorted_indexes]=sort(fitness1);

 
   
   
   
   
   
   
   

% Main loop
l=2;
while l<Maximum_numbef_of_iterations+1
    
    
    
      
    
    
    
    for i=1:size(mean_solution_position,1)  
        
       % Return back the search particles that go beyond the boundaries of the search space
        Flag4upperbound=mean_solution_position(i,:)>upperbound;
        Flag4lowerbound=mean_solution_position(i,:)<lowerbound;
        mean_solution_position(i,:)=(mean_solution_position(i,:).*(~(Flag4upperbound+Flag4lowerbound)))+upperbound.*Flag4upperbound+lowerbound.*Flag4lowerbound;               
        
        % Calculate objective function for each search particle
        fitness=benchmarkfunction(mean_solution_position(i,:));
        
      
        
        % Update first_solution_value , second_solution_value 
        if fitness<first_solution_value 
            first_solution_value=fitness; 
            first_solution_position=mean_solution_position(i,:);
        end
        
        if fitness~= first_solution_value && fitness<second_solution_value 
            second_solution_value=fitness;
            second_solution_position=mean_solution_position(i,:);
        end 
        
           if fitness~= second_solution_value && fitness<third_solution_value 
            third_solution_value=fitness; 
            third_solution_position=mean_solution_position(i,:);
        end  

          % Calculating the objective values for all particles
        fitness1(1,i)=benchmarkfunction(mean_solution_position(i,:));
      
    % fitness_history(1,i)=fitness;
     fitness_history(i,l)=fitness1(1,i);
        position_history(i,l,:)=mean_solution_position(i,:);
        
        Trajectories(:,l)=mean_solution_position(:,1);
        
        
    end
    
    
    
    
    
    
    
    
 
    a=a-.004;
    
    
    
    
    
    % Update the Position of search particles including omegas
    for i=1:size(mean_solution_position,1)
        for j=1:size(mean_solution_position,2)     
                       
            X1=first_solution_position(j)+(a*2*rand()-a)*abs(rand()*first_solution_position(j)-mean_solution_position(i,j)); % Equation (3.6)-part 1
      
            X2=second_solution_position(j)+(a*2*rand()-a)*(abs(rand()*second_solution_position(j)-mean_solution_position(i,j))); % Equation (3.6)-part 2       
            
             X3=third_solution_position(j)+(a*2*rand()-a)*(abs(rand()*third_solution_position(j)-mean_solution_position(i,j))); % Equation (3.6)-part 2       
          
            
            FirstP_D_1=first_solution_position(j);
         
 
   mean_solution_position(i,j)=(X1+X2+X3)/3;
   
   
   
   
   
                %************************************************************************* 
        


            
        end
    end
    l=l+1; 
    if best_solution_value>first_solution_value
        best_solution_value=first_solution_value;
    end
     if best_solution_value>second_solution_value
        best_solution_value=second_solution_value;
     end
      if best_solution_value>third_solution_value
        best_solution_value=third_solution_value;
    end
    Convergence_curve(l)= best_solution_value ;
    
    
    
    
    
end



