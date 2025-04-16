
function Im = Loadim(x, y, folderPath)
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
    irot_target = x;
    itilt_target = y;

    idx = find(irot_values_tff == irot_target & itilt_values_tff == itilt_target, 1);
    
    if isempty(idx)
        % If file is not found, return 4 blank frames
        fprintf('File with irot_%d and itilt_%d not found. Returning blank frames.\n', irot_target, itilt_target);
        Im = cell(1, 4);  % Return 4 blank frames
        for i = 1:4
            Im{i} = zeros(175, 175);  % Blank image of size 175x175
        end
        return;
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
    end

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

    for i = 1:numFrames
        images_shifted{i} = applyTransformation(images{i}, 0, dx(i), dy(i));
        % Attempt to crop the image
        try
            rect_Crop{i} = imcrop(images_shifted{i}, win);
        catch
            % If an error occurs during cropping, replace with zeros and show a warning
            fprintf('Warning: Invalid input image for cropping at frame %d. Replacing with zeros.\n', i);
            rect_Crop{i} = zeros(175, 175);  % Replace with a zero matrix of size 175x175
        end
        Im{i} = rect_Crop{i};
    end
end

function transformed_image = applyTransformation(image, angle, dx, dy)
    % Apply rotation
    rotated_image = imrotate(image, angle, 'bilinear', 'crop');

    % Apply translation
    translated_image = imtranslate(rotated_image, [dx, dy], 'bilinear');

    transformed_image = translated_image;
end
