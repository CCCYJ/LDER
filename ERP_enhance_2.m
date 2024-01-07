

% open EEGLAB
% load the sample data first 
for i = 1:59
% Parameter
cfg = [];

cfg.selected_elec = getfield(EEG.chanlocs,{1,i});
cfg.selected_elec = string(cfg.selected_elec.labels);
cfg.epoch_twd = [-100,1000];% in millisecond
cfg.base_twd = [-100,0];
cfg.resync_twd = [200,600];
% choose your number and fill it
cfg.selected_marker = {'9'}; % '5'or '9'     5 represents the non-target  9 represents the target choose your number 
cfg.non_selected_marker = {'9'}; % '5'or '9'
cfg.glb = 1;
EEG = reConstruct_ccc_2(EEG,cfg);
data_resync(i,:) = EEG.ReSync{1, i}.resync_data;  
end

