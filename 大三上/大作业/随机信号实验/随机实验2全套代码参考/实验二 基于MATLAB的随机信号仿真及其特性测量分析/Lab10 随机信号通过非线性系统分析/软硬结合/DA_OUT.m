%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FileName      : DA_OUT.m
%  Description   : DA������������ܣ����ڽ�PC�������������DA����ʾ�����۲졣
%  Function List :
%                   [] = DA_OUT(CH1_data,CH2_data,divFreq,dataNum)
%  Parameter List:       
%	Output Parameter

%	Input Parameter
%       CH1_data	        ��Դ����
%       CH1_data	        �ز�Ƶ��
%       divFreq      ��Ƶֵ
%       dataNum      ���ݳ���
%  History
%    1. Date        : 2018-09-18
%       Author      : tony.liu
%       Version     :1.1 
%       Modification: ����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = DA_OUT(CH1_data,CH2_data,divFreq,dataNum)
%% dataNum���ݳ��ȣ�����Ӳ��ROM��С���ƣ����Ҫ��dataNum��Χ100~30720
ROM_MAX_LEN=30720;
ROM_MIN_LEN=100;
if dataNum>ROM_MAX_LEN
    disp('���ݳ��ȣ������������Ʒ�Χ100��30720');
    dataNum=ROM_MAX_LEN;
end
if  dataNum<ROM_MIN_LEN
    disp('���ݳ��ȣ�����С�����Ʒ�Χ100��30720');
    dataNum=ROM_MIN_LEN;
end

%% dataNum���ݳ��ȣ�����Ӳ��ROM��С���ƣ����Ҫ��dataNumС�ڵ���30720
if (divFreq>1024)&(divFreq<0)
    disp('fs�����ʲ������ó�������Χ');
    divFreq=0;
end

%% ����ʹCH1_data��CH2_data ���ݳ��Ⱥ�dataNumֵһ�£�
%% ���������ǰCH1_data��CH2_data ���ݳ��ȡ�С�ڡ�dataNumֵ����0����������۲�������ʼͷ��
%% ���������ǰCH1_data��CH2_data ���ݳ��ȡ����ڡ�dataNumֵ����������ʾ������
%% ���������ǰCH1_data��CH2_data ���ݳ��ȡ����ڡ�dataNumֵ�����ȡ��Ч����dataNum��
temp_data=zeros(1,30720);
CH1_data_temp= [CH1_data ,temp_data];
CH2_data_temp= [CH2_data ,temp_data];
CH1_out_data=CH1_data_temp(1,1:dataNum);
CH2_out_data=CH2_data_temp(1,1:dataNum);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_Set_router = uint8(hex2dec({'00','00','99','bb', '68','00','00','06',  '00','00','00','00',  '00','00','00','00',  '00','00','00','00'})); %06 DA ���ڷ����ź�

%%%%%%%%%%%%%%%%%%%%%
%%���������������
divFreqL=mod(divFreq,256);
divFreqH=(divFreq-divFreqL)/256;
divFreqL=dec2hex(divFreqL);
divFreqH=dec2hex(divFreqH);

dataNumL=mod(dataNum,256);
dataNumH=(dataNum-dataNumL)/256;
dataNumL=dec2hex(dataNumL);
dataNumH=dec2hex(dataNumH);

test_tx_command = uint8(hex2dec({'00','00','99','bb', '65','0A','03','ff',  divFreqH,divFreqL,dataNumH,dataNumL,  '00','00','00','00',  '00','00','00','00'})); %�������


test_Send_IQ = uint8(hex2dec({'00','00','99','bb', '64','00','00','00',  '00','00','00','00',  '00','00','00','00',  '00','00','00','00'}));    %������������




SAMPLE_LENGTH = dataNum;                  
SEND_PACKET_LENGTH = 180;          

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%��������UDP���󣬲���
udp_obj = udp('192.168.1.166',13345,'LocalHost','192.168.1.180','LocalPort',12345,'TimeOut',100,'OutputBufferSize',61440,'InputBufferSize',61440*10);
fopen(udp_obj);

dataIQ = zeros(1,SAMPLE_LENGTH*2);
dataIQ(1,1:2:end) = CH1_out_data(1,:);
dataIQ(1,2:2:end) = CH2_out_data(1,:);
dataIQ = dataIQ.*(2047/max(dataIQ));    %�Ŵ��ֵ��2000,�ӽ����۷�ֵ2047
dataIQ = fix(dataIQ);                   %������ǿ��ȡ��

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��ֹ��������Ը������в������.���з���12λ���ݣ�ת��Ϊ�޷���12λ����
%eg -2048~2047,ת��Ϊ0~4095
%   0~2047  ����
%   -2048~-1 ��ӦתΪ 2048~4095
for n = 1 : SAMPLE_LENGTH*2
    if dataIQ(n) > 2047
        dataIQ(n) = 2047;
    elseif  dataIQ(n) < 0
        dataIQ(n) = 4096 + dataIQ(n);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%���ӿڶ������б�����
%I·��b11~b0 ��4bits
dataIQ(1,1:2:SAMPLE_LENGTH*2-1) = dataIQ(1,1:2:SAMPLE_LENGTH*2).*16;
%Q·��b7~b0 ��4bits b11~b8
dataIQ(1,2:2:SAMPLE_LENGTH*2) = fix(dataIQ(1,2:2:SAMPLE_LENGTH*2)./256) + rem(dataIQ(1,2:2:SAMPLE_LENGTH*2),256).*256;
dataIQ = uint16(dataIQ);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�����������
fwrite(udp_obj, test_Set_router,  'uint8');
fwrite(udp_obj, test_tx_command, 'uint8');
fwrite(udp_obj, test_Send_IQ, 'uint8');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��������

if SAMPLE_LENGTH*2<SEND_PACKET_LENGTH
    fwrite(udp_obj, dataIQ(1,1:(SAMPLE_LENGTH*2)), 'uint16');
else
    for pn = 1:fix(SAMPLE_LENGTH*2/SEND_PACKET_LENGTH)
        fwrite(udp_obj, dataIQ(1,((pn-1)*SEND_PACKET_LENGTH+1) : (pn*SEND_PACKET_LENGTH)), 'uint16');
    end
    fwrite(udp_obj, dataIQ(1,(pn*SEND_PACKET_LENGTH+1 ): (SAMPLE_LENGTH*2)),'uint16');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�ر�UDP����
echoudp('off')
fclose(udp_obj);
delete(udp_obj); 
clear udp_obj;

end