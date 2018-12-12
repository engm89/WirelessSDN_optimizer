function [xbest,all_best, ybest, funceval, allybest]=CarromTableGlobalOptimization(n,m,s,eps,a,b)
all_best=ones(7);
allybest=[];
% ally=[];
x0=ones(1,n);
for i=1:n
    r=a(i)+(b(i)-a(i))*rand;
    x0(i)=r;
end

[y0,y1,y2,y3,y4,y5,y6]=WCPP(x0);
z0=[x0 y0];
k=0;
xk=x0;
yk=y0;
zk=[xk yk];
funceval=1;

while (k<m)
    za=zeros(1,n+1);
    xbest=xk;
    ybest=yk;
    all_best=[y0,y1,y2,y3,y4,y5,y6];
    zk=[xk yk];
    
    
      z=zeros(1,n+1);
      flag=1;
      for i=1:n
          r=a(i)+(b(i)-a(i))*rand;
          if (r==a(i))||(r==b(i))
              flag=0;
          end
          z(i)=r;
      end
      if flag==0
          z(n+1)=ybest*rand;
      end
    
          
      
      
      for j=0:s-1
        t=j/(s-1);
        zt=t.*zk+(1-t).*z;
        xt=zt(1:n);
        yt=zt(n+1);
        [w,y1,y2,y3,y4,y5,y6]=WCPP(xt);
%         ally=[ally w];
        funceval=funceval+1;
        if (w<yt)&(w<ybest)
            xbest=xt;
            ybest=w;
            all_best=[w,y1,y2,y3,y4,y5,y6];
            allybest=[allybest ybest];
            break;
        end
    end
    k=k+1;
    zk=[xbest ybest];
    xk=zk(1:n);
    yk=zk(n+1);
end

    
        
        
        