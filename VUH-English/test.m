%After running 'main' to obtain 'canshumax', run this script to verify the simulation effect
%Specify the flood event to be inspected
jianyan=1:4;
%Apply for four arrays to record the simulation accuracy information of each flood separately
doc1=[];%NSE
doc2=[];%Flood volume
doc3=[];%Flood peak
doc4=[];%Lag time
%Traverse all flood events that need to be tested. For the jth event
for j=jianyan
    %As an example, due to only four floods, a 2*2 figure was chosen here
    subplot(2,2,j)
    %Call the rainfall-runoff model to get the simulation result Qsim of the jth event
    [nash,Qsim]=f(canshumax,data{j},F,dt,WU,WL,WD,location,LB);
    %Extract the observed streamflow and areal average rainfall from the measured data
    Qobs=data{j}(:,end);
    P=mean(data{j}(:,1:end-1),2);
    %Draw on the left y-axis
    yyaxis left
    hold on
    %Draw the observed streamflow with thick lines
    plot(Qobs,'LineWidth',1)
    %Draw the simulated streamflow with thin lines
    plot(Qsim)
    %Restrict the hydrograph to only occupy the bottom 70% of the figure
    axis([-inf inf 0 max(max(Qsim),max(Qobs))/0.7])
    %Set y-axis Name
    ylabel('Streamflow(m^3/s)')
    %Draw on the right y-axis
    yyaxis right
    hold on
    %Draw rainfall Bar chart
    ba=bar(P);
    set(ba(1),'facecolor',[0.26, 0.45, 0.77]);
    %Invert Bar chart
    set(gca,'YDir','reverse')
    %Restrict the bar chart to only occupy the top 25% of the figure
    axis([-inf inf 0 max(P)/0.25])
    %Set x-axis Name
    xlabel('time(h)')
    %Set y-axis Name
    ylabel('Rainfall(mm)')
    %Using NSE of each event as the title of the subgraph
    title(nash)
    %Record the accuracy information of the jth event
    %将NSE加入到doc1中
    doc1=[doc1 nash];
    %Add 'observed runoff, simulated runoff, runoff error, relative runoff error' to doc2
    doc2=[doc2 [sum(Qobs)*3600/F/1000;sum(Qsim)*3600/F/1000;sum(Qsim)*3600/F/1000-sum(Qobs)*3600/F/1000;(sum(Qsim)-sum(Qobs))/sum(Qobs)]];
    %Add 'observed flood peak, simulated flood peak, flood peak error, relative flood peak error' to doc3
    doc3=[doc3 [max(Qobs);max(Qsim);max(Qsim)-max(Qobs);(max(Qsim)-max(Qobs))/max(Qobs)]];
    %Add 'observed lag time, simulated lag time, lag time error' to doc3
    doc4=[doc4 [find(Qobs==max(Qobs))-find(P==max(P));find(Qsim==max(Qsim))-find(P==max(P));(find(Qsim==max(Qsim))-find(P==max(P)))-(find(Qobs==max(Qobs))-find(P==max(P)))]];
end
%add legend
legend('Qobs','Qsim','P')
%Merge all flood simulation accuracy statistics
doc=[doc1;doc2;doc3;doc4];
%Output statistics
for j=jianyan
    disp(['【flood ',num2str(j),'】observed runoff:',num2str(doc(2,j)),'mm, simulated runoff:',num2str(doc(3,j)),'mm, runoff error:',num2str(doc(4,j)),'mm, relative runoff error:',num2str(doc(5,j))])
    disp(['           observed peak:',num2str(doc(6,j)),'m^3/s, simulated peak:',num2str(doc(7,j)),'m^3/s, peak error',num2str(doc(8,j)),'m^3/s, relative peak error:',num2str(doc(9,j))])
    disp(['           NSE:',num2str(doc(1,j)),', observed lag time:',num2str(doc(10,j)),'h, simulated lag time:',num2str(doc(11,j)),'h, lag time error:',num2str(doc(12,j)),'h'])
end