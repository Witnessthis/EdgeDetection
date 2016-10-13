%% matlab file to generate bit files
clear all;
close all;
clc;

% define a 8 bit quantizer (to convert integer to binary)
q = quantizer('ufixed', 'ceil', 'saturate', [8 0]);

% file handlers for dumping the binary format
fid_pic_32bit = fopen('pic1.pgm32.bits','wb');
fid_pic_16bit = fopen('pic1.pgm16.bits','wb');

img_arr = imread('pic1.pgm');
[row, col] = size(img_arr);

img_arr_bin = num2bin(q,quantize(q,img_arr'));

temp_arr1 = [];
for j = 1:1:length(img_arr_bin)
        temp_arr1 = [img_arr_bin(j,:), temp_arr1];
        if(mod(j,4) == 0)
        fprintf(fid_pic_32bit,'%s\n', temp_arr1 );
        fprintf(fid_pic_16bit,'%s\n', temp_arr1(17:32) );
        fprintf(fid_pic_16bit,'%s\n', temp_arr1(1:16) );
        temp_arr1 = [];
        end
end

