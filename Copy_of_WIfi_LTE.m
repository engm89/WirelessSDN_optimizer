function [val,val1,val2,val3,val4,val5,val6] = Copy_of_WIfi_LTE(x)

global Operator1_coefficient_parameters  Operator2_coefficient_parameters ...
       wOperator1_bts_locations lOperator2_bts_locations M1 M2 M3;

   
M1 = containers.Map([0,5,10,15,20,25,30,35,40,45,50],[0.05,0.095,0.09,0.085,0.08,0.075,0.07,0.065,0.06,0.055,0.05]);
M2 = containers.Map([0,5,10,15,20,25,30,35,40,45,50],[0.06,0.12,0.13,0.11,0.1,0.09,0.08,0.07,0.065,0.06,0.055]);
M3 = containers.Map([0,5,10,15,20,25,30,35,40,45,50],[0.12,0.22,0.22,0.19,0.15,0.1,0.85,0.08,0.07,0.065,0.06]);

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
disp(val1)

val2=double(Wifi_AverageLinkFailure(wOperator1_controller_placement,wOperator1_bts_locations,lOperator2_controller_placement,lOperator2_bts_locations))*Operator1_coefficient_parameters(2);
%val3=double(Transparency(Operator1_controller_placement,Operator1_bts_locations))*Operator1_coefficient_parameters(3);
disp(val2)

val4=double(LTE_AverageLatency(lOperator2_controller_placement,lOperator2_bts_locations))*Operator2_coefficient_parameters(1);
disp(val4)


val5=double(LTE_AverageLinkFailure(lOperator2_controller_placement,lOperator2_bts_locations,wOperator1_controller_placement,wOperator1_bts_locations))*Operator2_coefficient_parameters(2);
%disp('->')
disp(val5)

val6=double(LTE_Transparency(lOperator2_controller_placement,lOperator2_bts_locations))*Operator2_coefficient_parameters(3);
disp(val6)

val=val1+val2+val4+val5+val6;%+val3;
%disp(vpa(val))
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
    global thetha_l alpa beta_l pl pw gamma_w_ed beta_w;
    syms tu ;

    lambda_l=posion_lambda(append_locations(controller_placement,bts_locations));
    lambda_w=posion_lambda(append_locations(w_controller_placement,w_bts_locations));
    
    s_fun=@(tu)((thetha_l*(tu^alpa))/pl);  
    A=@(c1,c2,c3,tu,r,fiii) 1-exp(-(c3/c1)*(r.^2+c2^2-r.*c2.*cos(fiii)).^(alpa/2));
    G=@(a1,a2,b1,b2,s,p,c1,c2,c3,tu) integral2(@(r,fiii) 2.*r.*A(c1,c2,c3,tu,r,fiii)./(1+r.^alpa./s.*p),a1,a2,b1,b2,'RelTol',1e-8,'AbsTol',1e-13);
    
    %Lill
    lambda_l_tilda=lambda_l*beta_l;
    Lill=@(s,tu)exp(-2.*lambda_l_tilda.*integral( @(r) r.*s.*pl.*r.^(-alpa)./(1+s.*pl.*r.^(-alpa)),abs(tu),inf));
   
    Lill_SOL = @(tu)arrayfun(@(tu)Lill(s_fun(tu),tu),tu);

   % ex1=integral(Lill_SOL,0,inf,'RelTol',1e-8,'AbsTol',1e-13);

    %Liwl
    Nw_top=pi*integral( @(x) x.^(2./alpa).*exp(-x),0,inf).*integral( @(x) x.^(-2./alpa).*exp(-x),0,inf);
    Z=@(s,a,b) pi.*(s.*a).^(alpa./2).*integral(@(u) (1./(1+u.^(-alpa./2))),(s.*a).*b.^2,inf);

    bw_tag=(1-exp(-lambda_w.*Nw_top))./lambda_w.*Nw_top;
    Liwl=@(s,tu) exp(-lambda_w.*(bw_tag.*G(0,pi,0,abs(tu),s,pw,pl,abs(tu),gamma_w_ed,tu)+beta_w.*Z(s,abs(tu),pw)));
    Liwl_SOL = @(tu)arrayfun(@(tu)Liwl(s_fun(tu),tu),tu);

    %ex2=integral(Liwl_SOL,0,inf,'RelTol',1e-8,'AbsTol',1e-13);

    
    SOL = @(tu) arrayfun(@(tu) Lill_SOL(tu).*Liwl_SOL(tu)...
        .*beta_l.*2.*pi.*lambda_l.*tu.*exp(-pi.*lambda_l.*(tu.^2)),tu);
   
    val=integral(SOL,0,inf,'RelTol',1e-8,'AbsTol',1e-13);
  
    disp(val)
end

%%%%%%%%%%%%%%%%%%%%%%%%

function val=indeicator(tu,delta_l) 
    v=[tu,0];
    val=v(find(v<delta_l,1,'first'))*(abs(tu)-delta_l);
end

function val=Wifi_AverageLinkFailure(controller_placement,bts_locations,lOperator2_controller_placement,lOperator2_bts_locations)
    global thetha_l alpa beta_l pl beta_w pw gamma_w_cs gamma_w_ed;
    syms tu r fiii;
    
    lambda_w=posion_lambda(append_locations(controller_placement,bts_locations));
    lambda_l=posion_lambda(append_locations(lOperator2_controller_placement,lOperator2_bts_locations));
    lambda_l_tilda=lambda_l*beta_l;
    
    
    s_fun=@(tu)((thetha_l*(abs(tu)^alpa))/pl);  
    A=@(c1,c2,c3,tu,r,fiii) 1-exp(-(c3/c1)*(r.^2+c2^2-r.*c2.*cos(fiii)).^(alpa/2));
    G=@(a1,a2,b1,b2,s,p,c1,c2,c3,tu,r,fiii) integral2(@(r,fiii) 2.*r.*A(c1,c2,c3,tu,r,fiii)./(1+r.^alpa./s.*p),a1,a2,b1,b2);
    %
    % check the order of integration TODO
    
    % Liww                             
    G_liww=@(r,fiii,tu) G(0,pi,abs(tu),inf,s_fun(tu),pw,pw,abs(tu),gamma_w_cs,tu,r,fiii);
    G_SOL = @(tu)arrayfun(G_liww,r,fiii,tu);

    
    LIWW=@(tu) exp(-beta_w.*lambda_w.*G_SOL(tu));
    LIWW_SOL = @(tu) arrayfun(LIWW,tu);

    %exp1=integral(LIWW_SOL,0,inf,'RelTol',1e-8,'AbsTol',1e-13);
    
    
  %  Lilw
   delta_l_int= @(x) arrayfun(@(x) x.^(((alpa+1)./alpa)-1).*exp(-x),x);
   delta_l=integral(delta_l_int,0,inf);
   delta_l=((pl/gamma_w_ed)^(1/alpa))*delta_l;
   
   G_Lilw1=@(r,fiii,tu) G(0,pi,indeicator(tu,delta_l),inf,s_fun(tu),pl,pl,abs(tu),gamma_w_ed,tu,r,fiii);
   G_Lilw1_SOL = @(tu)arrayfun(G_Lilw1,r,fiii,tu);
   

    G1=@(b1,b2,s,p,c1,c2,c3,tu,r,fiii) integral2(@(r,fiii) 2.*r.*A(c1,c2,c3,tu,r,fiii)./(1+r.^alpa./s.*p),b1,b2,0,@(r)acos((r.^2+abs(tu).^2+delta_l.^2)./(2*tu.^r)),'RelTol',1e-8,'AbsTol',1e-13);

   G_Lilw2=@(r,fiii,tu) G1(tu-delta_l,tu+delta_l,s_fun(tu),pl,pl,tu,gamma_w_ed,tu,r,fiii);
   G_Lilw2_SOL = @(tu) arrayfun(G_Lilw2,r,fiii,tu);
   
   Lilw=@(tu) exp(beta_l.*lambda_l.*(G_Lilw1_SOL(tu)-G_Lilw2_SOL(tu)));
   Lilw_SOL = @(tu)arrayfun(Lilw,tu);

   %exp2=integral(Lilw_SOL,0,inf,'RelTol',1e-8,'AbsTol',1e-13);
 
   
   %secend_exp

   Nw_top=pi*integral( @(x) x.^(2./alpa).*exp(-x),0,inf).*integral( @(x) x.^(-2./alpa).*exp(-x),0,inf);
   
   
   Nw_tilda_top_int= @(r,tu) r.*acos(r./2.*tu).*exp(-(gamma_w_cs./pw).*r.^alpa).*r;
   
   Nw_tilda_top=@(tu) 2.*integral(@(r)Nw_tilda_top_int(r,abs(tu)) ,0,  2.*abs(tu));
   
   t_fun=integral( @(t)exp(-t.^2),((pi.^2*lambda_l_tilda./4).*(sqrt(pl./gamma_w_ed))),inf);
  
   exp_expression=@(tu) ((1-exp(-lambda_w.*(Nw_top-Nw_tilda_top(tu))))./(lambda_w.*(Nw_top-Nw_tilda_top(tu)))).*(2./sqrt(pi)).*t_fun;
  
   exp3_SOL = @(tu)arrayfun(exp_expression,tu);
   %exp3=integral(exp3_SOL,0,inf,'RelTol',1e-8,'AbsTol',1e-13);

   SOL = @(tu)arrayfun(@(tu)( LIWW_SOL(tu).*Lilw_SOL(tu)*exp3_SOL(tu)...
        .*2.*pi.*lambda_w.*tu.*exp(-pi.*lambda_w.*(tu^2))),tu);
   
   val=integral(SOL,0,inf);
    
        %
    disp(val)
end
