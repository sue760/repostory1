clc;
clear;
x=linspace(-10,10,1000);
y=untitled(x);
figure;
subplot(2,2,1);
plot(x,y);

hold on
y2 =x;
subplot(2,2,2);
plot(x,y2,'r--');

hold on
y3 =x.^3;
subplot(2,2,3);
plot(x,y3,'go--');

hold on
y4 = sin(x);
subplot(2,2,4);
plot(x,y4,'k-.');
