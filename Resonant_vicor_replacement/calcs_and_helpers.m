W_norm = @(Ll, Cs) 1/sqrt(Ll.*Cs);

Qn = @(Ll, Cs, Re) sqrt(Ll./Cs)./(Re);

Q_from_Rl = @(Ll, Cs, Rl, n) sqrt(Ll/Cs)./Rpri_from_sec(8/(pi*pi).*Rl, n);

Rl_from_Qe = @(Ll, Cs, Qe, n) Rsec_from_pri(pi*pi/8*sqrt(Ll/Cs)/(Qe), n);

W0 = @(Ll, Cs) 1./(sqrt(Ll.*Cs));

Ws = @(Ll, Cs, Wn) Wn.*W0(Ll, Cs);

Ln_calc = @(Lm, Ll) Lm./Ll;

H = @(Wn, Ln, Qn) Ln.*Wn.^2 ./ sqrt((Wn.^2.*(Ln+1) - 1).^2 + ((Wn.^2-1).*Wn.*Qn.*Ln).^2);

M = @(Fs, Cr, Lr, Lm, n, Rl) H((Fs*2*pi)./W_norm(Lr, Cr), Ln_calc(Lm, Lr), Q_from_Rl(Lr, Cr, Rl, n)).*n/2;

H_back_calc = @(Vin, Vout, n) Vout/(Vin*n/2);

Rpri_from_sec = @(R, n) R ./ n^2;

Rsec_from_pri = @(R, n) R * n^2;