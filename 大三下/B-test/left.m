% 清除工作区、命令行窗口和图形窗口
clc;
clear;
close all;

% ==========【参数设定】==========
% 设置输入信号的基本参数
amplitude = 1;                % 信号幅度值
samplingFreq = 1000000;         % 采样频率，单位 Hz
signalFreq = 10000;             % 基础信号频率，用于某些情况
numSamples = 10000;             % 总采样点数
timeStep = 1 / samplingFreq;    % 时间步长
timeVector = 0:timeStep:(numSamples - 1)*timeStep;  % 时间向量

% 设置不同测试用例中的具体频率值
freqCase0 = 15 * 10^3;          % 情况0：15kHz 正弦波
freqCase1 = 20 * 10^3;          % 情况1：20kHz 正弦波
freqCase2 = 30 * 10^3;          % 情况1：30kHz 正弦波
freqCase3 = 100 * 10^3;         % 情况1：100kHz 正弦波

% ==========【选择输入信号类型】==========
dataSource = 2;  % 控制信号源的选择（0: 单频正弦波；1: 多频叠加；2: 方波）

switch dataSource
    case 0
        inputSignal = amplitude * sin(2 * pi * freqCase0 * timeVector);
    case 1
        inputSignal = amplitude * sin(2 * pi * freqCase1 * timeVector) + amplitude * sin(2 * pi * freqCase2 * timeVector) + amplitude * sin(2 * pi * freqCase3 * timeVector);
    case 2
        inputSignal = amplitude * square(2 * pi * freqCase1 * timeVector, 50); % 50%占空比方波
    otherwise
        inputSignal = zeros(size(timeVector)); % 默认为零信号
end

% ==========【绘制输入信号的时域和频域图】==========
figure(1);

% 时域图
subplot(2, 1, 1);
plot(timeVector, inputSignal);
title('输入信号的时域波形');
xlabel('时间 (s)');
ylabel('电压 (V)');
grid on;

% 频域图
frequencyDomain = fft(inputSignal, numSamples);
frequencyDomainShifted = abs(fftshift(frequencyDomain));
frequencyAxis = (-numSamples/2 : numSamples/2 - 1) * samplingFreq / numSamples;

subplot(2, 1, 2);
plot(frequencyAxis, frequencyDomainShifted / numSamples);
axis([-200*10^3 200*10^3 0 1]);
title('输入信号的频域波形');
xlabel('频率 (Hz)');
ylabel('幅度');
grid on;

% ==========【低通滤波器建模与波特图显示】==========
resistor = 63.7;               % 电阻阻值（Ω）
capacitor = 100 * 10^(-9);     % 电容容量（F）
transferFunc = tf(1, [resistor * capacitor, 1]);  % RC低通滤波器传递函数

figure(2);
bode(transferFunc);
title('RC低通滤波器的波特图');

% ==========【信号通过滤波器后的输出结果】==========
[outputSignal, timeOut] = lsim(transferFunc, inputSignal, timeVector);

figure(3);
% 输出信号时域图
subplot(2, 1, 1);
plot(timeOut, outputSignal);
title('滤波后输出信号的时域波形');
xlabel('时间 (s)');
ylabel('电压 (V)');
grid on;

% 输出信号频域图
outputFFT = fft(outputSignal);
outputFFTS = abs(fftshift(outputFFT));

subplot(2, 1, 2);
plot(frequencyAxis, outputFFTS / numSamples);
axis([-200*10^3 200*10^3 0 1]);
title('滤波后输出信号的频域波形');
xlabel('频率 (Hz)');
ylabel('幅度');
grid on;

% ==========【计算并绘制自相关函数】==========
figure(4);

% 输入信号自相关
[inputAutoCorr, lagValues] = xcorr(inputSignal, 'unbiased');
lagSeconds = lagValues / samplingFreq;

subplot(2, 1, 1);
plot(lagSeconds, inputAutoCorr / max(inputAutoCorr));
title('输入信号的归一化自相关函数');
xlabel('时间延迟 (s)');
ylabel('R(t)');
grid on;

% 输出信号自相关
[outputAutoCorr, lagValuesOut] = xcorr(outputSignal, 'unbiased');
lagSecondsOut = lagValuesOut / samplingFreq;

subplot(2, 1, 2);
plot(lagSecondsOut, outputAutoCorr / max(outputAutoCorr));
title('输出信号的归一化自相关函数');
xlabel('时间延迟 (s)');
ylabel('R(t)');
grid on;

% ==========【功率谱密度分析】==========
figure(5);

% 输出信号功率谱
outputPSD = outputFFTS .* conj(outputFFTS);
subplot(2, 1, 1);
plot(frequencyAxis, outputPSD);
title('输出信号的功率谱密度');
xlabel('频率 (Hz)');
ylabel('功率 (W/Hz)');
grid on;

% 输入信号功率谱
inputPSD = frequencyDomainShifted .* conj(frequencyDomainShifted);
subplot(2, 1, 2);
plot(frequencyAxis, inputPSD);
title('输入信号的功率谱密度');
xlabel('频率 (Hz)');
ylabel('功率 (W/Hz)');
grid on;