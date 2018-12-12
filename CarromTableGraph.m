clear all

x=zeros(101,1);
for i=0:100
    x(i+1)=-10+20*(i/100);
end
y=x;
Z=zeros(101,101);
for i=0:100
    for j=0:100
        z(i+1,j+1)=CarromTable([x(i+1) y(j+1)]);
    end
end
surf(z)
