# -*- coding: utf-8 -*-
"""
Created on Tue Nov 24 10:25:07 2020

@author: Selena
"""

from keras.preprocessing.image import ImageDataGenerator
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import skimage.io as io
import numpy as np
import os
import random

os.environ['KMP_DUPLICATE_LIB_OK']='True'

def normalize_mask(mask):
    """ Mask Normalization
    Function that returns normalized mask
    Each pixel is either 0 or 1
    """
    mask[mask > 0.5] = 1
    mask[mask <= 0.5] = 0
    return mask
def train_generator(
    batch_size,
    train_path,
    image_folder,
    mask_folder,
    target_size,
    image_color_mode = 'grayscale',
    mask_color_mode = 'grayscale'
):
    """ Image Data Generator
    Function that generates batches of data (img, mask) for training
    from specified folder.
    Does preprocessing (normalization to 0-1)
    """
    # only rescaling
    image_datagen = ImageDataGenerator(rescale=1. / 255)
    mask_datagen = ImageDataGenerator(rescale=1. / 255)
    image_generator = image_datagen.flow_from_directory(
        train_path,
        classes = [image_folder],
        class_mode = None,
        color_mode = image_color_mode,
        target_size = target_size,
        batch_size = batch_size,
        seed = 1
    )
    mask_generator = mask_datagen.flow_from_directory(
        train_path,
        classes = [mask_folder],
        class_mode = None,
        color_mode = mask_color_mode,
        target_size = target_size,
        batch_size = batch_size,
        seed = 1
    )
    train_generator = zip(image_generator, mask_generator)
    for (img,mask) in train_generator:
        mask = normalize_mask(mask)
        yield (img,mask)

def test_generator(
    test_path,
    num_images,
    target_size,
    as_gray = True
):
    """ Image Data Generator
    Function that generates batches of data for testing from specified folder
    Does preprocessing (normalization to 0-1)
    """
    for i in range(1, num_images + 1):
        img = io.imread(os.path.join(test_path,"%d.png"%i),as_gray = as_gray)
        yield img

def save_results(
    save_path,
    npyfile,
    num_class = 2
):
    """ Save Results
    Function that takes predictions from U-Net model
    and saves them to specified folder.
    """
    for i,item in enumerate(npyfile):
        img = normalize_mask(item)
        img = (img * 255).astype('uint8')
        io.imsave(os.path.join(save_path,"%d_predict.png"%(i+1)),img)

def is_file(
    file_name
) -> bool:
    """ Is File
    Check if file exists
    Later used to check if user has pretrained models
    """
    return os.path.isfile(file_name)