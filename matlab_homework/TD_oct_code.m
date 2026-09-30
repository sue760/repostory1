%Center
lamda0=830E-9;
%band
dlamda=60E-9;
c=3E8;
lc=4*log(2)/pi*lamda0^2/dlamda;
N=2^12;
dl=lc*linspace(-2,2,N);


k0=2*pi/lamda0;
subplot(5,1,1)
lac=exp(-16*log(2)*(dl/lc).^2).*cos(2*k0*dl);
plot(dl/lc,lac,'k')
title('a interferogram')
xlabel('deltal l_c')
ylabel('signal')
axis([-0.6,0.6,-1,1])
subplot(5,1,2)
lrec=abs(lac);
%plot(dl/lc,lre,'k')
title('b rectified interferogram')
xlabel('deltal l_c')
ylabel('signal')
axis([-0.6,0.6,-1,1])
subplot(5,1,3)
frec1=fft(lrec)/sqrt(N);
frec2=fftshift(frec1);


dfreq=1/(4*lc);
freq=dfreq*(-N/2:N/2-1);
plot(freq*lamda0,abs(frec2),'k')
title('c spectrum')



cutoff_freq = 0.05 * max(abs(freq)); 
high_pass_mask = abs(freq)< cutoff_freq; 
frec2_high_pass = frec2 .* high_pass_mask; 

subplot(5, 1, 4);
plot(freq * lamda0, abs(frec2_high_pass), 'k');
title('low pass');
xlabel('frequency * lamda0');
ylabel('amplitude');


lrec_filtered = ifft(ifftshift(frec2_high_pass)) * sqrt(N); 

subplot(5, 1, 5);
plot(dl/lc, real(lrec_filtered), 'k');
title('d Reconstructed signal after high-pass filtering');
xlabel('deltal / l_c');
ylabel('signal');
axis([-0.6, 0.6, -1, 1]);