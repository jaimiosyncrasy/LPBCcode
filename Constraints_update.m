% function [Pcmd, Qcmd, SOC1] = Constraints_update(Pcmd, Qcmd, Sinv, PTOD, t)
% gamma1 = 0.5; %Scaling factor for how much P is cared about compared to Q
% gamma2 = 0.5; %Scaling factor for how much Q is cared about compared to P
% SOC1 = 20; %percent SOC of battery 1, between 15-100% 
% PTOD1 = .50 %less than 100
% PTOD2 = .50
% dt= 0.1/3600;    
  

%%

% find the indexes with the vector of node values, then use those indexes
% to form a cell array with one entry for each node (zero pad to make
% everything 3 phase) -- for all zero entries add in constraint 
%Qcmd and Pcmd are rx1 vectors, for the 13 node feeder, n = 3
Pcmd = [1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8]; %TEMP test values 
Qcmd = [1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8];
n = 3;
Sinv = 600;
gamma = [0.75, 0.75];
% TimeofDay = PTOD(t) 

old611p = [0, 0, Pcmd(1)]; 
old632p = [Pcmd(2:4)]; 
old633p = [Pcmd(5:7)];
old634p = [Pcmd(8:10)]; 
old645p = [0, Pcmd(11:12)];
old646p = [0, Pcmd(13:14)]; 
old650p = [Pcmd(15:17)];
old651p = [Pcmd(18:20)]; 
old652p = [Pcmd(21), 0, 0];
old671p = [Pcmd(22:24)];
old675p = [Pcmd(25:27)];
old680p = [Pcmd(28:30)];
old684p = [Pcmd(31), 0, Pcmd(32)];
old692p = [Pcmd(33:35)];

Pcmd = [old611p, old632p, old633p, old634p, old645p, old646p, old650p, old651p, old652p, old671p, old675p, old680p, old684p, old692p]; 

old611q = [0, 0, Qcmd(1)]; 
old632q = [Qcmd(2:4)]; 
old633q = [Qcmd(5:7)];
old634q = [Qcmd(8:10)]; 
old645q = [0, Qcmd(11:12)];
old646q = [0, Qcmd(13:14)]; 
old650q = [Qcmd(15:17)];
old651q = [Qcmd(18:20)]; 
old652q = [Qcmd(21), 0, 0];
old671q = [Qcmd(22:24)];
old675q = [Qcmd(25:27)];
old680q = [Qcmd(28:30)];
old684q = [Qcmd(31), 0, Qcmd(32)];
old692q = [Qcmd(33:35)]; 

Qcmd = [old611q, old632q, old633q, old634q, old645q, old646q, old650q, old651q, old652q, old671q, old675q, old680q, old684q, old692q,];


 %inverter max 
    %Pmax=zeros(); Qmax=zeros(1,35);
    for i=1:42 % across phases, TEMP, assuming the single actuator is on 3 phases
        Pmax(i)=Pcmd(i)*Sinv/(sqrt(Pcmd(i)^2+Qcmd(i)^2));      
        Qmax(i)=Qcmd(i)*Sinv/(sqrt(Pcmd(i)^2+Qcmd(i)^2));
    end
    
Pmax(isnan(Pmax)) = 0;  
Qmax(isnan(Qmax)) = 0;
oldp = [-old611p' - old632p' - old633p' - old634p' - old645p' - old646p' - old650p' - old651p' - old652p' - old671p' - old675p' - old680p' - old684p' - old692p'];
oldq = [-old611q' - old632q' - old633q' - old634q' - old645q' - old646q' - old650q' - old651q' - old652q' - old671q' - old675q' - old680q' - old684q' - old692q'];
    
%TEMP the objective function needs to be fixed, I am stuck between how it
%is written now, and having each node have a gamma value. 
%Also, am debating whether the gammas need to be variables to be optimized

    cvx_begin quiet

        variables p611(n) q611(n) p632(n) q632(n) p633(n) q633(n) p634(n) q634(n) p645(n) q645(n) p646(n) q646(n) p650(n) q650(n) p651(n) q651(n) p652(n) q652(n) p671(n) q671(n) p675(n) q675(n) p680(n) q680(n) p684(n) q684(n) p692(n) q692(n);

        %objective function: 
        minimize ( gamma(1)*(norm(p611 + p632 + p633 + p634 + p645 + p646 + p650 + p651 + p652 + p671 + p675 + p680 + p684 + p692 + oldp)) + gamma(2)*(norm(q611 + q632 + q633 + q634 + q645 + q646 + q650 + q651 + q652 + q671 + q675 + q680 + q684 + q692 + oldq)) ) 
        subject to 
        
            %constraints
            p611 - Pmax(1:3)' <= 0 
            p632 - Pmax(4:6)' <= 0 
            p633 - Pmax(7:9)' <= 0 
            p634 - Pmax(10:12)' <= 0 
            p645 - Pmax(13:15)' <= 0
            p646 - Pmax(16:18)' <= 0
            p650 - Pmax(19:21)' <= 0
            p651 - Pmax(22:24)' <= 0
            p652 - Pmax(25:27)' <= 0
            p671 - Pmax(28:30)' <= 0
            p675 - Pmax(31:33)' <= 0
            p680 - Pmax(34:36)' <= 0
            p684 - Pmax(37:39)' <= 0
            p692 - Pmax(40:42)' <= 0
            
            q611 - Qmax(1:3)' <= 0 
            q632 - Qmax(4:6)' <= 0 
            q633 - Qmax(7:9)' <= 0 
            q634 - Qmax(10:12)' <= 0 
            q645 - Qmax(13:15)' <= 0
            q646 - Qmax(16:18)' <= 0
            q650 - Qmax(19:21)' <= 0
            q651 - Qmax(22:24)' <= 0
            q652 - Qmax(25:27)' <= 0
            q671 - Qmax(28:30)' <= 0
            q675 - Qmax(31:33)' <= 0
            q680 - Qmax(34:36)' <= 0
            q684 - Qmax(37:39)' <= 0
            q692 - Qmax(40:42)' <= 0
       
            
            %PV power factor constraint 
            %0.85 lead<**********<0.85 lag
            -0.85 <= p611 ./ Sinv <= 0.85
            -0.85 <= p632 ./ Sinv <= 0.85 
            -0.85 <= p633 ./ Sinv <= 0.85
            -0.85 <= p634 ./ Sinv <= 0.85
            -0.85 <= p645 ./ Sinv <= 0.85
            -0.85 <= p646 ./ Sinv <= 0.85
            -0.85 <= p650 ./ Sinv <= 0.85
            -0.85 <= p651 ./ Sinv <= 0.85
            -0.85 <= p652 ./ Sinv <= 0.85
            -0.85 <= p671 ./ Sinv <= 0.85
            -0.85 <= p675 ./ Sinv <= 0.85
            -0.85 <= p680 ./ Sinv <= 0.85
            -0.85 <= p684 ./ Sinv <= 0.85
            -0.85 <= p692 ./ Sinv <= 0.85
            
            %these should be redundant, but in case we need them, think
            %about if this meets the Pinv^2 + Qinv^2 < Sinv^2 
            - sin(acos(0.85)) <= p611 ./ Sinv <= sin(acos(0.85))
            - sin(acos(0.85)) <= p632 ./ Sinv <= sin(acos(0.85))
            - sin(acos(0.85)) <= p633 ./ Sinv <= sin(acos(0.85))
            - sin(acos(0.85)) <= p634 ./ Sinv <= sin(acos(0.85))
            - sin(acos(0.85)) <= p645 ./ Sinv <= sin(acos(0.85))
            - sin(acos(0.85)) <= p646 ./ Sinv <= sin(acos(0.85))
            - sin(acos(0.85)) <= p650 ./ Sinv <= sin(acos(0.85))
            - sin(acos(0.85)) <= p651 ./ Sinv <= sin(acos(0.85))
            - sin(acos(0.85)) <= p652 ./ Sinv <= sin(acos(0.85))
            - sin(acos(0.85)) <= p671 ./ Sinv <= sin(acos(0.85))
            - sin(acos(0.85)) <= p675 ./ Sinv <= sin(acos(0.85))
            - sin(acos(0.85)) <= p680 ./ Sinv <= sin(acos(0.85))
            - sin(acos(0.85)) <= p684 ./ Sinv <= sin(acos(0.85))
            - sin(acos(0.85)) <= p692 ./ Sinv <= sin(acos(0.85))
            
            p611(1) == 0; 
            p611(2) == 0;  
            p645(1) == 0; 
            p646(1) == 0;
            p652(2) == 0; 
            p652(3) == 0; 
            p684(2) == 0; 
                        
            q611(1) == 0; 
            q611(2) == 0;  
            q645(1) == 0; 
            q646(1) == 0;
            q652(2) == 0; 
            q652(3) == 0; 
            q684(2) == 0;
            
           % PV time of day(need to know which nodes are PV)          
%             p611 - TimeofDay < 0; 
%             p632 - TimeofDay < 0;
%             p633 - TimeofDay < 0; 
%             p634 - TimeofDay < 0; 
%             p645 - TimeofDay < 0;
%             p646 - TimeofDay < 0;
%             p650 - TimeofDay < 0;
%             p651 - TimeofDay < 0;
%             p652 - TimeofDay < 0;
%             p671 - TimeofDay < 0;
%             p675 - TimeofDay < 0;
%             p680 - TimeofDay < 0;
%             p684 - TimeofDay < 0;
%             p692 - TimeofDay < 0;
  
            %battery SOC conditions 
           % (SOC1 - Pinv1*dt) >= 0.15
           % (SOC1 + Pinv1*dt) <= 1 
        

     cvx_end
     
Pcmd = [p611', p632', p633', p634', p645', p646', p650', p651', p652', p671', p675', p680', p684', p692']; 
Qmcd = [q611', q632', q633', q634', q645', q646', q650', q651', q652', q671', q675', q680', q684', q692'];

Pcmd(Pcmd==0) = []; 
Qcmd(Qcmd==0) = [];
 
%  SOC1 = SOC1 + Pinv1*dt 
%end





%need to ask which ones are PV and which are battery (need to be hard coded)
%need to figure out the PTOD stuff (she will send it to me in a vector form??)
%need to work on the update saturation stuff 
