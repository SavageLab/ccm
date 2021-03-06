% calculate sweeps through sensitivity analysis
clear all
close all

resultsfolder = '../savedoutput/03262016Code/';
mkdir(resultsfolder)
addpath(fileparts(pwd))


Rcvec = 0.5*[2, 10, 20, 40]*1e-6; % 20 nm, 100nm, 200 nm, to 400 nm diameter carboxysomes
ratiovec= [1 10 100 1000]; % ratio between kcC and kcH
kmHvec = [3e-4 3e-3 3e-2]; % membrane permeability for H2CO3
% kcCvec = [3e-2  3e-4 3e-5 3e-6];
% Hmaxvec = [5 10 30 50]*1000;

alphavec =  [0 1e-6 1e-5 5e-5 8e-5 1e-4];

p = CCMParams_Csome;

figure

% for jj =1:length(Rcvec)
    jj = 2;
    p.Rc = Rcvec(jj);
    for kk = 1:length(ratiovec)
        ratio = ratiovec(kk);
        for nn =  2 %1:length(kmHvec)
            p.kmH_base = kmHvec(nn);
%              for mm = 3 %1:length(kcCvec)
%                  p.kcC = kcCvec(mm);
%                  p.kcH = ratio*kcCvec(mm);
%                  for pp = 3 %1:length(Hmaxvec)
%                      Hmax = Hmaxvec(pp);
            for qq = 1%:length(alphavec)
                p.alpha = alphavec(qq);
                    
                    
                    %
                                        critical_jc_vs_kc
%                     calcCarbonfate_vs_pH
%                     plotCarbonfateEnergetics2
                    
                    foldername = ['Rc', num2str(p.Rc), ...
                        'ratio', num2str(ratio), ...
                        'kmHbase', num2str(p.kmH_base), ...
                        'alpha', num2str(p.alpha), ...
                        '/']
%                         'kcC', num2str(p.kcC),...
%                         'Hmax', num2str(Hmax),...
%                         '/']
                    savefolder = [resultsfolder, foldername];
                    mkdir(savefolder)
                                        save([savefolder, 'jc_vs_kc.mat'])
%                     save([savefolder, '/calcCarbonfate_vs_pH'])
                    %                     p.kmH_in
%                                         load([savefolder, 'jc_vs_kc.mat'])
%                                         alphavec =  [0 1e-6 1e-5 5e-5 8e-5 1e-4];
%                     load([savefolder, 'calcCarbonfate_vs_pH'])
% 
%                     plot(pH, total_cost_ccm_h, 'o')
%                     hold on
%                     xlabel('pH')
%                     ylabel('H^+/(CO_2 fixation)')
                    dn = 3;
                    
                                        figure(119)
                                        loglog(critjc, kvec, 'Color', newcolor(3, dn))
                                        hold on
                                        loglog(critjcRub, kvec, 'Color', newcolor(1, dn))

                                        loglog(jc_Hmax, kvec, '--','Color', newcolor(2, dn))
%                                         loglog(critjc_uptake, kvec, '.-', 'Color', newcolor(4, dn))
                                        xlabel('Active HCO_3^- transport, j_c, (cm/s)')
                                        ylabel('Carboxysome permeability, k_c, (cm^3/s)')
                                        drawnow
                                        clear exec res Ccrit critjc critjcRub jcHmax kvec
            end
                    
                end
            end
%         end
%     end
%     
% end




