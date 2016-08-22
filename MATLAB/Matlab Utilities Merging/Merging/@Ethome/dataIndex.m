function ix = dataIndex( E, name )

labels = E.DataLabels(2, :);
ix = strcmp( labels, name );

end