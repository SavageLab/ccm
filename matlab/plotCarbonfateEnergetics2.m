%Run calcCarbonfate_vs_pH.m first

% Cost of transport in the 3 cases (per fixation)
cost_h = Hin./CratewO;
cost_cy_h = Hin_cy./CratewO_cy;
cost_just_rbc_h = Hin_just_rbc./CratewO_just_rbc;

% Cost of fixation (per fixation)
% 3 ATP, 2 NADPH per CO2 fixed in Calvin Cycle.
% 4 H+ per ATP, 10 H+ per NADPH based on assumptions of
% ATP synthase stoichiometry and ETC H+ pumping.
cost_fixation = 4*3.0 + 10*2.0;
all_ones = ones(size(pH));

% Cost of 2PG recovery through the C2 pathway is:
% -- 1/2 carbon fixation (one decarboxylation for every two 2PG).
% -- 1 ATP (one dephosphorylation for every 2PG).
% -- 1 NADH (one oxidation for every 2PG).
% -- 1/2 amination (one net deamination for every two 2PG).
% 4 H+ per ATP, 10 H+ per NADPH based on assumptions of
% ATP synthase stoichiometry and ETC H+ pumping.
% Cost of re-aminating assumed to be 1 ATP + 1 NADPH based on the
% assumption that glutamine synthetase/glutamate synthase pathway is the
% primary pathway of ammonium incorporation as in E. coli and that
% glutamate is the product of that pathway.
cost_per_amination = 4 + 10;
cost_per_2pg = (10 + 4 + 0.5*cost_fixation + 0.5*cost_per_amination);

%Cost of maintaining pH balance with a CCM 
% - only account for pH maintanence needed from CCM activity
% -- 1 ATP per HCO3- transported (need to export 1 H+?)
% -- gain 1 OH group (or loose one H+) from each HCO3- converted to CO2
cost_pH_maintenance = (Hin - OHrateCA)./CratewO;

% Fraction of RuBisCO reactions that are oxygenations. <--- not fraction,
% but the number of oxygenations normalized by carboxylations ie
% oxygenations/carboxylations
% Specificity ratio as defined by Savir et al. 2010.
% S = (RC/RO)([O2]/[CO2]) => RO/RC = [O2]/(S [CO2])
% TODO: check that RuBisCO is saturated in all cases here.
% frac_oxygenation_ccm = ccm_params.O ./ (Ccsome .* ccm_params.S_sat);
% frac_oxygenation_cy = ccm_params_cell.O ./ (Ccyto_cy .* ccm_params_cell.S_sat);
% frac_oxygenation_just_rbc = ccm_params_just_rbc.O ./ (Ccyto_just_rbc .* ccm_params_just_rbc.S_sat);

% use the oxygenations and carboxylation rates calculated in the analytic
% and model executor files (calc_Carbonfate_vs_pH.m calls them)
frac_oxygenation_ccm = OratewC./CratewO;
frac_oxygenation_cy = OratewC_cy./CratewO_cy;
frac_oxygenation_just_rbc = OratewC_just_rbc./CratewO_just_rbc;

% Cost of 2PG recovery on a per-fixation basis in each case.
cost_2pg_ccm_h = cost_per_2pg * frac_oxygenation_ccm;
cost_2pg_cy_h = cost_per_2pg * frac_oxygenation_cy;
cost_2pg_just_rbc_h = cost_per_2pg * frac_oxygenation_just_rbc;

% Total cost of the system in H+/fixation for each case.
total_cost_ccm_h = cost_2pg_ccm_h + cost_h + cost_fixation;
total_cost_cy_h = cost_2pg_cy_h + cost_cy_h + cost_fixation;
total_cost_just_rbc_h = cost_2pg_just_rbc_h + cost_just_rbc_h + cost_fixation;

% Fraction oxygenation as a function of pH. 
figure(222)
semilogy(pH, frac_oxygenation_ccm, 'b');
hold on;
semilogy(pH, frac_oxygenation_cy, 'g');
semilogy(pH, frac_oxygenation_just_rbc, 'r');
%semilogy(pH, frac_oxygenation_scaffold, 'k');
title('Ratio of Oxygenations/Carboxylations');
legend('CCM', 'cytosolic enzymes', 'RuBisCO alone', 'scaffolded enzymes');

% =========================================================================
% Plot cummulative plot
% =========================================================================
%%
plot1 = 1;
if plot1 == 1
    % Cost breakdown of the ccm model as a function of pH.
    figure(5)
    subplot(1,3,1);
    area(pH, total_cost_ccm_h, 'FaceColor', [.337,.165,.447], 'BaseValue', 1e-1);
    hold on;
    area(pH, cost_fixation + cost_2pg_ccm_h, 'FaceColor', [.251, .557, .184], 'BaseValue', 1e-1);
    area(pH, cost_2pg_ccm_h, 'FaceColor', [.667, .518, .224], 'BaseValue', 1e-1);
    plot(pH, total_cost_ccm_h, '-k', 'LineWidth', 3);
    set(gca, 'Yscale', 'log');
    axis([pH(1) pH(end) 1e-1 2e8]);
    ylabel('Energetic Cost H^+ / (CO_2 fixed)');
    xlabel('Cytoplasmic pH');
    title('Full CCM');
    
    % Cost breakdown of the cytosolic enzymes model as a function of pH.
    subplot(1,3,2);
    area(pH, total_cost_cy_h, 'FaceColor', [.337,.165,.447], 'BaseValue', 1e-1);
    hold on;
    area(pH, cost_fixation + cost_2pg_cy_h, 'FaceColor', [.667, .518, .224], 'BaseValue', 1e-1);
    area(pH, all_ones .* cost_fixation, 'FaceColor', [.251, .557, .184], 'BaseValue', 1e-1);
    plot(pH, total_cost_cy_h, '-k', 'LineWidth', 3);
    set(gca, 'Yscale', 'log');
    axis([pH(1) pH(end) 1e-1 2e8]);
    set(gca, 'YTick', []);
    xlabel('Cytoplasmic pH');
    title('Reactions in Cytosol');
    
    % Cost breakdown of the cytosolic enzymes model as a function of pH.
    subplot(1,3,3);
    area(pH, total_cost_just_rbc_h, 'FaceColor', [.337,.165,.447], 'BaseValue', 1e-1);
    hold on;
    area(pH, cost_fixation + cost_2pg_just_rbc_h, 'FaceColor', [.667, .518, .224], 'BaseValue', 1e-1);
    area(pH, all_ones .* cost_fixation, 'FaceColor', [.251, .557, .184], 'BaseValue', 1e-1);
    plot(pH, total_cost_just_rbc_h, '-k', 'LineWidth', 3);
    set(gca, 'Yscale', 'log');
    axis([pH(1) pH(end) 1e-1 2e8]);
    set(gca, 'YTick', []);
    xlabel('Cytoplasmic pH');
    title('RuBisCO Alone');
    legend('Transport', 'Photorespiration', 'Fixation', 'Total Cost');
end
%%
% =========================================================================
% Plot cost of transport, CCB cycle and photorespiration per carbon fixation
% =========================================================================
figure(2)
% for model with full CCM
subplot(1,3,1);

% plot cost of transport/CO2 fixation with pH
semilogy(pH, cost_h,'Color','r', 'LineWidth', 3);
axis([pH(1) pH(end) 1e-1 2e7])
hold on
ylabel('Energetic Cost H^+ / (CO_2 fixed)')
xlabel('Cytoplasmic pH')
text(6, 5e2, 'HCO3^- transport cost', 'Color', 'r')
% plot cost of fixation/CO2 (flat)
plot([pH(1) pH(end)], [cost_fixation cost_fixation], '--b');
text(3, 20, 'Calvin Cycle Fixation', 'Color', 'b');
% plot cost of photorespiration
semilogy(pH, cost_2pg_ccm_h, 'Color','k', 'LineWidth', 3);
text(6, 1, 'Cost of photorespiration', 'Color', 'k')
%plot cost of pH maintenance
semilogy(pH, cost_pH_maintenance, '--c', 'LineWidth',3)
title('Full CCM')
% 

% for model with rxns in Cytosol
subplot(1,3,2);
% plot cost of transport/CO2 fixation with pH
semilogy(pH, cost_cy_h,'Color','r', 'LineWidth', 3);
axis([pH(1) pH(end) 1e-1 2e7])
hold on
ylabel('Energetic Cost H^+ / (CO_2 fixed)')
xlabel('Cytoplasmic pH')
text(6, 1e4, 'HCO3^- transport cost', 'Color', 'r')
% plot cost of fixation/CO2 (flat)
plot([pH(1) pH(end)], [cost_fixation cost_fixation], '--b');
text(3, 20, 'Calvin Cycle Fixation', 'Color', 'b');
% plot cost of photorespiration
loglog(pH, cost_2pg_cy_h, 'Color','k', 'LineWidth', 3);
text(6, 5e2, 'Cost of photorespiration', 'Color', 'k')
title('Reactions in Cytosol')
subplot(1,3,3);
% plot cost of transport/CO2 fixation with pH
semilogy(pH, cost_just_rbc_h,'Color','r', 'LineWidth', 3);
axis([pH(1) pH(end) 1e-1 2e7])
hold on
ylabel('Energetic Cost H^+ / (CO_2 fixed)')
xlabel('Cytoplasmic pH')
% text(6, 5e2, 'HCO3^- transport cost', 'Color', 'r')
% plot cost of fixation/CO2 (flat)
plot([pH(1) pH(end)], [cost_fixation cost_fixation], '--b');
text(3, 20, 'Calvin Cycle Fixation', 'Color', 'b');
% plot cost of photorespiration
loglog(pH, cost_2pg_just_rbc_h, 'Color','k', 'LineWidth', 3);
text(6, 3e3, 'Cost of photorespiration', 'Color', 'k')
title('RuBisCO Alone')

% % plot cost of transport/CO2 fixation with Cell membrane permeability
% loglog(kmH, cost_h, 'Color', 'k', 'LineWidth', 3);
% hold on
% haxes1 = gca; % handle to axes
% set(haxes1,'XColor','k','YColor','k')
% axis([kmH(end) kmH(1) 1e-1 2e7])
% xlabel('k_m^H, Effective Membrane Permeability of HCO_3^* (cm/s)')
% haxes1_pos = get(haxes1,'Position'); % store position of first axes
% haxes2 = axes('Position',haxes1_pos,...
%     'XAxisLocation','top',...
%     'YAxisLocation','left',...
%     'Yscale', 'log', ...
%     'Color','none');
% hold on
% % plot cost of transport/CO2 fixation with pH
% loglog(pH, cost_h,'Parent', haxes2,'Color','r', 'LineWidth', 3);
% set(haxes2, 'XDir','Reverse')
% axis([pH(1) pH(end) 1e-1 2e7])
% ylabel('Energetic Cost H^+ / (CO_2 fixed)')
% xlabel('Cytoplasmic pH')
% text(5, 5e2, 'HCO3^- transport cost', 'Color', 'r')
% % plot cost of fixation/CO2 (flat)
% plot([pH(1) pH(end)], [cost_fixation cost_fixation], '--b');
% text(5, 15, 'Calvin Cycle Fixation', 'Color', 'b');
% % plot cost of photorespiration
% loglog(pH, cost_2pg_ccm_h, 'Parent', haxes2,'Color','c', 'LineWidth', 3);
% text(7.5, 1, 'Cost of photorespiration', 'Color', 'c')





% =========================================================================
% Plot CO2 and HCO3^- concentration in carboxysome as a function of pH
% =========================================================================
plot3 = 0;
if plot3 ==1
    figure(111)
    plot(pH, Ccsome, 'r')
    hold on
    plot(pH, Hcsome, 'b')
    xlabel('pH')
    ylabel('inorganic carbon')
end

