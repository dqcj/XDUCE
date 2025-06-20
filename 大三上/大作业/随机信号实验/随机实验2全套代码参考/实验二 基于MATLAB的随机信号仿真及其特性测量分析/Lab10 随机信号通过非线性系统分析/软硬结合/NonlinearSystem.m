clc
clear
type=1;%��Ӳ��Ϸ�ʽ��0��ʾ������ֱ��ͨ�����߽����ݷ��͵��豸������͵�DA
%                                         1��ʾ������mif�����ļ���ͨ��FPGA�������͵�DA

fs=30720;        % ������,Ӳ��ϵͳ��׼������30.72 MHz, Ϊ�򻯷�Ƶ���ã�fs����30.72MHz, 3.72Mhz��307.2KHz , 30.72KHz
N=10000;    %������
dt=1/fs;     %ʱ����
t=0:dt:(N-1)*dt;    %ʱ������
freqPixel=fs/N;%Ƶ�ʷֱ��ʣ��������֮��Ƶ�ʵ�λ

%% �����ź�
Snr=10;%�����ֵ
xt=(1+cos(2*pi*1000*t)).*cos(2*pi*4000*t);
xt=awgn(xt,Snr);

%% 
figure(1)
subplot(211)
plot(t,xt);title('�����ź�');
xlabel('ʱ��/s');
ylabel('��ֵ/V');

freq=fft(xt);%����ɢ����Ҷ
w1=(-N/2:1:N/2-1)*freqPixel; 
subplot(212)
freq_d=abs(fftshift(freq))*2/N;
plot(w1,freq_d);
xlabel('Ƶ��/Hz');
ylabel('����/V');
xlim([-7/5*4000,7/5*4000]);
title('�����ź�Ƶ��');

%% ƽ����
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
title('����ź�');
xlabel('ʱ��/s');
ylabel('��ֵ/V');

subplot(212)
freq=fft(xo)*2/N;%����ɢ����Ҷ
w1=(-N/2:1:N/2-1)*freqPixel; %w=-N/2:1:N/2-1��˫��
freq_d=abs(fftshift(freq));
plot(w1,freq_d);
xlabel('Ƶ��/Hz');
ylabel('����/V');
title('����ź�Ƶ��');

%������
freq_s(1:length(freq_d)/2)=freq_d(length(freq_d)/2+1:length(freq_d));
ypsd=freq_s.*conj(freq_s);
w2=(0:length(freq_s)-1)*fs/length(freq_d); %����
figure(4)
plot(w2,ypsd);
title('�źŹ�����');
xlabel('Ƶ��/Hz');
ylabel('����/V');


%ϵͳ����������
figure(5)
[Rx,maxlags]=xcorr(xo);  %�źŵ������
plot(maxlags/fs,Rx);
title('ϵͳ��������');
xlabel('ʱ��/s');
ylabel('��ֵ/V');


%��ֵ�뷽��
aver1=mean(xo)
v1=var(xo)

CH1_data=xt;%CH1ͨ����������ź�
CH2_data=xo;%CH1ͨ������ѵ��ź�
%% ����DA����
if  type==0
    divFreq=30720000/fs-1;
    dataNum=length(CH1_data);
     DA_OUT(CH1_data,CH2_data,divFreq,dataNum);
else 
    gain_flag=0;    %is_gain �Ƿ�����ݽ��зŴ� 0�������ݷŴ����ֵΪ511,  1�����Ŵ�
    SaveData('.\ROM_DATA_ch1.mif',CH1_data,gain_flag);
    SaveData('.\ROM_DATA_ch2.mif',CH2_data,gain_flag);
end














