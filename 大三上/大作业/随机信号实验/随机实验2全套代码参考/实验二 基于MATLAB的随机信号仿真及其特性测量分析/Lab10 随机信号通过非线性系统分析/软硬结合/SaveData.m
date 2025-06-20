function status=SaveData(path,y,is_gain)
%path �洢�����ļ�·��
%y Ҫ�洢������
%is_gain �Ƿ�����ݽ��зŴ� 0�������ݷŴ����ֵΪ511,  1�����Ŵ� 
%status Ϊ0��д�����ݳ���


A=511;
width=10;           %����λ��
depth=30720;        %�����ݳ���

fid=fopen(path,'w+');
status=fprintf(fid,'WIDTH=%d;\r\n',width);
status=fprintf(fid,'DEPTH=%d;\r\n',depth)*status;
status=fprintf(fid,'\r\n')*status;
status=fprintf(fid,'ADDRESS_RADIX=UNS;\r\n')*status;
status=fprintf(fid,'DATA_RADIX=DEC;\r\n')*status;
status=fprintf(fid,'\r\n')*status;
status=fprintf(fid,'CONTENT BEGIN\r\n')*status;

if status==0                            %�ж�д�������Ƿ�ɹ�
    fclose(fid);
    return;
end

if is_gain==0                           %�����ֵ�Ŵ�511
    val=max(y);
    y=y*(A/val);
end

y=floor(y);
data_temp=zeros(1,30720);
y=[y,data_temp];
y=y(1,1:depth);                         %���������ݳ���С��30720�����0ֱ������Ϊ30720
                                        %���������ݴ���30720�򽫶�������ݶ���

for i=1:depth
    status=fprintf(fid,'\t%d  :   %d;\r\n',i-1,y(i));
    if status==0
        fclose(fid);
        return;
    end
end

status=fprintf(fid,'END;');
fclose(fid);
end

