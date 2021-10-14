function elecmatrix=sortElectrodes(tb_elecs,cfg)
%   Created by:
%
%     Copyright (C) 2009  D. Hermes, Dept of Neurology and Neurosurgery, University Medical Center Utrecht
%     Copyright (C) 2019  D. van Blooijs, Dept of Neurology and Neurosurgery, University Medical Center Utrecht
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

%   Version 1.1.0, released 26-11-2009%

% DH - fixed bug with waitforbuttonpress Matlab version > 2007
% DvB - made it BIDScompatible September 2019

%% load electrodes file

[data1.elecName]=spm_select(1,'image','Select image with electrodes (electrodes1.img)',[],cfg.deriv_directory);
data1.elecStruct=spm_vol(data1.elecName);
% from structure to data matrix
data1.elec=spm_read_vols(data1.elecStruct);
[x,y,z]=ind2sub(size(data1.elec),find(data1.elec>1.5));
% from indices 2 native
data1.elecXYZ=([x y z]*data1.elecStruct.mat(1:3,1:3)')+repmat(data1.elecStruct.mat(1:3,4),1,length(x))';


%%
temp.X=data1.elecXYZ(:,1);
temp.Y=data1.elecXYZ(:,2);
temp.Z=data1.elecXYZ(:,3);

figure;
plot3(temp.X,temp.Y,temp.Z,'.','MarkerSize',20);
hold on;
h=datacursormode;

%%
% startckeck=0;
% disp('specify total number of electrodes')
% r=input('');
% totalnrElec=r;
totalnrElec=size(tb_elecs,1);

% % check whether total number of electrodes matches total number in electrodes.tsv
% if totalnrElec == numel(find(strcmp(tb_elecs.group,'other')==0))
%     disp('Total number of electrodes is in agreement with total number of electrodes in electrodes.tsv')
% else
%     disp('ERROR: mismatch between mentioned number of electrodes and electrodes in electrodes.tsv!')
% end

elecmatrix=zeros(totalnrElec,3);
fprintf('Total number of electrodes is %d\n',numel(find(strcmp(tb_elecs.group,'other')==0)))

elecNr=1;
disp('press 1 to start')
r=input('');
if r==1
    while elecNr<=totalnrElec
        if strcmp(tb_elecs.group(elecNr),'other') % when electrode is not part of ECoG/SEEG
            elecmatrix(elecNr,:) = NaN;
            elecNr = elecNr+1;
        else % when the electrode is on ECoG/SEEG
            disp(['select electrode ' tb_elecs.name{elecNr} ' and press enter'])
            
            next_el=input('');
            if isempty(next_el) % pressed enter
                info_struct = getCursorInfo(h);
                if elecNr>1 % if second click, check whether ok
                    if ismember(info_struct.Position,elecmatrix,'rows')
                        disp('same position as a previous electrode, try again');
                    else
                        elecmatrix(elecNr,:)=info_struct.Position;
                        disp(['electrode ' tb_elecs.name{elecNr} ' position ' int2str(elecmatrix(elecNr,:))]);
                        %                     plot3(info_struct.Position(1),info_struct.Position(2),info_struct.Position(3),'r.','MarkerSize',20);
                        text(info_struct.Position(1)*1.01,info_struct.Position(2)*1.01,info_struct.Position(3)*1.01,tb_elecs.name{elecNr},'FontSize',12,'HorizontalAlignment','center','VerticalAlignment','middle')
                        elecNr=elecNr+1;
                    end
                else % first click, always add an electrode
                    elecmatrix(elecNr,:)=info_struct.Position;
                    disp(['electrode ' int2str(elecNr) ' position ' int2str(elecmatrix(elecNr,:))]);
                    %                 plot3(info_struct.Position(1),info_struct.Position(2),info_struct.Position(3),'r.','MarkerSize',20);
                    text(info_struct.Position(1)*1.01,info_struct.Position(2)*1.01,info_struct.Position(3)*1.01,tb_elecs.name{elecNr},'FontSize',12,'HorizontalAlignment','center','VerticalAlignment','middle')
                    elecNr=elecNr+1;
                end
            end
        end
    end
end

name = tb_elecs.name;

%% save electrode matrix
pathname = cfg.saveFile;
save(pathname,'name','elecmatrix');

% outputdir= spm_select(1,'dir','select directory to save locations matrix');
% 
% for filenummer=1:100
%     outputnaam=strcat([outputdir 'electrodes_loc' int2str(filenummer) '.mat' ]);
%     if ~exist(outputnaam,'file')>0
%         disp(strcat(['saving ' outputnaam]));
%         save(outputnaam,'elecmatrix');
%         break
%     end
% end


