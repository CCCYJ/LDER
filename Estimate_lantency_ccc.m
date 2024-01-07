function lantency = Estimate_lantency_ccc(template,data)
% sliding window to define
sliding = 1; %time-points
sliding_num = (size(data,2)-(size(template,2)))/(sliding);

for k=1:fix(sliding_num)
    
    sliding_window = ((k-1)*sliding+1):(((k-1)*sliding)+size(template,2));
    sample_data = data(:,sliding_window);
    %caculate GFP
    for i=1:size(template,2)
        GFP_ori = 0;
        GFP_template_ori = 0;
        
        vol_mean = mean(sample_data(:,i));
        vol_mean_template = mean(template(:,i));
        
        for j = 1:size(sample_data,1)
            GFP_train = (sample_data(j,i)-vol_mean)^2;
            GFP_template = (template(j,i)-vol_mean_template)^2;
            
            GFP_ori = GFP_ori+GFP_train;
            GFP_template_ori = GFP_template+GFP_template_ori;
        end
        GFP_ori = sqrt(GFP_ori/size(sample_data,1));
        GFP_samp(i) = GFP_ori;
        
        GFP_template_ori = sqrt(GFP_template_ori/size(sample_data,1));
        GFP_samp_template(i) = GFP_template_ori;
    end
    %caculate GMD
    for i=1:size(template,2)
        
        vol_mean = mean(sample_data(:,i));
        vol_mean_template = mean(template(:,i));
        GMD_total = 0;
        
        for j = 1:size(sample_data,1)
            
            GMD = ((sample_data(j,i)-vol_mean)/GFP_samp(i)-(template(j,i)-vol_mean_template)/GFP_samp_template(i))^2;
            GMD_total = GMD_total+GMD;
        
        end
        
        GMD_t(i) = GMD_total/size(sample_data,1);
    end
    
    GMD_sum(k) = sum(GMD_t);
end
[~,position] = min(GMD_sum);    

% output
lantency = position;
end