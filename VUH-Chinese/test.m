%在运行main得到canshumax后，方可运行该脚本以检验模拟效果
%指定需要检验的洪水场次
jianyan=1:4;
%申请四个数组，分别记录每场洪水的模拟精度信息
doc1=[];%NSE
doc2=[];%洪量
doc3=[];%洪峰
doc4=[];%滞时
%遍历所有需要被检验的洪水场次，对于第j场洪水
for j=jianyan
    %作为示例，由于只有四场洪水，就选择了2*2的拼图
    subplot(2,2,j)
    %调用水文模型，得到第j场洪水的模拟结果Qsim
    [nash,Qsim]=f(canshumax,data{j},F,dt,WU,WL,WD,location,LB);
    %再从实测数据中摘出实测流量和面平均雨量
    Qobs=data{j}(:,end);
    P=mean(data{j}(:,1:end-1),2);
    %绘图于左侧y轴
    yyaxis left
    hold on
    %用粗线绘制实测流量
    plot(Qobs,'LineWidth',1)
    %用细线绘制模拟流量
    plot(Qsim)
    %限制流量过程线仅占据图幅的下70%
    axis([-inf inf 0 max(max(Qsim),max(Qobs))/0.7])
    %设置纵轴名称
    ylabel('Streamflow(m^3/s)')
    %绘图于右侧y轴
    yyaxis right
    hold on
    %绘制降雨量条形图
    ba=bar(P);
    set(ba(1),'facecolor',[0.26, 0.45, 0.77]);
    %倒置
    set(gca,'YDir','reverse')
    %限制降雨过程仅占据图幅的上25%
    axis([-inf inf 0 max(P)/0.25])
    %设置横轴名称
    xlabel('time(h)')
    %设置纵轴名称
    ylabel('Rainfall(mm)')
    %以场次洪水的NSE作为子图的图名
    title(nash)
    %记录第j场洪水的精度信息
    %将NSE加入到doc1中
    doc1=[doc1 nash];
    %将'实测径流量 模拟径流量 径流误差 径流相对误差'加入到doc2中
    doc2=[doc2 [sum(Qobs)*3600/F/1000;sum(Qsim)*3600/F/1000;sum(Qsim)*3600/F/1000-sum(Qobs)*3600/F/1000;(sum(Qsim)-sum(Qobs))/sum(Qobs)]];
    %将'实测洪峰 模拟洪峰 洪峰误差 洪峰相对误差'加入到doc3中
    doc3=[doc3 [max(Qobs);max(Qsim);max(Qsim)-max(Qobs);(max(Qsim)-max(Qobs))/max(Qobs)]];
    %将'实测滞时 模拟滞时 滞时误差'加入到doc4中
    doc4=[doc4 [find(Qobs==max(Qobs))-find(P==max(P));find(Qsim==max(Qsim))-find(P==max(P));(find(Qsim==max(Qsim))-find(P==max(P)))-(find(Qobs==max(Qobs))-find(P==max(P)))]];
end
%添加图例
legend('Qobs','Qsim','P')
%合并所有洪水模拟精度统计信息
doc=[doc1;doc2;doc3;doc4];
%输出所有洪水模拟精度统计信息
for j=jianyan
    disp(['【第',num2str(j),'场洪水】实测径流:',num2str(doc(2,j)),'mm,模拟径流:',num2str(doc(3,j)),'mm,径流误差:',num2str(doc(4,j)),'mm,相对误差:',num2str(doc(5,j))])
    disp(['            实测洪峰:',num2str(doc(6,j)),'m^3/s,模拟洪峰:',num2str(doc(7,j)),'m^3/s,洪峰误差:',num2str(doc(8,j)),'m^3/s,相对误差:',num2str(doc(9,j))])
    disp(['            NSE:',num2str(doc(1,j)),',实测滞时:',num2str(doc(10,j)),'h,模拟滞时:',num2str(doc(11,j)),'h,滞时误差:',num2str(doc(12,j)),'h'])
end