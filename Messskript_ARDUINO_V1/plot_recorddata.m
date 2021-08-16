clc;
clear all;

[a,b] = uigetfile('*.mat');
load([b,a]);


plot((record_data(:,1)-record_data(end,1))/1000,record_data(:,2));
xlabel('Zeit[s]');
ylabel('Druck [mBar]');
grid on;
ylim([0,50]);
title('Beatmungsdruck');
set(gcf(),'Position',[100,100,1400,600])
% title(a(1:end-4),'Interpreter','none');
% 
% [~,indmpp] = max(record_data(:,4));
% plot(record_data(indmpp,2),record_data(indmpp,3),'ro'); hold off;
% 
% str = sprintf(['R[Ohm]         U[mV]              I[mA]      P[mW]\n' num2str(record_data(indmpp,:))]);
% txt1 = text(record_data(indmpp,2)+120,record_data(indmpp,3),str);
% set(txt1,'HorizontalAlignment','right','VerticalAlignment','top');
% txt2 = text(record_data(indmpp,2),record_data(indmpp,3),'  MPP');
% set(txt2,'HorizontalAlignment','left','VerticalAlignment','bottom','color','r');