function [csv_file,pram_file] = SimSelector(number_of_bts,number_controllers)
% clear all memory

draw=true;
% Global Const for WCPP formula
global thetha_l alpa beta_l pl Operator1_coefficient_parameters  Operator2_coefficient_parameters ...
       Operator1_bts_locations Operator2_bts_locations;  

thetha_l=10; 
alpa=4; 
beta_l=7; %
pl=23;  %


Operator1_coefficient_parameters=[1/3,1/3,1/3];
Operator2_coefficient_parameters=[1/3,1/3,1/3];


% CONST for the simultor
settings.number_of_avg_runs=1;
% controllers data
settings.max_number_of_controllers=2*number_controllers;

settings.number_of_bts=number_of_bts;

settings.upper_bound_xy_limit=250;
settings.lower_bound_xy_limit=0;

settings.max_iterations=100;

settings.pool_computing=false;

settings.on_lb=0.5;
settings.off_lb=0.4999;
settings.starting_pos=0.5;

settings.Carrom=false;


Operator1_bts_locations=randi(settings.upper_bound_xy_limit,1,2*settings.number_of_bts);
Operator2_bts_locations=randi(settings.upper_bound_xy_limit,1,2*settings.number_of_bts);


% simulanneal settings

al_settings.InitialTemperature=1000000;
% re anneal every X itreations.
al_settings.ReannealInterval=10000;
% the cooling parm
al_settings.cooling=0.9999;

% stop after X itretions in which the change wasn't higher then "TolFun" 
al_settings.StallIterLimit=15;
% early stop 
al_settings.TolFun=10^-5;
  
  % create the csv header
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
   csv_header= [csv_header,'Total_val'];
   csv_header= [csv_header,'AverageLatency1'];
   csv_header= [csv_header,'AverageLinkFailure1'];
   csv_header= [csv_header,'Transparency1'];
   csv_header= [csv_header,'AverageLatency2'];
   csv_header= [csv_header,'AverageLinkFailure2'];
   csv_header= [csv_header,'Transparency2'];
   csv_header= [csv_header,'OnControl1'];
   csv_header= [csv_header,'OnControl2'];

  % run the expimrents
  results = [];
  for i=1:settings.number_of_avg_runs
      if settings.Carrom
        [x,all_best,time]=CarromTableSim(settings);
          algo_name='CarromTable';
      else
        [x,all_best,time]=SimulannealbndSim(settings,al_settings);
        algo_name='Simulannealbnd';
      end
        format long g
        y1=round(x(2*settings.max_number_of_controllers+1:1:2*settings.max_number_of_controllers+(settings.max_number_of_controllers/2)),4);
        size1=size(y1,2)-size(y1(y1~=0.5),2);
        y2=round(x(2*settings.max_number_of_controllers+(settings.max_number_of_controllers/2)+1:1:end),4);
        size2=size(y2,2)-size(y2(y2~=0.5),2);
        sample=[i,x,time,all_best,size1,size2];
        results = [results;sample];
  end
  
  
  % write out
  Filename = strcat(algo_name,sprintf('_%s.', datestr(now,'mm-dd-yyyy-HH-MM-SS')));
  csv_file=strcat(strcat('outputs\Results_',Filename),'csv');
  csvwrite_with_headers(csv_file,results,csv_header);
  
  pram_file=strcat(strcat('outputs\Experiment_',Filename),'txt');
  fid = fopen(pram_file,'w');
 
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
    fprintf(fid, '%d\n',settings.Carrom);
    
   fprintf(fid, '%s','***********simulannealbnd parms*************');

   fprintf(fid, '%s','InitialTemperature: ');
   fprintf(fid, '%d\n',al_settings.InitialTemperature);
    
    fprintf(fid, '%s','ReannealInterval: ');
    fprintf(fid, '%d\n',al_settings.ReannealInterval);
    
    fprintf(fid, '%s','StallIterLimit: ');
    fprintf(fid, '%d\n',al_settings.StallIterLimit);
    
     fprintf(fid, '%s','TolFun: ');
    fprintf(fid, '%d\n',al_settings.TolFun);
    
    fprintf(fid, '%s','cooling: ');
    fprintf(fid, '%d\n',al_settings.cooling);
    
    
    fclose(fid);


  
  x1= Operator1_bts_locations(1:2:end);
  y1= Operator1_bts_locations(2:2:end);
  
  x2=Operator2_bts_locations(1:2:end);
  y2=Operator2_bts_locations(2:2:end);
  
  
  c_x_1=x(1:2:settings.max_number_of_controllers);
  c_y_1=x(2:2:settings.max_number_of_controllers);
  c_on_1=x(2*settings.max_number_of_controllers+1:1:2*settings.max_number_of_controllers+settings.max_number_of_controllers/2);
  
  c_x_2=x(settings.max_number_of_controllers+1:2:2*settings.max_number_of_controllers);
  c_y_2=x(settings.max_number_of_controllers+2:2:2*settings.max_number_of_controllers);
  c_on_2=x(2*settings.max_number_of_controllers+settings.max_number_of_controllers/2+1:1:end);

   format long g
   usage1=round(c_on_1,4);
   usage2=round(c_on_2,4);
   
   usage1(usage1~=0.5)=-1;
   usage2(usage2~=0.5)=-1;

  if draw
    scatter(x1,y1,'o','r'); hold on;
    scatter(x2,y2,'o','g'); hold on;
    scatter(c_x_1(usage1>0),c_y_1(usage1>0),'x','r'); hold on;
    scatter(c_x_2(usage2>0),c_y_2(usage2>0),'x','g'); hold on;
  end
end
