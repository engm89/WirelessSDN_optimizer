function [val,val1,val2,val3,val4,val5,val6] = WCPP(x)

global Operator1_coefficient_parameters  Operator2_coefficient_parameters ...
       Operator1_bts_locations Operator2_bts_locations;

% take all as an single input parse them to there difftent varibles
size=length(x)/3;
Operator1_controller_placement=x(1,1:size);
Operator2_controller_placement=x(1,size+1:2*size);
len=size/2;
Operator1_controller_usage=x(1,2*size+1:2*size+len);
Operator2_controller_usage=x(1,(2*size+len+1):(3*size));

disp('operator 1 locations:');
disp(Operator1_controller_placement);
disp('operator 2 locations:');
disp(Operator2_controller_placement);
disp('operator 1 usege in controllers:');
disp(Operator1_controller_usage);
disp('operator 2 usege in controllers:');
disp(Operator2_controller_usage);     
disp('********************************');

% get array of 0 and 1 
usage1=round(duplicate(Operator1_controller_usage));
usage2=round(duplicate(Operator2_controller_usage));

% send to zero the elements in not in use
Operator1_controller_placement=Operator1_controller_placement.*usage1;
Operator2_controller_placement=Operator2_controller_placement.*usage2;

% replace the 0 with -1 (out of the game)
Operator1_controller_placement(Operator1_controller_placement==0)=-1;
Operator2_controller_placement(Operator2_controller_placement==0)=-1;

val1=double(AverageLatency(Operator1_controller_placement,Operator1_bts_locations));
val2=double(AverageLinkFailure(Operator1_controller_placement,Operator1_bts_locations));
val3=double(Transparency(Operator1_controller_placement,Operator1_bts_locations));
val4=double(AverageLatency(Operator2_controller_placement,Operator2_bts_locations));
val5=double(AverageLinkFailure(Operator2_controller_placement,Operator2_bts_locations));
val6=double(Transparency(Operator2_controller_placement,Operator2_bts_locations));
val=Operator1_coefficient_parameters(1)*(val1)...
    +Operator1_coefficient_parameters(2)*(val2)...
    +Operator1_coefficient_parameters(3)*(val3)...
    +Operator2_coefficient_parameters(1)*(val4)...
    +Operator2_coefficient_parameters(2)*(val5)...
    +Operator2_coefficient_parameters(3)*(val6);
disp(vpa(val))
end

function MM = duplicate(controller_usage)
MM=repelem(controller_usage,2);
end

%%
%% functions for AverageLatency
%%


% Done
function [val]=AverageLatency(controller_placement,bts_locations)
   global thetha_l;
   other_pl=AverageLinkFailure(controller_placement,bts_locations);
   lambda_l=posion_lambda(append_locations(controller_placement,bts_locations));
   val=(1)/...
       (other_pl*lambda_l*log(1+thetha_l));
end

%%
%% functions for Transparency
%%

function val=Ten(v,other_pl)
   global thetha_l;
   val=1/(v*other_pl*log(1+thetha_l));
end

function val=posion_lambda(nodes_location)
   % get function that return the lambda
   lambda_x=fitdist(nodes_location(1:2:end)','Poisson');
   lambda_y=fitdist(nodes_location(2:2:end)','Poisson');
   val=lambda_x.lambda+lambda_y.lambda;
   
end

function val=append_locations(controller_placement,bts_locations)
        val=[controller_placement(controller_placement>0) bts_locations];
end

function val=Transparency(controller_placement,bts_locations)
    other_pl=AverageLinkFailure(controller_placement,bts_locations);
    total_locations=append_locations(controller_placement,bts_locations);
    v2=posion_lambda(total_locations);
    v1=posion_lambda(bts_locations);
    val=(Ten(v2,other_pl)-Ten(v1,other_pl))/...
        Ten(v1,other_pl);
    
end



%%
%% functions for AverageLinkFailure
%%


function val=AverageLinkFailure(controller_placement,bts_locations)
    global thetha_l alpa beta_l pl;
    syms tu r;
    lambda_l=posion_lambda(append_locations(controller_placement,bts_locations));
    lambda_l_tilda=lambda_l*beta_l;
    s=(thetha_l*(tu^alpa))/pl;
    val=beta_l*int(...
        exp(-2*lambda_l_tilda*int(r*(s*pl*(r^(-alpa)))/(1+s*pl*(r^(-alpa))),'r',tu,inf))...
        *2*pi*lambda_l*tu*exp(-pi*lambda_l*(tu^2))...
        , 'tu', 0, inf);
end
