
% Folder path where the CSV files are located
folderPath = '/home/shaghparast/Cryo-EM_simulated_data/Particle_stacks_mercator_new/labels_covid_spike/';
load('resval.mat')
% Get the list of CSV files matching the new pattern
csvFiles = dir(fullfile(folderPath, 'rot_*_tilt_*_particles_metadata.csv'));

% Initialize arrays to store irot and itilt values
irotValues = zeros(length(csvFiles), 1);
itiltValues = zeros(length(csvFiles), 1);



% Use regular expressions to extract irot and itilt values
for k = 1:length(csvFiles)
    fileName = csvFiles(k).name;
    irotMatch = regexp(fileName, 'rot_(\d+)_tilt', 'tokens');
    itiltMatch = regexp(fileName, 'tilt_(\d+)_particles_metadata.csv', 'tokens');
    
    if ~isempty(irotMatch) && ~isempty(itiltMatch)
        irotValues(k) = str2double(irotMatch{1}{1});
        itiltValues(k) = str2double(itiltMatch{1}{1});
    else
        error('Filename pattern does not match for file: %s', fileName);
    end
end

% Combine irot and itilt values into a single array for sorting
numbers = [irotValues, itiltValues];
[~, sortedIdx] = sortrows(numbers);
csvFiles_sorted = csvFiles(sortedIdx);

% Initialize cell arrays to store data and labels
maxIrot = max(irotValues);
maxItilt = max(itiltValues);
allData = cell(maxIrot + 1, maxItilt + 1);  % +1 because indexing starts from 0
labels = cell(maxIrot + 1, maxItilt + 1);
length_of_data = zeros(maxIrot + 1, maxItilt + 1);

% Iterate over the sorted list and read each CSV file
for k = 1:length(csvFiles)
    % Get the full path of the CSV file
    csvFilename = fullfile(folderPath, csvFiles_sorted(k).name);
    
    % Detect import options
    opts = detectImportOptions(csvFilename);
    
    % Read the CSV file
    data = readtable(csvFilename, opts);
    
    % Store the data and labels
    irotVal = irotValues(sortedIdx(k));
    itiltVal = itiltValues(sortedIdx(k));
    
    allData{irotVal + 1, itiltVal + 1} = data;
    labels{irotVal + 1, itiltVal + 1} = data.conformation;  % Assuming 'conformation' is a column in the CSV file
    length_of_data(irotVal + 1, itiltVal + 1) = size(data.conformation, 1);
    
    % Clear the data variable for the next iteration
    clear data
end

% Display the irot and itilt values along with the corresponding filenames
for k = 1:length(csvFiles)
    fprintf('File: %s, irot: %d, itilt: %d\n', csvFiles_sorted(k).name, irotValues(sortedIdx(k)), itiltValues(sortedIdx(k)));
end

%% Now sort based on number of particles : 

matrix = length_of_data;

% Get the size of the matrix
[rows, cols] = size(matrix);

% Flatten the matrix and get the sorted indices
[sortedValues, linearIndices] = sort(matrix(:));

% Convert linear indices to row and column indices
[rowIndices, colIndices] = ind2sub(size(matrix), linearIndices);

% Display the sorted values with their corresponding row and column indices
for k = 1:length(sortedValues)
    fprintf('Value: %d, Row: %d, Column: %d\n', sortedValues(k), rowIndices(k), colIndices(k));
end

%% Now load and run

for k=1:length(sortedValues)
 if sortedValues(k)<5
    warning('File empty');
    k=k+1
 else
    % Get list of all TIFF files in the folder
filePattern = fullfile(folderPath, 'irot_*.tif');
tiffFiles = dir(filePattern);

% Extract the numerical parts from the filenames
pattern = 'irot_(\d+)_itilt_(\d+).tif';
irot_values_tff = zeros(length(tiffFiles), 1);
itilt_values_tff = zeros(length(tiffFiles), 1);

for kk = 1:length(tiffFiles)
    tokens = regexp(tiffFiles(kk).name, pattern, 'tokens');
    if ~isempty(tokens)
        irot_values_tff(kk) = str2double(tokens{1}{1});
        itilt_values_tff(kk) = str2double(tokens{1}{2});
    end
end

% Iterate over each TIFF file and find the one that matches the given irot and itilt
irot_target = rowIndices(k)-1; % Example irot value
itilt_target = colIndices(k)-1; % Example itilt value
% Find the index of the matching file
idx = find(irot_values_tff == irot_target & itilt_values_tff == itilt_target, 1);

if isempty(idx)
    error('File with irot_%d and itilt_%d not found', irot_target, itilt_target);
else
    baseFileName = tiffFiles(idx).name;
    fullFileName = fullfile(tiffFiles(idx).folder, baseFileName);
    
    % Display the file being processed
    fprintf('Processing file %s\n', fullFileName);
    
    % Open the TIFF file
    tiffObj = Tiff(fullFileName, 'r');
    
    % Initialize frame count
    numFrames = 0;
    
    % Determine the number of frames
    try
        while true
            tiffObj.setDirectory(numFrames + 1);
            numFrames = numFrames + 1;
        end
    catch
        % When the end of the file is reached, an error will occur,
        % breaking out of the loop.
    end
    
    % Initialize a cell array to store the frames
    images = cell(1, numFrames);
    
    % Loop through the frames
    for i = 1:numFrames
        % Set the directory to the i-th image
        tiffObj.setDirectory(i);
        
        % Read the image data
        images{i} = tiffObj.read();
    end
    
    % Close the TIFF object
    tiffObj.close();
    
 
    % Define the cropping window
    win = centerCropWindow2d([256 256], [175 175]);
    
    % Generate random shifts
    minValue = 0;
    maxValue = 0;
    vectorLength = numFrames;
    dx = randi([0, maxValue - minValue], 1, vectorLength) + minValue;
    dy = randi([0, maxValue - minValue], 1, vectorLength) + minValue;
    
    % Initialize cell array to store shifted and cropped images
    images_shifted = cell(1, numFrames);
    rect_Crop = cell(1, numFrames);
    
    for i=1:numFrames
    images_shifted{i}= applyTransformation(images{i}, 0, dx(i), dy(i));
    rect_Crop{i}=imcrop(images_shifted{i},win);
    end
        num_images = numFrames;
    p = 1;
    for i = 1:num_images
        for j = 1:num_images
            pp{i,j} = [i,j];
            
            i_indices(p) = i;
            j_indices(p) = j;
            
            p = p + 1;
        end
    end
    
    pairwise_mse_matrix = calculatePairwiseMSE(rect_Crop,num_images, i_indices, j_indices);
    mds_MSE = mdscale((pairwise_mse_matrix),30,'Criterion','metricstress');    


    Time=toc
    
    % saving dir
    directory = '/home/shaghparast/Cryo-EM_simulated_data/Results/mercator/';
    filename = [ 'irot_' num2str(rowIndices(k)-1) '_itilt_' num2str(colIndices(k)-1) '_MDS.mat'];
    fullpath = fullfile(directory, filename);

    try
        % Attempt to save the variables to the specified file
        save(fullpath, 'mds_MSE', 'length_of_data', 'labels', 'irot_target', 'itilt_target', 'length_of_data');
    catch ME
        % Display the error message
        fprintf('Error saving file %s: %s\n', fullpath, ME.message);
        % Optionally, you can log the error or take other actions

        continue;  % Skip to the next iteration
    end
    
    
 
    keepVars = {'tiffFiles', 'folderPath','filePattern','sortedValues','rowIndices','colIndices','length_of_data','labels'};

% Get the list of all variables in the workspace
allVars = who;

% Find the variables to clear
varsToClear = setdiff(allVars, keepVars);

% Clear the variables
clear(varsToClear{:});



end
end
end


%% Functions



function images = readImagesFromTIFFStack(stackFilePath, num_images)
    tiffObj = Tiff(stackFilePath, 'r');
    images = {};
    
    % Loop to read images
    for i = 1:num_images
        images{i} = tiffObj.read();
        if tiffObj.lastDirectory()
            break; % Break the loop if the last directory is reached
        else
            tiffObj.nextDirectory();
        end
    end
    
    tiffObj.close();
end


function pairwise_mse_matrix = calculatePairwiseMSE(images, num_images, i_indices, j_indices)
    num_images = round(numel(images));
    pairwise_mse_vector = zeros(1, length(i_indices));

    parfor k = 1:length(i_indices)
        if j_indices(k) > i_indices(k)
            tic;
            pairwise_mse_vector(k) = calculateMinimumMSE(images{i_indices(k)}, images{j_indices(k)});
            elapsed_time = toc;
            disp(['Elapsed time is ', num2str(elapsed_time), ' seconds for each pair ', num2str(100 * num_images / length(i_indices)), ' %' ]);
        end
    end
    
    pairwise_mse_matrix = reshape(pairwise_mse_vector, num_images, num_images);
    pairwise_mse_matrix = pairwise_mse_matrix + pairwise_mse_matrix'; % Make it symmetric
end


function mse_val = calculateMSE(image1, image2)
    % Check if the images have the same size
    if ~isequal(size(image1), size(image2))
        error('The input images must have the same size.');
    end
    mse_val = sum(sum((double(image1) - double(image2)).^2)) / numel(image1);


end

function min_mse_val = calculateMinimumMSE(image1, image2)
    predefined_angles = [-2,-1,0,1,2];  % Predefined rotation angles
    predefined_shifts = [-2,-1,0,1,2];  % Predefined translation shifts
    num_trials = numel(predefined_angles) * numel(predefined_shifts);
    mse_vals = zeros(num_trials, 1);
    
    % Apply all combinations of predefined transformations
    idx = 1;
    for i = 1:numel(predefined_angles)
        for j = 1:numel(predefined_shifts)
            for k=1:numel(predefined_shifts)
                angle = predefined_angles(i);
                dx = predefined_shifts(j);
                dy = predefined_shifts(k);

                % Apply the same fixed transformation parameters to both images
                rotated_translated_image1 = applyTransformation(image1, 0, 0, 0);
                rotated_translated_image2 = applyTransformation(image2, angle, dx, dy);

                % Calculate MSE between the transformed images
                mse_vals(idx) = calculateMSE(rotated_translated_image1, rotated_translated_image2);
                idx = idx + 1;
            end
        end
    end
    
    min_mse_val = min(mse_vals);
end

function transformed_image = applyTransformation(image, angle, dx, dy)
    % Apply rotation
    rotated_image = imrotate(image, angle, 'bilinear', 'crop');
    
    % Apply translation
    translated_image = imtranslate(rotated_image, [dx, dy], 'bilinear');
    
    transformed_image = translated_image;
end

