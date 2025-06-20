%================= STEP 0: 初始化环境 ===================
clc; clear; close all;

%================= STEP 1: 设置仿真参数 ===================
N = 1e5;                          % 每种设置下的比特数
SNR_dB = 0:2:20;                  % 定义信噪比范围：从0到20 dB，步长为2 dB
mod_type = '16QAM';               % 改为使用 16QAM 调制方式
M = 16;                           % 16QAM对应的调制阶数（16个符号点）
k = log2(M);                      % 每个符号携带的比特数（log2(16)=4）
Nr_antennas = 1:5;                % 接收天线数量测试集（L = 1 到 5）
combine_methods = {'SC', 'MRC', 'EGC'}; % 分集合并方式

% 预分配 BER 存储空间
ber_SC = zeros(length(SNR_dB), length(Nr_antennas)); % SC 合并方式的 BER
ber_EGC = zeros(length(SNR_dB), length(Nr_antennas)); % EGC 合并方式的 BER
ber_MRC = zeros(length(SNR_dB), length(Nr_antennas)); % MRC 合并方式的 BER

%================= STEP 2: 生成随机调制信号 ===================
data = randi([0 1], N*k, 1); % 生成 N*k 个随机比特作为发送数据
tx_sym = qammod(data, M, 'InputType', 'bit', 'UnitAveragePower', true);
% 使用QAM调制将比特转换为复数符号（16QAM），单位平均功率归一化

%================= STEP 3: 开始仿真 ===================
for method_idx = 1:length(combine_methods) % 遍历三种合并方式
    method = combine_methods{method_idx}; % 获取当前合并方式名称
    
    for nRx_idx = 1:length(Nr_antennas) % 遍历不同接收天线数
        nRx = Nr_antennas(nRx_idx); % 当前使用的接收天线数量
        
        ber = zeros(size(SNR_dB)); % 初始化 BER 存储数组
        
        for snr_idx = 1:length(SNR_dB) % 遍历每个 SNR 点
            snr = SNR_dB(snr_idx); % 当前信噪比值（dB）
            noise_var = 10^(-snr/10); % 将 SNR 转换为噪声方差
            
            % 多天线瑞利衰落信道 + 加性高斯白噪声 AWGN
            h = (randn(N, nRx) + 1j*randn(N, nRx)) / sqrt(2); % 信道系数（均值0，方差0.5）
            noise = sqrt(noise_var/2)*(randn(N, nRx) + 1j*randn(N, nRx)); % 噪声
            rx = h .* repmat(tx_sym, 1, nRx) + noise; % 接收到的信号矩阵（N x L）

            % 根据当前合并方式对接收信号进行合并处理
            switch method
                case 'SC' % Selection Combining - 选择合并
                    [~, idx_max] = max(abs(h), [], 2); % 对每个时刻选择信道幅值最大的天线
                    idx_linear = sub2ind(size(rx), (1:N)', idx_max); % 转换为线性索引
                    rx_comb = rx(idx_linear) ./ h(idx_linear); % 提取最强路径信号并均衡
                    
                case 'MRC' % Maximal Ratio Combining - 最大比合并
                    rx_comb = sum(conj(h) .* rx, 2); % 所有支路共轭加权后相加
                    h_pow = sum(abs(h).^2, 2); % 每个时刻的信道能量平方和
                    rx_comb = rx_comb ./ h_pow; % 归一化得到合并后的信号
                    
                case 'EGC' % Equal Gain Combining - 等增益合并
                    rx_ph = h ./ abs(h); % 提取各支路的相位信息
                    rx_comb = sum(conj(rx_ph) .* rx, 2); % 相干叠加
                    rx_comb = rx_comb ./ nRx; % 平均功率归一化
            end

            % 解调接收到的合并信号
            try
                rx_bits = qamdemod(rx_comb, M, 'OutputType', 'bit', 'UnitAveragePower', true);
            catch
                % 如果解调失败（如信号太弱），则用随机比特代替以避免程序中断
                rx_bits = randi([0 1], size(data));
            end
            
            % 计算误码率 BER
            ber(snr_idx) = sum(rx_bits ~= data) / length(data); % 错误比特数 / 总比特数
        end
        
        % 存储当前合并方式和天线数的 BER 结果
        switch method
            case 'SC'
                ber_SC(:, nRx_idx) = ber;
            case 'MRC'
                ber_MRC(:, nRx_idx) = ber;
            case 'EGC'
                ber_EGC(:, nRx_idx) = ber;
        end
    end
end

%================= STEP 4: 绘图 - 按 L 值分开 ===================
L_vals = Nr_antennas; % 接收天线数量列表
method_names = {'SC','EGC','MRC'}; % 合并方式名称
colors = {'b','r','g'}; % 图形颜色
markers = {'o','s','d'}; % 图形标记样式

for idx = 1:length(L_vals)
    L = L_vals(idx); % 当前天线数
    
    % 创建新图形窗口，标题中显示当前天线数
    figure('Name', ['16QAM 合并方式对比 - L = ' num2str(L)], 'Color','w');
    
    % 绘制不同合并方式的 BER 曲线（对数坐标）
    semilogy(SNR_dB, ber_SC(:, L),  ['-' markers{1}], 'Color', colors{1}, 'LineWidth', 1.8); hold on;
    semilogy(SNR_dB, ber_EGC(:, L), ['-' markers{2}], 'Color', colors{2}, 'LineWidth', 1.8);
    semilogy(SNR_dB, ber_MRC(:, L), ['-' markers{3}], 'Color', colors{3}, 'LineWidth', 1.8);
    grid on;

    % 添加标题和坐标轴标签
    title(['16QAM 合并方式对比（L = ' num2str(L) '）'], 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('SNR (dB)', 'FontSize', 12);
    ylabel('误码率（BER）', 'FontSize', 12);
    legend('SC','EGC','MRC','Location','southwest'); % 添加图例
    xlim([min(SNR_dB) max(SNR_dB)]); % 设置横轴范围
    ylim([1e-4 1]); % 设置纵轴范围（BER）
    
    % 保存图片为 PNG 文件
    saveas(gcf, ['16QAM_L' num2str(L) '_Compare.png']);
end

%================= STEP 5: 数学统计分析 ===================
mean_BER = zeros(3, length(L_vals));  % [SC; EGC; MRC]
rel_gain_MRC_SC = zeros(1, length(L_vals));
rel_gain_MRC_EGC = zeros(1, length(L_vals));
rel_gain_EGC_SC = zeros(1, length(L_vals));

for idx = 1:length(L_vals)
    l = L_vals(idx); % 当前天线数
    
    % 计算各种合并方式的平均 BER
    mean_BER(1, idx) = mean(ber_SC(:, l));     % SC 平均 BER
    mean_BER(2, idx) = mean(ber_EGC(:, l));     % EGC 平均 BER
    mean_BER(3, idx) = mean(ber_MRC(:, l));     % MRC 平均 BER

    % 计算相对提升比例（百分比）
    rel_gain_MRC_SC(idx) = mean((ber_SC(:, l) - ber_MRC(:, l)) ./ ber_SC(:, l)); % MRC vs SC
    rel_gain_MRC_EGC(idx) = mean((ber_EGC(:, l) - ber_MRC(:, l)) ./ ber_EGC(:, l)); % MRC vs EGC
    rel_gain_EGC_SC(idx)  = mean((ber_SC(:, l) - ber_EGC(:, l)) ./ ber_SC(:, l));  % EGC vs SC
end

%================= STEP 6: 打印结果 ===================
fprintf('\n===== [16QAM] 平均 BER（列为 L=1~5）=====\n');
disp(array2table(mean_BER, ...
    'VariableNames', {'L1','L2','L3','L4','L5'}, ...
    'RowNames', {'SC','EGC','MRC'}));

fprintf('\n[16QAM] MRC 相对 SC 的平均提升比例：\n'); disp(rel_gain_MRC_SC);
fprintf('[16QAM] MRC 相对 EGC 的平均提升比例：\n'); disp(rel_gain_MRC_EGC);
fprintf('[16QAM] EGC 相对 SC 的平均提升比例：\n');  disp(rel_gain_EGC_SC);

%================= STEP 7: 可选导出为 Excel 表格 ===================
T = array2table([mean_BER; rel_gain_MRC_SC; rel_gain_MRC_EGC; rel_gain_EGC_SC], ...
    'RowNames', {'SC_BER','EGC_BER','MRC_BER','MRC_SC_提升','MRC_EGC_提升','EGC_SC_提升'}, ...
    'VariableNames', {'L1','L2','L3','L4','L5'});

writetable(T, '16QAM_合并方式性能统计.xlsx', 'WriteRowNames', true);