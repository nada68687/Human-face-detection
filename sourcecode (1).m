clc;
clear;
close all;

[filename, pathname] = uigetfile({'.jpg;.png;*.jpeg'}, 'اختر صورة');
if isequal(filename,0)
    disp('❌ لم يتم اختيار صورة.');
    return;
else
    img = imread(fullfile(pathname, filename));
end

img = imresize(img, [300 300]);
img = imadjust(img, stretchlim(img));


ycbcr = rgb2ycbcr(img);
Cb = ycbcr(:,:,2);
Cr = ycbcr(:,:,3);


skinMask = (Cb >= 77 & Cb <= 127) & (Cr >= 133 & Cr <= 173);
skinMask = medfilt2(skinMask, [5 5]);
skinMask = imfill(skinMask, 'holes');
skinMask = bwareaopen(skinMask, 500);


stats = regionprops(skinMask, 'BoundingBox', 'Area');


imshow(img);
hold on;
faceCount = 0;

if ~isempty(stats)
    for i = 1:length(stats)
        faceBox = stats(i).BoundingBox;
        x = max(1, round(faceBox(1)));
        y = max(1, round(faceBox(2)));
        w = round(faceBox(3));
        h = round(faceBox(4));

        
        x_end = min(size(img,2), x+w-1);
        y_end = min(size(img,1), y+h-1);
        w = x_end - x + 1;
        h = y_end - y + 1;

        if w <= 0 || h <= 0
            continue;
        end

        
        aspectRatio = w / h;
        faceCandidate = img(y:y+h-1, x:x+w-1, :);
        gray = rgb2gray(faceCandidate);
        contrast = std(double(gray(:)));

        
        if aspectRatio >= 0.4 && aspectRatio <= 2.5 && contrast > 25
            rectangle('Position', [x y w h], 'EdgeColor', 'r', 'LineWidth', 2);
            faceCount = faceCount + 1;
        end
    end
    title(['Faces Detected: ', num2str(faceCount)]);
else
    title('No face detected');
end