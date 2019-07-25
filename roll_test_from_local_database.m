correct_ratio = [];
earn = [];


for kk=201:220
    xh_test=find(date==kk);xh_test0 = find(date==kk-20);
    train(~isfinite(train))=0;
    % [~,yfit, eps, alpha]= adaboost_original(train(1:xh_test(1)-1,:),label(1:xh_test(1)-1,:), train(xh_test(1):xh_test(end),:));
     
     MdlLinear = fitcdiscr(train(xh_test0(1):xh_test(1)-1,:),label(xh_test0(1):xh_test(1)-1,:),'discrimType', 'linear');
     yfit = predict(MdlLinear,train(xh_test(1):xh_test(end),:));
    
     % [classestimate,model]=adaboost('train',train(1:xh_test(1)-1,:),label(1:xh_test(1)-1,:),30);
     % yfit=adaboost('apply',train(xh_test(1):xh_test(end),:),model);
    
    % B = TreeBagger(600,train(1:xh_test(1)-1,:),label(1:xh_test(1)-1,:));  
    % yfit= predict(B,train(xh_test(1):xh_test(end),:)); 
    % yfit = str2double(yfit);
   
    % linear_in=fitclinear(train(1:xh_test(1)-1,:),label(1:xh_test(1)-1,:),'Learner','logistic');
    % yfit = predict(linear_in,train(xh_test(1):xh_test(end),:));   
    
    % Mdl1 = fitensemble(train(1:xh_test(1)-1,:),label(1:xh_test(1)-1,:),'AdaBoostM1',100,'Tree') % Gentleboost  AdaBoostM1
    % yfit = predict(Mdl1,train(xh_test(1):xh_test(end),:));
    
    % [estimateclasstotal,model]=adaboost('train',Xtrain,Ytrain,3)
    
    % Xtrain=train(1:xh_test(1)-1,:); Ytrain=label(1:xh_test(1)-1,:); Xtest=train(xh_test(1):xh_test(end),:);
    % Mdl1 = fitcensemble(train(1:xh_test(1)-1,:),label(1:xh_test(1)-1,:))
    % yfit = predict(Mdl1,train(xh_test(1):xh_test(end),:));
    
    % Mdl1 = fitctree(train(1:xh_test(1)-1,:),label(1:xh_test(1)-1,:))
    % yfit = predict(Mdl1,train(xh_test(1):xh_test(end),:));
    
    % Mdl1 = fitcsvm(train(1:xh_test(1)-1,:),label(1:xh_test(1)-1,:),'KernelFunction','rbf')
    % yfit = predict(Mdl1,train(xh_test(1):xh_test(end),:));

    % Mdl1 = fitensemble(train(1:xh_test(1)-1,:),label(1:xh_test(1)-1,:),'Subspace',120,'Discriminant')
    % yfit = predict(Mdl1,train(xh_test(1):xh_test(end),:));
      
    % discrim = fitcdiscr(train(1:xh_test(1)-1,:),label(1:xh_test(1)-1,:));
    % yfit = predict(discrim,train(xh_test(1):xh_test(end),:));
   
    % yfit = predict(Mdl1,train(xh_test(1):xh_test(end),:));
    pred_times_label = yfit.*label(xh_test(1):xh_test(end));  
    pred_times_label(pred_times_label==0) = [];
    pred_times_label(pred_times_label==-1) = 0;  
    correct_ratio(kk-200) = sum(pred_times_label)/length(pred_times_label);  
    % mean(correct_ratio) plot(correct_ratio);

% pnl accumulate
    price_change_pertrain = price_change(xh_test(1):xh_test(end));
    earn = [earn; yfit.*price_change_pertrain];
    
    % csvwrite('yfit_save_random_forest.csv',yfit_save);
end
plot(cumsum(earn));

earn1 = earn; earn1=cumsum(earn1);correct_r1=mean(correct_ratio);  % back test 20 days
earn2 = earn; earn2=cumsum(earn2);correct_r2=mean(correct_ratio);  % back test 30 days
earn3 = earn; earn3=cumsum(earn3);correct_r3=mean(correct_ratio);  % 40
earn4 = earn; earn4=cumsum(earn4);correct_r4=mean(correct_ratio);  % 50
earn5 = earn; earn5=cumsum(earn5);correct_r5=mean(correct_ratio);  % 60
earn6 = earn; earn6=cumsum(earn6);correct_r6=mean(correct_ratio);  % 70
earn7 = earn; earn7=cumsum(earn7);correct_r7=mean(correct_ratio);  % 80
earn8 = earn; earn8=cumsum(earn8);correct_r8=mean(correct_ratio);  % 90
earn9 = earn; earn9=cumsum(earn9);correct_r9=mean(correct_ratio);  % 100
earn10 = earn; earn10=cumsum(earn10);correct_r10=mean(correct_ratio);  % 110
earn11 = earn; earn11=cumsum(earn11);correct_r11=mean(correct_ratio);  % 120
earn12 = earn; earn12=cumsum(earn12);correct_r12=mean(correct_ratio);  % 130
earn13 = earn; earn13=cumsum(earn13);correct_r13=mean(correct_ratio);  % 140
earn14 = earn; earn14=cumsum(earn14);correct_r14=mean(correct_ratio);  % 150
earn15 = earn; earn15=cumsum(earn15);correct_r15=mean(correct_ratio);  % 160
earn16 = earn; earn16=cumsum(earn16);correct_r16=mean(correct_ratio);  % 170
earn17 = earn; earn17=cumsum(earn17);correct_r17=mean(correct_ratio);  % 180
earn18 = earn; earn18=cumsum(earn18);correct_r18=mean(correct_ratio);  % 190

earn_total = [earn1,earn2,earn3,earn4,earn5,earn6,earn7,earn8,earn9,earn10,earn11,earn12,earn13,earn14,earn15, earn16, earn17, earn18];
correct = [correct_r1, correct_r2,correct_r3, correct_r4, correct_r5, correct_r6,correct_r7, correct_r8, correct_r9, correct_r10,correct_r11, correct_r12, correct_r13,correct_r14, correct_r15, correct_r16,correct_r17, correct_r18];
 hold on
 
 hold off
xlabel("number of forcasts")
ylabel("net value")
title("test time span")

legend(["adaboost 3models logi logi lineardis chaos pure train select 0.6515" "adaboost:ordered 0.6532 " "adaboost: ordered mix train_select 0.6527" ])
legend(["linear discriminant 0.6087, max 0.81" "logistic regression 0.6096, max 0.68" "adaboost decision tree 0.6083"  "adaboost original 0.6077, max 0.68" "adaboost classic 0.6144, max 0.66" ])
legend([ "140" "150" "160" "170" "180" "190" ]) 
legend([ "20" "30" "40" "50" "60" "70" ]) 
legend([ "80" "90" "100" "110" "120" "130" ]) 
legend(["20", "120", "130", "170"])

x = 1:length(earn1);
plot(x,earn1,'b',x,earn2,'r',x,earn3,'c',x,earn4,'m',x,earn5, x, earn6);
plot(x, earn7, x, earn8, x, earn9, x,earn10, x,earn11, x,earn12 );
plot(x, earn1, x, earn11, x, earn12, x, earn16);

plot(x,earn13, x, earn14,x, earn15, x, earn16, x, earn17, x, earn18);
plot(x,earn1,'r',x,earn3,'c')
legend(["adaboost original 0.6503" "adaboost classic 70 rounds 0.6463"])