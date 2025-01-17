%%%%%%%%%
% Fecha creaci�n: 9/Nov/2019
% Fecha modificado: 11/Abr/2020
% Abrir archivos WSI y extraer parches cuadrados
% Nota: 1mm de imagen de histo equivale a 2000 pix en la imagen original
% Nota: la imagen original est� en im_in=imread(file_name);
%%%%%%%%%%

clc;
clear;
close all;

%% Main 

path_dir='C:\Users\Andres\Downloads\WSI\test\';

read_folder=dir(strcat(path_dir,'*.jpg'));


for num_case=1:size(read_folder,1) % Testing

    
    disp('***************');
    disp(['Caso numero ',num2str(num_case)])
    disp('***************');
    
    file_name=read_folder(num_case).name; 
    file_name=file_name(1:size(file_name,2)-4);
    info_patches=croppatches(file_name,path_dir);
    
    table_patches(num_case,:)=[file_name,info_patches(:,2)'];

    Name = table_patches(:,1);
    LE = table_patches(:,2);
    IT = table_patches(:,3);
    CT = table_patches(:,4);
    NE = table_patches(:,5);
    HB = table_patches(:,6);
    PC = table_patches(:,7);
    MV = table_patches(:,8);
    
    info_paches=table(Name,LE,IT,CT,NE,HB,PC,MV);
  
    writetable(info_paches,'C:\Users\Andres\Desktop\prueba2\TablePatches3.xlsx','Sheet','test');

end

disp("The process has ended")

%% Function Crop patches

function [info_patches]=croppatches(subblock_id,path_dir_wsi)


path_dir_segmentation='C:\Users\Andres\Downloads\SG\test\';

% wsi: Whole Slide Image || wsi_SG: Whole Slide Image Segmentation
wsi=importdata([path_dir_wsi,subblock_id,'.jpg']);
wsi_SG=importdata([path_dir_segmentation,'SG_',subblock_id,'.jpg']);

% Scale factor
scale=2; 

% Scaled Images (WSI and Feature Annotation)
% scaled_wsi = imresize(wsi,1/scale);
scaled_wsi_SG = imresize(wsi_SG,1/scale);

for ind=1:7
    
    coord=[];
%     path_region=[];
    
    switch ind

        case 1 % Leading Edge

            region = 'LE';
            LEr = double(scaled_wsi_SG(:,:,1)==33 & scaled_wsi_SG(:,:,2)==143);
            
            stride=224;
            [~,coord] = crop_patches(LEr,scale,stride);
            

        case 2 % Infiltrating Tumor (IT)

            region = 'IT';
            ITr=double(scaled_wsi_SG(:,:,1)==210 & scaled_wsi_SG(:,:,2)==5);
            
            stride=224;
            [~,coord] = crop_patches(ITr,scale,stride);
            
        case 3 % Celular Tumor (CT)

            region = 'CT';            
            CTr=double(scaled_wsi_SG(:,:,1)==5 & scaled_wsi_SG(:,:,2)==208);
            
            stride=224;
            [~,coord] = crop_patches(CTr,scale,stride);

        case 4 % Necrosis (NE)

            region = 'NE';
            NEr=double(scaled_wsi_SG(:,:,1)==5 & scaled_wsi_SG(:,:,2)==5);
            
            stride=224;
            [~,coord] = crop_patches(NEr,scale,stride);
            
        case 5 % Hyperplastic blood vessels (HBV)

            region = 'HB'; 
            HBr=double(scaled_wsi_SG(:,:,1)==255 & scaled_wsi_SG(:,:,2)==102);
            
            stride=224;   
            [~,coord] = crop_patches(HBr,scale,stride);
            
        case 6 % Pseudopalisading cells

            region = 'PC';
            
            stride=224;
            
            % Pseudopalisading cells around necrosis (CTpan)
            PCran=double(scaled_wsi_SG(:,:,1)==6 & scaled_wsi_SG(:,:,2)==208);
            [~,coord_an] = crop_patches(PCran,scale,stride); 
%             [PCran_maskcoord,coord_an] = crop_patches(PCran,scale,stride); 
            
            % Pseudopalisading cells but no visible necrosis (CTpnn)
            PCrnn=double(scaled_wsi_SG(:,:,1)==6 & scaled_wsi_SG(:,:,2)==4);
            [~,coord_nn] = crop_patches(PCrnn,scale,stride);  
%             [PCrnn_maskcoord,coord_nn] = crop_patches(PCrnn,scale,stride);  
            
            %maskcoord = PCrnn_maskcoord | PCran_maskcoord;
            coord=[coord_an;coord_nn];

            
        case 7 % Microvascular

            region = 'MV';
            MVr=double(scaled_wsi_SG(:,:,1)==255 & scaled_wsi_SG(:,:,2)==51);
            
            stride=224;
            [~,coord] = crop_patches(MVr,scale,stride);
            
    end
    
     
    %%%% Saving Patches
    path_region = ['C:\Users\Andres\Desktop\test7\',region,'\'];
    save_patches(wsi,coord,scale,path_region,subblock_id,region) 
    
    info_patches{ind,2}=size(coord,1);
    info_patches{ind,1}=region;
    
    
    clear coord path_region
    
end

TableInfoPatches=table(info_patches(:,1),info_patches(:,2));


disp('------------------------');
disp('Number of extracted patches');
disp(TableInfoPatches)
disp(['from: ',subblock_id,' at ',num2str(scale)]);
disp('------------------------');

end

% FIN DEL C�DIGO


%% Other Functions

function im_out=graph_grid(im_in,patchsize,esc,color)


[m,n] = size(im_in);

% tam_vent=200;    % El tama�o real es 10 veces m�s (2000 pix)
winsize=patchsize/esc;

col=floor(n/winsize);
row=floor(m/winsize);

im_in=imcrop(im_in,[1 1 winsize*col-1 winsize*row-1]);
% figure(1);
im_out=imshow(im_in,[],'InitialMagnification','fit');

hold on;

    for j=1:col

        % Grafica lineas verticales
        y=[1 m];
        x=[j*winsize j*winsize];
        hold on; plot(x,y,color);

    end

    for i=1:row
        % Grafica lineas horizontales
        x=[1 n];
        y=[i*winsize i*winsize];
        hold on; plot(x,y,color);
    end

end

%%

function [maskcoord,coord] = crop_patches(mask,scale,stride)

% OUT: [maskcoord: BW image , coord: patches coordinates]

win_size=224/scale;
stride_size=stride/scale;


rows=floor(size(mask,1)/win_size);
cols=floor(size(mask,2)/stride_size);

maskcoord=zeros(size(mask,1),size(mask,2));

index=0; % BEgin index with 0
coord=[];

    for i=1:rows

        for j=1:cols


            mask_crop=imcrop(mask,[(j-1)*stride_size+1 (i-1)*win_size+1 win_size-1 win_size-1]);
           
            calc_area=sum(mask_crop(:));
            porcentaje=(calc_area/(win_size*win_size))*100;

            % Tissue Percentage

            % tenia esto en 95
            if porcentaje>95
                index=index+1;

                % Extracts patch coordinates

                coord(index,:)=[(i-1)*win_size+1 (j-1)*stride_size+1];
                % Build a mask with squared patches that will be extracted
                maskcoord(coord(index,1):coord(index,1)+win_size-1,coord(index,2):coord(index,2)+win_size-1)=1;

            end

        end
    end
    
    % Garantiza que la mascara de segmentaci�n tenga el mismo tama�o a la
    % entrada y la salida
    maskcoord=imcrop(maskcoord,[1 1 size(mask,2)-1 size(mask,1)-1]);

%     a=0;
    
    
end


%%

function [] = save_patches(wsi,coord,scale,path,sub_block,region)

win_size = 224/scale;

    for i=1:size(coord,1)

        % Recuerde que _CT/_Ot depende de la carpeta

        patch=imcrop(wsi,[coord(i,2)*scale coord(i,1)*scale win_size*scale-1 win_size*scale-1]);
        name=[sub_block,'_',num2str(i),'_',region,'.jpg']; %%%% CAMBIAR ESTO (OJO!!!)

        imwrite(patch,strcat(path,name),'jpg');

    end

end
