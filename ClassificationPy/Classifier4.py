# -*- coding: utf-8 -*-
"""
Created on Thu Nov 12 19:30:36 2020

@author: Andres
"""
#%%

#import PIL
import math
import cv2 as cv
import numpy as np
from matplotlib import pyplot as plt
from PIL import Image
Image.MAX_IMAGE_PIXELS = None

#%%

from ClassifierUtils import scaled_wsi, wsiregion, grtrpixelmask
from ClassifierUtils import pixtomask

path='/home/usuario/Descargas/'
path_SG='/home/usuario/Descargas/'

filename='298766898_1.jpg'
#filename='W5-1-1-N.2.01_0002_PC.jpg'

scale=2
th=0.5
patchsize=224



scaled_WSI = scaled_wsi(path,filename,scale)
#scaled_WSI_SG = scaled_wsi(path_SG,'SG_'+filename,scale)
scaled_WSI_SG = scaled_wsi(path_SG,filename,scale)

#%%

# Selecting 
#NEr=wsiregion(scaled_WSI_SG,ch1=5,ch2=5)
#CTr=wsiregion(scaled_WSI_SG,ch1=5,ch2=208)
NEr=np.uint16(scaled_WSI_SG[:,:,0]<245)
CTr=np.uint16(scaled_WSI_SG[:,:,0]<245)


# Create groundtruth mask
(imheigth,imwidth,x)=np.shape(scaled_WSI)
grtr_mask=np.zeros((imheigth,imwidth))

grtr_mask[NEr==1]=1
grtr_mask[CTr==1]=2


[NEr_pix,NEcoordpix,NEcoord]=grtrpixelmask(NEr,
                                            patchsize,
                                            scale,
                                            th=th)
        
[CTr_pix,CTcoordpix,CTcoord]=grtrpixelmask(CTr,
                                            patchsize,
                                            scale,
                                            th=th)

grtr_mask_pix=np.zeros((np.shape(CTr_pix)))
grtr_mask_pix[NEr_pix==1]=1
grtr_mask_pix[CTr_pix==1]=2

plt.imshow(grtr_mask_pix,cmap='gray')

#%% Prediction

import tensorflow.keras as keras

dir='C:/Users/Andres/Desktop/GBM_Project/Experiments/CNN_Models/Model_CRvsNE.h5'
model=keras.models.load_model(dir)

#%%
coord_array=np.array(NEcoord+CTcoord)
#coord_array=np.array(CTcoord)

prediction_list=[]

WSI = Image.open(path + filename)

#%%

from tqdm import tqdm

for i in tqdm(range(np.shape(coord_array)[0])):
#for i in range(200,2000):
    
    top=coord_array[i,0]
    left=coord_array[i,1]
    
    # Extracting patch from original WSI
    
    # im1 = im.crop((left, top, right, bottom))
    WSIpatch=WSI.crop((left,top,left+patchsize,top+patchsize))
    WSI_patch_array=np.array(WSIpatch)
    WSI_patch_array_norm = WSI_patch_array/255 
    
    # Expand 
    WSI_patch_array_norm=np.expand_dims(WSI_patch_array_norm, axis=0)
    predict_value=model.predict(WSI_patch_array_norm)
    
    prediction_list.append(np.argmax(predict_value))

#%%
pred_mask_pix=np.zeros((np.shape(CTr_pix)))

coordpix=np.array(NEcoordpix+CTcoordpix)
#coordpix=np.array(CTcoordpix)

#%%

for ind in range(np.shape(coordpix)[0]):
    print(ind)
    rowx,colx = coordpix[ind]        
    pred_mask_pix[rowx,colx]=prediction_list[ind]+1

#%%
plt.imshow(pred_mask_pix)

# Convierte la máscara de pixeles en una de tamaño original
patchsize=224

pp1=pixtomask(pred_mask_pix,CTr,patchsize)
pp2=pixtomask(grtr_mask_pix,CTr,patchsize)

zz=np.int16(pp1>0.5)

#%%

def smoothmask(imin):
    
    ResizedMask = cv.resize(imin,(np.shape(pred_mask_pix)[1]*4,np.shape(pred_mask_pix)[0]*4),
                       interpolation = cv.INTER_AREA)
    BlurredMask = cv.GaussianBlur(ResizedMask, (5,5),8)
    ModifiedMask = np.uint16(BlurredMask>0.5)
    return ModifiedMask
    
imA=smoothmask(np.int16(pred_mask_pix==1))
imB=smoothmask(np.int16(pred_mask_pix==2))


smoothM=np.zeros((np.shape(imA)[0],np.shape(imA)[1]))
smoothM[imA==1]=1
smoothM[imB==1]=2

ResizedMask = cv.resize(smoothM,(np.shape(scaled_WSI)[1],np.shape(scaled_WSI)[0]),
                       interpolation = cv.INTER_AREA)

ResizedMask = np.round(ResizedMask)

plt.imshow(ResizedMask)


#jj=np.int16(pp1==1)

#ResizedMask = cv.resize(jj,(np.shape(pred_mask_pix)[1]*4,np.shape(pred_mask_pix)[0]*4),
#                       interpolation = cv.INTER_AREA)

#plt.imshow(ResizedMask)

#%%
ResizedMask = cv.resize(pp1,(np.shape(pp1)[1]//64,np.shape(pp1)[0]//64),
                       interpolation = cv.INTER_AREA)

kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (9,9))
result = cv.morphologyEx(ResizedMask, cv.MORPH_CLOSE, kernel)

plt.imshow(result)




#%%

dilated = cv.open(pp1, 
                     cv.getStructuringElement(cv.MORPH_ELLIPSE, (3, 3)), 
                     iterations=2)


#%%





plt.imshow(BlurredMask)

# imgoutput2=np.int16(imgoutput>0.5)

# ll=np.zeros((np.shape(pp1)[0]//4,np.shape(pp1)[1]//4,3))

# ll[:,:,0]=imgoutput2
# ll[:,:,1]=imgoutput2
# ll[:,:,2]=imgoutput2

#%%

for i in range (0,10):

    ll = cv.GaussianBlur(ll, (5,5), 10)

plt.imshow(ll)






#a=0
# #%%

# resized=np.int16(resized)
# ll=np.zeros((9024//8,7520//8))
# ll[resized==1]=1

# ll1=np.zeros((9024//8,7520//8,3))
# ll1[:,:,0]=0
# ll1[:,:,1]=ll*255
# ll1[:,:,2]=0


# #%%

# added_image = cv.addWeighted(ll1,1,wsiscal/255,0.6,0)
# plt.imshow(added_image)
# plt.axis('off')

# #%%
# from skimage import io, color

# overlapimg=color.label2rgb(resized,wsiscal[:,:,:]/255,
#                           colors=[(0,0,0),(0,1,0)],
#                           alpha=0.4, bg_label=0, bg_color=None)

# plt.imshow(overlapimg)




