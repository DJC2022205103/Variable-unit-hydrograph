%Improved Gradient descent method for parameter calibration of rainfall-runoff model
clear;clc;
%Firstly, input flood data and place it in a cell array, where each cell represents a flood (consisting of n columns of rainfall data and 1 column of flow data). The following is an example of four floods. The first five columns of each flood contain data from five rainfall stations, and the sixth column contains measured flow data, with a duration of one hour.
data{1}=[0,0,0,0,0,0.08;0,0,0,0,0,0.102857143;0,0,0,0,0,0.125714286;0,7.5,0,0,0,0.148571429;29.4,72.7,33,27.3,33,0.6;21.1,17.6,27.2,11.2,20.5,103;3.1,0,0.2,0.5,0.3,37.6;0,0,0,0,0.3,9.09;0,0,0,0,0.3,5.57;0,0,0,0,0.3,3.09;0,0,0,0,0.3,3.020243902;0,0,0,0,0.3,2.83;0,0,0,0,0.3,2.476666667;0,0,0,0,0.3,2.123333333;0,0,0,0,0.3,1.77;0,0,0,0,0.3,1.416666667;0,0,0,0,0.3,1.23970724;0,0,0,0,0.3,1.238731373;0,0,0,0,0.3,1.237755506;0,0,0,0,0.3,1.236779639;0,0,0,0,0.3,1.235803772];
data{2}=[0.9,1.6,0,0,0,0.530751174;0.9,2.9,0.1,1.2,1.4,0.530375587;3.8,10.1,1.4,3.3,4.2,0.53;5.2,8,5.4,6.4,5,1.275;11.8,12.2,9.2,12.2,8.4,2.39;11.3,18.7,9.7,10,8.8,12.92769231;20.1,10,19.8,23.3,15,29.25;9.2,9.4,10.6,9.4,10.9,42.4;11.1,21.6,6.3,6.4,6.5,29;46.4,65.7,28.4,42.4,30.5,84.2;50.5,39,71.3,54.3,59.4,543;11.8,4.4,39.5,32.3,38.2,516;1.8,16.9,1.5,1.3,12.5,139;14.5,8.3,9,14.5,5.9,83.8;0.3,2,0.6,0.2,0.1,107;4.5,6.2,0.2,0.2,0.2,45.9;5.6,7.6,1.1,2.7,1.3,36.84285714;21.4,20.1,5.2,8.1,22.7,105;5.2,3.1,44.6,44.4,36.1,447;3.3,4.7,2.9,3.1,3.9,126;5.3,4.5,3.5,4.5,4.2,61;18.2,33.4,3.3,3.7,3.5,50.6;16.8,3,29.5,26.4,17.7,80.9;3.9,5,1.3,1.4,3.3,192;0.4,1.9,0.1,3.8,0.7,48;8,7.7,5,4.9,7.5,41;0.2,0.8,0.9,1.5,1.4,38.5;1,1.5,2.4,1.3,13,36.5;1.4,15,0.8,0.3,0.8,36;14.3,0.9,18.8,15.1,9.2,39.7;0.1,0.2,5.8,0.8,9.4,64.6;0,0,0.8,1,0.1,44.24;0,0,0,0,0,34.3;0,0,0,0,0,32.65;0,0,0,0,0,31;0,0,0,0,0.1,29.35;0,0,0,0,0,27.7;0,0,0,0,0,26.05;0,0.2,0,0,0,24.4;0,0.1,0,0,0,22.75;0,0.1,0,0,0,21.1;0,0.1,0,0,0,19.45;0,0.1,0,0,0,17.8;0,0.1,0,0,0,16.15;0,0.1,0,0,0,14.5;0,0.1,0,0,0.1,13.80434783;0,0.1,0,0,0,13.10869565;0,0.1,0,0,0,12.67628866;0,0.1,0,0,0,12.35670103;0,0.1,0,0,0,12.0371134;0,0.1,0,0,0,11.71752577;0,0.1,0,0,0,11.39793814;0,0.1,0,0,0,11.07835052;0,0.1,0.1,0,0,10.75876289;0,0.1,0,0,0,10.43917526;0,0.1,0,0,0,10.11958763;0,0.1,0,0,0,9.8];
data{3}=[0,0,0,0,0,0;0,0,0,0,0,0;0,0,0,0,0,0;0,0,0,0,0,0;0,0,0,0,0,0;19.4,9.5,15,0,20.4,0;11.7,6.8,8.2,15,10.6,30.3;0.7,0.2,0.3,6,0.5,5.55;0,0,0,0.2,0,1.16;0,0,0,0,0,0.77;0,0,0,0,0,0.38;0,0,0,0,0,0.31;0,0,0,0,0,0.30849711;0,0,0,0,0,0.306184971;0,0,0,0,0,0.303872832;0,0,0,0,0,0.301560694;0,0,0,0,0,0.299248555;0,0,0,0,0,0.296936416;0,0,0,0,0,0.294624277;0,0,0,0,0,0.292312139;0,0,0,0,0,0.29;0,0,0,0,0,0.265833333;0,0,0,0,0,0.241666667;0,0,0,0,0,0.2175];
data{4}=[0,0,0,0,0,0.188956311;0,0,0,0,0,0.187463592;0,0,0,0,0,0.185970874;0,0,0,0,0,0.184478155;0,0,0,0,0,0.182985437;0,0,0,0,0,0.181492718;0,59.2,0,0,1,0.18;44,2.6,10.1,12.5,7.8,34.13333333;0.8,0,0.1,4.1,0.1,16.8;0,0,0,0.1,0,5.37;0.2,0,0,0,0,4.333333333;0,0,0,0,0,3.296666667;0,0,0,0,0,2.26;0,0,0,0,0,2.086;0,0,0,0,0,1.912;0,0,0,0,0,1.738;0,0,0,0,0,1.564;0,0,0,0,0,1.39;0,0,0,0,0,1.216;0,0,0,0,0,1.042;0,0,0,0,0,0.868];
%'tic' starts timing after the program runs, in order to record the current time when updating the optimal parameters for visualization purposes
tic
%The first line of 'doc' records the time of each update, and the second line records the NSE corresponding to the current optimal solution
doc=[];
%When 'state' is 0, calibration will start from the default value of the parameter from scratch; When 'state' is 1, the last calibration will continue
state=0;
%If you want to optimize from scratch
if state==0
    %The algorithm hyperparameters are set as follows
    maxdiedai=200;%The maximum number of iterations, the larger the value, the longer the running time, but it may also bring about better results
    mtp=30;%Maximum step coefficient. The maximum value for perturbing a parameter is mtp*the step of the parameter
    lvding=1:3;%The selected flood events for calibration. You can choose either a single flood or multiple floods, such as selecting 1-3 events for calibrating, and the fourth event is excluded because it needs to be kept for testing
    delta1=0.00001;%The minimum gradient allowed in MODE1 and MODE2 of the Gradient method. If the gradient is less than delta1, you need to enter MODE3 or end the search
    delta2=0.1;%The relative error limit between the current NSE and the best NSE found. At the end of MODE1 or MODE2: if the relative error is below delta3, the MODE3 search will begin; If the relative error is higher than delta3, it will end and start the next round of search.
    delta3=0.000000001;%The minimum gradient allowed in MODE3, if the gradient is less than delta3, it will end and start the next round of search
    cnm=3;%When starting a new round of search, the initial parameters need to be obtained through perturbating the current optimal parameters. This disturbance can change up to 'cnm' parameters. The larger the 'cnm', the slower it converges, but it is also easier to jump out of the local optimal solution. 'cnm'should be less than the number of parameters.
    modegate=100;%Switching frequency between MODE1 and MODE2. Switch mode every 'modegate' iterations
    %The state of the watershed before the flood is set as follows. For simplicity, it is assumed that the state before each flood is the same
    F=57.3;%watershed area
    dt=1;%Time step size of flood data
    location=[5.5 2.4;4.5 4.4;2.6 0.7;2.9 -1.7;0 0];%A matrix with n rows and 2 columns. Each row stores the east-west and north-south distances of a rainfall station from the watershed outlet, which can be dimensionless in units
    LB=10.1;%Basin length. Units can be dimensionless, but they must be consistent with the units of 'location'
    WU=40;%Initial upper soil moisture content of the watershed
    WL=60;%Initial lower soil moisture content of the watershed
    WD=36;%Initial deep soil moisture content of the watershed
    %Set the parameter matrix. Each row represents a parameter, the first two columns represent the lower and upper bounds of the parameter, the third column represents the step size of the parameter, and the fourth column represents the initial value of the parameter
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
    %Before calibration, set the optimal value of the parameter as the default value of the parameter
    canshumax=canshu;
    %Set an array 'temp' with 1 row and 2 columns. The second column records the NSE after this gradient descent iteration, and the first column records the NSE before the iteration. Comparing the two can measure the remaining space for optimization
    temp=zeros(1,2);
%If you want to continue with the last calibration
elseif state==1
    %Directly assign the optimal parameter 'canshumax' found last time to the initial value of this time
    canshu=canshumax;
    %The algorithm hyperparameters are set as follows
    maxdiedai=200;
    mtp=30;
    lvding=1:3;
end
%Assign initial values to the array 'temp'. You can fill in 'temp' with two poor NSEs
temp(1)=-inf;
temp(2)=-1;
%Believing that the initial specified optimal parameters also have poor NSE
tempmax=-inf;
%The algorithm sets three MODEs: when MODE=1, the step size of gradient descent is a large random number, which gives MODE1 the ability to jump out of local optima; When MODE=2, the step size of gradient descent is a value that decreases from 'mtp' to 0, which gives MODE2 good convergence ability; When MODE=3, this means that the current parameter effect is very close to the effect of the optimal parameter that has been found, so iteration is still allowed to continue even when the gradient is very small.
MODE=0;
%Record the number of times a warning was issued. Due to possible flaws in the algorithm, the optimization result may be inf, complex, or nan, which requires abandoning the current optimization and starting a new one
warn=0;
%Start the iteration of gradient descent. The number of iterations starts from 3 because two 'temp' values have already been specified
for i=3:maxdiedai
    %First, determine whether the NSE obtained after the last gradient descent iteration is a real number
    if imag(temp(2))~=0 || isnan(temp(2)) || abs(temp(2))==inf
        %If it is not a real number, warning count+1
        warn=warn+1;
        %Abandon the current search and start a new search with the best parameters already found
        canshu=canshumax;
    end
    %Secondly, determine the difference in NSE before and after the last gradient descent iteration. If it is less than delta1, it indicates that the gradient is already small
    if abs(temp(2)-temp(1))<delta1
        %Now compare the difference between the NSE after the last iteration and the optimal NSE that has been found
        if (tempmax-temp(2))/tempmax<delta2
            %If the difference is less than delta2, it indicates that the current result has the potential to surpass the optimal NSE found, so enter MODE3
            MODE=3;
            %If the difference in NSE before and after the last iteration is too small (<delta3), then end MODE3
            if abs(temp(2)-temp(1))<delta3
                %Determine whether the current NSE exceeds the optimal NSE found before ending
                if temp(2)>tempmax
                    %If it exceeds, update the optimal parameter to the current parameter
                    canshumax=canshu;
                    %Simultaneously update the optimal NSE to the current NSE
                    tempmax=temp(2);
                %If the current NSE does not exceed the optimal NSE found
                else
                    %So reset the current parameter to the optimal parameter that has been found
                    canshu=canshumax;
                end
                %Starting a new round of search, the initial value of the search is randomly perturbed based on the current optimal parameters
                %Randomly select 'cn' parameters to prepare for disturbance. 'cn' is an integer between 1 and cnm.
                cn=randi(cnm);
                %If there are m parameters, 'list' will store numbers ranging from 1 to m
                list=[1:size(canshu,1)];
                %Disorder these numbers
                list=list(randperm(length(list)));
                %And take the first 'cn' numbers of 'list'. The extracted number is loaded into the 'change' array, which is the sequence number of the parameter that needs to be perturbed
                change=list(1:cn);
                %Now perturb the 'cn' parameters that need to be perturbed
                for j=1:cn
                    %The principle of perturbation is to randomly sample once between the upper and lower bounds of the parameter in a uniform distribution
                    canshu(change(j),4)=rand*(canshu(change(j),2)-canshu(change(j),1))+canshu(change(j),1);
                end
                %Since MODE3 has ended, now place MODE into 0
                MODE=0;
            end
        %If the difference is greater than delta2, it indicates that the current NSE may not exceed the optimal NSE found, and the current parameters is abandoned
        else
            %Determine whether the current NSE exceeds the optimal NSE found before ending
            if temp(2)>tempmax
                %If it exceeds, update the optimal parameter to the current parameter
                canshumax=canshu;
                %Simultaneously update the optimal NSE to the current NSE
                tempmax=temp(2);
            %If the current NSE does not exceed the optimal NSE found
            else
                %So reset the current parameter to the optimal parameter that has been found
                canshu=canshumax;
            end
            %Starting a new round of search, the initial value of the search is randomly perturbed based on the current optimal parameters
            %Randomly select 'cn' parameters to prepare for disturbance. 'cn' is an integer between 1 and cnm.
            cn=randi(cnm);
            %If there are m parameters, 'list' will store numbers ranging from 1 to m
            list=[1:size(canshu,1)];
            %Disorder these numbers
            list=list(randperm(length(list)));
            %And take the first 'cn' numbers of 'list'. The extracted number is loaded into the 'change' array, which is the sequence number of the parameter that needs to be perturbed
            change=list(1:cn);
            %Now perturb the 'cn' parameters that need to be perturbed
            for j=1:cn
                %The principle of perturbation is to randomly sample once between the upper and lower bounds of the parameter in a uniform distribution
                canshu(change(j),4)=rand*(canshu(change(j),2)-canshu(change(j),1))+canshu(change(j),1);
            end
            %Since MODE1 or MODE2 has ended, now place MODE into 0
            MODE=0;
        end
    end
    %Then confirm whether the current search mode is MODE1 or MODE2 (MODE3 will also overlay MODE1 or MODE2)
    %The division of MODE1 and MODE2 is as follows: the first 'modegate' searches are MODE1, followed by every 'modegate' searches, switching between the two search modes once
    %If the following equation is met, it is currently MODE1
    if mod(floor(i/modegate),2)==0
        %In MODE1, the search step coefficient 'k' is 'mtp' multiplied by a random number from 0 to 1
        k=rand*mtp;
        %If it is currently in MODE3
        if MODE==3 || MODE==31 || MODE==32
            %So the current mode will be superimposed as MODE31
            MODE=31;
        %If it is not currently in MODE3
        else
            %So the current mode is MODE1
            MODE=1;
        end
    %If the current state is not MODE1, it is MODE2
    else
        %MODE2 will continue to search 'modegate' times. During this period, the search step coefficient 'k' will decrease linearly from 'mtp' to 0
        k=mtp*(modegate-i+modegate*floor(i/modegate))/modegate;
        %If it is currently in MODE3
        if MODE==3 || MODE==31 || MODE==32
            %So the current mode will be superimposed as MODE32
            MODE=32;
        %If it is not currently in MODE3
        else
            %So the current mode is MODE2
            MODE=2;
        end
    end
    %Now let's start the gradient descent work for this iteration
    %Traverse all parameters that need to be calibrated. For the nth parameter
    for n=1:30%Since the last two parameters do not require calibration, this line does not need to be written as 'for n=1:size(canshu,1)'
        a1=[];%When the nth parameter remains unchanged, the vector composed of all NSEs participating in the calibration flood will be recorded in 'a1'
        a2=[];%After increasing the nth parameter by k * one step, the vector composed of NSE of all floods participating in calibration will be recorded in 'a2'
        a0=[];%After decreasing the nth parameter by k * one step, the vector composed of NSE of all floods participating in calibration will be recorded in 'a0'
        %First, copy the initial parameters of this iteration to para1
        para1=canshu;
        %Traverse the flood events participating in calibration. For the jth event
        for j=lvding
            %Input rainfall runoff data, parameters and status to run the rainfall-runoff model, and obtain the NSE of the jth event
            nash=f(canshu,data{j},F,dt,WU,WL,WD,location,LB);
            %Add the NSE of the jth event to the 'a1' vector
            a1=[a1 nash];
        end
        %Average the NSE of several events in 'a1' and record it as 'c1'.'c1' can measure the reasonableness of the current parameter 'para1'
        c1=mean(a1);
        %Increase the nth parameter by k * one step
        canshu(n,4)=canshu(n,4)+k*canshu(n,3);
        %Determine whether the parameter exceeds the upper bound after adjustment
        if canshu(n,4)>canshu(n,2)
            %If it exceeds, make it equal to the upper bound
            canshu(n,4)=canshu(n,2);
        end
        %After increasing the nth parameter, copy the current parameter to 'para2'
        para2=canshu;
        %Traverse the flood events participating in calibration. For the jth event
        for j=lvding
            %Input rainfall runoff data, parameters and status to run the rainfall-runoff model, and obtain the NSE of the jth event
            nash=f(canshu,data{j},F,dt,WU,WL,WD,location,LB);
            %Add the NSE of the jth event to the 'a2' vector
            a2=[a2 nash];
        end
        %Average the NSE of several events in 'a2' and record it as 'c2'.'c2' can measure the reasonableness of the current parameter 'para2'
        c2=mean(a2);
        %Temporarily restore the increased parameters
        canshu=para1;
        %Decrease the nth parameter by k * one step
        canshu(n,4)=canshu(n,4)-k*canshu(n,3);
        %Determine whether the parameter is lower than the lower bound after adjustment
        if canshu(n,4)<canshu(n,1)
            %If it is lower than the lower bound, make it equal to the lower bound
            canshu(n,4)=canshu(n,1);
        end
        %After decreasing the nth parameter, copy the current parameter to 'para0'
        para0=canshu;
        %Traverse the flood events participating in calibration. For the jth event
        for j=lvding
            %Input rainfall runoff data, parameters and status to run the rainfall-runoff model, and obtain the NSE of the jth event
            nash=f(canshu,data{j},F,dt,WU,WL,WD,location,LB);
            %Add the NSE of the jth event to the 'a0' vector
            a0=[a0 nash];
        end
        %Average the NSE of several events in 'a0' and record it as 'c0'.'c0' can measure the reasonableness of the current parameter 'para0'
        c0=mean(a0);
        %By comparing the sizes of c0, c1, and c2, one can determine the reasonable degree of parameter combinations para0, para1, and para2
        maxx=max([c0 c1 c2]);
        %If c1 is the largest among them
        if c1==maxx
            %So para1 is the most reasonable, and the parameters after this iteration are saved as para1
            canshu=para1;
        %If c2 is the largest among them
        elseif c2==maxx
            %So para2 is the most reasonable, and the parameters after this iteration are saved as para2
            canshu=para2;
        %If c0 is the largest among them
        else
            %So para0 is the most reasonable, and the parameters after this iteration are saved as para0
            canshu=para0;
        end
    end
    %To avoid adding additional storage memory, overwrite the results of the previous iteration with earlier results and place them in temp(1)
    temp(1)=temp(2);
    %Use the result of this iteration as the initial solution for the next iteration and place it in temp(2)
    temp(2)=max([c0 c1 c2]);
    %Print 'current MODE, current NSE, optimal NSE found, number of warnings'. Canceling printing can improve computational speed.
    disp([MODE temp(2) tempmax warn])
    %So far, an iteration has been completed. Record the current moment
    time=toc;
    %Record the current moment and the currently optimal NSE found in the 'doc' for later visualization
    doc=[doc [time;max(temp(2),tempmax)]];
end
%Draw the optimal NSE curve over time
plot(doc(1,:),doc(2,:))
xlabel('time(h)')
ylabel('average NSE of floods')
%Continue running the test script for further visualization