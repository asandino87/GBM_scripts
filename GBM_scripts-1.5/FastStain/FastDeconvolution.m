% Stain Normalization

% Clear all previous data
% clc, 
% clear, 
% close all;
% 
% path = '.\Deconvolve\';
% 
% addpath(path);
% mex .\Deconvolve\colour_deconvolution.c;

%% Load input & reference image


function []=FastDeconvolution(path,destpath)

% ImRef: Reference Image

readfolder=dir(strcat(path,'*.jpg'));


    for numsample = 1:size(readfolder,1)

        % Read Image filename
        filename = readfolder(numsample).name;     
        % Read Image
        ImSample = importdata([path,filename]);    
        % Normalized image (Function faststain)
        [ ~, ~, E, ~, ~ ] = Deconvolve(ImSample, [], 0 );
        ImOut = E;
        % Save image
        imwrite(ImOut,[destpath,filename]);
        %disp(numsample)

    end
    

end


% path_dir='C:\Users\Andres\Desktop\PatchesGBM\test11\CT\';
% 
% read_folder=dir(strcat(path_dir,'*.jpg'));
% 
% i=1;
% 
% filename = read_folder(i).name;
% im1=imread([path_dir,filename]);
% 
% [ ~, H, E, Bg, ~ ] = Deconvolve( im1, [], 0 );
% 
% figure, imshow(E,[])
% 
% a=0;


