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
settings.number_of_avg_runs=1;
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
  Filename = strcat(algo_name,sprintf('_%s.', datestr(now,'mm-dd-yyyy-HH-MM')));
  csvwrite_with_headers(strcat(strcat('outputs\Results_',Filename),'xlsx'),results,csv_header);
  
  fid = fopen(strcat(strcat('outputs\Experiment_',Filename),'.txt'),'w');
 
   fprintf(fid, '%s','Operator1_bts_locations ');
   fprintf(fid, '%d\n',Operator1_bts_locations);
   
   fprintf(fid, '%s','Operator2_bts_locations ');
   fprintf(fid, '%d\n',Operator2_bts_locations);
      
   fprintf(fid, '%s','Operator1_coefficient_parameters ');
   fprintf(fid, '%d\n',Operator1_coefficient_parameters);
   
   fprintf(fid, '%s','Operator1_coefficient_parameters ');
   fprintf(fid, '%d\n',Operator1_coefficient_parameters);
   
   fprintf(fid, '%s','thetha_l ');
   fprintf(fid, '%d\n',thetha_l);
      
   fprintf(fid, '%s','alpa ');
   fprintf(fid, '%d\n',alpa);
   
   fprintf(fid, '%s','beta_l ');
   fprintf(fid, '%d\n',beta_l);
   
   fprintf(fid, '%s','pl ');
   fprintf(fid, '%d\n',pl);
  
    fprintf(fid, '%s','number_of_avg_runs ');
   fprintf(fid, '%d\n',settings.number_of_avg_runs);
   
    fprintf(fid, '%s','max_number_of_controllers ');
   fprintf(fid, '%d\n',settings.max_number_of_controllers);
   
    fprintf(fid, '%s','upper_bound_xy_limit ');
   fprintf(fid, '%d\n',settings.upper_bound_xy_limit);
   
    fprintf(fid, '%s','lower_bound_xy_limit ');
   fprintf(fid, '%d\n',settings.lower_bound_xy_limit);
   
    fprintf(fid, '%s','max_iterations ');
   fprintf(fid, '%d\n',settings.max_iterations);
   
    fprintf(fid, '%s','pool_computing ');
   fprintf(fid, '%d\n',settings.pool_computing);
   
    fprintf(fid, '%s','on_lb ');
   fprintf(fid, '%d\n',settings.on_lb);
   
    fprintf(fid, '%s','off_lb ');
   fprintf(fid, '%d\n',settings.off_lb);
   
   fprintf(fid, '%s','starting_pos ');
   fprintf(fid, '%d\n',settings.starting_pos);
   
    fprintf(fid, '%s','Carrom ');
    fprintf(fid, '%d\n',Carrom);

   fclose(fid);

   
  
  
  
  
  
  
  
  
  
  
