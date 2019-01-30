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

%disp('operator 1 locations:');
%disp(Operator1_controller_placement);
%disp('operator 2 locations:');
%disp(Operator2_controller_placement);
%disp('operator 1 usege in controllers:');
%disp(Operator1_controller_usage);
%disp('operator 2 usege in controllers:');
%disp(Operator2_controller_usage);     
%disp('********************************');

% get array of 0 and 1 
format long g
usage1=round(duplicate(Operator1_controller_usage),4);
usage2=round(duplicate(Operator2_controller_usage),4);

% replace the 0 with -1 (out of the game)
Operator1_controller_placement(usage1~=0.5)=-1;
Operator2_controller_placement(usage2~=0.5)=-1;


val1=double(AverageLatency(Operator1_controller_placement,Operator1_bts_locations))*Operator1_coefficient_parameters(1);
%disp('->')
val2=double(AverageLinkFailure(Operator1_controller_placement,Operator1_bts_locations))*Operator1_coefficient_parameters(2);
val3=double(Transparency(Operator1_controller_placement,Operator1_bts_locations))*Operator1_coefficient_parameters(3);

val4=double(AverageLatency(Operator2_controller_placement,Operator2_bts_locations))*Operator2_coefficient_parameters(1);
%disp('->')

val5=double(AverageLinkFailure(Operator2_controller_placement,Operator2_bts_locations))*Operator2_coefficient_parameters(2);
%disp('->')
%disp(val5)

val6=double(Transparency(Operator2_controller_placement,Operator2_bts_locations))*Operator2_coefficient_parameters(3);

val=val1+val2+val3+val4+val5+val6;
%disp(vpa(val))
end

function MM = duplicate(controller_usage)
MM=repelem(controller_usage,2);
end

%%
%% functions for AverageLatency
%%


% Done
function [val]=Wifi_AverageLatency(controller_placement,bts_locations)
   lambda_l=posion_lambda(append_locations(controller_placement,bts_locations));
   number_of_bts=len(bts_locations)/2;
   
   %%maped TODO
   val=1/maped;
end


% Done
function [val]=LTE_AverageLatency(controller_placement,bts_locations)
   global thetha_l beta_l;
   lambda_l=	posion_lambda(append_locations(controller_placement,bts_locations));
   val=(1)/...
       (lambda_l*log(1+thetha_l)/((1/beta_l)+(thetha_l^(2/alpa))*int(1/(1+(u^(alpa/2))),'u',thetha_l^(-2/alpa),inf)));
end

%%
%% functions for Transparency
%%

function val=Ten(v)
    global thetha_l alpa beta_l;
    syms u;
    val=((1/beta_l)*(thetha_l^(2/alpa))*int(1/(1+(u^(alpa/2))),'u',thetha_l^(-2/alpa),inf))/(v*log(1+thetha_l));
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

function val=LTE_Transparency(controller_placement,bts_locations)
    total_locations=append_locations(controller_placement,bts_locations);
    v2=posion_lambda(total_locations);
    v1=posion_lambda(bts_locations);
    val=(Ten(v2)-Ten(v1))/...
        Ten(v1);
    val=abs(val);
end



%%
%% functions for AverageLinkFailure
%%


function val=LTE_AverageLinkFailure(controller_placement,bts_locations,w_controller_placement,w_bts_locations)
    global thetha_l alpa beta_l beta_w pl pw gamma_w_ed;
   
    lambda_l=posion_lambda(append_locations(controller_placement,bts_locations));
    lambda_w=posion_lambda(append_locations(w_controller_placement,w_bts_location));
    lambda_l_tilda=lambda_l*beta_l;
    % TODO: NW
    
    
    syms tu r;
    s=(thetha_w*tu^alpa)/pw;
    val=int(...
        exp(-2*lambda_l_tilda*int(r*((s*pl*r^(-alpa))/(1+s*pl*r^(-alpa))),'r',tu,inf))*...
        exp(-lambda_w*((1-exp(-lambda_w*NW))/(lambda_w*NW))*...
        int(int( (2*r*(1-exp(-(gamma_w_ed*(r^2+tu^2-2*r*tu*cos(fi))^(alpa/2))/pl)))/(1+(r^alpa/s*pw)),'r',0,tu),'fi',0,pi)*...
        beta_w*pi*(s*tu)^(2/alpa)*int(1/(1+u^(-alpa/2)),'u',(pw^2)*(s*tu^(-2/alpa)),inf)) ...
        *2*pi*lambda_l*tu*exp(-pi*lambda_l*(tu^2))...
        *beta_l ...
        , 'tu', 0, inf);
    val=val;
    disp(val)
end

%%%%%%%%%%%%%%%%%%%%%%%%

function val=Wifi_AverageLinkFailure(controller_placement,bts_locations)
    global thetha_l alpa beta_l pl beta_w pw gamma_w_cs thetha_w;
    syms tu r;
    lambda_w=posion_lambda(append_locations(controller_placement,bts_locations));
    lambda_l_tilda=lambda_l*beta_l;
    
    s=((thetha_l*(tu^alpa))/pl);  
    
    val=int(...
        exp(beta_w*lambda_w*int(int((2*r*(1-exp(-(gamma_w_cs*(r^2+th^2 -2*r*tu*cos(fi))^(alpa/2))/pw)  ))/(1+r^q/(((thetha_w*tu^alpa)/pw)*pw)),'r',tu,inf),'fi',0,pi))*...
        exp(lambda_l_tilda*...
        (int(int(),'r',0,pi)-...
         int(int(),'r',0,acos((r^2+tu^2-)))...
        *2*pi*lambda_w*tu*exp(-pi*lambda_w*(tu^2))...
        , 'tu', 0, inf);
    val=val;
    disp(val)
end
