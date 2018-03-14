
function spiral (mode, numAbs, controllers, progression)
w = [0];
addpath(genpath('../..'));
addpath(genpath('~/ownCloud/C++/SCOTS_modified/mfiles/'));

% colors
colors=get(groot,'DefaultAxesColorOrder');
if (strcmp(mode, 'CZ'))
    % visualize progression. black = sub-controller domain, red = sub-target
    openfig('problem')
    
    if strcmp(progression, 'b')
        for ii=1:controllers
            disp(num2str(ii))
            if ii ~= 1
                Z = SymbolicSet(['Z/Z' int2str(ii-1) '.bdd']);
                p = Z.points;
                Zset = plot(p(:,1),p(:,2),'ro');
                pause
            end
            
            C = SymbolicSet(['C/C' int2str(ii) '.bdd']);
            p = C.points;
            %         plotColor = colors(mod(ii,7)+1,:)*0.3+0.3;
            Cset = plot(p(:,1),p(:,2),'ko');
            pause
            
            if ii ~= 1
                delete(Zset)
            end
            delete(Cset)
        end
    elseif strcmp(progression, 'f')
        for ii = controllers:-1:1
            disp(num2str(ii))
            C = SymbolicSet(['C/C' int2str(ii) '.bdd']);
            p = C.points;
            %         plotColor = colors(mod(ii,7)+1,:)*0.3+0.3;
            Cset = plot(p(:,1),p(:,2),'ko');
            pause
            
            if ii ~= 1
                Z = SymbolicSet(['Z/Z' int2str(ii-1) '.bdd']);
                p = Z.points;
                Zset = plot(p(:,1),p(:,2),'ro');
                pause
            end
            
            if ii ~= 1
                delete(Zset)
            end
            delete(Cset)
        end
    end
end
if (strcmp(mode, 'S'))
    figure
    hold on
    box on
    drawnow
    l = 0.36; % length of rod, will be used to find the position of the bob in cartesian coordinate
    
    % load and draw state space
    X = SymbolicSet('plotting/X.bdd', 'projection', [1 3]);
%     lb = X.first();
%     ub = X.last();
    lb = zeros(2,1);
    ub = zeros(2,1);
    [lb(1),lb(2)] = pol2cart(X.first(3),l);
    [ub(1),ub(2)] = pol2cart(X.last(3),l);
    axis([lb(1)-1 ub(1)+1 lb(2)-1 ub(2)+1])
    plotCells(X, 'facecolor', 'none', 'edgec', [0.8 0.8 0.8], 'linew', 0.1);
    drawnow
    disp('Done plotting state space')
    
    savefig('system');
end

if (strcmp(mode,'P'))
    openfig('system');
    hold on
    drawnow
    
    % load and draw obstacles
    try
        O = SymbolicSet('plotting/O.bdd', 'projection', [1 3]);
        plotCells(O, 'facecolor', colors(1,:)*0.5+0.5, 'edgec', colors(1,:), 'linew', 0.1)
        drawnow
        disp('Done plotting obstacles')
    catch
        warning('No obstacles');
    end
    
    % load and draw safe sets
    G = SymbolicSet('plotting/SafeInner.bdd', 'projection', [1 3]);
    plotCells(G, 'facecolor', colors(2,:)*0.5+0.5, 'edgec', colors(2,:), 'linew', 0.1)
    drawnow
    disp('Done plotting safe sets')
    
    %     % load and draw initial
    %     I = SymbolicSet('plotting/I.bdd', 'projection', [1 2]);
    %     plotCells(I, 'facecolor', colors(3,:)*0.5+0.5, 'edgec', colors(3,:), 'linew', 0.1)
    %     drawnow
    %     disp('Done plotting initial')
    
    savefig('problem');
    
end

if (strcmp(mode, 'T'))
    openfig('problem')
    T1 = SymbolicSet('T/T1.bdd', 'projection', [1 2]);
    p1 = T1.points;
    x = plot(p1(:,1),p1(:,2),'ko');
    pause
    delete(x)
    
    T2 = SymbolicSet('T/T2.bdd', 'projection', [1 2]);
    p2 = T2.points;
    x = plot(p2(:,1),p2(:,2),'bo');
    pause    
    delete(x)
    
    T3 = SymbolicSet('T/T3.bdd', 'projection', [1 2]);
    p3 = T3.points;
    plot(p3(:,1),p3(:,2),'ro');
    title('T')
end


if (strcmp(mode,'Q')) % plot controller domains
    openfig('problem');
    hold on;
    cmap = [hot(numAbs) 0.5*ones(numAbs,1)];
    
    %       if numAbs~=size(etaAbs,1) % Sanity check
    %           error();
    %       end
    
    for ii=controllers:-1:1
        C = SymbolicSet(['C/C' int2str(ii) '.bdd'], 'projection', [1 2]);
        eta = C.eta(1:2);
        for jj=1:numAbs
            if isequal(eta',etaAbs(jj,1:2))
                layer = jj;
                break;
            end
        end
        
        
        if (ii == 1)
            G = SymbolicSet(['G/G' int2str(numAbs) '.bdd'], 'projection', [1 2]);
        else
            G = SymbolicSet(['Z/Z' int2str(ii-1) '.bdd'], 'projection', [1 2]);
        end
        
        points = setdiff(C.points,G.points,'rows');
        for jj=1:size(points,1)
            rectangle('Position',[points(jj,:)-eta' 2*eta'],'FaceColor',cmap(layer,:));
            %alpha(s,0.5);
        end
    end
end

if (strcmp(mode,'R'))
    openfig('problem');
    hold on
    drawnow
    l = 0.36; % length of rod, will be used to find the position of the bob in cartesian coordinate

    
    %     I = SymbolicSet('plotting/I.bdd');
    %     x = I.points();
    %     x = x(1,:);
    x = [-0.4875    1.1250    0.0125   -0.5750];    
    v = [];    
    j = 1;

    for i = controllers:-1:1
        disp(['iteration: ' int2str(i)])
        
        C = SymbolicSet(['C/C' int2str(i) '.bdd'], 'projection', [1 2 3]);
        if (i == 1)
            G = SymbolicSet(['G/G' int2str(numAbs) '.bdd']);
        else
            G = SymbolicSet(['Z/Z' int2str(i-1) '.bdd']);
        end
        
        points = G.points();
        Gset = plot(points(:,1), points(:,2), 'o', 'MarkerFaceColor', colors(mod(i,7)+1,:)*0.3+0.3, 'MarkerSize', 2);
        
        Z = SymbolicSet(['Z/Z' int2str(i) '.bdd']);
        eta = Z.eta();
        eta = eta';
        tau = eta(1)*9; % Fix this by including tau in Z itself
        
        disp('eta')
        disp(eta)
        disp('tau')
        disp(tau)
        
        while (1)
            disp(j)
            disp('x')
            disp(x(end,:))
            [hor,vert] = pol2cart(x(:,3),l);
            
            if (mod(j,1) == 0)
                plot(hor,vert,'k.-')
                drawnow
                pause
            end
            
            if (G.isElement(x(end,:)))
                plot(hor,vert,'k.-')
                drawnow
                delete(Gset);
                break
            end       
            
            u = C.getInputs(x(end,:));
            ran = randi([1 size(u,1)], 1, 1);
            v = [v; u(ran,:)];
            d = disturbance(w);
            [t phi] = ode45(@sysODE, [0 tau], x(end,:), [], u(ran,:), d);
            x = [x; phi];
            
            disp('u')
            disp(u(ran,:))
            disp('d')
            disp(d)
            
            j = j + 1;
        end
    end
    %      plotCells(G,'facecolor',colors(2,:)*0.5+0.5,'edgec',colors(2,:),'linew',.1)
    savefig('simulation');
end

if (strcmp(mode,'Safe'))
    %openfig('problem');
    figure;
    hold on
    drawnow
    
    v = [];    
    j = 1;
    tauSet = [0.9;0.9/2;0.9/2/2;0.9/2/2/2;0.9/2/2/2/2];
    
    C = cell(numAbs,1);
    Z = cell(numAbs,1);
    for ii=1:numAbs
        C{ii} = SymbolicSet(['C/C' int2str(ii) '.bdd']);
        Z{ii} = SymbolicSet(['Z/Z' int2str(ii) '.bdd']);
    end
    
    for rounds=1:400
        for ii=1:numAbs
            if (Z{ii}.isElement(x(end,:)))
                tau = tauSet(ii);
                if (ii==3)
                    a = 1;
                end
                break;
            end
        end
%         try
            u = C{ii}.getInputs(x(end,:));
%         catch
%             debug = 1;
%         end
        ran = randi([1 size(u,1)], 1, 1);
        v = [v; u(ran,:)];
        d = disturbance(w);
        [t phi] = ode45(@sysODE, [0 tau], x(end,:), [], u(ran,:), d);
        x = [x; phi];

            plot(t,x(:,3),'k.-')
            drawnow
        disp(ii)
%         disp('u')
%         disp(u(ran,:))
%         disp('d')
%         disp(d)
%         disp('x')
        disp(x(end,:))
%         pause
       
    end

    %      plotCells(G,'facecolor',colors(2,:)*0.5+0.5,'edgec',colors(2,:),'linew',.1)
    savefig('simulation');
end

end

function d = disturbance(w)
d = -w + (2 * w .* rand(size(w)));
end

function dxdt = sysODE(t,x,u, d)
M = 2.4;
m = 0.23;
l = 0.36;
fr = 0.1;
g = 9.81;
dxdt = zeros(4,1);
dxdt(1)=x(2);
dxdt(2)=(-m*g*sin(x(3))*cos(x(3)) + m*l*x(4)^2*sin(x(3)) + fr*m*x(4)*cos(x(3)) + u(1))/(M + (1-cos(x(3))^2)*m);
dxdt(3)=x(4);
dxdt(4) = ((M+m)*(g*sin(x(3)) - fr*x(4)) - (l*m*x(4)^2*sin(x(3))+u(1))*cos(x(3)))/(l*(M+ (1-cos(x(3))^2)*m));
% dxdt = dxdt + d';
end
