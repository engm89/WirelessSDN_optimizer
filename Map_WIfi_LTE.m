function [val,val1,val2,val3,val4,val5,val6] = Map_WIfi_LTE(x)

global Operator1_coefficient_parameters  Operator2_coefficient_parameters ...
       wOperator1_bts_locations lOperator2_bts_locations M1 M2 M3 WM_0 WM_15 WM_30 LM_10 LM_20 LM_30;

   
M1 = containers.Map([0,5,10,15,20,25,30,35,40,45,50],[0.05,0.095,0.09,0.085,0.08,0.075,0.07,0.065,0.06,0.055,0.05]);
M2 = containers.Map([0,5,10,15,20,25,30,35,40,45,50],[0.06,0.12,0.13,0.11,0.1,0.09,0.08,0.07,0.065,0.06,0.055]);
M3 = containers.Map([0,5,10,15,20,25,30,35,40,45,50],[0.12,0.22,0.22,0.19,0.15,0.1,0.85,0.08,0.07,0.065,0.06]);


WM_0 = containers.Map([5,10,15,20,25,30,35,40],[0.55,0.35,0.25,0.2,0.18,0.13,0.11,0.1]);
WM_15 = containers.Map([5,10,15,20,25,30,35,40],[0.2,0.12,0.09,0.08,0.07,0.06,0.05,0.04]);
WM_30 = containers.Map([5,10,15,20,25,30,35,40],[0.02,0.015,0.012,0.01,0.07,0.05,0.003,0.001]);

LM_10 = containers.Map([5,10,15,20,25,30,35,40],[0.25,0.18,0.12,0.09,0.05,0.02,0.01,0.005]);
LM_20 = containers.Map([5,10,15,20,25,30,35,40],[0.14,0.1,0.07,0.05,0.03,0.018,0.006,0.005]);
LM_30 = containers.Map([5,10,15,20,25,30,35,40],[0.09,0.07,0.05,0.022,0.02,0.015,0.005,0.005]);


% take all as an single input parse them to there difftent varibles
size=length(x)/3;
wOperator1_controller_placement=x(1,1:size);
lOperator2_controller_placement=x(1,size+1:2*size);
len=size/2;
wOperator1_controller_usage=x(1,2*size+1:2*size+len);
lOperator2_controller_usage=x(1,(2*size+len+1):(3*size));

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
usage1=round(duplicate(wOperator1_controller_usage),4);
usage2=round(duplicate(lOperator2_controller_usage),4);

% replace the 0 with -1 (out of the game)
wOperator1_controller_placement(usage1~=0.5)=-1;
lOperator2_controller_placement(usage2~=0.5)=-1;


val1=double(Wifi_AverageLatency(lOperator2_controller_placement,lOperator2_bts_locations,wOperator1_controller_placement,wOperator1_bts_locations))*Operator1_coefficient_parameters(1);
%disp(val1)

val2=double(Wifi_AverageLinkFailure(wOperator1_controller_placement,wOperator1_bts_locations,lOperator2_controller_placement,lOperator2_bts_locations))*Operator1_coefficient_parameters(2);

%val3=double(Transparency(Operator1_controller_placement,Operator1_bts_locations))*Operator1_coefficient_parameters(3);
%disp(val2)

val4=double(LTE_AverageLatency(lOperator2_controller_placement,lOperator2_bts_locations))*Operator2_coefficient_parameters(1);
%disp(val4)


val5=double(LTE_AverageLinkFailure(lOperator2_controller_placement,lOperator2_bts_locations,wOperator1_controller_placement,wOperator1_bts_locations))*Operator2_coefficient_parameters(2);
%disp('->')
%disp(val5)

val6=double(LTE_Transparency(lOperator2_controller_placement,lOperator2_bts_locations))*Operator2_coefficient_parameters(3);
%disp(val6)

val=val1+val2+val4+val5+val6;%+val3;
%disp(vpa(val))

val3=0;
end

function MM = duplicate(controller_usage)
MM=repelem(controller_usage,2);
end

%%
%% functions for AverageLatency
%%


% Done
function [val]=Wifi_AverageLatency(controller_placement,bts_locations,W_controller_placement,W_bts_locations)
    global M1 M2 M3 ;
   lambda_l=posion_lambda(append_locations(controller_placement,bts_locations));
   lambda_W=posion_lambda(append_locations(W_controller_placement,W_bts_locations));
   if lambda_l<2
       val=M1(min(max(lambda_W-rem(lambda_W,5),0),50));
   elseif lambda_l>=2 && lambda_l<8
       val=M2(min(max(lambda_W-rem(lambda_W,5),0),50));
   else
       val=M3(min(max(lambda_W-rem(lambda_W,5),0),50));
   end
   
   val=1/val;
end


% Done
function [val]=LTE_AverageLatency(controller_placement,bts_locations)
   global thetha_l beta_l alpa;
   
   syms u;
   lambda_l=posion_lambda(append_locations(controller_placement,bts_locations));
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
  %  disp(val)
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
  global LM_10 LM_20 LM_30 ;
   lambda_l=posion_lambda(append_locations(controller_placement,bts_locations))/10;
   lambda_W=posion_lambda(append_locations(w_controller_placement,w_bts_locations))/10;
   if lambda_W<15
       val=LM_10(min(max(lambda_l-rem(lambda_l,5),5),40));
   elseif lambda_W>=15 && lambda_W<25
       val=LM_20(min(max(lambda_l-rem(lambda_l,5),5),40));
   else
       val=LM_30(min(max(lambda_l-rem(lambda_l,5),5),40));
   end
   
end

%%%%%%%%%%%%%%%%%%%%%%%%


function val=Wifi_AverageLinkFailure(controller_placement,bts_locations,lOperator2_controller_placement,lOperator2_bts_locations)
  global WM_0 WM_15 WM_30 ;
   lambda_l=posion_lambda(append_locations(lOperator2_controller_placement,lOperator2_bts_locations))/10;
   lambda_W=posion_lambda(append_locations(controller_placement,bts_locations))/10;

   if lambda_l<7
       val=WM_0(min(max(lambda_W-rem(lambda_W,5),5),40));
   elseif lambda_l>=7 && lambda_l<22
       val=WM_15(min(max(lambda_W-rem(lambda_W,5),5),40));
   else
       val=WM_30(min(max(lambda_W-rem(lambda_W,5),5),40));
   end
   
end