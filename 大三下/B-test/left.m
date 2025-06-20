% ����������������д��ں�ͼ�δ���
clc;
clear;
close all;

% ==========�������趨��==========
% ���������źŵĻ�������
amplitude = 1;                % �źŷ���ֵ
samplingFreq = 1000000;         % ����Ƶ�ʣ���λ Hz
signalFreq = 10000;             % �����ź�Ƶ�ʣ�����ĳЩ���
numSamples = 10000;             % �ܲ�������
timeStep = 1 / samplingFreq;    % ʱ�䲽��
timeVector = 0:timeStep:(numSamples - 1)*timeStep;  % ʱ������

% ���ò�ͬ���������еľ���Ƶ��ֵ
freqCase0 = 15 * 10^3;          % ���0��15kHz ���Ҳ�
freqCase1 = 20 * 10^3;          % ���1��20kHz ���Ҳ�
freqCase2 = 30 * 10^3;          % ���1��30kHz ���Ҳ�
freqCase3 = 100 * 10^3;         % ���1��100kHz ���Ҳ�

% ==========��ѡ�������ź����͡�==========
dataSource = 2;  % �����ź�Դ��ѡ��0: ��Ƶ���Ҳ���1: ��Ƶ���ӣ�2: ������

switch dataSource
    case 0
        inputSignal = amplitude * sin(2 * pi * freqCase0 * timeVector);
    case 1
        inputSignal = amplitude * sin(2 * pi * freqCase1 * timeVector) + amplitude * sin(2 * pi * freqCase2 * timeVector) + amplitude * sin(2 * pi * freqCase3 * timeVector);
    case 2
        inputSignal = amplitude * square(2 * pi * freqCase1 * timeVector, 50); % 50%ռ�ձȷ���
    otherwise
        inputSignal = zeros(size(timeVector)); % Ĭ��Ϊ���ź�
end

% ==========�����������źŵ�ʱ���Ƶ��ͼ��==========
figure(1);

% ʱ��ͼ
subplot(2, 1, 1);
plot(timeVector, inputSignal);
title('�����źŵ�ʱ����');
xlabel('ʱ�� (s)');
ylabel('��ѹ (V)');
grid on;

% Ƶ��ͼ
frequencyDomain = fft(inputSignal, numSamples);
frequencyDomainShifted = abs(fftshift(frequencyDomain));
frequencyAxis = (-numSamples/2 : numSamples/2 - 1) * samplingFreq / numSamples;

subplot(2, 1, 2);
plot(frequencyAxis, frequencyDomainShifted / numSamples);
axis([-200*10^3 200*10^3 0 1]);
title('�����źŵ�Ƶ����');
xlabel('Ƶ�� (Hz)');
ylabel('����');
grid on;

% ==========����ͨ�˲�����ģ�벨��ͼ��ʾ��==========
resistor = 63.7;               % ������ֵ������
capacitor = 100 * 10^(-9);     % ����������F��
transferFunc = tf(1, [resistor * capacitor, 1]);  % RC��ͨ�˲������ݺ���

figure(2);
bode(transferFunc);
title('RC��ͨ�˲����Ĳ���ͼ');

% ==========���ź�ͨ���˲��������������==========
[outputSignal, timeOut] = lsim(transferFunc, inputSignal, timeVector);

figure(3);
% ����ź�ʱ��ͼ
subplot(2, 1, 1);
plot(timeOut, outputSignal);
title('�˲�������źŵ�ʱ����');
xlabel('ʱ�� (s)');
ylabel('��ѹ (V)');
grid on;

% ����ź�Ƶ��ͼ
outputFFT = fft(outputSignal);
outputFFTS = abs(fftshift(outputFFT));

subplot(2, 1, 2);
plot(frequencyAxis, outputFFTS / numSamples);
axis([-200*10^3 200*10^3 0 1]);
title('�˲�������źŵ�Ƶ����');
xlabel('Ƶ�� (Hz)');
ylabel('����');
grid on;

% ==========�����㲢��������غ�����==========
figure(4);

% �����ź������
[inputAutoCorr, lagValues] = xcorr(inputSignal, 'unbiased');
lagSeconds = lagValues / samplingFreq;

subplot(2, 1, 1);
plot(lagSeconds, inputAutoCorr / max(inputAutoCorr));
title('�����źŵĹ�һ������غ���');
xlabel('ʱ���ӳ� (s)');
ylabel('R(t)');
grid on;

% ����ź������
[outputAutoCorr, lagValuesOut] = xcorr(outputSignal, 'unbiased');
lagSecondsOut = lagValuesOut / samplingFreq;

subplot(2, 1, 2);
plot(lagSecondsOut, outputAutoCorr / max(outputAutoCorr));
title('����źŵĹ�һ������غ���');
xlabel('ʱ���ӳ� (s)');
ylabel('R(t)');
grid on;

% ==========���������ܶȷ�����==========
figure(5);

% ����źŹ�����
outputPSD = outputFFTS .* conj(outputFFTS);
subplot(2, 1, 1);
plot(frequencyAxis, outputPSD);
title('����źŵĹ������ܶ�');
xlabel('Ƶ�� (Hz)');
ylabel('���� (W/Hz)');
grid on;

% �����źŹ�����
inputPSD = frequencyDomainShifted .* conj(frequencyDomainShifted);
subplot(2, 1, 2);
plot(frequencyAxis, inputPSD);
title('�����źŵĹ������ܶ�');
xlabel('Ƶ�� (Hz)');
ylabel('���� (W/Hz)');
grid on;