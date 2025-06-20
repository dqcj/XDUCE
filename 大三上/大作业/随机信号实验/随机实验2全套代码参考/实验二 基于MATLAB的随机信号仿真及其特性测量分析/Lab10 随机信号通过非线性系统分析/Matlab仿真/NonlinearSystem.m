clc
clear
close all;
fs=50000;% fs 采样率
N=fs;% N 采样个数
dt=1/fs;     %时间间隔
t=0:dt:(N-1)*dt;    %时间向量
freqPixel=fs/N;%频率分辨率，即点与点之间频率单位
Snr=10;%信噪比值
xt=(1+cos(2*pi*1000*t)).*cos(2*pi*4000*t);
xt=awgn(xt,Snr);
figure(1)
subplot(211)
plot(t,xt);title('输入信号');
xlabel('时间/s');
ylabel('幅值/V');

freq=fft(xt);%做离散傅里叶
w1=(-N/2:1:N/2-1)*freqPixel; 
subplot(212)
freq_d=abs(fftshift(freq))*2/N;
plot(w1,freq_d);
xlabel('频率/Hz');
ylabel('幅度/V');
xlim([-7/5*4000,7/5*4000]);
title('输入信号频谱');

for n=1:length(xt)
   if xt(n)>0
       xo(n)=xt(n)^2;
   else
       xo(n)=0;
   end
end

figure(2)
subplot(211)
plot(t,xo);
title('输出信号');
xlabel('时间/s');
ylabel('幅值/V');

subplot(212)
freq=fft(xo)*2/N;%做离散傅里叶
w1=(-N/2:1:N/2-1)*freqPixel; %w=-N/2:1:N/2-1，双边
freq_d=abs(fftshift(freq));
plot(w1,freq_d);
xlabel('频率/Hz');
ylabel('幅度/V');
title('输出信号频谱');

%功率谱
freq_s(1:length(freq_d)/2)=freq_d(length(freq_d)/2+1:length(freq_d));
ypsd=freq_s.*conj(freq_s);
w2=(0:length(freq_s)-1)*fs/length(freq_d); %单边
figure(4)
plot(w2,ypsd);
title('信号功率谱');
xlabel('频率/Hz');
ylabel('幅度/V');


%系统输出的自相关
figure(5)
[Rx,maxlags]=xcorr(xo);  %信号的自相关
plot(maxlags/fs,Rx);
title('系统输出自相关');
xlabel('时间/s');
ylabel('幅值/V');


%均值与方差
aver1=mean(xo)
v1=var(xo)
















