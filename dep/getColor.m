% to look at these demos, rename the main function to getColor_x
%% show all colours
% a = []; col = [];
% idx = [1 12 27  2 5 19  3 8 21  4 10 22 6 18 24 7 20 25 9 23 26 11 14 13 15 16 17];
% for ii=1:27
%     col(ii,:) = getColor_x('idx',idx(ii));
%     a = [a repmat(reshape(col(ii,:),1,1,3),20,3,1)];
% end
% figure
% subplot(211);imshow(a)
% subplot(212);plot(mean(col,2),'ko-','LineWidth',2); hold on
% plot(1,mean(col(1,:)),'kx','LineWidth',2,'MarkerSize',14)
% plot(3,mean(col(3,:)),'kx','LineWidth',2,'MarkerSize',14)
% set(gca,'XTick',1:27); grid on; 
% set(gca,'XLim',[0.5 27.5],'YLim',[0.3 1.1])
% set(gca,'XTickLabel',idx)

%% show range for a pair of colours
% a = [];  col = [];
% col = getColor_x('range',[5 8 100]);
% for ii=1:100
%     a = [a repmat(reshape(col(ii,:),1,1,3),20,3,1)];
% end
% figure
% subplot(211);imshow(a)
% subplot(212);plot(mean(col,2))

%%
function col = getColor(varargin)
    p =  inputParser;
    addOptional(p,'range',[],@(x) length(x)==3 && sum(x(1:2)>28)==0);
    addOptional(p,'idx',randi(26,1),@(x) isnumeric(x) && isscalar(x) && (x > 0) && (x < 28));
    parse(p,varargin{:});

    range = p.Results.range;
    idx = p.Results.idx;
    
    cols = getAllCols;

    if ~isempty(range)
        col1 = (cols(range(1),:));
        col2 = (cols(range(2),:));
        
        r = linspace(col1(1),col2(1),range(3));
        g = linspace(col1(2),col2(2),range(3));
        b = linspace(col1(3),col2(3),range(3));
        colRGB = [r;g;b]';
        
        % col1 = rgb2hsv(cols(range(1),:));
        % col2 = rgb2hsv(cols(range(2),:));
        % h = linspace(col1(1),col2(1),range(3));
        % s = linspace(col1(2),col2(2),range(3));
        % v = linspace(col1(3),col2(3),range(3));
        % colHSV = hsv2rgb([h;s;v]');
        % 
        % a = [];
        % for ii=1:range(3)
        %     a = [a repmat(reshape(colRGB(ii,:),1,1,3),20,3,1)];
        % end
        % b = [];
        % for ii=1:range(3)
        %     b = [b repmat(reshape(colHSV(ii,:),1,1,3),20,3,1)];
        % end
        
        % imshow([a;b])
        col = colRGB;
    else
        col = cols(idx,:);
    end
end

function cols = getAllCols
    a = dec2base(0:26,3);
    cols = nan(27,3);
    for ii=1:27
        for jj=1:3
            cols(ii,jj) = str2double(a(ii,jj))+1;
        end
    end
    base = [1 0.7 0.4];
    cols = base(cols);
    [~,idx] = sort(mean(cols,2));
    cols = cols(idx,:);
end