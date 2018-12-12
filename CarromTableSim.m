function [xbest,all_best,time] = CarromTableSim(settings)
% This file corresponds to the global-minimization of the Carrom-Table
% function. 
% In order to see the 3-D graph of the Carrom-Table, call CarromTableGraph 
% The optimization is based on the Ray-Shooting Method developed by 
% Dr.Yossi Peretz from Lev Academic Center, Jerusalem, Israel.
% In order to execute the algorithm do the following

% Set domain dimension
n=settings.max_number_of_controllers*3; %(x,y,on/off)
% Set number of outer-loop iterations
m=sqrt(settings.max_iterations);
% Set number of inner-loop iterations
s=sqrt(settings.max_iterations);


% Set error
eps=10^-16;

% Set domain boundaries
ub = [ones(1,settings.max_number_of_controllers)*settings.upper_bound_xy_limit ,...
      ones(1,settings.max_number_of_controllers)*settings.upper_bound_xy_limit ,...
      ones(1,settings.max_number_of_controllers).*settings.on_lb];

lb = [ones(1,settings.max_number_of_controllers)*settings.lower_bound_xy_limit ,...
      ones(1,settings.max_number_of_controllers)*settings.lower_bound_xy_limit,...
      ones(1,settings.max_number_of_controllers).*settings.off_lb];

% Call the global optimization algorithm
tic;
[xbest,all_best, ybest, funceval, allybest]=CarromTableGlobalOptimization(n,m,s,eps,lb,ub);
time=toc;       


% where:
% xbset is vector where a global minimum is accepted
% ybest is the value of the function at xbest
% funceval is the number of functions call
% allybest is a list of all the improvments of ybest during the run


% In order to apply the algorithm to other function, write your function
% and in the algorithm CarromTableGlobalOptimization, change the calls 
% CarromTable (on line 9 and on line 44) to the name of you function. 
% See CarromTable.m for how to write your function. 
% Note that your function domain should be an n dimensional uniform box [a,b]^{n}, i.e.
% each variable is between a and b, and note that any function defined on any box could be rescaled, 
% so that the new domain would be a uniform box.
end