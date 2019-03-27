20190327 - WF
  * runme.m
  * r2prime_mc.m and create_t2t2star_mc.m
    * ditch 3mm resampling
    * motion correction and t2->t1->mni warp with fsl (mcflirt, flirt, applywarp)

20190326 - WF
 chan's code produces R2map not T2map! Maybe

20181206 - WF - deconstucting matlab code
 3x3x3 resample with 3dresample okay?

20181206 - Chan Moon (copied from box, git init)
>  The codes and example (20190930) are upload to the box. The program generates T2
>  and T2* maps which can be converted to R2 (=1/T2) and R2*(=1/T2*), so R’ = R2 –
>  R2* with your processing. The processing is as,
>
>  1 Make study folder (20190930)
>  2 DICOM data (20190930/DICOM)
>  3 Nifti file conversion (20190930/Analyze)
>  4 Matlab, run ‘T2T2s.m’ (20190930/Processing) with appropriate editing of files and
>   folder name
>
>  Details are described in ‘T2T2s.m’ file

20181203 - Bart Larsen 
> R2' is calculated from two values, R2 and R2*, that must be estimated from their
> respective acquisitions (in the mMR it was a TSE and GRE image for R2 and R2*
>       respectively). R2 and R2* are the inverse of T2 and T2* (1/T2 = R2; 1/T2* = R2*).
> T2 and T2* are estimated by modeling the signal fall off across the acquired echo
> times. There is likely going to be susceptibility artifact in the T2* scans, which can
> be corrected for to some extent (though it is best to try to prevent at the time of
>       acquisition). Details about one technique can be found here:
> https://www.sciencedirect.com/science/article/pii/S1053811913009142?via%3Dihub
> 
> 
> Once R2 and R2* are estimated, the images must be aligned so that you can
> subtract them, R2* - R2 = R2'. The alignment is obviously very important. There
> is a good amount of detail and contrast in the images, so that shouldn't be
> difficult.
> 
> As far as the actual modeling is concerned, I don't think it is too difficult. There
> are examples in papers and in Valur's code that we use for our 3T data (I think he
>       did something extra to improve things). I don't know about how easy it is to
> (attempt to) correct for susceptibility distortions, or if there are better methods
> available than are presented in the link I sent.
