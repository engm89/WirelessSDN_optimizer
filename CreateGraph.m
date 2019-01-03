
clear all;

% (num_of_bts,max_num_of_controllers)
experiments=[[5,3];[10,5];[20,12];[30,17];[35,25];[40,27];[50,35];[60,45];[70,50];[80,60];[90,70];[100,80];[110,90];[120,100];[130,110];[140,120];[150,130]];
parm={'Time','OnControl1','OnControl2','Total_val','AverageLatency1','AverageLinkFailure1','Transparency1','AverageLatency2','AverageLinkFailure2','Transparency2'};
							

% Run 
csv_results={};
for i=1:size(experiments,1)
 num_of_bts=experiments(i,1);
 max_num_of_controllers=experiments(i,2);
[csv_file , txt_file ]=SimSelector(num_of_bts,max_num_of_controllers);
csv_results=[csv_results csv_file];
end

csv=[];
for i=1:size(csv_results,2)
   table=readtable(csv_results{1,i});
   row=[ experiments(i,1) ];
   for j=1:size(parm,2);
       row = [row , mean(table2array(table(:,parm{1,j})))];
   end
   csv= [csv;row];
end

 parm=['bts_count',parm];
 Filename = sprintf('_%s.', datestr(now,'mm-dd-yyyy-HH-MM-SS'));
 csv_file=strcat(strcat('outputs\Experiments_sum_',Filename),'csv');
 csvwrite_with_headers(csv_file,csv,parm);
