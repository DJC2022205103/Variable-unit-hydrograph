%This function is used to generate discrete unit hydrograph. a,b,h,d and w are the shape factors of UH, and N is the length of the discrete sequence to be generated
function y=gen(a,b,h,d,w,N)
%Restrict a,w,h to be positive
a=max(a,0.01);
w=max(w,0.01);
h=max(h,0.01);
%If b~=0, calculate according to the expression of the normal unit hydrograph
if abs(b)>0.000000001
    %First, apply for memory of UH, that is an array with a length of N
    y=zeros(N,1);
    %Generate discrete values of UH one by one, for the t-th time period
    for t=1:N
        %if t-d<0，it indicates that the flood has not arrived at this time
        if t-d<=0
            %Directly set the value of UH at that time to 0
            y(t)=0;
        %if t-d>0，it indicates that the flood has arrived at this time
        else
            %Calculate the unit hydrograph value at this time according to the expression below
            y(t)=exp(log(h)+a/b*log(w*(t-d))+a/b/b*(1-exp(b*log(w*(t-d)))));
            %Due to the fact that UH is a bell shaped curve, on the right side of the peak, when the value is already small, the subsequent values will only be smaller.
            if t>1/w+d && y(t)<0.0001 && y(t)>0
                %Therefore, the calculation will no longer continue, and the initial UH value 0 will be retained
                break;
            end
        end
    end
%If b is very close to 0, the UH expression will show strangeness, and it is necessary to modify the UH expression
else
    y=zeros(N,1);
    for t=1:N
        if t-d<0
            y(t)=0;
        else
            %The UH expression has been simplified
            y(t)=h*exp(-(a*(log(w*(t-d)))^2)/2);
            if t>1/w+d && y(t)<0.0001 && y(t)>0
                break;
            end
        end
    end
end