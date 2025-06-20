function status=SaveData(path,y,is_gain)
%path 存储数据文件路径
%y 要存储的数据
%is_gain 是否对数据进行放大 0，将数据放大到最大值为511,  1，不放大 
%status 为0则写入数据出错


A=511;
width=10;           %数据位宽
depth=30720;        %总数据长度

fid=fopen(path,'w+');
status=fprintf(fid,'WIDTH=%d;\r\n',width);
status=fprintf(fid,'DEPTH=%d;\r\n',depth)*status;
status=fprintf(fid,'\r\n')*status;
status=fprintf(fid,'ADDRESS_RADIX=UNS;\r\n')*status;
status=fprintf(fid,'DATA_RADIX=DEC;\r\n')*status;
status=fprintf(fid,'\r\n')*status;
status=fprintf(fid,'CONTENT BEGIN\r\n')*status;

if status==0                            %判断写入数据是否成功
    fclose(fid);
    return;
end

if is_gain==0                           %将最大值放大到511
    val=max(y);
    y=y*(A/val);
end

y=floor(y);
data_temp=zeros(1,30720);
y=[y,data_temp];
y=y(1,1:depth);                         %若输入数据长度小于30720则填充0直到数据为30720
                                        %若输入数据大于30720则将多出的数据丢弃

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

