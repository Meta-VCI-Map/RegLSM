function copy_lesion_geometry(source, lesion)
    source_nii = load_untouch_nii(source);
    lesion_nii = load_untouch_nii(lesion);

    % Check dimensions.
    if any(lesion_nii.hdr.dime.dim ~= source_nii.hdr.dime.dim)
        error('Lesion and source images have different dimensions');
    end

    % Copy voxel dimensions.
    lesion_nii.hdr.dime.pixdim = source_nii.hdr.dime.pixdim;

    % Copy orientation.
    for attr = {'qform_code', 'sform_code', 'quatern_b', 'quatern_c', 'quatern_d', 'qoffset_x', 'qoffset_y', 'qoffset_z', 'srow_x', 'srow_y', 'srow_z'}
        lesion_nii.hdr.hist.(attr{1}) = source_nii.hdr.hist.(attr{1});
    end

    % Back-up the original lesion file.
    copyfile(lesion, [lesion '.bak']);

    % Save the new lesion file.
    save_untouch_nii(lesion_nii, lesion)
