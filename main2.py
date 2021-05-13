# -*- coding: utf-8 -*-
import sys
sys.path.append('/home/new-ece/szc0173/liver/')
from unet import UNet
from tools import train_generator, test_generator, save_results, is_file, show_image
import tensorflow as tf
tf.test.gpu_device_name()

img_height = 512
img_width = 512
img_size = (img_height, img_width)
train_path = '/home/new-ece/szc0173/liver/'
test_path = '/home/new-ece/szc0173/liver/test/'
save_path = '/home/new-ece/szc0173/liver/result4/'
model_name = 'unet_model3.hdf5'
model_weights_name = 'unet_weight_model4.hdf5'

if __name__ == "__main__":
    
    
    # generates training set
    train_gen = train_generator(
        batch_size = 2,
        train_path = train_path,
        image_folder = 'liver',
        mask_folder = 'mask',
        target_size = img_size
    )

    # check if pretrained weights are defined
    if is_file(file_name=model_weights_name):
        pretrained_weights = model_weights_name
    else:
        pretrained_weights = None

    # build model
    unett = UNet(
        input_size = (img_width,img_height,1),
        n_filters = 64,
        pretrained_weights = pretrained_weights
    )
    unett.build()

    # creating a callback, hence best weights configurations will be saved
    model_checkpoint = unett.checkpoint(model_name)

    # model training
    # steps per epoch should be equal to number of samples in database divided by batch size
    # in this case, it is 560 / 2 = 280
    unett.fit_generator(
        train_gen,
        steps_per_epoch = 281,
        epochs = 10,
        callbacks = [model_checkpoint]
    )
    #history=unett.fit(
    #    train_gen,
    #    steps_per_epoch=280,
    #    epochs=5,
    #    callbacks=[model_checkpoint]
    #    )

    # saving model weights
    unett.save_model(model_weights_name)
    #pyunett.load_weights('unet_weight_model.hdf5')
    test_gen = test_generator(test_path, 121, img_size)
    results = unett.predict_generator(test_gen,121,verbose=1) 
    save_results(save_path, results)
