# -*- coding: utf-8 -*-
"""
Created on Thu Apr 15 00:39:49 2021

@author: Selena
"""

import sys
sys.path.append('/home/new-ece/szc0173/liver/')
from unet import UNet
from tools import train_generator, test_generator, save_results, is_file, prepare_dataset, show_image
import tensorflow as tf
tf.test.gpu_device_name()
test_path = '/home/new-ece/szc0173/liver/test/'
save_path = '/home/new-ece/szc0173/liver/result2/'
model_weights_name='unet_weight_model3.hdf5'
# TODO: move to config .json files
img_height = 512
img_width = 512
img_size = (img_height, img_width)
model = UNet(
    input_size = (img_width,img_height,1),
    n_filters = 64,
    pretrained_weights = model_weights_name
    )
model.build()
test_gen = test_generator(test_path, 121, img_size)
results = model.predict_generator(test_gen,121,verbose=1) 
save_results(save_path, results)
