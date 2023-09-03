%%%% For different currents, plots the various input and output voltages
%%%% that result in DCM operation. Used in inductor and capacitor sizing



Vin = linspace(10,90, 90-10+1);
Vout = linspace(90,150, 150-90+1);

inductor_ripple = zeros(length(Vin), length(Vout));


for i = 1:length(Vin)
    for j = 1:length(Vout)
        if(Vin(i) >= Vout(j)-10)
            % Invalid region of operation, so discard
            inductor_ripple(i,j) = 0;
        else
            inductor_ripple(i,j) = get_ripple(Vin(i), Vout(j), 460*10^-6);
        end
    end
end



figure('Name', 'DCM boundry regions across input and outptu voltage levels')

surf(Vout, Vin, inductor_ripple);
colorbar('westoutside')
hold on;
xlabel("Voltage Ouput")
ylabel("Voltage Input")
zlabel("Inductor ripple current")
[C, h] = contour3(Vout, Vin, inductor_ripple/2, [0.304 0.6 0.9 1.2 1.82 2.42 3.02 6], 'LineWidth', 2, 'ShowText','on');
%clabel('5%', '10%', '20%', '30%', '40%', '50%', '100%')

%legend('10% irradiance', '100% irradiance', '100% irradiance')

function ripple_current = get_ripple(Vin, Vout, L)
Fsw = 20000;
ripple_current = (Vin * (Vout - Vin)) / (L * Fsw * Vout);
end
