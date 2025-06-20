function y=d2b(a,N)
%简单的将10进制转化为N为2进制小数
m=10;
for i= 1: N
    temp=a*2;
    y(i)=floor(temp);
    a=temp-floor(temp);
end
