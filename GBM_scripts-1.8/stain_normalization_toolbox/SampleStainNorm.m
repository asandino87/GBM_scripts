% Stain Normalization

% Clear all previous data
clc, 
clear, 
close all;

%path = '.\stain_normalization_toolbox\';

addpath(path);
mex colour_deconvolution.c;

%% Load input & reference image

path_dir='C:\Users\Andres\Desktop\PatchesGBM\test11\HB\';

read_folder=dir(strcat(path_dir,'*.jpg'));

%for i=1:size(read_folder,1)
 for i=1:50

    filename = read_folder(i).name;
    
    im1=imread(['C:\Users\Andres\Desktop\PatchesGBM\test11\HB\',filename]);
    [ ~, H, E, Bg, ~ ] = Deconvolve( im1, [], 0 );
    figure();
    imshow(E,[]);
    a=0;
    
    
    %dest_path = 'C:\Users\Andres\Desktop\PatchesGBM\test11\CTnorm4\';
    
    %NormalizeSamples(im1,dest_path,filename)

end

% filename = read_folder.name[i];


% filename = 'W1-1-2-X.1.01_2_HB.jpg';




function [] = NormalizeSamples(im1,dest_path,filename)

imwrite(im1,'SampleImg.jpg')
%Source = 'sample100.jpg';
Source = 'SampleImg.jpg';
%img_src = imread(Source);
% ref=imread('Ref4.jpg');

fid = fopen( 'filename.txt', 'w+' );
fprintf(fid, '%s\n', Source);
fclose(fid);

% 
% if exist('normalised/', 'dir') == 7
%     rmdir('normalised', 's');
% end
% 
% if exist('normalised/', 'dir')==0
%     mkdir('normalised/');
% end

% dos(['ColourNormalisation.exe BimodalDeconvRVM filename.txt', ...
%     ' Ref2.png HE.colourmodel']);

dos(['ColourNormalisation.exe BimodalDeconvRVM filename.txt', ...
    ' Ref.png HE.colourmodel']);


clc;
% pause(4);
NormDM = imread(['.\normalised\', Source]);


imwrite(NormDM,[dest_path,filename])

% figure, 
% subplot(1,3,1);
% imshow(img_src,[]);
% title('Source');
% subplot(1,3,2);
% imshow(ref,[]);
% title('Reference');
% subplot(1,3,3);
% imshow(NormDM,[]);
% title('Normalization');

end