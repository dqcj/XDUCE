clear
clc
% close all
load('EMG.mat');
load('EEG.mat');
load('ECG.mat');
EEG=EEG_1;
fs=5000000;

%求均值和方差
aver=mean(EMG);
v=var(EMG);
fprintf("EMG信号的均值为%.6f,方差为%.6f\n",aver,v)

aver=mean(EEG);
v=var(EEG);
fprintf("EEG信号的均值为%.6f,方差为%.6f\n",aver,v)

aver=mean(ECG);
v=var(ECG);
fprintf("ECG信号的均值为%.6f,方差为%.6f\n",aver,v)

%绘制图像
figure(1)
subplot(3,1,1)
plot(ECG)
title('ECG波形');

subplot(3,1,2)
plot(EEG)
title('EEG波形');

subplot(3,1,3)
plot(EMG)
axis([0 1000 -10 10])
title('EMG波形');


N=size(ECG);
N=N(2);
%自相关
figure(2)
[Rx,maxlags]=xcorr(ECG,'unbiased');  %信号的自相关
plot(maxlags/fs*1000,Rx/max(Rx));
xlabel('时延差/ms');
title('ECG自相关');
ylabel('R(τ)');
ylim([-1,1]);
   
%频谱
figure(3)
freq=fft(ECG,N)*2/N;%做离散傅里叶
freq_d=abs(fftshift(freq));
w=(-N/2:1:N/2-1)*fs/N; %双边  
plot(w,freq_d);
title('ECG频谱');
xlabel('频率/Hz');
ylabel('幅值/V');

%功率谱
figure(4)
ypsd=freq_d.*conj(freq_d);
plot(w,ypsd);
title('ECG功率谱');
xlabel('频率/Hz');
ylabel('W/Hz');

N=size(EEG);
N=N(2);
%自相关
figure(5)
[Rx,maxlags]=xcorr(EEG,'unbiased');  %信号的自相关
plot(maxlags/fs*1000,Rx/max(Rx));
xlabel('时延差/ms');
title('EEG自相关');
ylabel('R(τ)');
ylim([-1,1]);
   
%频谱
figure(6)
freq=fft(EEG,N)*2/N;%做离散傅里叶
freq_d=abs(fftshift(freq));
w=(-N/2:1:N/2-1)*fs/N; %双边  
plot(w,freq_d);
title('EEG频谱');
xlabel('频率/Hz');
ylabel('幅值/V');

%功率谱
figure(7)
ypsd=freq_d.*conj(freq_d);
plot(w,ypsd);
title('EEG功率谱');
xlabel('频率/Hz');
ylabel('W/Hz');

N=size(EMG);
N=N(2);
%自相关
figure(8)
[Rx,maxlags]=xcorr(EMG,'unbiased');  %信号的自相关
plot(maxlags/fs*1000,Rx/max(Rx));
xlabel('时延差/ms');
title('EMG自相关');
ylabel('R(τ)');
ylim([-1,1]);
   
%频谱
figure(9)
freq=fft(EMG,N)*2/N;%做离散傅里叶
freq_d=abs(fftshift(freq));
w=(-N/2:1:N/2-1)*fs/N; %双边  
plot(w,freq_d);
title('EMG频谱');
xlabel('频率/Hz');
ylabel('幅值/V');

%功率谱
figure(10)
ypsd=freq_d.*conj(freq_d);
plot(w,ypsd);
title('EMG功率谱');
xlabel('频率/Hz');
ylabel('W/Hz');



