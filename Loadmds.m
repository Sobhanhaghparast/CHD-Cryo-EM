function [outputArg1,outputArg3,outputArg4] = Loadmds(folder_path)
% List all .mat files in the folder
mat_files = dir(fullfile(folder_path, '*.mat'));


% Loop through each .mat file
for k = 1:length(mat_files)
    % Get the filename
    file_name = mat_files(k).name;
    
    % Use regular expressions to extract irot and itilt values from the filename
    tokens = regexp(file_name, 'irot_(\d+)_itilt_(\d+)_MDS\.mat', 'tokens');
    
    % If tokens are found, add the pair and file path to the respective cell arrays
    if ~isempty(tokens)
        irot_value = str2double(tokens{1}{1});
        itilt_value = str2double(tokens{1}{2});
        
        % Store the pair of (itilt, irot) and the corresponding file path
        pairs{k} = [itilt_value, irot_value];
        file_paths{k} = fullfile(folder_path, file_name); % Full file path
        
    end
end


%% Bug fix:


f=1;
for i=1:length(pairs)
    f=f+1;
    irot_target=pairs{1,i}(2);
    itilt_target=pairs{1,i}(1);
    desired_filename = sprintf('irot_%d_itilt_%d_MDS.mat', irot_target, itilt_target);
    desired_file_path = fullfile(folder_path, desired_filename);  % Create the full path of the specific pair
    load(desired_file_path)
    
    MDS_total{irot_target+1,itilt_target+1}=mds_MSE;
 
     
    keepVars = {'f','explained_ISO_total','mappedX_total','explained_MDS_total','filtered_indices','tiffFiles', 'folder_path','filePattern','pairs','length_of_data','labels','MDS_total'};

    % Get the list of all variables in the workspace
    allVars = who;
    
    % Find the variables to clear
    varsToClear = setdiff(allVars, keepVars);
    
    % Clear the variables
    clear(varsToClear{:});

end

outputArg1 = MDS_total;
outputArg3 = pairs;
outputArg4 = labels;

end

