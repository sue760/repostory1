img = imread('test.jpg');
if size(img,3) == 3
    gray_img = rgb2gray(img)
end

figure;
subplot(1,2,1);
imshow(gray_img);
title('yuan');

subplot(1,2,2);
histogram(gray_img(:),256);
title('huidu');
grid on;

I= gray_img;
I2 = histeq(I);

figure;
subplot(1,4,1);
imhist(I);
title('yuantu');

subplot(1,4,2);
imshow(I);
title('yuan');

subplot(1,4,3);
imshow(I2);
title('zeng');

subplot(1,4,4);
imhist(I2);
title('zengzhi');