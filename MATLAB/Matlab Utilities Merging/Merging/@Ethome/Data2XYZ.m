function out = Data2XYZ( E )
% function out = Data2XYZ( E )
% Computes synchronised xyz position for limbs and gaze

% if ~isempty( E.xyzData )
%     out = E.xyzData;
%     return
% end

if ~isempty( E.Suit ) && ~isempty( E.Data ) && ~isempty( E.dataIndex( 'Suit' ) )
    tmp.Data = E.Data(:, E.dataIndex( 'Suit' ) );
    %ix = ~any( isnan( tmp.Data ), 2 ); % Data w/o NaNs
    %tmp.Data = tmp.Data(ix, :);
    tmp.Time= E.Time;
    tmp.Skel = E.Suit.Skel;
    tmpSuit = Suit( tmp );
    tmpSuit.Data2XYZ();
    E.xyzData.Suit = tmpSuit.xyzData;
    E.xyzData.Suit.Time = tmpSuit.Time;
end
clear tmp;

if ~isempty( E.Gaze ) && ~isempty( E.Data) && ~isempty( E.dataIndex( 'Gaze' ) )
    tmp.Data = E.Data(:, E.dataIndex( 'Gaze' ) );
    %ix = ~any( isnan( tmp.Data ), 2 ); % Data w/o NaNs
    tmp.Time= E.Time;
 %   tmp.Data = tmp.Data(ix, :);
    tmpGaze = Gaze( tmp );
    tmpGaze.Data2XYZ();
    E.xyzData.Gaze.endPoint= tmpGaze.xyzData.endPoint;
    E.xyzData.Gaze.Left= tmpGaze.xyzData.Left;
    E.xyzData.Gaze.Right= tmpGaze.xyzData.Right;
    E.xyzData.Gaze.Time= tmpGaze.Time;
end


out = E.xyzData;

end