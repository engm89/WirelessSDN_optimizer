clear all

% Global Const for WCPP formula
global thetha_l alpa beta_l pl Operator1_coefficient_parameters  Operator2_coefficient_parameters ...
       Operator1_bts_locations Operator2_bts_locations;

   
thetha_l=0.2;
alpa=4;
beta_l=1;
pl=23; 

Operator1_coefficient_parameters=[1/3,1/3,1/3];
Operator2_coefficient_parameters=[1/3,1/3,1/3];

Operator1_bts_locations=[50,50,50,100,75,75,100,100,100,50];
Operator2_bts_locations=[150,150,150,200,175,175,200,200,200,150];


% CONST for the simultor
settings.number_of_avg_runs=2;
settings.max_number_of_controllers=6;

settings.upper_bound_xy_limit=2000;
settings.lower_bound_xy_limit=0;

settings.max_iterations=10;

settings.pool_computing=false;
settings.on_lb=0.5;
settings.off_lb=0.4999;
settings.starting_pos=0.5;

  Carrom=false;
  
  
  
  csv_header={};
  csv_header=[csv_header,'index'];
  for i=1:settings.max_number_of_controllers
      csv_header= [csv_header,strcat('x', num2str(i))];
      csv_header= [csv_header,strcat('y', num2str(i))];
  end
   for i=1:settings.max_number_of_controllers
      csv_header= [csv_header,strcat('is_on', num2str(i))];
   end
   csv_header= [csv_header,'Time'];
   csv_header= [csv_header,'Total val'];
   csv_header= [csv_header,'AverageLatency1'];
   csv_header= [csv_header,'AverageLinkFailure1'];
   csv_header= [csv_header,'Transparency1'];
   csv_header= [csv_header,'AverageLatency2'];
   csv_header= [csv_header,'AverageLinkFailure2'];
   csv_header= [csv_header,'Transparency2'];
  
  results = [];
  for i=1:settings.number_of_avg_runs
      if Carrom
        [x,all_best,time]=CarromTableSim(settings);
          algo_name='CarromTable';
      else
        [x,all_best,time]=SimulannealbndSim(settings);
        algo_name='Simulannealbnd';
      end
        sample=[i,x,time,all_best];
        results = [results;sample];
  end
  Filename = strcat(algo_name,sprintf('_%s.xlsx', datestr(now,'mm-dd-yyyy-HH-MM')));
  csvwrite_with_headers('results.csv',results,csv_header)
  
  
  
  
  
  
  
  
  
  
  
  
  
