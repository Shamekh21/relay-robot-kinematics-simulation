function RelayRobotGUI()
%% ============================================================
%  Relay Autonomous Service Robot — Differential Drive
%  Kinematic Simulation (MAM 331 — Mobile Robots)
%  Dr. Muhammed Gaafar
%  Team: Mahmoud Shamekh, Mohsen Hany, Yousef Mostafa, Barthinia Hany
%  Page 1: Controls + Plots | Page 2: Live Animation
%% ============================================================

BG      = [1 1 1];
PANEL   = [0.97 0.97 0.97];
ACCENT  = [0.85 0.1 0.1];
ACCENT2 = [0.6 0.05 0.05];
TXT     = [0.1 0.1 0.1];
GRID_C  = [0.85 0.85 0.85];

fig = uifigure('Name','Relay Robot — Kinematic Simulator',...
    'Position',[30 30 1250 780],'Color',BG);

%% PAGE 1
pg1 = uipanel(fig,'Position',[0 0 1250 780],...
    'BackgroundColor',BG,'BorderType','none');

uipanel(pg1,'Position',[0 730 1250 50],'BackgroundColor',ACCENT,'BorderType','none');
uilabel(pg1,'Text','Relay Robot  —  Differential Drive Kinematic Simulator',...
    'Position',[20 735 700 38],'FontSize',17,'FontWeight','bold',...
    'FontColor','white','BackgroundColor',ACCENT);
uilabel(pg1,'Text','Mobile Robots (MAM 331)  |  Dr. Muhammed Gaafar',...
    'Position',[750 740 480 25],'FontSize',11,'FontColor',[1 0.85 0.85],...
    'BackgroundColor',ACCENT,'HorizontalAlignment','right');

%% Robot Parameters
pParams = uipanel(pg1,'Title','  Robot Parameters','Position',[15 490 240 235],...
    'BackgroundColor',PANEL,'ForegroundColor',ACCENT,...
    'FontSize',12,'FontWeight','bold','BorderColor',ACCENT);
paramLabels  = {'Wheel Radius r (m):','Half Track a (m):','Time Step dt (s):','Duration T (s):'};
paramDefaults= {0.075, 0.20, 0.05, 20};
fields = gobjects(1,4);
for i = 1:4
    uilabel(pParams,'Text',paramLabels{i},...
        'Position',[10 200-50*(i-1) 160 20],...
        'FontColor',TXT,'BackgroundColor',PANEL,'FontSize',10);
    fields(i) = uieditfield(pParams,'numeric','Value',paramDefaults{i},...
        'Position',[10 180-50*(i-1) 140 22],'FontColor',TXT,'BackgroundColor','white');
end
eR=fields(1); eA=fields(2); eDt=fields(3); eT=fields(4);

%% Wheel Speeds
pSpeed = uipanel(pg1,'Title','  Wheel Speeds','Position',[15 250 240 235],...
    'BackgroundColor',PANEL,'ForegroundColor',ACCENT,...
    'FontSize',12,'FontWeight','bold','BorderColor',ACCENT);

uilabel(pSpeed,'Text','Right Wheel  vR (m/s)','Position',[10 195 160 20],...
    'FontColor',ACCENT,'BackgroundColor',PANEL,'FontWeight','bold');
sVR = uislider(pSpeed,'Limits',[0 2],'Value',0.8,'Position',[10 175 150 3]);
eVR = uieditfield(pSpeed,'numeric','Value',0.8,'Limits',[0 2],...
    'Position',[168 163 60 24],'FontColor',TXT,'BackgroundColor','white');
lblVR = uilabel(pSpeed,'Text','0.80 m/s','Position',[55 143 100 22],...
    'FontColor',ACCENT,'BackgroundColor',PANEL,'HorizontalAlignment','center',...
    'FontWeight','bold','FontSize',12);

uilabel(pSpeed,'Text','Left Wheel  vL (m/s)','Position',[10 118 160 20],...
    'FontColor',[0.2 0.2 0.2],'BackgroundColor',PANEL,'FontWeight','bold');
sVL = uislider(pSpeed,'Limits',[0 2],'Value',0.6,'Position',[10 100 150 3]);
eVL = uieditfield(pSpeed,'numeric','Value',0.6,'Limits',[0 2],...
    'Position',[168 88 60 24],'FontColor',TXT,'BackgroundColor','white');
lblVL = uilabel(pSpeed,'Text','0.60 m/s','Position',[55 68 100 22],...
    'FontColor',[0.2 0.2 0.2],'BackgroundColor',PANEL,'HorizontalAlignment','center',...
    'FontWeight','bold','FontSize',12);

uilabel(pSpeed,'Text','Initial Heading φ₀ (°):','Position',[10 40 160 20],...
    'FontColor',TXT,'BackgroundColor',PANEL,'FontSize',10);
uilabel(pSpeed,'Text','0°=right | 90°=up | 180°=left','Position',[10 22 200 16],...
    'FontColor',[0.5 0.5 0.5],'BackgroundColor',PANEL,'FontSize',8);
ePhi0 = uieditfield(pSpeed,'numeric','Value',0,...
    'Position',[10 3 80 22],'FontColor',TXT,'BackgroundColor','white');

%% Slider sync
sVR.ValueChangedFcn = @(s,~) deal(set(eVR,'Value',s.Value), set(lblVR,'Text',sprintf('%.2f m/s',s.Value)));
eVR.ValueChangedFcn = @(e,~) deal(set(sVR,'Value',e.Value), set(lblVR,'Text',sprintf('%.2f m/s',e.Value)));
sVL.ValueChangedFcn = @(s,~) deal(set(eVL,'Value',s.Value), set(lblVL,'Text',sprintf('%.2f m/s',s.Value)));
eVL.ValueChangedFcn = @(e,~) deal(set(sVL,'Value',e.Value), set(lblVL,'Text',sprintf('%.2f m/s',e.Value)));

%% FK Results
pFK = uipanel(pg1,'Title','  FK / IK Results','Position',[15 130 240 115],...
    'BackgroundColor',PANEL,'ForegroundColor',ACCENT,...
    'FontSize',11,'FontWeight','bold','BorderColor',ACCENT);
lblFK = uilabel(pFK,'Text','Press  RUN  to compute',...
    'Position',[8 5 225 88],'FontColor',TXT,'BackgroundColor',PANEL,...
    'FontSize',10,'WordWrap','on');

%% Buttons
btnRun = uibutton(pg1,'Text','▶   RUN SIMULATION',...
    'Position',[15 78 240 45],'FontSize',13,'FontWeight','bold',...
    'BackgroundColor',ACCENT,'FontColor','white');
btnReset = uibutton(pg1,'Text','↺  Reset',...
    'Position',[15 30 115 38],'FontSize',11,'FontWeight','bold',...
    'BackgroundColor',[0.9 0.9 0.9],'FontColor',ACCENT2);
btnGo = uibutton(pg1,'Text','⏩  Animation  ▶',...
    'Position',[140 30 115 38],'FontSize',11,'FontWeight','bold',...
    'BackgroundColor',ACCENT2,'FontColor','white');

%% Axes
makeAx = @(parent,pos,ttl,xl,yl,tip) makeAxFn(parent,pos,ttl,xl,yl,tip,TXT,PANEL,GRID_C,ACCENT);

axTraj  = makeAx(pg1,[265 395 480 320],'Trajectory (Odometry)','X (m)','Y (m)','Actual robot path on ground');
axPhi   = makeAx(pg1,[760 395 475 320],'Heading Angle  φ','Time (s)','φ (°)','Robot heading direction');
axOmega = makeAx(pg1,[265 45  480 320],'Inverse Kinematics — ω Wheels','Time (s)','ω (rad/s)','Wheel angular speeds (IK)');
axVQ    = makeAx(pg1,[760 45  475 320],'Linear & Angular Velocity','Time (s)','Velocity','vQ=center speed | φdot=angular rate');

fig.UserData = struct('ready',false);

%% Callbacks
btnRun.ButtonPushedFcn   = @(~,~) cbRun(eR,eA,eDt,eT,eVR,eVL,ePhi0,...
    axTraj,axPhi,axOmega,axVQ,lblFK,fig,ACCENT,PANEL,TXT);
btnReset.ButtonPushedFcn = @(~,~) cbReset(axTraj,axPhi,axOmega,axVQ,...
    lblFK,sVR,eVR,lblVR,sVL,eVL,lblVL,fig);

%% PAGE 2
pg2 = uipanel(fig,'Position',[0 0 1250 780],...
    'BackgroundColor',BG,'BorderType','none','Visible','off');

uipanel(pg2,'Position',[0 730 1250 50],'BackgroundColor',ACCENT2,'BorderType','none');
uilabel(pg2,'Text','Relay Robot  —  Live Animation',...
    'Position',[20 735 500 38],'FontSize',17,'FontWeight','bold',...
    'FontColor','white','BackgroundColor',ACCENT2);
btnBack = uibutton(pg2,'Text','◀  Back to Plots',...
    'Position',[1070 738 165 38],'FontSize',12,'FontWeight','bold',...
    'BackgroundColor','white','FontColor',ACCENT2);

uilabel(pg2,'Text','Animation Speed:','Position',[20 692 120 20],...
    'FontColor',TXT,'BackgroundColor',BG,'FontSize',11);
sSpeed = uislider(pg2,'Limits',[1 10],'Value',5,'Position',[150 700 180 3]);
eSpeed = uieditfield(pg2,'numeric','Value',5,'Limits',[1 10],...
    'Position',[340 690 45 24],'FontColor',TXT,'BackgroundColor','white');
uilabel(pg2,'Text','Slow','Position',[148 678 35 16],...
    'FontColor',[0.6 0.6 0.6],'BackgroundColor',BG,'FontSize',9);
uilabel(pg2,'Text','Fast','Position',[320 678 35 16],...
    'FontColor',[0.6 0.6 0.6],'BackgroundColor',BG,'FontSize',9);
sSpeed.ValueChangedFcn = @(s,~) set(eSpeed,'Value',round(s.Value));
eSpeed.ValueChangedFcn = @(e,~) set(sSpeed,'Value',e.Value);

btnPlay = uibutton(pg2,'Text','▶  Play',...
    'Position',[400 688 105 32],'FontSize',12,'FontWeight','bold',...
    'BackgroundColor',ACCENT,'FontColor','white');

%% Live metrics
pLive = uipanel(pg2,'Title','  Live State','Position',[15 50 225 625],...
    'BackgroundColor',PANEL,'ForegroundColor',ACCENT,...
    'FontSize',12,'FontWeight','bold','BorderColor',ACCENT);
mLabels = {'Time (s):','X Position (m):','Y Position (m):','Heading φ (°):',...
    'v_Q (m/s):','φ-dot (rad/s):','ω_R (rad/s):','ω_L (rad/s):'};
mDesc = {'Current time','Horizontal displacement','Vertical displacement','Robot heading direction',...
    'Robot center speed','Angular velocity','Right wheel angular speed','Left wheel angular speed'};
hMetrics = gobjects(1,8);
for i=1:8
    uilabel(pLive,'Text',mLabels{i},'Position',[8 600-72*(i-1) 210 18],...
        'FontColor',[0.5 0.5 0.5],'BackgroundColor',PANEL,'FontSize',9);
    hMetrics(i) = uilabel(pLive,'Text','—','Position',[8 580-72*(i-1) 200 22],...
        'FontColor',ACCENT,'BackgroundColor',PANEL,'FontSize',14,'FontWeight','bold');
    uilabel(pLive,'Text',mDesc{i},'Position',[8 562-72*(i-1) 210 14],...
        'FontColor',[0.65 0.65 0.65],'BackgroundColor',PANEL,'FontSize',8);
end

axAnim = uiaxes(pg2,'Position',[255 50 980 638]);
axAnim.Color=PANEL; axAnim.XColor=TXT; axAnim.YColor=TXT;
axAnim.GridColor=GRID_C; axAnim.GridAlpha=1; axAnim.Box='on';
grid(axAnim,'on'); hold(axAnim,'on'); axis(axAnim,'equal');
xlabel(axAnim,'X Position (m)','Color',TXT,'FontSize',11);
ylabel(axAnim,'Y Position (m)','Color',TXT,'FontSize',11);
title(axAnim,'Relay Robot — Live Pose Animation',...
    'Color',ACCENT,'FontSize',13,'FontWeight','bold');

%% Page switch
btnGo.ButtonPushedFcn   = @(~,~) deal(set(pg1,'Visible','off'), set(pg2,'Visible','on'));
btnBack.ButtonPushedFcn = @(~,~) deal(set(pg2,'Visible','off'), set(pg1,'Visible','on'));

btnPlay.ButtonPushedFcn = @(~,~) cbPlay(fig,axAnim,hMetrics,eSpeed,ACCENT,ACCENT2);

end % ── END RelayRobotGUI ────────────────────────────────────


%% ════════════════════════════════════════════════════════════
%  LOCAL FUNCTIONS
%% ════════════════════════════════════════════════════════════

function ax = makeAxFn(parent,pos,ttl,xl,yl,tip,TXT,PANEL,GRID_C,ACCENT)
    ax = uiaxes(parent,'Position',pos);
    ax.Color=PANEL; ax.XColor=TXT; ax.YColor=TXT;
    ax.GridColor=GRID_C; ax.GridAlpha=1; ax.Box='on';
    grid(ax,'on'); hold(ax,'on');
    xlabel(ax,xl,'Color',TXT,'FontSize',10);
    ylabel(ax,yl,'Color',TXT,'FontSize',10);
    title(ax,sprintf('%s\n{\color[rgb]{0.5 0.5 0.5}\fontsize{8}%s}',ttl,tip),...
        'Color',ACCENT,'FontSize',11,'FontWeight','bold');
end

function cbRun(eR,eA,eDt,eT,eVR,eVL,ePhi0,axTraj,axPhi,axOmega,axVQ,lblFK,fig,ACCENT,PANEL,TXT)
    r_v=eR.Value; a_v=eA.Value; dt_v=eDt.Value; T_v=eT.Value;
    vR_v=eVR.Value; vL_v=eVL.Value; phi0=deg2rad(ePhi0.Value);

    N=round(T_v/dt_v)+1;
    x_l=zeros(1,N); y_l=zeros(1,N); phi_l=zeros(1,N); t_l=zeros(1,N);
    tR_l=zeros(1,N); tL_l=zeros(1,N); vQ_l=zeros(1,N); pd_l=zeros(1,N);

    x=0; y=0; phi=phi0;
    for k=1:N
        t_l(k)=(k-1)*dt_v;
        vQ=(vR_v+vL_v)/2; phidot=(vR_v-vL_v)/(2*a_v);
        tR_l(k)=(1/r_v)*(vQ+a_v*phidot);
        tL_l(k)=(1/r_v)*(vQ-a_v*phidot);
        vQ_l(k)=vQ; pd_l(k)=phidot;
        x_l(k)=x; y_l(k)=y; phi_l(k)=rad2deg(phi);
        x=x+vQ*cos(phi)*dt_v; y=y+vQ*sin(phi)*dt_v; phi=phi+phidot*dt_v;
    end

    fig.UserData=struct('x_log',x_l,'y_log',y_l,'phi_log',phi_l,...
        'time_log',t_l,'thetaR_log',tR_l,'thetaL_log',tL_l,...
        'vQ_log',vQ_l,'phidot_log',pd_l,'a_val',a_v,'ready',true);

    cla(axTraj);
    plot(axTraj,x_l,y_l,'-','Color',ACCENT,'LineWidth',2.5);
    plot(axTraj,x_l(1),y_l(1),'o','Color',[0.1 0.7 0.2],'MarkerSize',12,'MarkerFaceColor',[0.1 0.7 0.2]);
    plot(axTraj,x_l(end),y_l(end),'x','Color',ACCENT,'MarkerSize',14,'LineWidth',3);
    legend(axTraj,'Path','Start','End','Location','best','TextColor',TXT,'Color',PANEL);
    axis(axTraj,'equal');

    cla(axPhi);
    plot(axPhi,t_l,phi_l,'-','Color',ACCENT,'LineWidth',2);
    fill(axPhi,[t_l fliplr(t_l)],[phi_l zeros(1,N)],ACCENT,'FaceAlpha',0.08,'EdgeColor','none');

    cla(axOmega);
    plot(axOmega,t_l,tR_l,'-','Color',ACCENT,'LineWidth',2,'DisplayName','\omega_R (Right)');
    plot(axOmega,t_l,tL_l,'--','Color',[0.3 0.3 0.3],'LineWidth',2,'DisplayName','\omega_L (Left)');
    legend(axOmega,'TextColor',TXT,'Color',PANEL);

    cla(axVQ);
    plot(axVQ,t_l,vQ_l,'-','Color',ACCENT,'LineWidth',2,'DisplayName','v_Q (m/s)');
    plot(axVQ,t_l,pd_l,'--','Color',[0.5 0.5 0.5],'LineWidth',2,'DisplayName','\phi-dot (rad/s)');
    legend(axVQ,'TextColor',TXT,'Color',PANEL);

    set(lblFK,'Text',sprintf('v_Q   = %.3f m/s\nφ-dot = %.3f rad/s\nω_R  = %.2f rad/s\nω_L  = %.2f rad/s',...
        vQ_l(1),pd_l(1),tR_l(1),tL_l(1)));
end

function cbReset(axTraj,axPhi,axOmega,axVQ,lblFK,sVR,eVR,lblVR,sVL,eVL,lblVL,fig)
    cla(axTraj); cla(axPhi); cla(axOmega); cla(axVQ);
    set(lblFK,'Text','Press  RUN  to compute');
    sVR.Value=0.8; eVR.Value=0.8; set(lblVR,'Text','0.80 m/s');
    sVL.Value=0.6; eVL.Value=0.6; set(lblVL,'Text','0.60 m/s');
    fig.UserData=struct('ready',false);
end

function cbPlay(fig,axAnim,hMetrics,eSpeed,ACCENT,ACCENT2)
    d=fig.UserData;
    if ~d.ready
        uialert(fig,'Run simulation first  (Page 1 → RUN)','No Data'); return;
    end
    cla(axAnim); hold(axAnim,'on'); axis(axAnim,'equal');

    N=numel(d.x_log); a_v=d.a_val;
    spd=max(11-round(eSpeed.Value),1);  % inverted: slider=1 → fastest
    skip=max(1,round(N/(150*spd/5)));
    mg=max(0.4,a_v*2);

    plot(axAnim,d.x_log,d.y_log,'-','Color',[0.85 0.85 0.85],'LineWidth',1);
    hPath =plot(axAnim,NaN,NaN,'-','Color',ACCENT,'LineWidth',2.5);
    hBody =patch(axAnim,'XData',[],'YData',[],'FaceColor',[1 0.9 0.9],'EdgeColor',ACCENT,'LineWidth',2);
    hArrow=plot(axAnim,NaN,NaN,'-','Color',ACCENT2,'LineWidth',3);
    hDot  =plot(axAnim,NaN,NaN,'o','MarkerSize',8,'MarkerFaceColor',ACCENT,'MarkerEdgeColor',ACCENT2);
    hWR   =plot(axAnim,NaN,NaN,'s','MarkerSize',10,'MarkerFaceColor',[0.25 0.25 0.25],'MarkerEdgeColor','black');
    hWL   =plot(axAnim,NaN,NaN,'s','MarkerSize',10,'MarkerFaceColor',[0.25 0.25 0.25],'MarkerEdgeColor','black');

    W=a_v*0.7; L=a_v*1.2; xdata=[]; ydata=[];
    for k=1:skip:N
        if ~isvalid(fig), return; end
        x=d.x_log(k); y=d.y_log(k); phi=deg2rad(d.phi_log(k));
        R=[cos(phi) -sin(phi); sin(phi) cos(phi)];
        c=R*[-L -L L L;-W W W -W];
        arr=R*[0;L*1.4];
        wR=R*[0;-a_v]+[x;y]; wL=R*[0;a_v]+[x;y];
        xdata(end+1)=x; ydata(end+1)=y; %#ok
        set(hPath, 'XData',xdata,'YData',ydata);
        set(hBody, 'XData',c(1,:)+x,'YData',c(2,:)+y);
        set(hArrow,'XData',[x x+arr(1)],'YData',[y y+arr(2)]);
        set(hDot,  'XData',x,'YData',y);
        set(hWR,   'XData',wR(1),'YData',wR(2));
        set(hWL,   'XData',wL(1),'YData',wL(2));
        xlim(axAnim,[min(d.x_log)-mg max(d.x_log)+mg]);
        ylim(axAnim,[min(d.y_log)-mg max(d.y_log)+mg]);
        set(hMetrics(1),'Text',sprintf('%.2f',  d.time_log(k)));
        set(hMetrics(2),'Text',sprintf('%.3f m',x));
        set(hMetrics(3),'Text',sprintf('%.3f m',y));
        set(hMetrics(4),'Text',sprintf('%.1f °',d.phi_log(k)));
        set(hMetrics(5),'Text',sprintf('%.3f',  d.vQ_log(k)));
        set(hMetrics(6),'Text',sprintf('%.4f',  d.phidot_log(k)));
        set(hMetrics(7),'Text',sprintf('%.2f',  d.thetaR_log(k)));
        set(hMetrics(8),'Text',sprintf('%.2f',  d.thetaL_log(k)));
        drawnow limitrate;
        pause(0.008/max(spd/5,0.1));
    end
end