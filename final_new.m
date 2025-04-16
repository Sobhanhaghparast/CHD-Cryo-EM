%% Goal correct a 5 x 5 matrix
folder_path = '/home/shaghparast/Cryo-EM_simulated_data/Results_old_sim/mercator';
folderPath = '/tudelft.net/staff-umbrella/Cryo EM Continuous heterogeneity/20240507_fullSO3_500ugraph/particle_stacks_mercator';
%% Load mds
[MDS_All,Rot_tilt,Labels] = Loadmds(folder_path)

%% Gen rule 4xNxN first two coumns ref 
irange=31:33;
jrange=14:16;
subplotrangei=max(irange)-min(irange)+1
subplotrangej=max(jrange)-min(jrange)+1
ruled_indices_H = genrule(irange, jrange,'horizontal');
ruled_indices_V = genrule(irange, jrange,'vertical');

% Initialize default pcx
default_pcx = 1;

for i=1:length(ruled_indices_H)
    % Calculate horizontal and vertical polarity swap decisions
    [swap_decision_H(ruled_indices_H(i,1),ruled_indices_H(i,2)), ...
     decision_value_H(ruled_indices_H(i,1),ruled_indices_H(i,2))] = ...
         polswap(ruled_indices_H(i,1:2),ruled_indices_H(i,3:4), MDS_All, folderPath,1,1);

    [swap_decision_V(ruled_indices_V(i,1),ruled_indices_V(i,2)), ...
     decision_value_V(ruled_indices_V(i,1),ruled_indices_V(i,2))] = ...
         polswap(ruled_indices_V(i,1:2),ruled_indices_V(i,3:4), MDS_All, folderPath,1,1);
end


save
%% Now, swap_decision_H is swH and swap_decision_V is swV predict the arrow matrix
swH = swap_decision_H(min(irange):max(irange),min(jrange):max(jrange)-1)
swV = swap_decision_V(min(irange):max(irange)-1,min(jrange):max(jrange))

swH(swH==1)=-1
swV(swV==1)=-1
swH(swH==0)=1
swV(swV==0)=1
figure,subplot(1,2,1),imshow(swH),title('H'), subplot(1,2,2),imshow(swV),title('V')

%% Load and show the latent 
k=1
for i = irange
    for j = jrange
            [LP{i,j},~,~]=MDS_out(MDS_All{i, j},Loadim(i-1,j-1,folderPath),1,1);

    end
end
k=1
for i = irange
    for j = jrange
            subplot(subplotrangei,subplotrangej,k),scatter(LP{i,j},zeros(1,length(LP{i,j})),30,(Labels{i,j}),'o'),
           % subplot(subplotrangei,subplotrangej,k),scatter3(MDS_All{i,j}(:,1),MDS_All{i,j}(:,2),MDS_All{i,j}(:,3),30,(Labels{i,j}),'filled'),
            axis equal
            ylim([-0.01 0.01])
            xlim([-0.5 0.5])
            %             ylim([-0.5 0.5])
            % zlim([-0.5 0.5])

% set(gca, 'XTickLabel', []);
% 
% % Remove Y-axis tick labels
% set(gca, 'YTickLabel', []);
% 
% % Remove Z-axis tick labels (for 3D plots)
%  set(gca, 'ZTickLabel', []);
            colormap("jet")
            %title(['DvV= ' num2str(decision_value_V(i,j), '%.3f') 'DvH= ' num2str(decision_value_H(i,j), '%.3f')] )
            k=k+1;
    end
end

%% Predict the arrows
num_it=20
[regenerated] = regen_polm(swH,swV,36,num_it);
figure,
imshow(regenerated)
apply_flipsm(regenerated, swH, swV);


%% Apply the flip

[row,col]=find(regenerated==-1)
rowc =row +irange(1)-1
colc=col+jrange(1)-1

LP_new=LP;
for i = 1:length(rowc)
    
ind=[rowc(i), colc(i)]
        current_values = LP{ind(1),ind(2)};
        max_value = max(current_values(:));  % Get the maximum value in the matrix
        mean_value = mean(max_value - current_values(:));  % Calculate the mean of the differences

        % Update LPnew based on the condition
        LP_new{ind(1),ind(2)} = max_value - current_values - mean_value;

    end



 %% plot the corrected
% 



k=1
for i = irange
    for j = jrange
            sizer=size(LP_new{i,j});
            if sizer(2)>1
                k=k+1;
                break
            end
            subplot(subplotrangei,subplotrangej,k),scatter(LP_new{i,j},zeros(1,length(LP_new{i,j})),30,(Labels{i,j}),'o'),
            ylim([-0.01 0.01])
            xlim([-0.5 0.5])
            colormap("jet")
            k=k+1;
    end
end

%%
LP_new=LP;
 Labels=labels;
% % Initialize a 36x36 grid for RGB image
rgb_image = zeros(36, 36, 3);
bc=0;,rc=0;,yc=0;,kc=0;,rcp=0;,bcp=0;
for i = irange
    for j = jrange
        sizer = size(LP_new{i,j});
        
        % Check the conditions for yellow or black
        if sizer(2) > 1
            rgb_image(i,j,:) = [0, 0, 0]; % Yellow
            yc=yc+1;
            M(i,j)="K";
            continue;
        elseif sizer(1) < 30
            rgb_image(i,j,:) = [1, 1, 0]; % Black
            kc=kc+1;
            M(i,j)="Y"
            continue;
        end
        
        % Sort LP_new{i,j} and Labels{i,j} together based on LP_new
        [sorted_LP, sort_index] = sort(LP_new{i,j});
        sorted_labels = Labels{i,j}(sort_index);
        
        % Calculate indices for the first and last 20%
        num_points = length(sorted_LP);
        first_20_percent = 1:round(0.03 * num_points);
        last_20_percent = round(0.97 * num_points):num_points;
        
        % Get the corresponding sorted labels for the first and last 20%
        first_20_labels = sorted_labels(first_20_percent);
        last_20_labels = sorted_labels(last_20_percent);
        
        % Calculate the average label values for first and last 20%
        avg_first_20 = mean(first_20_labels);
        avg_last_20 = mean(last_20_labels);
        
        % Determine sorting direction based on average labels
        if avg_last_20 > avg_first_20
            rgb_image(i,j,:) = [1, 0.2, 0.2]; % Red for 'R'
            rc=rc+1;
            rcp=rcp+length(LP_new{i,j});
            M(i,j)="R"
        else
            rgb_image(i,j,:) = [0.2, 0.2, 1]; % Blue for 'B'
            bc=bc+1;
            bcp=bcp+length(LP_new{i,j});
            M(i,j)="B"

        end
    end
end

% Display the RGB image
imshow(rgb_image);
matching_ratio_pixelwise=rc/(rc+bc)
matching_ratio_particlewise=rcp/(rcp+bcp)


%% create a folder and save as CSV file

% Define the folder name
folder_name = 'LP_new_CSVs';

% Create the folder if it doesn't exist
if ~exist(folder_name, 'dir')
    mkdir(folder_name);
end

% Loop through each cell in the 36x36 grid
for i = 1:36
    for j = 1:36
        % Extract the data from the current cell
        data = LP_new{i, j};
        
        % Create the filename based on the row and column indices
        filename = sprintf('R_%02d_C_%02d.csv', i, j);
        
        % Define the full file path
        file_path = fullfile(folder_name, filename);
        
        % Save the data to the CSV file
        csvwrite(file_path, data);
    end
end


%%

% Define the filename for the CSV file
csv_filename = 'polarity.csv';

% Convert the string matrix to a cell array
cell_matrix = cellstr(M);

% Write the cell array to a CSV file
writecell(cell_matrix, csv_filename);
