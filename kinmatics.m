%% ============================================================
%  Relay Autonomous Service Robot — Differential Drive
%  Kinematic Simulation (MAM 331 — Mobile Robots)
%  Dr. Muhammed Gaafar
%  Team: Mahmoud Shamekh, Mohsen Hany, Yousef Mostafa, Barthinia Hany
%% ============================================================
clear; clc; close all;

%% ─── Robot Parameters (from report) ───────────────────────
r  = 0.075;    % Wheel radius (m)
a  = 0.20;     % Half track width (m) — 2a = 40 cm
dt = 0.05;     % Time step (s)
T  = 20.0;     % Total simulation time (s)

%% ─── Initial State [x, y, phi] ────────────────────────────
x   = 0.0;
y   = 0.0;
phi = 0.0;     % Initial heading (rad)

%% ─── Data Logging Arrays ───────────────────────────────────
N = T/dt + 1;
time_log   = zeros(1,N);
x_log      = zeros(1,N);
y_log      = zeros(1,N);
phi_log    = zeros(1,N);
vQ_log     = zeros(1,N);
phidot_log = zeros(1,N);
thetaR_log = zeros(1,N);
thetaL_log = zeros(1,N);

%% ─── Simulation Loop ───────────────────────────────────────
for k = 1:N
    t = (k-1) * dt;

    % ── Wheel Speeds (3 phases) ──────────────────────────────
    if t < 8
        vR = 0.8;  vL = 0.6;   % Phase 1: Turn Left (CCW)
    elseif t < 14
        vR = 0.7;  vL = 0.7;   % Phase 2: Straight
    else
        vR = 0.5;  vL = 0.75;  % Phase 3: Turn Right (CW)
    end

    % ── Forward Kinematics ───────────────────────────────────
    vQ     = (vR + vL) / 2;
    phidot = (vR - vL) / (2*a);
    xdot   = vQ * cos(phi);
    ydot   = vQ * sin(phi);

    % ── Log current state BEFORE integration ────────────────
    time_log(k)   = t;
    x_log(k)      = x;
    y_log(k)      = y;
    phi_log(k)    = rad2deg(phi);
    vQ_log(k)     = vQ;
    phidot_log(k) = phidot;

    % ── Inverse Kinematics (wheel angular velocities) ───────
    thetaR_log(k) = (1/r) * (vQ + a*phidot);
    thetaL_log(k) = (1/r) * (vQ - a*phidot);

    % ── Euler Integration (Odometry) ────────────────────────
    x   = x   + xdot   * dt;
    y   = y   + ydot   * dt;
    phi = phi + phidot * dt;
end

%% ─── Odometry Numerical Example (from report: phi=28.6°) ──
fprintf('\n=== Odometry Numerical Example (Matches Report) ===\n');
r_ex  = 0.075; a_ex = 0.20;
vR_ex = 0.8;   vL_ex = 0.6;
phi_ex = deg2rad(28.6);

thetaR_ex = vR_ex / r_ex;
thetaL_ex = vL_ex / r_ex;

% Forward Kinematics Matrix
J = [ (r_ex/2)*cos(phi_ex),  (r_ex/2)*cos(phi_ex) ;
      (r_ex/2)*sin(phi_ex),  (r_ex/2)*sin(phi_ex) ;
       r_ex/(2*a_ex),        -r_ex/(2*a_ex)       ];

theta_vec = [thetaR_ex; thetaL_ex];
result_FK = J * theta_vec;

fprintf('θ_R = %.4f rad/s\n', thetaR_ex);
fprintf('θ_L = %.4f rad/s\n', thetaL_ex);
fprintf('x_dot = %.5f m/s  (report: 0.61239)\n', result_FK(1));
fprintf('y_dot = %.5f m/s  (report: 0.33380)\n', result_FK(2));
fprintf('phi_dot = %.4f rad/s (report: 0.4875)\n', result_FK(3));

% Inverse Kinematics Matrix
J_inv = (1/r_ex) * [ cos(phi_ex), sin(phi_ex),  a_ex ;
                      cos(phi_ex), sin(phi_ex), -a_ex ];

result_IK = J_inv * result_FK;
fprintf('\n--- Inverse Kinematics Verification ---\n');
fprintf('θ_R recovered = %.4f rad/s (expected: 10.6)\n', result_IK(1));
fprintf('θ_L recovered = %.4f rad/s (expected: 8.0)\n',  result_IK(2));

%% ─── Plot 1: Robot Trajectory ──────────────────────────────
figure('Name','Relay Robot Trajectory','Color','white');
plot(x_log, y_log, 'b-', 'LineWidth', 2); hold on;
plot(x_log(1),   y_log(1),   'go', 'MarkerSize',12, 'MarkerFaceColor','g'); % Start
plot(x_log(end), y_log(end), 'rx', 'MarkerSize',12, 'LineWidth', 3);        % End
legend('Robot Path','Start','End','Location','best');
xlabel('X Position (m)'); ylabel('Y Position (m)');
title('Relay Robot Odometry Trajectory (20 s)');
grid on; axis equal;
text(x_log(80),  y_log(80),  '← Turn Left',  'FontSize',10,'Color','blue');
text(x_log(180), y_log(180), '← Straight',   'FontSize',10,'Color','blue');
text(x_log(320), y_log(320), '← Turn Right', 'FontSize',10,'Color','blue');

%% ─── Plot 2: Heading Angle Over Time ───────────────────────
figure('Name','Heading Angle','Color','white');
plot(time_log, phi_log, 'r-', 'LineWidth', 2);
xline(8,  '--k', 'Straight',    'LabelHorizontalAlignment','right');
xline(14, '--k', 'Turn Right',  'LabelHorizontalAlignment','right');
xlabel('Time (s)'); ylabel('φ (degrees)');
title('Robot Heading Angle φ — Odometry State Estimation');
grid on;

%% ─── Plot 3: Wheel Angular Velocities (IK) ─────────────────
figure('Name','Wheel Velocities','Color','white');
plot(time_log, thetaR_log, 'b-', 'LineWidth', 2); hold on;
plot(time_log, thetaL_log, 'r-', 'LineWidth', 2);
xline(8,  '--k'); xline(14, '--k');
legend('ω_R (Right Wheel)','ω_L (Left Wheel)','Location','best');
xlabel('Time (s)'); ylabel('ω (rad/s)');
title('Inverse Kinematics: Wheel Angular Velocities');
grid on;

fprintf('\nSimulation complete. Final position: x=%.3f m, y=%.3f m\n',...
    x_log(end), y_log(end));