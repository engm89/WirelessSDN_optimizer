function [final_x,all_best,time] = SimulannealbndSim(settings,al_settings)


% the locations of controllers from the following foramt :
% (controllter_num1_x,controllter_num1_y,controllter_num2_x,controllter_num2_y)
center=(settings.upper_bound_xy_limit-settings.lower_bound_xy_limit)/2;
Operator1_controller_placement=ones(1,settings.max_number_of_controllers)*center;
Operator2_controller_placement=ones(1,settings.max_number_of_controllers)*center;


% a value that will say what controller is on
Operator1_controller_usage=ones(1,settings.max_number_of_controllers/2)*settings.starting_pos;
Operator2_controller_usage=ones(1,settings.max_number_of_controllers/2)*settings.starting_pos;


% run
ObjectiveFunction = @Copy_of_WIfi_LTE;%@WCPP;

% the first guess
x=[Operator1_controller_placement,...
   Operator2_controller_placement,...
   Operator1_controller_usage,...
   Operator2_controller_usage];

% upper bound
ub = [ones(1,length(Operator1_controller_placement))*settings.upper_bound_xy_limit ,...
      ones(1,length(Operator2_controller_placement))*settings.upper_bound_xy_limit ,...
      ones(1,length(Operator1_controller_usage)).*settings.on_lb,...
      ones(1,length(Operator2_controller_usage)).*settings.on_lb ];

  
% lower bound
lb = [ones(1,length(Operator1_controller_placement))*settings.lower_bound_xy_limit ,...
      ones(1,length(Operator2_controller_placement))*settings.lower_bound_xy_limit,...
      ones(1,length(Operator1_controller_usage)).*settings.off_lb,...
      ones(1,length(Operator2_controller_usage)).*settings.off_lb ];


try
    % start parallel computing
    if settings.pool_computing
    parpool;
    end
  temp_updater= @( optim,options ) options.InitialTemperature.*(al_settings.cooling.^optim.k);
  %'AnnealingFcn'
  % new_points= @(state_struct, problemData) 
  options = saoptimset('MaxIter',settings.max_iterations,'InitialTemperature',...
      al_settings.InitialTemperature,'ReannealInterval', al_settings.ReannealInterval,...
      'StallIterLimit',al_settings.StallIterLimit,'TolFun',al_settings.TolFun,'TemperatureFcn',temp_updater);
  tic; 
  % get the locations x's
  [final_x,fval,exitFlag,output]=simulannealbnd(ObjectiveFunction,x,lb,ub,options);
  % get the algorithem results
   [y0,y1,y2,y3,y4,y5,y6]=WCPP(final_x);
   all_best=[y0,y1,y2,y3,y4,y5,y6];
  %get time
  time=toc;
catch ME
    disp(ME.message);
    disp('Crashed!')
end

% end parallel computing
if settings.pool_computing
delete(gcp)
end

end
