function [ price ]=cost4single(Single,City)
Product=struct(...
'Base',250,...                            % ÿ���̶��ɱ�250Ԫ/��
'km_price',3,...                          % ����ɱ�3Ԫ/km
'Load_Max',9,...                          % �������������9t
'Speed',45,...                            % ����45km/h
'Unit',4000,...                           % ��λ��Ʒ��ֵ4000Ԫ/t
'Cold_Move_Minu',0.05,...                 % ��������е�λʱ������ɱ�0.05Ԫ/����
'Cold_Dicharge_Minu',0.1,...              % ж�������е�λʱ������ɱ�0.1Ԫ/����
'A1',0.002,...
'A2',0.003,...
'Gas4Move',0.225,...                      % ������䳵��λ�����ͺ�22.5L/100km
'Gas4Cold',0.0025,...                     % �����豸��λ��������ĵ�λʱ�����Դ������0.0025L/t*km
'CarbonIndex',1.052,...                   % ̼�ŷ�ϵ��1.052kg/L
'CarbonPrice',0.13326);                   % ̼˰�۸�0.13326Ԫ/kg*CO2

%%
%route=max(find(Single.table_load));%ͨ��route�������Ϊ���һ�����иպ����������bug
route=max(find(Single.table))-1;
C=zeros(1,5);
%% C1
C(1)=Product.Base;
%% C2
d=zeros(1,route);
for i=1:route
    d(i)=City.Distance(Single.table(i),Single.table(i+1));
end
C(2)=sum(d.*Single.table_load(1:route));
%% C3
% ����=����������ʱ��*�õص����������+ж��ʱ��*�뿪�õص����������
% ����������ʱ��=ÿ�ص�ж��ʱ��+·��ʱ�䣬��1��Ϊ0

flag=find(Single.table==1);%Ϊ1�ı�־λ
period=length(flag);%�Ͽ���
D=[];
for i=1:period-1
    temp{i}=cumsum(d(flag(i):(flag(i+1)-1)));
    D=[D temp{i}];%��ԭ����������������
end
T1=D/Product.Speed+Single.sevice_time(1:route)/60;%�����е���ʱ��
for i=1:route
    if Single.table_load(i+1)==9
        nd(i)=Single.table_load(i)-Single.table_load(i+1)+9;
    else nd(i)=Single.table_load(i)-Single.table_load(i+1);
    end
end
c31=sum(nd.*(1-exp(-Product.A1*(T1))));
% ж��ʱ��=������/װ����*����ʱ��
T2=Single.sevice_time(1:route)/60;
c32=sum(Single.table_load(1:route).*(1-exp(-Product.A2*(T2))));
C(3)=Product.Unit*(c31+c32);
%% C4
% ��������
for i=1:route
    if Single.table_load(i+1)==0
        d_cold(i)=0;
    else d_cold(i)=d(i);
    end
end
c41=sum(d_cold/Product.Speed*Product.Cold_Move_Minu);
% ж������
c42=sum(Single.sevice_time(1:route)*Product.Cold_Dicharge_Minu);
C(4)=c41+c42;
%% C5
% ʱ��

c51=sum(d_cold/Product.Speed.*Single.table_load(1:route));
% ����
c52=Product.Gas4Move*sum(d_cold);
C(5)=Product.CarbonIndex*Product.CarbonPrice*(c51+c52);
%% 
price=sum(C);
end

