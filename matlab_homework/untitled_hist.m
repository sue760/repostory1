x =linspace(-10,10,100);
y = untitled(x);
y=randn(1,1000);
figure;
subplot(2,1,1);
histogram(y,10);
title('bins = 10');

subplot(2,1,2);
histogram(y,50);
title('bins = 50');