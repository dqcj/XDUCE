clc
clear
% close all
%由于输入的生物电信号是十进制数，而我们需要传输的是二进制数，所以我们必须将生物电信号转换成二进制再进行调制。

load('ECG.mat');
imput=ECG;
M=size(imput);
M=M(2);%M为生物电信号的长度
a=double(dec2bin(fix(max(abs(imput)))))-48;
MM=size(a);
MM=MM(2);%MM为最长整数位数的长度

zs=MM;%转换成二进制的整数位数
xs=2*MM;%转换成二进制的小数位数
%每个生物电信号转换成一个zs+xs+1位的二进制信号来进行编码，其中第一位是极性位，1代表正，0代表负，第2位开始连续zs位为整数位，剩余部分为小数位

data=[];%用来存放编码后的生物电信号
for i=1:M
    jx=1;
    if imput(i)<0
        jx=0;
    end
    data=[data jx];
    si=abs(imput(i));%当前的生物电信号数据
    si1=double(dec2bin(fix(si)))-48;
    MMM=size(si1);
    MMM=MMM(2);%二进制整数位的长度
    for j=MMM:zs-1
        data=[data 0];%补全0
    end
    data=[data si1];
    si2=d2b(si-fix(si),xs);
    data=[data si2];
end

A=100;       % A 幅度值，在这里即为信噪比
fs=5000000; % fs 采样率
F=50000;   % F 频率,小于采样率的一半（奈奎斯特）

M=size(data);
L=100;%一个码元的采样点数
N=L*M(2);%N是信号长度
NN=M(2);
dt=1/fs;    %时间间隔
t=0:dt:(N-1)*dt;    %时间向量
freqPixel=fs/N;     %频率分辨率，即点与点之间频率单位

%信源产生
baseband=[];
for i=1:L:N
    for j=1:L-1
        baseband(i+j)=data((i-1)/L+1);
    end
end



%载波信号
Rb=fs/L;%码元速率
carrier=A*cos(4*Rb*2*pi*t);%载波

Tlabel='时间/s';

No=wgn(1,N,1);%白噪声产生
%模拟信源信号
figure(1)
subplot(211)
t1=t(1:100000);
baseband1=baseband(1:100000);
plot(t1,baseband1)
axis([0,0.02,-0.5,1.5]);
title('基带信号波形');
xlabel(Tlabel);
ylabel('幅度/V');

%信号频谱
subplot(212)
t1=t(1:1000);
carrier1=carrier(1:1000);
plot(t1,carrier1);
title('载波波形');
xlabel(Tlabel);
ylabel('幅值/V');

%生成BPSK信号
doublebaseband=(baseband-0.5).*2;
BPSKsignal=doublebaseband.*carrier;

%BPSK信号加噪声
BPSKwithnoise=BPSKsignal+No;

%自相关
figure(2)
[Rx,maxlags]=xcorr(BPSKsignal,'unbiased');  %信号的自相关
plot(maxlags/fs*1000,Rx/max(Rx));
xlabel('时延差/ms');
title('BPSK加噪自相关');
ylabel('R(τ)');
ylim([-1,1]);
   
%频谱
figure(3)
freq=fft(BPSKwithnoise,N)*2/N;%做离散傅里叶
freq_d=abs(fftshift(freq));
w=(-N/2:1:N/2-1)*fs/N; %双边  
plot(w,freq_d);
title('BPSK加噪频谱');
xlabel('频率/Hz');
ylabel('幅值/V');

%功率谱
figure(4)
ypsd=freq_d.*conj(freq_d);
plot(w,ypsd);
title('BPSK加噪功率谱');
xlabel('频率/Hz');
ylabel('W/Hz');

%BPSK加噪输出图像
figure(5)
t1=t(1:500);
BPSKwithnoise1=BPSKwithnoise(1:500);
plot(t1,BPSKwithnoise1)
title('BPSK加噪输出图像');
xlabel('时间/s');
ylabel('幅值/V');

%求均值和方差
aver=mean(BPSKwithnoise);
v=var(BPSKwithnoise);




