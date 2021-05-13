# -*- coding: utf-8 -*-
"""
Created on Wed Apr 14 15:39:59 2021

@author: Selena
"""
import sys
sys.path.append('/home/new-ece/szc0173/liver/')
from unet import UNet
from tools import train_generator, test_generator, save_results, is_file, prepare_dataset, show_image
import tensorflow as tf
tf.test.gpu_device_name()
train_path = '/home/new-ece/szc0173/liver/'
test_path = '/home/new-ece/szc0173/liver/test/'
save_path = '/home/new-ece/szc0173/liver/result2/'
model_weights_name='unet_weight_model.hdf5'
# TODO: move to config .json files
img_height = 512
img_width = 512
img_size = (img_height, img_width)
model = UNet(
    input_size = (img_width,img_height,1),
    n_filters = 64,
    pretrained_weights = model_weights_name
    )
train_gen = train_generator(
        batch_size = 2,
        train_path = train_path,
        image_folder = 'liver',
        mask_folder = 'mask',
        target_size = img_size
    )
model.build()
model_name2='/home/new-ece/szc0173/liver/unet_model2.hdf5'
model_checkpoint2 = model.checkpoint(model_name2)
model.fit_generator(
    train_gen,
    steps_per_epoch=280,
    epochs=10,
    callbacks=[model_checkpoint2]
    )
#history1=model.fit(
#    train_gen,
#    steps_per_epoch =280 ,
#    epochs = 10,
#    callbacks = [model_checkpoint2]
#    )

# saving model weights
model.save_model('/home/new-ece/szc0173/liver/unet_weight_model2.hdf5')
model.save('/home/new-ece/szc0173/liver/unet_model2.hdf5') 
