%改进的梯度下降法，用于水文模型参数寻优
clear;clc;
%首先录入洪水数据，放入一个元胞数组data中，每个元胞代表一场洪水（由n列降水数据和1列流量数据组成）。以下录入了研究所使用的所有20场洪水，每场洪水前五列为五个雨量站数据，第六列为实测流量数据，时段长为1小时。
load('data.mat');
%tic在程序运行后开始计时，以便在更新最优解时记录当前时刻，以达到可视化的目的
tic
%doc的第一行记录每次更新的时刻，第二行记录当前最优解对应的NSE
doc=[];
%state为0时，将会从参数默认值开始从头寻优；state为1时，将会继续上次寻优
state=0;
%如果要从头寻优
if state==0
    %算法参数设置如下
    maxdiedai=200;%最大迭代次数，数值越大运行时间越长，但也可能得到更好的结果
    mtp=30;%最大步长数。对一个参数进行扰动的最大值就是mtp*该参数的步长设置值
    lvding=1:15;%率定选用洪水场次，可以选择单场，也可以选择多场，比如选择1~15场检验，第16~20场不参与率定因为它要留作检验
    delta1=0.00001;%梯度法搜索MODE1和MODE2中允许的最小梯度，如果梯度小于delta1就需要进入MODE3或者结束搜索
    delta2=0.1;%梯度法搜索当前NSE与已找到最佳NSE之间的相对误差限，在MODE1或MODE2结束时：如果相对误差低于delta3，就会开始MODE3搜索；如果相对误差高于delta3，就会结束并开始下一轮搜索。
    delta3=0.000000001;%梯度法搜索MODE3中允许的最小梯度，如果梯度小于delta3就会结束并开始下一轮搜索
    cnm=3;%当开始新一轮的搜索时，初始参数需要在当前最优参数的基础上扰动形成。这次扰动最多改变cnm个参数。cnm越大收敛越慢，但是也越容易跳出局部最优解。cnm应该小于参数数量。
    modegate=100;%梯度下降法搜索模式MODE1与MODE2之间的切换频率，每隔modegate次搜索切换一次模式
    %洪水前流域状态值设置如下，简单起见认为每场洪水前的状态是相同的
    F=57.3;%流域面积
    dt=1;%洪水数据的时段长
    location=[5.5 2.4;4.5 4.4;2.6 0.7;2.9 -1.7;0 0];%n行2列，每一行存储了一个雨量站距离流域出口的东西间距和南北间距，单位可以无量纲
    LB=10.1;%流域长度，单位可以无量纲，但要与location中的单位一致
    WU=40;%流域初始上层土壤含水量
    WL=60;%流域初始下层土壤含水量
    WD=36;%流域初始深层土壤含水量
    %设置参数矩阵，每一行代表一个参数，前两列代表参数的下界和上界，第三列代表参数的步长，第四列代表参数的初始值
    canshu(1,1:4)=[-1 10 0.01 0.1];%EP
    canshu(2,1:4)=[0.1 4 0.01 0.32];%B
    canshu(3,1:4)=[1 50 1 24];%WUM
    canshu(4,1:4)=[1 90 1 60];%WLM
    canshu(5,1:4)=[120 200 1 120];%WM
    canshu(6,1:4)=[0.01 40 0.01 9.62];%a0
    canshu(7,1:4)=[-10 3 0.01 -2.0795];%b0
    canshu(8,1:4)=[0 20 0.01 1.93];%h0
    canshu(9,1:4)=[-10 10 0.01 -1.15];%d0
    canshu(10,1:4)=[0.01 1 0.01 0.43];%w0
    canshu(11,1:4)=[-10 10 0.01 0.52];%a1
    canshu(12,1:4)=[-10 10 0.01 -2.55];%b1
    canshu(13,1:4)=[-10 10 0.01 2.26];%h1
    canshu(14,1:4)=[-10 10 0.01 -0.73];%d1
    canshu(15,1:4)=[-10 10 0.01 0.5];%w1
    canshu(16,1:4)=[0.01 100 0.01 0.01];%a2
    canshu(17,1:4)=[0.01 100 0.01 10.85];%b2
    canshu(18,1:4)=[0.01 100 0.01 0.78];%h2
    canshu(19,1:4)=[0.01 100 0.01 0.02];%d2
    canshu(20,1:4)=[0.01 100 0.01 0.49];%w2
    canshu(21,1:4)=[-10 10 0.01 0];%a3
    canshu(22,1:4)=[-10 10 0.01 0];%b3
    canshu(23,1:4)=[-10 10 0.01 0];%h3
    canshu(24,1:4)=[-10 10 0.01 0];%d3
    canshu(25,1:4)=[-10 10 0.01 0];%w3
    canshu(26,1:4)=[-100 100 0.01 1];%a4
    canshu(27,1:4)=[-100 100 0.01 1];%b4
    canshu(28,1:4)=[-100 100 0.01 1];%h4
    canshu(29,1:4)=[-100 100 0.01 1];%d4
    canshu(30,1:4)=[-100 100 0.01 1];%w4
    canshu(31,1:4)=[0.01 0.5 0.01 0.16];%cc
    canshu(32,1:4)=[0.0001 0.5 0.0001 0.001];%IM
    %在率定前，把最优参数设置为参数默认值
    canshumax=canshu;
    %设置一个数组temp，1行2列，第二列记录本次梯度下降迭代后的NSE，第一列记录迭代前的NSE。比较二者可以衡量优化的剩余空间
    temp=zeros(1,2);
%如果要继续上次寻优
elseif state==1
    %直接把上次找到的最优参数canshumax赋给这次的参数初值
    canshu=canshumax;
    %算法参数设置如下
    maxdiedai=200;
    mtp=30;
    lvding=1:3;
end
%给temp数组赋初值，可以填入两个很差的NSE;
temp(1)=-inf;
temp(2)=-1;
%认为初始指定的最优参数效果也很差
tempmax=-inf;
%算法设置了三种MODE：当MODE=1时，梯度下降的步长为一个很大的随机数，这让MODE1具有跳出局部最优的能力；当MODE=2时，梯度下降的步长为一个由mtp递减到的0的值，这让MODE2具有好的收敛能力；当MODE=3时，这意味着当前的参数效果已经非常接近已经找到的最优参数的效果了，因此在梯度很小时仍然允许继续迭代。
MODE=0;
%记录发出警告的次数。由于算法可能存在缺陷，优化结果可能为inf、complex或者nan，这就需要放弃当前优化而开启新的优化
warn=0;
%开始梯度下降的迭代。迭代次数从3开始是因为已经指定了两个temp的值
for i=3:maxdiedai
    %首先判断上次梯度下降迭代后得到的NSE是否为实数
    if imag(temp(2))~=0 || isnan(temp(2)) || abs(temp(2))==inf
        %如果不是实数，警告次数+1
        warn=warn+1;
        %放弃当前搜索，从已经找到的最优参数开始新的搜索
        canshu=canshumax;
    end
    %其次判断上次梯度下降迭代前后的NSE差别，如果小于delta1的话，说明梯度已经较小了
    if abs(temp(2)-temp(1))<delta1
        %现在比较上次梯度下降迭代后的NSE与已经找到的最优NSE之间的差距
        if (tempmax-temp(2))/tempmax<delta2
            %如果差距小于delta2，说明当前结果有希望超越已经找到的最优NSE，所以进入MODE3
            MODE=3;
            %如果上次梯度下降迭代前后的NSE差别过于小（<delta3），那么结束MODE3
            if abs(temp(2)-temp(1))<delta3
                %结束前判断当前NSE是否超过已经找到的最优NSE
                if temp(2)>tempmax
                    %如果超过的话，则更新最优参数为当前参数
                    canshumax=canshu;
                    %同时更新最优NSE为当前NSE
                    tempmax=temp(2);
                %如果当前NSE没有超过已经找到的最优NSE
                else
                    %那么重置当前参数为已经找到的最优参数
                    canshu=canshumax;
                end
                %开始新一轮搜索，搜索的初值在当前最优参数的基础上作随机扰动产生
                %随机选择cn个参数准备进行扰动。cn为介于1和cnm之间的整数。
                cn=randi(cnm);
                %如果参数有m个，那么list存储了1~m这些数字
                list=[1:size(canshu,1)];
                %将这些数字乱序
                list=list(randperm(length(list)));
                %并取出前cn个。被取出的数字装入change数组中，即为需要扰动的参数的序号
                change=list(1:cn);
                %现在对需要扰动的cn个参数进行扰动
                for j=1:cn
                    %扰动的原理就是以均匀分布在该参数上下界之间随机采样一次
                    canshu(change(j),4)=rand*(canshu(change(j),2)-canshu(change(j),1))+canshu(change(j),1);
                end
                %由于MODE3已经结束，现在将MODE置于空挡
                MODE=0;
            end
        %如果差距大于delta2，说明当前结果可能无望超过已经找到的最优NSE，放弃当前结果
        else
            %结束前判断当前NSE是否超过已经找到的最优NSE
            if temp(2)>tempmax
                %如果超过的话，则更新最优参数为当前参数
                canshumax=canshu;
                %同时更新最优NSE为当前NSE
                tempmax=temp(2);
            %如果当前NSE没有超过已经找到的最优NSE
            else
                %那么重置当前参数为已经找到的最优NSE
                canshu=canshumax;
            end
            %开始新一轮搜索，搜索的初值在当前最优参数的基础上作随机扰动产生
            %随机选择cn个参数准备进行扰动。cn为介于1和cnm之间的整数。
            cn=randi(cnm);
            %如果参数有m个，那么list存储了1~m这些数字
            list=[1:size(canshu,1)];
            %将这些数字乱序
            list=list(randperm(length(list)));
            %并取出前cn个。被取出的数字装入change数组中，即为需要扰动的参数的序号
            change=list(1:cn);
            %现在对需要扰动的cn个参数进行扰动
            for j=1:cn
                %扰动的原理就是以均匀分布在该参数上下界之间随机采样一次
                canshu(change(j),4)=rand*(canshu(change(j),2)-canshu(change(j),1))+canshu(change(j),1);
            end
            %由于MODE1或MODE2已经结束，现在将MODE置于空挡
            MODE=0;
        end
    end
    %然后确认当前搜索模式是MODE1还是MODE2（MODE3也会叠加MODE1或MODE2）
    %MODE1与MODE2的划分方式为：前modegate次搜索为MODE1，随后每隔modegate次搜索，就在两种搜索模式之间切换一次
    %如果满足下式，则当前为MODE1
    if mod(floor(i/modegate),2)==0
        %在MODE1中，搜索的步长系数k为mtp乘以一个0到1的随机数
        k=rand*mtp;
        %如果现当前处于MODE3
        if MODE==3 || MODE==31 || MODE==32
            %那么当前模式叠加为MODE31
            MODE=31;
        %如果当前不处于MODE3
        else
            %那么当前模式为MODE1
            MODE=1;
        end
    %如果当前不为MODE1，则为MODE2
    else
        %MODE2将会持续modegate次搜索，在此期间，搜索的步长系数k将会从mtp线性减少到0
        k=mtp*(modegate-i+modegate*floor(i/modegate))/modegate;
        %如果现当前处于MODE3
        if MODE==3 || MODE==31 || MODE==32
            %那么当前模式叠加为MODE32
            MODE=32;
        %如果当前不处于MODE3
        else
            %那么当前模式为MODE2
            MODE=2;
        end
    end
    %以下开始本次迭代的梯度下降工作
    %遍历所有需要率定的参数，对于第n个参数来说
    for n=1:30%由于最后2个参数不需要率定，因此无需设置为for n=1:size(canshu,1)
        a1=[];%a1将记录：第n个参数保持原状时，所有参与率定的洪水的NSE组成的向量
        a2=[];%a2将记录：第n个参数调大一个k*步长后，所有参与率定的洪水的NSE组成的向量
        a0=[];%a0将记录：第n个参数调小一个k*步长后，所有参与率定的洪水的NSE组成的向量
        %首先把本次迭代的初始参数表拷贝至para1
        para1=canshu;
        %遍历参与率定的洪水场次，对于第j场洪水来说
        for j=lvding
            %输入降雨径流数据、参数和状态来运行水文模型，得到第j场洪水的NSE
            nash=f(canshu,data{j},F,dt,WU,WL,WD,location,LB);
            %把第j场洪水的NSE加入到a1向量中
            a1=[a1 nash];
        end
        %把a1中几场洪水的NSE求平均并记作c1，c1即可衡量当前参数para1的合理程度
        c1=mean(a1);
        %将第n个参数调大一个k*步长
        canshu(n,4)=canshu(n,4)+k*canshu(n,3);
        %判断调大后是否超过参数上界
        if canshu(n,4)>canshu(n,2)
            %如果超过的话，则令它等于上界
            canshu(n,4)=canshu(n,2);
        end
        %调大第n个参数后，将当前参数表拷贝至para2
        para2=canshu;
        %遍历参与率定的洪水场次，对于第j场洪水来说
        for j=lvding
            %输入降雨径流数据、参数和状态来运行水文模型，得到第j场洪水的NSE
            nash=f(canshu,data{j},F,dt,WU,WL,WD,location,LB);
            %把第j场洪水的NSE加入到a2向量中
            a2=[a2 nash];
        end
        %把a2中几场洪水的NSE求平均并记作c2，c2即可衡量当前参数para2的合理程度
        c2=mean(a2);
        %将调大的参数暂时复原
        canshu=para1;
        %将第n个参数调小一个k*步长
        canshu(n,4)=canshu(n,4)-k*canshu(n,3);
        %判断调小后是否低于参数下界
        if canshu(n,4)<canshu(n,1)
            %如果低于的话，则令它等于下界
            canshu(n,4)=canshu(n,1);
        end
        %调小第n个参数后，将当前参数表拷贝至para0
        para0=canshu;
        %遍历参与率定的洪水场次，对于第j场洪水来说
        for j=lvding
            %输入降雨径流数据、参数和状态来运行水文模型，得到第j场洪水的NSE
            nash=f(canshu,data{j},F,dt,WU,WL,WD,location,LB);
            %把第j场洪水的NSE加入到a0向量中
            a0=[a0 nash];
        end
        %把a0中几场洪水的NSE求平均并记作c0，c0即可衡量当前参数para0的合理程度
        c0=mean(a0);
        %通过比较c0、c1、c2的大小，即可知道参数组合para0、para1、para2的合理程度
        maxx=max([c0 c1 c2]);
        %如果c1最大
        if c1==maxx
            %那么para1最合理，本次迭代后的参数保存为para1
            canshu=para1;
        %如果c2最大
        elseif c2==maxx
            %那么para2最合理，本次迭代后的参数保存为para2
            canshu=para2;
        %如果c0最大
        else
            %那么para0最合理，本次迭代后的参数保存为para0
            canshu=para0;
        end
    end
    %为了不增加额外的储存内存，将上次迭代的结果覆盖掉上上次迭代的结果，放入temp(1)
    temp(1)=temp(2);
    %而将本次迭代的结果作为下次迭代的初解而放入temp(2)
    temp(2)=max([c0 c1 c2]);
    %打印'当前模式，当前参数NSE，已找到的最优参数NSE，警告次数'。取消打印可以提高运算速度。
    disp([MODE temp(2) tempmax warn])
    %至此完成了一次迭代，记录当前时刻
    time=toc;
    %把当前时刻和当前已找到的最优参数NSE记入doc中，以便稍后的可视化
    doc=[doc [time;max(temp(2),tempmax)]];
end
%绘制最优NSE随时间的变化过程线
plot(doc(1,:),doc(2,:))
xlabel('time(second)')
ylabel('average NSE of floods')
%继续运行test脚本以进行可视化
