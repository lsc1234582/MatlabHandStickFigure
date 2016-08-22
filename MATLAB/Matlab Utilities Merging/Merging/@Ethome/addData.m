function addData( E, dBEntry )

%% Check that we are looking at the same subject and setting
if strcmp( E.SubjectID, '' )
    E.SubjectID = dBEntry.SubjectID;
elseif ~strcmp( E.SubjectID, dBEntry.SubjectID )
    error( 'addData:wrongSubject', ...
        'The data added does not correspond to the current subject.' );
end

if strcmp( E.SettingID, '' )
    E.SettingID = dBEntry.SettingID;
elseif ~strcmp( E.SettingID, dBEntry.SettingID )
    error( 'addData:wrongSetting', ...
        'The data added does not correspond to the current setting.' );
end

%%
mods = arrayfun( @(x) x.FileType, dBEntry, 'UniformOutput', false );
uMods = unique( mods );

for k = 1:numel( uMods )
    ix = strcmp( mods, uMods{k} );
    switch uMods{k}
        case 'LeftHandData'
            E.LeftHand = Glove( dBEntry(ix) );
        case 'RightHandData'
            E.RightHand = Glove( dBEntry(ix) );
        case 'SuitData'
            E.Suit = Suit( dBEntry(ix) ); % Call to class constructor Suit, not property
        case 'SuitTime'
            % Do nothing, treated by Suit;
        otherwise
            warning( 'Ethome:NotImplemented', ...
                [uMods{k} ' has not been implemented yet. Skipping...'] )
    end
end

end