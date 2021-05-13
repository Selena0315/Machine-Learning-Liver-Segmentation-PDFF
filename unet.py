# -*- coding: utf-8 -*-
"""
Created on Tue Nov 24 10:04:16 2020

@author: Selena
"""
from keras.models import Model
from keras.optimizers import Adam
from tensorflow import keras
from keras.layers import Input, Conv2D, Conv2DTranspose, BatchNormalization, Activation, MaxPooling2D, Dropout, concatenate
from keras.callbacks import ModelCheckpoint

class UNet(Model):
    """ U-Net atchitecture
    Creating a U-Net class 
    checkpoint returns a ModelCheckpoint for best model fitting
    """
    def __init__(
        self,
        input_size,
        n_filters,
        pretrained_weights = None
    ):
        kernel_size =3
        stride = 2
        input = Input(input_size)
        conv1 = Conv2D(filters = n_filters, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(input)
        conv1 = BatchNormalization()(conv1)
        conv1 = Activation('relu')(conv1)
        conv1 = Conv2D(filters = n_filters, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(conv1)
        conv1 = BatchNormalization()(conv1)
        conv1 = Activation('relu')(conv1)
        pool1 = MaxPooling2D(pool_size = (2, 2))(conv1)
        pool1 = Dropout(rate = 0.1)(pool1)
        
        conv2 = Conv2D(filters = n_filters*2, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(pool1)
        conv2 = BatchNormalization()(conv2)
        conv2 = Activation('relu')(conv2)
        conv2 = Conv2D(filters = n_filters*2, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(conv2)
        conv2 = BatchNormalization()(conv2)
        conv2 = Activation('relu')(conv2)
        pool2 = MaxPooling2D(pool_size = (2, 2))(conv2)
        pool2 = Dropout(rate = 0.1)(pool2)

        conv3 = Conv2D(filters = n_filters*4, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(pool2)
        conv3 = BatchNormalization()(conv3)
        conv3 = Activation('relu')(conv3)
        conv3 = Conv2D(filters = n_filters*4, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(conv3)
        conv3 = BatchNormalization()(conv3)
        conv3 = Activation('relu')(conv3)
        pool3 = MaxPooling2D(pool_size = (2, 2))(conv3)
        pool3 = Dropout(rate = 0.1)(pool3)

        conv4 = Conv2D(filters = n_filters*8, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(pool3)
        conv4 = BatchNormalization()(conv4)
        conv4 = Activation('relu')(conv4)
        conv4 = Conv2D(filters = n_filters*8, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(conv4)
        conv4 = BatchNormalization()(conv4)
        conv4 = Activation('relu')(conv4)
        pool4 = MaxPooling2D(pool_size = (2, 2))(conv4)
        pool4 = Dropout(rate = 0.1)(pool4)

        conv5 = Conv2D(filters = n_filters*16, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(pool4)
        conv5 = BatchNormalization()(conv5)
        conv5 = Activation('relu')(conv5)
        conv5 = Conv2D(filters = n_filters*16, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(conv5)
        conv5 = BatchNormalization()(conv5)
        conv5 = Activation('relu')(conv5)

        # expansive path
        up6 = Conv2DTranspose(filters = n_filters*8, kernel_size = (kernel_size, kernel_size), strides = (stride, stride), padding = 'same')(conv5)
        up6 = concatenate([conv4,up6])
        conv6 = Conv2D(filters = n_filters*8, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(up6)
        conv6 = BatchNormalization()(conv6)
        conv6 = Activation('relu')(conv6)
        conv6 = Conv2D(filters = n_filters*8, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(conv6)
        conv6 = BatchNormalization()(conv6)
        conv6 = Activation('relu')(conv6)
        
        up7 = Conv2DTranspose(filters = n_filters*4, kernel_size = (kernel_size, kernel_size), strides = (stride, stride), padding = 'same')(conv6)
        up7 = concatenate([conv3,up7])
        conv7 = Conv2D(filters = n_filters*4, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(up7)
        conv7 = BatchNormalization()(conv7)
        conv7 = Activation('relu')(conv7)
        conv7 = Conv2D(filters = n_filters*4, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(conv7)
        conv7 = BatchNormalization()(conv7)
        conv7 = Activation('relu')(conv7)
        
        up8 = Conv2DTranspose(filters = n_filters*2, kernel_size = (kernel_size, kernel_size), strides = (stride, stride), padding = 'same')(conv7)
        up8 = concatenate([conv2,up8])
        conv8 = Conv2D(filters = n_filters*2, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(up8)
        conv8 = BatchNormalization()(conv8)
        conv8 = Activation('relu')(conv8)
        conv8 = Conv2D(filters = n_filters*2, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(conv8)
        conv8 = BatchNormalization()(conv8)
        conv8 = Activation('relu')(conv8)
        
        up9 = Conv2DTranspose(filters = n_filters*1, kernel_size = (kernel_size, kernel_size), strides = (stride, stride), padding = 'same')(conv8)
        up9 = concatenate([conv1,up9])
        conv9 = Conv2D(filters = n_filters*1, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(up9)
        conv9 = BatchNormalization()(conv9)
        conv9 = Activation('relu')(conv9)
        conv9 = Conv2D(filters = n_filters*1, kernel_size = (kernel_size, kernel_size), padding = 'same', kernel_initializer = 'he_normal')(conv9)
        conv9 = BatchNormalization()(conv9)
        conv9 = Activation('relu')(conv9)

        output = Conv2D(filters = 1, kernel_size = (1, 1), activation = 'sigmoid')(conv9)
 # initialize Keras Model with defined above input and output layers
        super(UNet, self).__init__(inputs = input, outputs = output)
        
        # load preatrained weights
        if pretrained_weights:
            self.load_weights(pretrained_weights)

    def build(self):
         self.compile(optimizer=Adam(lr=0.001), loss="binary_crossentropy", metrics=["accuracy"])
         self.summary()

    def save_model(self, name):
         self.save_weights(name)

    @staticmethod
    def checkpoint(name):
         return ModelCheckpoint(name, monitor='loss',verbose=1, save_best_only=True)

    
