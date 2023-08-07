%水文模型函数：产流与新安江模型相同，不分水源，汇流采用非线性单位线
function [nash,Qsim]=f(canshu,dat,F,dt,WU,WL,WD,location,LB)
%首先从参数列表中把每个参数取出
EP=canshu(1,4);
B=canshu(2,4);
WUM=canshu(3,4);
WLM=canshu(4,4);
WM=canshu(5,4);
a0=canshu(6,4);
b0=canshu(7,4);
h0=canshu(8,4);
d0=canshu(9,4);
w0=canshu(10,4);
a1=canshu(11,4);
b1=canshu(12,4);
h1=canshu(13,4);
d1=canshu(14,4);
w1=canshu(15,4);
a2=canshu(16,4);
b2=canshu(17,4);
h2=canshu(18,4);
d2=canshu(19,4);
w2=canshu(20,4);
a3=canshu(21,4);
b3=canshu(22,4);
h3=canshu(23,4);
d3=canshu(24,4);
w3=canshu(25,4);
a4=canshu(26,4);
b4=canshu(27,4);
h4=canshu(28,4);
d4=canshu(29,4);
w4=canshu(30,4);
cc=canshu(31,4);
IM=canshu(32,4);
%记M为一场暴雨洪水所经历的时段数
M=size(dat,1);
%建立一个M行2列的记录表，模型的计算过程将记录于此。2列分别代表产流系列和模拟的流量结果系列。
doc=zeros(M,2);
%逐时段处理降雨数据，对于第t时段
for t=1:M
    %提取第t时段的面平均雨量
    P=mean(dat(t,1:end-1));
    %计算当前时段的各层土壤的蒸散发
    if WU+P>=EP
        EU=EP;EL=0;ED=0;
    elseif WU+P<EP && WL>=cc*WLM
        EU=WU+P;EL=(EP-EU)*WL/WLM;ED=0;
    elseif WU+P<EP && cc*(EP-EU)<=WL && WL<cc*WLM
        EU=WU+P;EL=cc*(EP-EU);ED=0;
    else
        EU=WU+P;EL=WL;ED=cc*(EP-EU)-EL;
    end
    %降雨扣除蒸散发得到净雨
    PE=max(P-EU-EL-ED,0);
    %新安江模型蓄满产流计算
    WMM=WM*(B+1)/(1-IM);
    W0=WU+WL+WD;
    A=WMM*(1-(1-W0/WM)^(1/(1+B)));
    if PE+A<WMM
        R=PE-WM*((1-A/WMM)^(1+B)-(1-(PE+A)/WMM)^(1+B));
    else
        R=PE-(WM-W0);
    end
    %把时段产流量存入记录表第一列
    doc(t,1)=R;
    %更新土壤含水量
    WU=WU+P-EU-R;
    WL=WL-EL;
    WD=WD-ED;
    if WD<0
        WD=0;
    end
    if WU>WUM
        WU=WUM;
        WL=WL+WU-WUM;
    end
    if WL>WLM
        WL=WLM;
        WD=WD+WL-WLM;
    end
    if WD>WM-WUM-WLM
        WD=WM-WUM-WLM;
    end
end
%beta用于储存每个时段暴雨中心的相对位置，初始全部设为0
beta=zeros(M,1);
%逐时段计算暴雨中心的相对位置，对于第t个时段
for t=1:M
    %先申请一个1行2列的数组
    temp=[0 0];
    %遍历(size(dat,2)-1)个雨量站
    for j=1:(size(dat,2)-1)
        %把每个雨量站的位置与时段降雨量的乘积累加进数组中
        temp=temp+dat(t,j)*location(j,:);
    end
    %累加完后再除以所有雨量站时段降雨量之和。就相当于按照降雨量对雨量站的位置做了加权平均，即时段暴雨中心的位置
    temp=temp./sum(dat(t,1:(end-1)));
    %计算这个位置到流域出口的距离，再除以流域长度，就得到了时段暴雨中心的相对位置
    beta(t,1)=(temp(1)^2+temp(2)^2)^0.5/LB;
end
%在没有降雨的时段，暴雨中心的位置会被计算为nan。这个数不会对模拟结果有任何影响，但为了不影响计算过程，将其用0.5替换。
beta(isnan(beta))=0.5;
%当只有流域出口处在下雨时，暴雨中心的相对位置就会是0，而0对幂运算具有局限性，所以对所有的beta统一增加0.01，以避免0的出现。
beta=beta+0.01;
%汇流计算，采用非线性单位线
%对于第t时段
for t=1:M
    %令θ代表a、b、h、d、w五个单位线形状因子。
    %a0、b0、h0、d0、w0这五个参数是单位线形状因子的初始值，统称为θ0。
    %a3、b3、h3、d3、w3、a4、b4、h4、d4、w4这十个参数描绘了θ0随beta(t)的变化特性，统称为θ3、θ4.
    %a1、b1、h1、d1、w1、a2、b2、h2、d2、w2这十个参数描绘了θ0随alpha的变化特性，统称为θ1、θ2.
    %先根据时段暴雨中心的相对位置beta(t)来修正参数θ0得到θθ
    aa=a0*(1+a3*beta(t)^a4);
    bb=b0*(1+b3*beta(t)^b4);
    hh=h0*(1+h3*beta(t)^h4);
    dd=d0*(1+d3*beta(t)^d4)+t-1;
    ww=w0*(1+w3*beta(t)^w4);
    %根据θθ可以生成一条单位线，乘以当前时段产流量doc(t,1)可以得到当前时段产流对应的流量子过程，记作new
    new=doc(t,1)*gen(aa,bb,hh,dd,ww,M);
    %先前所有流量子过程的非线性叠加结果记作old
    old=doc(:,2);
    %可以计算Q-t图中二者的重叠面积占new的比例，作为new受到old影响的大小，记作alpha
    alpha=sum(min(new,old))/(sum(new)+0.001);
    %有了alpha之后，在θθ的基础上用alpha进一步作出修正，得到θθθ
    aaa=aa*(1+a1*alpha^a2);
    bbb=bb*(1+b1*alpha^b2);
    hhh=hh*(1+h1*alpha^h2);
    ddd=dd*(1+d1*alpha^d2)+t-1;
    www=ww*(1+w1*alpha^w2);
    %根据θθθ可以生成一条单位线，乘以当前时段产流量doc(t,1)可以得到修正后的当前时段产流对应的流量子过程，记作fin
    fin=doc(t,1)*gen(aaa,bbb,hhh,ddd,www,M);
    %fin即可与当前时段的old进行叠加，得到下一时段的old
    doc(:,2)=doc(:,2)+fin;
end
%把每个时段的流量子过程都进行非线性叠加之后，即可得到模拟的洪水过程Qsim
Qsim=doc(:,2);
%实测洪水过程Qobs可以从dat矩阵中拿到
Qobs=dat(:,end);
%计算确定性系数，衡量模拟效果
nash=1-(sum((Qsim-Qobs).^2)/sum((Qobs-mean(Qobs)).^2));
end