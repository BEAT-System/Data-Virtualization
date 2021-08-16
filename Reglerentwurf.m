clc;
clear all;
Tu_ms = 73;
Ta_ms = 304;
Ks_bar = 0.045;

%% PI Regler nach Chien, Rhones, Reswick
if Ta_ms/Tu_ms > 3; disp('Verfahren kann verwendet werden'); else;...
disp('Verfahren kann nicht verwendet werden'); end

% Reglerparamter für 0 % Überschwingen
Kp_0_PI = 0.35 * ( Ta_ms/(Tu_ms*Ks_bar) ); % Kp [1/Bar]
Tn_ms_0_PI = 1.2 * Ta_ms;

% Reglerparamter für 20 % Überschwingen
Kp_20_PI = 0.60 * ( Ta_ms/(Tu_ms*Ks_bar) ); % Kp [1/Bar]
Tn_ms_20_PI = 1.0 * Ta_ms;

%% PID Regler nach Chien, Rhones, Reswick
if Ta_ms/Tu_ms > 3; disp('Verfahren kann verwendet werden'); else;...
disp('Verfahren kann nicht verwendet werden'); end

% Reglerparamter für 0 % Überschwingen
Kp_0_PID = 0.6 * ( Ta_ms/(Tu_ms*Ks_bar) ); % Kp [1/Bar]
Tn_ms_0_PID = 1.0 * Ta_ms;
Tv_ms_0_PID = 0.5 * Tu_ms;

% Reglerparamter für 20 % Überschwingen
Kp_20_PID = 0.95 * ( Ta_ms/(Tu_ms*Ks_bar) ); % Kp [1/Bar]
Tn_ms_20_PID = 1.35 * Ta_ms;
Tv_ms_20_PID = 0.47 * Ta_ms;