%Hfunction of rainfall-runoff (RR) model: The runoff generation is the same as the Xin'anjiang model, regardless of water source division, and the runoff concentration adopts nonlinear unit hydrographs
function [nash,Qsim]=f(canshu,dat,F,dt,WU,WL,WD,location,LB)
%First, obtain each parameter from the parameter list
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
%Note that M is the number of periods of a flood
M=size(dat,1);
%Establish a record table 'doc' with M rows and 2 columns, where the calculation process of the RR model will be recorded. Two columns represent the runoff generation series and the simulated streamflow series, respectively.
doc=zeros(M,2);
%Process observed rainfall series period by period. For the t-th period:
for t=1:M
    %Calculate the areal average rainfall during the t-th period
    P=mean(dat(t,1:end-1));
    %Calculate the evapotranspiration of each layer of soil during the t-th period
    if WU+P>=EP
        EU=EP;EL=0;ED=0;
    elseif WU+P<EP && WL>=cc*WLM
        EU=WU+P;EL=(EP-EU)*WL/WLM;ED=0;
    elseif WU+P<EP && cc*(EP-EU)<=WL && WL<cc*WLM
        EU=WU+P;EL=cc*(EP-EU);ED=0;
    else
        EU=WU+P;EL=WL;ED=cc*(EP-EU)-EL;
    end
    %Net rain obtained by deducting evapotranspiration from observed rainfall
    PE=max(P-EU-EL-ED,0);
    %Calculation of 'runoff generation in excess of saturation' like Xin'anjiang Model
    WMM=WM*(B+1)/(1-IM);
    W0=WU+WL+WD;
    A=WMM*(1-(1-W0/WM)^(1/(1+B)));
    if PE+A<WMM
        R=PE-WM*((1-A/WMM)^(1+B)-(1-(PE+A)/WMM)^(1+B));
    else
        R=PE-(WM-W0);
    end
    %Store the runoff generation of the t-th period in the first column of the record table
    doc(t,1)=R;
    %Update the soil moisture
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
%'beta' is used to document the relative positions of rainstorm centers in each period, initially set to 0
beta=zeros(M,1);
%Cauculate relative position of the rainstorm center period by period. For the t-th period:
for t=1:M
    %Apply for an array of 1 row and 2 columns first
    temp=[0 0];
    %Traverse '(size(dat,2)-1)' rainfall stations
    for j=1:(size(dat,2)-1)
        %Accumulate the multiplication of the location of each rainfall station and the precipitation during the period to the array
        temp=temp+dat(t,j)*location(j,:);
    end
    %After accumulation, divide by the sum of rainfall from all rainfall stations in this period. It is equivalent to the weighted average of the position of the rainfall stations according to the rainfall, and this is just the position of the rainstorm center in this period
    temp=temp./sum(dat(t,1:(end-1)));
    %Calculate the distance from this position to the outlet of the
    %watershed, and then divide it by the length of the watershed to get the relative position of the rainstorm center of this period
    beta(t,1)=(temp(1)^2+temp(2)^2)^0.5/LB;
end
%In the period without rainfall, the location of the rainstorm center will be calculated as nan. This number will not have any impact on the simulation results, but in order not to affect the calculation process, it will be replaced with 0.5.
beta(isnan(beta))=0.5;
%When only the outlet of the basin is in rain, the relative position of the rainstorm center will be 0, and 0 has limitations on power operation. Therefore, all beta will be increased by 0.01 to avoid 0.
beta=beta+0.01;
%Calculation of runoff concentration, using nonlinear unit hydrograph
%For the t-th period
for t=1:M
    %Let S represents the five UH shape factors a,b,h,d and w.
    %The five parameters a0,b0,h0,d0, and w0 are the initial values of the UH shape factor, collectively referred to as S0.
    %The ten parameters a3, b3, h3, d3, w3, a4, b4, h4, d4, and w4 describe the variation characteristics of S0 with beta (t), collectively referred to as S3 and S4
    %The ten parameters a1, b1, h1, d1, w1, a2, b2, h2, d2, and w2 describe the variation characteristics of S0 with alpha, collectively referred to as S1 and S2
    %First, modify parameter S0 according to the relative position of the rainstorm center during the t-th period to obtain SS
    aa=a0*(1+a3*beta(t)^a4);
    bb=b0*(1+b3*beta(t)^b4);
    hh=h0*(1+h3*beta(t)^h4);
    dd=d0*(1+d3*beta(t)^d4)+t-1;
    ww=w0*(1+w3*beta(t)^w4);
    %According to SS, a UH can be generated, multiplied by the current period's runoff generation 'doc(t,1)' to obtain the corresponding sub hydrograph for the current period's runoff generation, denoted as 'new'
    new=doc(t,1)*gen(aa,bb,hh,dd,ww,M);
    %The nonlinear superposition results of all previous sub hydrographs are denoted as 'old'
    old=doc(:,2);
    %The ratio of the overlapping area of the two in the Q-t graph to 'new' can be calculated as the size of the impact of 'old' on 'new', denoted as 'alpha'
    alpha=sum(min(new,old))/(sum(new)+0.001);
    %After having 'alpha', further modifications were made using 'alpha' on the basis of SS to obtain SSS
    aaa=aa*(1+a1*alpha^a2);
    bbb=bb*(1+b1*alpha^b2);
    hhh=hh*(1+h1*alpha^h2);
    ddd=dd*(1+d1*alpha^d2)+t-1;
    www=ww*(1+w1*alpha^w2);
    %According to SSS, a UH can be generated and multiplied by the current period's runoff generation 'doc(t,1)' to obtain the corrected sub hydrograph corresponding to the current period's runoff generation, denoted as 'fin'
    fin=doc(t,1)*gen(aaa,bbb,hhh,ddd,www,M);
    %'fin' can be overlaid with the 'old' of the current period to obtain the 'old' of the next period
    doc(:,2)=doc(:,2)+fin;
end
%After non-linear superposition of the sub hydrographs at each period, the simulated streamflow 'Qsim' can be obtained
Qsim=doc(:,2);
%The observed streamflow 'Qobs' can be obtained from the matrix 'dat'
Qobs=dat(:,end);
%Calculate NSE to measure the simulation effect
nash=1-(sum((Qsim-Qobs).^2)/sum((Qobs-mean(Qobs)).^2));
end