function [ch_status,ch_status_desc]=status_and_description(metadata)

ch_label = metadata.ch_label                         ;
ch2use_included = metadata.ch2use_included; 
ch2use_silicon = metadata.ch2use_silicon;
% in some patients in some files an extra headbox is included in a later
% stadium because an EMG-recording was necessary (for example).
% if size(metadata.ch2use_included,1) < size(metadata.ch_label,1)
%     ch2use_included = zeros(size(ch_label));
%     ch2use_included(1:size(metadata.ch2use_included,1)) =  metadata.ch2use_included;
%     ch2use_included = logical(ch2use_included);
%     ch2use_silicon = zeros(size(ch_label));
%     ch2use_silicon(1:size(metadata.ch2use_silicon,1)) = metadata.ch2use_silicon;
%     ch2use_silicon = logical(ch2use_silicon);
%     
% elseif size(metadata.ch2use_included,1) == size(metadata.ch_label,1)
%     ch2use_included = metadata.ch2use_included;
%     ch2use_silicon = metadata.ch2use_silicon;
% elseif size(metadata.ch2use_included,1) > size(metadata.ch_label,1)
%     ch2use_included =  metadata.ch2use_included(1:size(metadata.ch_label,1));
%     ch2use_included = logical(ch2use_included);
%     ch2use_silicon = metadata.ch2use_silicon(1:size(metadata.ch_label,1));
%     ch2use_silicon = logical(ch2use_silicon);
%     
% end

ch_status                                                       = cell(size(ch2use_included))      ;
ch_status_desc                                                  = cell(size(ch2use_included))      ;

idx_ecg                                                         = ~cellfun(@isempty,regexpi(ch_label,'ECG'));
idx_ecg                                                         = idx_ecg                                  ;
idx_mkr                                                         = ~cellfun(@isempty,regexpi(ch_label,'MKR'));
idx_mkr                                                         = idx_mkr                                  ;
% channels which are open but not recording
ch_open                                                         = ~(ch2use_included | ...
    metadata.ch2use_bad      | ...
    ch2use_silicon  | ...
    idx_ecg                  | ...
    idx_mkr                    ...
    )                                       ;
%     metadata.ch2use_cavity   | ...

[ch_status{:}]                                                  = deal('good')                              ;

if(any(metadata.ch2use_bad              ...
        )) % removed metadata.ch2use_cavity  | ...
    
    [ch_status{(metadata.ch2use_bad     ...
        )}] = deal('bad'); % removed metadata.ch2use_cavity  | ...
end

% bad in high frequency band
if(any(metadata.ch2use_badhf)) % removed metadata.ch2use_cavity  | ...
    
    [ch_status{(metadata.ch2use_badhf     ...
        )}] = deal('bad_hf'); % removed metadata.ch2use_cavity  | ...
end

if (any(ch_open))
    [ch_status{ch_open}] = deal('bad');
end

%% status description
if(any(ch2use_included))
    [ch_status_desc{ch2use_included}] = deal('included');
end

if(any(metadata.ch2use_bad))
    [ch_status_desc{metadata.ch2use_bad}] = deal('noisy (visual assessment)');
end

if(any(metadata.ch2use_badhf))
    if strcmp(metadata.ch2use_badhf.note,'NB BadHF annotated in avg')
        [ch_status_desc{metadata.ch2use_badhf}] = deal('noisy in high frequency bands >80Hz&<500 Hz(visual assessment). Please note, BadHF was annotated in avg!');
    else
        [ch_status_desc{metadata.ch2use_badhf}] = deal('noisy in high frequency bands >80Hz&<500 Hz(visual assessment)');
    end
end

% if(any(metadata.ch2use_cavity))
%     [ch_status_desc{metadata.ch2use_cavity}] = deal('cavity');
% end
%
% silicon information not in channels.tsv but in electrodes.tsv
% if(any(metadata.ch2use_silicon))
%     [ch_status_desc{metadata.ch2use_silicon}] = deal('silicon');
% end

if(any(ch_open))
    [ch_status_desc{ch_open}] = deal('not recording');
end

if(sum(idx_ecg))
    [ch_status_desc{idx_ecg}] = deal('not included');
end
if(sum(idx_mkr))
    [ch_status_desc{idx_mkr}] = deal('not included');
end