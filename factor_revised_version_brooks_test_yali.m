% Yajun Li  2019.6.28
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preprocess the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maindata=importdata('601888.csv'); 
tradetime=maindata.textdata(2:end,3);
c_p = str2double(maindata.textdata(2:end,4));
vol = str2double(maindata.textdata(2:end,7));
B_S=maindata.textdata(2:end,8); % cell

T = datevec(tradetime);
B = [0,0;0,0;0,0;60,0;1,0;0,1];
A = T*B;  % minutes & seconds
A(:,1) = A(:,1)-570;
idx = find(A(:,1)>120);
A(idx,1) = A(idx,1)-89;

% delete those rows where minute <0 & minute>240
idx = find(A(:,1)<0 | A(:,1)>240);
A(idx,:) = [];
T(idx,:) = [];
tradetime(idx,:) = [];
maindata.data(idx,:) = [];
B_S(idx) = [];
c_p(idx) = [];
vol(idx) = [];


B_S=cell2mat(B_S);
b_s = ones(size(B_S));
ind = find(B_S == 'S');
b_s(ind) = -1;
% b_s = cellfun(@str2num, B_S);

data_save = [A(:,1),b_s,c_p,vol,maindata.data];  
T_save = T;

b_s_save = b_s;
b_1_save=data_save(:,5);  % buy-1
s_1_save=data_save(:,10);  % sell-1
b_save=data_save(:,5:9);  % buy-1 to 5
s_save=data_save(:,10:14);  % sell-1 to 5
b_v_save=data_save(:,15:19);  % buy volumn 1 to 5
s_v_save=data_save(:,20:24);  % sell volumn 1 to 5
current_price_tick_save = data_save(:,3);  % current price
volumn_save = data_save(:,4);
sec_save = A(:,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate factors & labels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ymd=datetime(T(:,1:3));  % year-month-day
uu =unique(ymd);
label_save =[];
train_save = [];
uuid = 1:length(uu);
for i=uuid
    % prepare subdata for one day
    sub_idx = find(ymd==uu(i));
    data = data_save(sub_idx,:);
    b_s = b_s_save(sub_idx);
    b_1=b_1_save(sub_idx,:); 
    s_1=s_1_save(sub_idx,:); 
    b_=b_save(sub_idx,:); 
    s_=s_save(sub_idx,:); 
    b_v=b_v_save(sub_idx,:); 
    s_v=s_v_save(sub_idx,:); 
    voll = volumn_save(sub_idx);
    current_price_tick = current_price_tick_save(sub_idx,:);
    sec = sec_save(sub_idx);
    
    factor = []; label=[]; price=data(:,3);
    for k=0:data(end,1)
        if ~isempty(find(data(:,1)==k))  % added to debug
           xh=find(data(:,1)==k);  % tick rows for the k's minute
           
           lab=sign(price(xh(end))-price(xh(1)));  
           lab(lab==0)=1;
           label = [label;lab];
          
           b=b_s(xh(1):xh(end));  s=b_s(xh(1):xh(end)); 
           b(b==-1)=0;  s(s==1)=0; 
% unconditional factors
           factor(k+1,1)=sum(abs(b))/sum(abs(s)); % buy / sell in one minute
           factor(k+1,2)=b_1(xh(end))/b_1(xh(1)); 
           factor(k+1,3)=s_1(xh(end))/s_1(xh(1)); %  these two may not change much in one min
           factor(k+1,4)=(b_1(xh(end))+s_1(xh(end)))/2-(b_1(xh(1))+s_1(xh(1)))/2; 
           factor(k+1,5)=(b(end)-s(end))/(b(end)+s(end)); 
           factor(k+1,6)=(sum(b_v(xh(end),:))-sum(s_v(xh(end),:)))/(sum(b_v(xh(end),:))+sum(s_v(xh(end),:))); % revised already
           factor(k+1,7)=sum(b_v(xh(end),:))/sum(b_v(xh(1),:)); 
           factor(k+1,8)=(b_1(xh(end))-s_1(xh(end)))/(b_1(xh(end))+s_1(xh(end)));  
           factor(k+1,9) = current_price_tick(xh(end))-current_price_tick(xh(1)); 
           factor(k+1,37)=data(xh(end),3)/data(xh(1),3); 
           
           % for factors 38 - 51
           ATR_=ATR(max(price(xh(1):xh(end))),min(price(xh(1):xh(end))),price(xh(end)),14,0);
           BIAS_=BIAS(price(xh(end)),6,0);
           CR_=CR(max(price(xh(1):xh(end))),min(price(xh(1):xh(end))),price(xh(end)),26);
           [Kvalue,Dvalue,Jvalue]=KDJ(max(price(xh(1):xh(end))),min(price(xh(1):xh(end))),price(xh(end)),14,3,3,3);
           [DIF,DEA,MACDValue]=MACD(price(xh(end)),12,26,9);
           MTM_=MTM(price(xh(end)),12);
           OBV_=OBV(price(xh(end)),voll(xh(end)));
           PSY_=PSY(price(xh(end)),12);
           RSI_=RSI(price(xh(end)),14);
           VR_=VR(price(xh(end)),voll(xh(end)),26);
    
           factor(1,38)=ATR_(end);
           factor(1,39)=BIAS_(end);
           factor(1,40)=CR_(end);
           factor(1,41)=Kvalue(end);
           factor(1,42)=Dvalue(end);
           factor(1,43)=Jvalue(end);
           factor(1,44)=DIF(end);
           factor(1,45)=DEA(end);
           factor(1,46)=MACDValue(end);
           factor(1,47)=MTM_(end);
           factor(1,48)=OBV_(end);
           factor(1,49)=PSY_(end);
           factor(1,50)=RSI_(end);
           factor(1,51)=VR_(end);
           
           factor(k+1,52) = current_price_tick(xh(end))-current_price_tick(xh(1));  % price change
           factor(k+1,53) = i;  % day number

% conditional factors
              time_s = sec(xh(1):xh(end));  % second in that minute
              price_min=data(xh(1):xh(end),3);  % current tick price in that minute
          if time_s(end)>45 && time_s(1)<15  
              A=find(time_s<15);
              B=find(time_s<30);
              C=find(time_s<45);
              D=find(time_s<60); 
           
              % quarter high
              high1=max(price_min(1:A(end)));
              high2=max(price_min(A(end)+1:B(end)));
              high3=max(price_min(B(end)+1:C(end)));
              high4=max(price_min(C(end)+1:D(end)));
              
              % quarter low
              low1=min(price_min(1:A(end)));
              low2=min(price_min(A(end)+1:B(end)));
              low3=min(price_min(B(end)+1:C(end)));
              low4=min(price_min(C(end)+1:D(end)));
           
              % quarter close
              close1=(price_min(A(end)));
              close2=(price_min(B(end)));
              close3=(price_min(C(end)));
              close4=(price_min(D(end)));
              
              % quarter open
              open1=(price_min(1));
              open2=(price_min(A(end)+1));
              open3=(price_min(B(end)+1));
              open4=(price_min(C(end)+1));
           
              % position of max & min of high, low, close, open
              [~,factor(k+1,10)]=max([high1,high2,high3,high4]); 
              [~,factor(k+1,11)]=max([low1,low2,low3,low4]); 
              [~,factor(k+1,12)]=max([close1,close2,close3,close4]); 
              [~,factor(k+1,13)]=max([open1,open2,open3,open4]); 
              
              [~,factor(k+1,14)]=min([high1,high2,high3,high4]); 
              [~,factor(k+1,15)]=min([low1,low2,low3,low4]); 
              [~,factor(k+1,16)]=min([close1,close2,close3,close4]); 
              [~,factor(k+1,17)]=min([open1,open2,open3,open4]); 
              
              factor(k+1,18:21)=b_(xh(end),2:end)/b_(xh(1),2:end); 
              factor(k+1,22:25)=b_v(xh(end),2:end)/b_v(xh(1),2:end);
              factor(k+1,26)=sum(b_(xh(end),:).*b_v(xh(end),:))/sum(b_v(xh(end),:))-sum(b_(xh(1),:).*b_v(xh(1),:))/sum(b_v(xh(1),:));
              factor(k+1,27)=sum(s_(xh(end),:).*s_v(xh(end),:))/sum(s_v(xh(end),:))-sum(s_(xh(1),:).*s_v(xh(1),:))/sum(s_v(xh(1),:)); 
              factor(k+1,28)=sum(data(xh(1):xh(end),2).*data(xh(1):xh(end),4));  % buy vol*price minus sell vol*price
        
              factor(k+1,29)=sum((data(xh(2):xh(end),2)==1).*(data(xh(2):xh(end),3)-data(xh(2):xh(end),10)>0).*data(xh(2):xh(end),4)); 
              factor(k+1,30)=sum((data(xh(2):xh(end),2)==-1).*(data(xh(2):xh(end),3)-data(xh(2):xh(end),5)>0).*data(xh(2):xh(end),4)); 
              factor(k+1,31)=sum((data(xh(2):xh(end),2)==1).*(data(xh(2):xh(end),3)-data(xh(2):xh(end),5)<0).*data(xh(2):xh(end),4));  
              factor(k+1,32)=sum((data(xh(2):xh(end),2)==-1).*(data(xh(2):xh(end),3)-data(xh(2):xh(end),10)<0).*data(xh(2):xh(end),4)); 
              factor(k+1,33)=factor(k+1,29)-factor(k+1,30); 
              factor(k+1,34)=factor(k+1,31)-factor(k+1,32); 
              factor(k+1,35)=data(xh(end),3)/data(xh(1),3); 
              factor(k+1,36)=std([close1/open1-1,close2/open2-1,close3/open3-1,close4/open4-1]);  % keep this  
          else
              factor(k+1,10:36)=0;
          end              
       else
           factor(k+1,1:53)=0;
           label = [label;0];
       end
    end  
    
   label=label(2:end,:);
   label_save = [label_save; label];
   factor_52 = factor(2:end,52);  % price change
   train=factor(1:end-1,:);
   train(:,52) = factor_52;  % plug in price change again
   train_save = [train_save; train];  % stack all
end 
%%
train = train_save; label = label_save;  % the big chunk of all training set
del2=find(label==0);
train(del2,:) = [];
label(del2) = [];

del3 = find(train(:,37)==0);  % del3 = find(train(:,35)==0); change into this condition to remove sparse data
train(del3,:) = [];
label(del3,:) = [];

% extract price change and date index 
price_change = train(:,52);
date = train(:,53);

% update train
train=train(:,1:51);